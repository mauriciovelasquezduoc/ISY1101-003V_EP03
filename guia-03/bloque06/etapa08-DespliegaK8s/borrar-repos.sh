#!/bin/bash
# ==================================================================
# borrar-repos.sh — Limpiar ECR + Namespace K8s para recrear desde cero
# Uso: bash borrar-repos.sh
# ==================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGION="us-east-1"
NAMESPACE="alumnos"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   LIMPIEZA DE RECURSOS — ECR + KUBERNETES                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Esto ELIMINARÁ:"
echo "    - Los 3 repositorios ECR (alumnos-db, alumnos-backend, alumnos-frontend)"
echo "    - El namespace '$NAMESPACE' de Kubernetes (pods, services, deployments, HPA)"
echo ""
echo "  ⚠  Esta acción NO se puede deshacer."
echo ""
read -r -p "  ¿Estás seguro de continuar? (s/N): " CONFIRM
echo ""

if [ "$CONFIRM" != "s" ] && [ "$CONFIRM" != "S" ]; then
  echo "  ❌ Operación cancelada."
  exit 0
fi

# ==================================================================
# 1. Validar conectividad AWS
# ==================================================================
echo "============================================================="
echo " [1/4] Validando conectividad AWS..."
echo "============================================================="
echo ""
if ! aws sts get-caller-identity &>/dev/null; then
  echo "  ❌ ERROR: Sin conexión a AWS. Ejecuta 'aws configure' primero."
  exit 1
fi
echo "  ✅ Conectado a AWS"
echo ""

# ==================================================================
# 2. Eliminar namespace de Kubernetes
# ==================================================================
echo "============================================================="
echo " [2/4] Eliminando namespace '$NAMESPACE' de Kubernetes..."
echo "============================================================="
echo ""

if kubectl get namespace "$NAMESPACE" &>/dev/null; then
  # Primero eliminar HPA y deployments para que no queden huérfanos
  kubectl delete hpa -n "$NAMESPACE" --all --grace-period=0 --force 2>/dev/null || true
  kubectl delete deployment -n "$NAMESPACE" --all --grace-period=0 --force 2>/dev/null || true
  kubectl delete svc -n "$NAMESPACE" --all --grace-period=0 --force 2>/dev/null || true
  kubectl delete pod -n "$NAMESPACE" --all --grace-period=0 --force 2>/dev/null || true

  # Eliminar el namespace
  kubectl delete namespace "$NAMESPACE" --grace-period=0 --force 2>/dev/null && echo "  ✅ Namespace '$NAMESPACE' eliminado" || echo "  ⚠ No se pudo eliminar el namespace"
else
  echo "  ⚠ El namespace '$NAMESPACE' no existe"
fi
echo ""

# ==================================================================
# 3. Eliminar repositorios ECR
# ==================================================================
echo "============================================================="
echo " [3/5] Eliminando repositorios ECR..."
echo "============================================================="
echo ""

for repo in alumnos-db alumnos-backend alumnos-frontend; do
  if aws ecr describe-repositories --repository-name "$repo" --region "$REGION" &>/dev/null; then
    aws ecr delete-repository --repository-name "$repo" --region "$REGION" --force &>/dev/null && echo "  ✅ ECR $repo eliminado" || echo "  ⚠ Error al eliminar ECR $repo"
  else
    echo "  ⚠ ECR $repo no existe"
  fi
done
echo ""

# ==================================================================
# 4. Eliminar repositorios de GitHub
# ==================================================================
echo "============================================================="
echo " [4/5] Eliminando repositorios de GitHub..."
echo "============================================================="
echo ""

GH_USER="mauriciovelasquezduoc"
for repo in 202601_ep03_db 202601_ep03_backend 202601_ep03_frontend; do
  if gh repo view "$GH_USER/$repo" --json name &>/dev/null; then
    gh repo delete "$GH_USER/$repo" --confirm 2>/dev/null && echo "  ✅ GitHub $repo eliminado" || echo "  ⚠ Error al eliminar GitHub $repo"
  else
    echo "  ⚠ GitHub $repo no existe"
  fi
done
echo ""

# ==================================================================
# 5. Verificar limpieza
# ==================================================================
echo "============================================================="
echo " [5/5] Verificando limpieza..."
echo "============================================================="
echo ""

REMAINING=$(aws ecr describe-repositories --region "$REGION" --query 'repositories[*].repositoryName' --output text 2>/dev/null | tr '\t' '\n' | grep -c "alumnos" || true)
if [ "$REMAINING" -gt 0 ]; then
  echo "  ⚠ Aún quedan $REMAINING repos ECR con 'alumnos'"
  aws ecr describe-repositories --region "$REGION" --query "repositories[?contains(repositoryName, 'alumnos')].repositoryName" --output table
else
  echo "  ✅ No quedan repos ECR con 'alumnos'"
fi

NAMESPACE_EXISTS=$(kubectl get namespace "$NAMESPACE" &>/dev/null && echo "si" || echo "no")
if [ "$NAMESPACE_EXISTS" = "si" ]; then
  echo "  ⚠ El namespace '$NAMESPACE' aún existe"
else
  echo "  ✅ Namespace '$NAMESPACE' eliminado correctamente"
fi

GH_USER="mauriciovelasquezduoc"
GH_REMAINING=0
for repo in 202601_ep03_db 202601_ep03_backend 202601_ep03_frontend; do
  if gh repo view "$GH_USER/$repo" --json name &>/dev/null; then
    GH_REMAINING=$((GH_REMAINING + 1))
  fi
done
if [ "$GH_REMAINING" -gt 0 ]; then
  echo "  ⚠ Aún quedan $GH_REMAINING repositorios en GitHub"
else
  echo "  ✅ No quedan repositorios en GitHub"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   LIMPIEZA COMPLETADA                                       ║"
echo "║                                                            ║"
echo "║   Ahora puedes ejecutar nuevamente:                        ║"
echo "║     bash ejecutar.sh                                       ║"
echo "║                                                            ║"
echo "║   Se recrearán los ECR, se construirán las imágenes y      ║"
echo "║   se desplegará todo desde cero.                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
