#!/bin/bash
# ==================================================================
# ETAPA 12 — Limpieza total del laboratorio
# ==================================================================

REGION="us-east-1"
CLUSTER="laboratorio-eks"
NAMESPACE="alumnos"

echo ""
echo "============================================================="
echo " ETAPA 12 — Limpieza total del laboratorio"
echo "============================================================="
echo ""

# ==================================================================
# 1. Borrar namespace alumnos (Pods, Services, Deployments, ELB)
# ==================================================================
echo "[1/8] Borrando namespace alumnos..."
kubectl delete namespace $NAMESPACE --ignore-not-found
echo "  OK"
echo ""

# ==================================================================
# 2. Borrar stack EKS
# ==================================================================
echo "[2/8] Borrando stack laboratorio-eks..."
echo "  (cluster EKS + NodeGroup + addons)"
echo "  Tarda ~10-15 min..."
echo ""

aws cloudformation delete-stack \
  --stack-name laboratorio-eks \
  --region $REGION

echo "  Esperando a que se borre el stack..."
aws cloudformation wait stack-delete-complete \
  --stack-name laboratorio-eks \
  --region $REGION
echo "  OK: stack laboratorio-eks eliminado"
echo ""

# ==================================================================
# 3. Borrar stack VPC
# ==================================================================
echo "[3/8] Borrando stack laboratorio-vpc-completa..."
echo "  (VPC + subnets + Internet Gateway + VPC Endpoints)"
echo "  Tarda ~5 min..."
echo ""

aws cloudformation delete-stack \
  --stack-name laboratorio-vpc-completa \
  --region $REGION

echo "  Esperando a que se borre el stack..."
aws cloudformation wait stack-delete-complete \
  --stack-name laboratorio-vpc-completa \
  --region $REGION
echo "  OK: stack laboratorio-vpc-completa eliminado"
echo ""

# ==================================================================
# 4. Borrar repositorios ECR
# ==================================================================
echo "[4/8] Borrando repositorios ECR..."
for repo in alumnos-db alumnos-backend alumnos-frontend; do
  aws ecr delete-repository \
    --repository-name $repo \
    --region $REGION \
    --force 2>/dev/null && echo "  $repo: ELIMINADO" || echo "  $repo: ya no existia"
done
echo ""

# ==================================================================
# 5. Borrar repositorios en GitHub
# ==================================================================
echo "[5/8] Borrando repositorios en GitHub..."
USER_GITHUB=$(gh api user --jq '.login' 2>/dev/null || echo "")
if [ -n "$USER_GITHUB" ]; then
  for repo in 202601_ep03_db 202601_ep03_backend 202601_ep03_frontend; do
    FULL_NAME="$USER_GITHUB/$repo"
    if gh repo view "$FULL_NAME" &>/dev/null; then
      gh repo delete "$FULL_NAME" --yes 2>/dev/null && echo "  $FULL_NAME: ELIMINADO" || echo "  $FULL_NAME: error al borrar"
    else
      echo "  $FULL_NAME: ya no existia"
    fi
  done
else
  echo "  ⚠ No se pudo obtener usuario GitHub. Salta borrado de repos."
fi
echo ""

# ==================================================================
# 6. Borrar directorios locales de los repos clonados
# ==================================================================
echo "[6/8] Borrando directorios locales de repositorios..."

BASE_PASO00="/root/work/bloque04-aplicacion/paso-00-github-cli"
BASE_PASO01="/root/work/bloque04-aplicacion/paso-01-deploy-aws"

for repo_dir in "$BASE_PASO00"/202601_ep03_*; do
  if [ -d "$repo_dir" ]; then
    rm -rf "$repo_dir"
    echo "  Eliminado: $repo_dir"
  fi
done

for repo_dir in "$BASE_PASO01"/202601_ep03_*; do
  if [ -d "$repo_dir" ]; then
    # Si es el directorio raiz del repo, borrar solo .git
    if [ -d "$repo_dir/.git" ]; then
      rm -rf "$repo_dir/.git"
      echo "  .git eliminado: $repo_dir"
    fi
  fi
done

echo "  OK"
echo ""

# ==================================================================
# 7. Limpiar kubeconfig local
# ==================================================================
echo "[7/8] Limpiando kubeconfig local..."
kubectl config delete-context "arn:aws:eks:$REGION:$(aws sts get-caller-identity --query Account --output text):cluster/$CLUSTER" 2>/dev/null || true
kubectl config delete-cluster "arn:aws:eks:$REGION:$(aws sts get-caller-identity --query Account --output text):cluster/$CLUSTER" 2>/dev/null || true
kubectl config delete-user "arn:aws:eks:$REGION:$(aws sts get-caller-identity --query Account --output text):cluster/$CLUSTER" 2>/dev/null || true
echo "  OK"
echo ""

# ==================================================================
# 8. Limpiar known_hosts de github.com (para que SSH sea fresco)
# ==================================================================
echo "[8/8] Limpiando known_hosts de github.com..."
ssh-keygen -R github.com 2>/dev/null || true
echo "  OK"
echo ""

# ==================================================================
# FIN
# ==================================================================
echo "============================================================="
echo " ETAPA 12 COMPLETADA — Laboratorio limpio para empezar desde 0"
echo "============================================================="
echo ""
echo "  Borrado:"
echo "    [X] Namespace alumnos (Pods, Services, ELB, HPA)"
echo "    [X] Stack laboratorio-eks (EKS + NodeGroup)"
echo "    [X] Stack laboratorio-vpc-completa (VPC + subnets)"
echo "    [X] Repositorios ECR (alumnos-db, alumnos-backend, alumnos-frontend)"
echo "    [X] Repositorios en GitHub (202601_ep03_*)"
echo "    [X] Directorios: paso-00/202601_ep03_*"
echo "    [X] .git en paso-01/202601_ep03_*"
echo "    [X] kubeconfig limpiado"
echo "    [X] known_hosts de github.com limpiado"
echo ""
echo "  Ya puedes rehacer el laboratorio desde: cd ../etapa01-ValidaEntorno"
echo ""
