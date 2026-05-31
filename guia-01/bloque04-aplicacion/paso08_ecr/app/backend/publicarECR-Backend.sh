#!/bin/bash

set -e

# =====================================================
# VARIABLES
# =====================================================

REGION="us-east-1"
REPOSITORY_NAME="tienda-backend"
IMAGE_TAG="eks-v1"

echo ""
echo "====================================================="
echo " VALIDANDO AWS CLI"
echo "====================================================="
echo ""

aws sts get-caller-identity

echo ""
echo "====================================================="
echo " OBTENIENDO ACCOUNT ID"
echo "====================================================="
echo ""

ACCOUNT_ID=$(aws sts get-caller-identity \
  --query Account \
  --output text)

echo "ACCOUNT_ID=$ACCOUNT_ID"

echo ""
echo "====================================================="
echo " VALIDANDO DOCKER"
echo "====================================================="
echo ""

docker --version

echo ""
echo "====================================================="
echo " VALIDANDO ARCHIVOS BACKEND"
echo "====================================================="
echo ""

ls -lh

echo ""
echo "====================================================="
echo " VALIDANDO DOCKERFILE"
echo "====================================================="
echo ""

if [ ! -f Dockerfile ]; then
  echo "ERROR: Dockerfile no encontrado"
  exit 1
fi

echo "Dockerfile OK"

echo ""
echo "====================================================="
echo " VALIDANDO PACKAGE.JSON"
echo "====================================================="
echo ""

if [ ! -f package.json ]; then
  echo "WARNING: package.json no encontrado"
else
  echo "package.json OK"
fi

echo ""
echo "====================================================="
echo " VALIDANDO REPOSITORIO ECR"
echo "====================================================="
echo ""

REPO_EXISTS=$(aws ecr describe-repositories \
  --repository-names $REPOSITORY_NAME \
  --region $REGION \
  --query "repositories[0].repositoryName" \
  --output text 2>/dev/null || true)

if [ "$REPO_EXISTS" == "$REPOSITORY_NAME" ]; then

  echo "Repositorio ECR ya existe"

else

  echo "Creando repositorio ECR..."

  aws ecr create-repository \
    --repository-name $REPOSITORY_NAME \
    --region $REGION

fi

echo ""
echo "====================================================="
echo " LOGIN AMAZON ECR"
echo "====================================================="
echo ""

aws ecr get-login-password --region $REGION | \
docker login \
  --username AWS \
  --password-stdin \
  $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo ""
echo "====================================================="
echo " BUILD IMAGEN BACKEND"
echo "====================================================="
echo ""

docker build -t $REPOSITORY_NAME .

echo ""
echo "====================================================="
echo " VALIDANDO IMAGEN LOCAL"
echo "====================================================="
echo ""

docker images | grep $REPOSITORY_NAME || true

echo ""
echo "====================================================="
echo " CREANDO TAG ECR"
echo "====================================================="
echo ""

docker tag $REPOSITORY_NAME:latest \
$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_TAG

echo ""
echo "====================================================="
echo " PUSH IMAGEN A ECR"
echo "====================================================="
echo ""

docker push \
$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_TAG

echo ""
echo "====================================================="
echo " VALIDANDO IMAGEN EN ECR"
echo "====================================================="
echo ""

aws ecr list-images \
  --repository-name $REPOSITORY_NAME \
  --region $REGION \
  --output table

echo ""
echo "====================================================="
echo " IMAGEN BACKEND PUBLICADA"
echo "====================================================="
echo ""

echo "IMAGE URI:"
echo ""
echo "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_TAG"

echo ""
echo "====================================================="
echo " IMPORTANTE PARA KUBERNETES YAML"
echo "====================================================="
echo ""

echo "Actualizar backend-deployment.yaml:"
echo ""
echo "image: $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_TAG"

echo ""
echo "====================================================="
echo " PROCESO FINALIZADO"
echo "====================================================="
echo ""
