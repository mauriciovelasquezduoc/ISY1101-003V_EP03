#!/bin/bash
# ==================================================================
# ETAPA 08 — Publicar en GitHub + Desplegar en Kubernetes
# ==================================================================
# Flujo:
#   A. crear-repos-y-secrets.sh → repos + secrets + SSH key en GitHub
#   B. github-action.sh → push del código (CI/CD publica en ECR)
#   C. Esperar a que las imágenes estén en ECR
#   D. kubectl apply → despliega DB, Backend y Frontend en EKS
# ==================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGION="us-east-1"
NAMESPACE="tienda"

echo ""
echo "============================================================="
echo " ETAPA 08 — Publicar en GitHub + Desplegar en Kubernetes"
echo "============================================================="
echo ""

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "  AWS Account ID: $ACCOUNT_ID"
echo ""

# ==================================================================
# Limpiar SSH keys de GitHub de contenedores anteriores
# ==================================================================
echo "============================================================="
echo " LIMPIANDO SSH KEYS DE GITHUB"
echo "============================================================="
echo ""

if command -v gh &> /dev/null; then
  KEY_COUNT=$(gh ssh-key list --json id -q '.[].id' 2>/dev/null | wc -l)
  if [ "$KEY_COUNT" -gt 0 ]; then
    for KEY_ID in $(gh ssh-key list --json id -q '.[].id'); do
      gh ssh-key delete "$KEY_ID" --confirm 2>/dev/null && \
        echo "  ✔ Eliminada key ID: $KEY_ID" || \
        echo "  ⚠ No se pudo eliminar key ID: $KEY_ID"
    done
    echo "  Se eliminaron $KEY_COUNT SSH keys de GitHub."
  else
    echo "  No hay SSH keys que limpiar."
  fi
else
  echo "  gh CLI no disponible, saltando limpieza de SSH keys."
fi
echo ""

# ==================================================================
# Configurar kubeconfig para EKS (si no está configurado)
# ==================================================================
if ! kubectl cluster-info 2>/dev/null | grep -q "controlplane\|eks"; then
  echo "============================================================="
  echo " Configurando kubeconfig para EKS..."
  echo "============================================================="
  CLUSTER=$(aws eks list-clusters --region "$REGION" --query 'clusters[0]' --output text)
  if [ -n "$CLUSTER" ] && [ "$CLUSTER" != "None" ]; then
    aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER"
    echo "  ✔ kubeconfig configurado para el cluster: $CLUSTER"
  else
    echo "  ⚠ No se encontró ningún cluster EKS en la región $REGION"
  fi
  echo ""
fi

# ==================================================================
# PARTE A — Crear repos y secrets en GitHub
# ==================================================================
echo "============================================================="
echo " [A] CREANDO REPOSITORIOS + SECRETS EN GITHUB"
echo "============================================================="
echo ""

GH_SCRIPT="../../bloque04-aplicacion/paso-00-github-cli/crear-repos-y-secrets.sh"

if [ -x "$GH_SCRIPT" ]; then
  cd "$(dirname "$GH_SCRIPT")"
  bash "$(basename "$GH_SCRIPT")"
  cd "$SCRIPT_DIR"
else
  echo "  ⚠ No se encontró $GH_SCRIPT. Saltando creación de repos/secrets."
fi

echo ""
echo "✔ Repositorios y secrets configurados en GitHub."
echo ""

# ==================================================================
# PARTE B — Push del código a GitHub (dispara CI/CD → ECR)
# ==================================================================
echo "============================================================="
echo " [B] PUBLICANDO CÓDIGO EN GITHUB (CI/CD → ECR)"
echo "============================================================="
echo ""

DEPLOY_SCRIPT="../../bloque04-aplicacion/paso-01-deploy-aws/github-action.sh"

if [ -x "$DEPLOY_SCRIPT" ]; then
  cd "$(dirname "$DEPLOY_SCRIPT")"
  # github-action.sh ahora hace exit 1 si falla el push SSH
  # set -e propaga el error automaticamente
  bash "$(basename "$DEPLOY_SCRIPT")"
  cd "$SCRIPT_DIR"
else
  echo "  ⚠ No se encontro $DEPLOY_SCRIPT. Saltando push a GitHub."
fi

echo ""
echo "✔ Código publicado en GitHub. GitHub Actions construirá las imágenes."
echo ""

# ==================================================================
# PARTE C — Esperar a que las imágenes estén disponibles en ECR
# ==================================================================
echo "============================================================="
echo " [C] ESPERANDO IMÁGENES EN ECR (máx 10 min)"
echo "============================================================="
echo ""

IMAGES=("tienda-db:latest" "tienda-backend:latest" "tienda-frontend:latest")
MAX_RETRIES=60  # 60 intentos × 10s = 600s = 10 min
SLEEP_SECS=10

for IMAGE in "${IMAGES[@]}"; do
  echo ""
  echo "  Esperando imagen: $IMAGE ..."
  RETRY=0
  FOUND=false
  while [ $RETRY -lt $MAX_RETRIES ]; do
    REPO_NAME="${IMAGE%%:*}"
    if aws ecr describe-images --repository-name "$REPO_NAME" --image-ids imageTag=latest --region "$REGION" &>/dev/null; then
      echo "  ✔ Imagen $IMAGE encontrada en ECR (intento $((RETRY+1)))"
      FOUND=true
      break
    fi
    RETRY=$((RETRY+1))
    printf "\r    intento %2d/%d — esperando..." "$RETRY" "$MAX_RETRIES"
    sleep "$SLEEP_SECS"
  done
  if [ "$FOUND" = false ]; then
    echo ""
    echo "============================================================="
    echo " ERROR: Imagen $IMAGE no apareció en ECR tras 10 minutos."
    echo " Revisa los GitHub Actions en:"
    echo "   https://github.com/<tu-usuario>/202601_ep03_$REPO_NAME/actions"
    echo "============================================================="
    exit 1
  fi
done

echo ""
echo "✔ Las 3 imágenes están disponibles en ECR."
echo ""

# ==================================================================
# PARTE D — Desplegar en Kubernetes (DB → Backend → Frontend)
# ==================================================================
echo "============================================================="
echo " [D] DESPLEGANDO EN KUBERNETES (DB → Backend → Frontend)"
echo "============================================================="

K8S_BASE="../../bloque04-aplicacion/paso-01-deploy-aws"

# ==================================================================
# D1. DATABASE
# ==================================================================
echo ""
echo "-------------------------------------------------------------"
echo " [D1/3] DESPLEGANDO MySQL DATABASE"
echo "-------------------------------------------------------------"

DB_DIR="$K8S_BASE/202601_ep03_db/k8s"
cd "$DB_DIR"

echo "  Aplicando namespace..."
kubectl apply -f namespace.yaml

echo "  Aplicando secret..."
kubectl apply -f mysql-secret.yaml

echo "  Aplicando service..."
kubectl apply -f mysql-service.yaml

echo "  Aplicando deployment..."
kubectl apply -f mysql-deployment.yaml

echo "  Esperando a que MySQL este Running..."
kubectl wait --for=condition=Ready pod -l app=tienda-db -n $NAMESPACE --timeout=120s 2>/dev/null || echo "  (espera manual si tarda mas de 2 min)"

echo "  Estado DB:"
kubectl get pods -n $NAMESPACE | grep tienda-db || echo "  (pods de DB no visibles aun)"

cd "$SCRIPT_DIR"

# ==================================================================
# D2. BACKEND
# ==================================================================
echo ""
echo "-------------------------------------------------------------"
echo " [D2/3] DESPLEGANDO BACKEND API"
echo "-------------------------------------------------------------"

BACK_DIR="$K8S_BASE/202601_ep03_backend/k8s"
cd "$BACK_DIR"

echo "  Aplicando namespace..."
kubectl apply -f namespace.yaml

echo "  Aplicando service..."
kubectl apply -f backend-service.yaml

echo "  Aplicando deployment..."
kubectl apply -f backend-deployment.yaml

if [ -f backend-hpa.yaml ]; then
  echo "  Aplicando HPA..."
  kubectl apply -f backend-hpa.yaml
fi

echo "  Esperando a que Backend este Running..."
kubectl wait --for=condition=Ready pod -l app=tienda-backend -n $NAMESPACE --timeout=120s 2>/dev/null || echo "  (espera manual si tarda mas de 2 min)"

echo "  Estado Backend:"
kubectl get pods -n $NAMESPACE | grep tienda-backend || echo "  (pods de Backend no visibles aun)"

cd "$SCRIPT_DIR"

# ==================================================================
# D3. FRONTEND
# ==================================================================
echo ""
echo "-------------------------------------------------------------"
echo " [D3/3] DESPLEGANDO FRONTEND WEB"
echo "-------------------------------------------------------------"

FRONT_DIR="$K8S_BASE/202601_ep03_frontend/k8s"
cd "$FRONT_DIR"

echo "  Aplicando namespace..."
kubectl apply -f namespace.yaml

echo "  Aplicando service (LoadBalancer)..."
kubectl apply -f frontend-service.yaml

echo "  Aplicando deployment..."
kubectl apply -f frontend-deployment.yaml

if [ -f frontend-hpa.yaml ]; then
  echo "  Aplicando HPA..."
  kubectl apply -f frontend-hpa.yaml
fi

echo "  Esperando a que Frontend este Running..."
kubectl wait --for=condition=Ready pod -l app=tienda-frontend -n $NAMESPACE --timeout=120s 2>/dev/null || echo "  (espera manual si tarda mas de 2 min)"

echo "  Estado Frontend:"
kubectl get pods -n $NAMESPACE | grep tienda-frontend || echo "  (pods de Frontend no visibles aun)"

cd "$SCRIPT_DIR"

# ==================================================================
# RESUMEN FINAL
# ==================================================================
echo ""
echo "============================================================="
echo " ETAPA 08 COMPLETADA — GitHub + K8s desplegado"
echo "============================================================="
echo ""
echo "=== Todos los Pods ==="
kubectl get pods -n $NAMESPACE
echo ""
echo "=== Services ==="
kubectl get svc -n $NAMESPACE
echo ""
echo "=== HPA ==="
kubectl get hpa -n $NAMESPACE 2>/dev/null || echo "  (sin HPAs configurados)"
echo ""
echo "=== Deployments ==="
kubectl get deployment -n $NAMESPACE
echo ""
echo "============================================================="
echo " Continua con: cd ../etapa09-ValidaApp"
echo "============================================================="
echo ""
