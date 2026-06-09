#!/bin/bash
# ==================================================================
# ETAPA 07 — Crear repositorios en Amazon ECR
# ==================================================================
# Solo crea los repositorios. Las imagenes se publican despues
# mediante GitHub Actions (CI/CD).
# ==================================================================
set -e

REGION="us-east-1"

echo ""
echo "============================================================="
echo " ETAPA 07 — Crear repositorios en Amazon ECR"
echo "============================================================="
echo ""

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_BASE="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

echo "  ACCOUNT_ID=$ACCOUNT_ID"
echo "  ECR_BASE=$ECR_BASE"

# --- Crear repositorios ECR ---
echo ""
echo "Creando repositorios ECR..."
for repo in tienda-db tienda-backend tienda-frontend; do
  if aws ecr describe-repositories --repository-names "$repo" --region "$REGION" >/dev/null 2>&1; then
    echo "  $repo: YA EXISTE"
  else
    aws ecr create-repository --repository-name "$repo" --region "$REGION"
    echo "  $repo: CREADO"
  fi
done

echo ""
echo "============================================================="
echo " REPOSITORIOS ECR CREADOS"
echo "============================================================="
echo ""
echo "  $ECR_BASE/tienda-db"
echo "  $ECR_BASE/tienda-backend"
echo "  $ECR_BASE/tienda-frontend"
echo ""
echo "Las imagenes se publicaran automaticamente mediante"
echo "GitHub Actions al hacer push a main en cada repositorio."
echo ""
echo "============================================================="
echo " ETAPA 07 COMPLETADA — 3 repositorios ECR listos"
echo "============================================================="
echo "Continua con: cd ../etapa08-DespliegaK8s"
echo ""
