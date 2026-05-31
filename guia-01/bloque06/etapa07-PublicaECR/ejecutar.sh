#!/bin/bash
# ==================================================================
# ETAPA 07 — Publicar imagenes en Amazon ECR
# ==================================================================
set -e

REGION="us-east-1"

echo ""
echo "============================================================="
echo " ETAPA 07 — Publicar imagenes Docker en Amazon ECR"
echo "============================================================="
echo ""

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_BASE="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

echo "  ACCOUNT_ID=$ACCOUNT_ID"
echo "  ECR_BASE=$ECR_BASE"

# --- 1. Crear repositorios ECR ---
echo ""
echo "[1] Creando repositorios ECR..."
for repo in tienda-db tienda-backend tienda-frontend; do
  if aws ecr describe-repositories --repository-names $repo --region $REGION >/dev/null 2>&1; then
    echo "  $repo: YA EXISTE"
  else
    aws ecr create-repository --repository-name $repo --region $REGION
    echo "  $repo: CREADO"
  fi
done

# --- 2. Login ECR ---
echo ""
echo "[2] Login en ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_BASE

# --- 3. Build + Tag + Push para cada capa ---
for app in db backend frontend; do
  echo ""
  echo "============================================================="
  echo "  $app"
  echo "============================================================="
  
  APP_DIR="../../bloque04-aplicacion/paso08_ecr/app/$app"
  
  echo "[3] Build $app..."
  docker build -t "tienda-$app" "$APP_DIR"
  
  echo "[4] Tag $app..."
  docker tag "tienda-$app:latest" "$ECR_BASE/tienda-$app:eks-v1"
  
  echo "[5] Push $app..."
  docker push "$ECR_BASE/tienda-$app:eks-v1"
  
  echo "[6] Validando $app en ECR..."
  aws ecr list-images --repository-name "tienda-$app" --region $REGION --output table
done

echo ""
echo "============================================================="
echo " IMAGENES PUBLICADAS EN ECR"
echo "============================================================="
echo ""
echo "  $ECR_BASE/tienda-db:eks-v1"
echo "  $ECR_BASE/tienda-backend:eks-v1"
echo "  $ECR_BASE/tienda-frontend:eks-v1"
echo ""
echo "============================================================="
echo " ETAPA 07 COMPLETADA — 3 imagenes en ECR"
echo "============================================================="
echo "Continua con: cd ../etapa08"
echo ""
