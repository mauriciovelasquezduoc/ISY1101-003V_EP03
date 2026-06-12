#!/bin/bash
# ==================================================================
# ETAPA 07 — Crear repositorios en Amazon ECR
# ==================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../report_helper.sh"

REGION="us-east-1"

init_reporte "Creación de repositorios en Amazon ECR"

echo ""
echo "============================================================="
echo " ETAPA 07 — Crear repositorios en Amazon ECR"
echo "============================================================="
echo ""

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_BASE="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

echo "  ACCOUNT_ID=$ACCOUNT_ID"
echo "  ECR_BASE=$ECR_BASE"

add_texto_evidencia "**Account ID:** \`${ACCOUNT_ID}\`  
**ECR Base URL:** \`${ECR_BASE}\`"

# --- Crear repositorios ECR ---
echo ""
echo "Creando repositorios ECR..."
for repo in alumnos-db alumnos-backend alumnos-frontend; do
  if aws ecr describe-repositories --repository-names "$repo" --region "$REGION" >/dev/null 2>&1; then
    echo "  $repo: YA EXISTE"
  else
    aws ecr create-repository --repository-name "$repo" --region "$REGION"
    echo "  $repo: CREADO"
  fi
done

add_evidencia "Repositorios ECR creados" "for repo in alumnos-db alumnos-backend alumnos-frontend; do echo '---'; echo \$repo; aws ecr describe-repositories --repository-names \$repo --region $REGION --query 'repositories[0].repositoryUri' --output text; aws ecr list-images --repository-name \$repo --region $REGION --query 'imageIds[*].imageTag' --output table 2>/dev/null || echo '(sin imágenes aún)'; done" "IE2"

add_texto_evidencia "**Comandos para login y push manual:**  

\`\`\`bash
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_BASE

docker build -t alumnos-backend .
docker tag alumnos-backend:latest $ECR_BASE/alumnos-backend:latest
docker push $ECR_BASE/alumnos-backend:latest
\`\`\`

> Las imágenes se publicarán automáticamente mediante GitHub Actions
> al hacer push a \`main\` en cada repositorio."

cerrar_reporte

echo ""
echo "============================================================="
echo " REPOSITORIOS ECR CREADOS"
echo "============================================================="
echo ""
echo "  $ECR_BASE/alumnos-db"
echo "  $ECR_BASE/alumnos-backend"
echo "  $ECR_BASE/alumnos-frontend"
echo ""
echo "  📋 Reporte generado en: docs/reports/etapa07-PublicaECR.md"
echo ""
echo "Continua con: cd ../etapa08-DespliegaK8s"
echo ""
