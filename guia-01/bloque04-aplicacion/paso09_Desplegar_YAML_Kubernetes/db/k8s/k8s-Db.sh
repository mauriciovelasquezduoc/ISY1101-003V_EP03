#!/bin/bash

set -e

# =====================================================
# VARIABLES
# =====================================================

REGION="us-east-1"
NAMESPACE="tienda"

echo ""
echo "====================================================="
echo " OBTENIENDO ACCOUNT ID AWS"
echo "====================================================="
echo ""

ACCOUNT_ID=$(aws sts get-caller-identity \
  --query Account \
  --output text)

echo "ACCOUNT_ID=$ACCOUNT_ID"

echo ""
echo "====================================================="
echo " VALIDANDO ARCHIVOS YAML"
echo "====================================================="
echo ""

ls -lh

echo ""
echo "====================================================="
echo " VALIDANDO MYSQL DEPLOYMENT"
echo "====================================================="
echo ""

if [ ! -f mysql-deployment.yaml ]; then
  echo "ERROR: mysql-deployment.yaml no encontrado"
  exit 1
fi

echo "mysql-deployment.yaml OK"

echo ""
echo "====================================================="
echo " REEMPLAZANDO IMAGE ECR"
echo "====================================================="
echo ""

IMAGE_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/tienda-db:eks-v1"

echo "IMAGE_URI=$IMAGE_URI"

sed -i.bak "s|image: .*|image: $IMAGE_URI|g" mysql-deployment.yaml

echo ""
echo "====================================================="
echo " VALIDANDO REEMPLAZO"
echo "====================================================="
echo ""

grep image mysql-deployment.yaml

echo ""
echo "====================================================="
echo " CREANDO NAMESPACE"
echo "====================================================="
echo ""

kubectl apply -f namespace.yaml

echo ""
echo "====================================================="
echo " APLICANDO SECRET MYSQL"
echo "====================================================="
echo ""

kubectl apply -f mysql-secret.yaml

echo ""
echo "====================================================="
echo " APLICANDO SERVICE MYSQL"
echo "====================================================="
echo ""

kubectl apply -f mysql-service.yaml

echo ""
echo "====================================================="
echo " APLICANDO DEPLOYMENT MYSQL"
echo "====================================================="
echo ""

kubectl apply -f mysql-deployment.yaml

echo ""
echo "====================================================="
echo " VALIDANDO RECURSOS"
echo "====================================================="
echo ""

kubectl get all -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO POD MYSQL"
echo "====================================================="
echo ""

kubectl get pods -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO SERVICE MYSQL"
echo "====================================================="
echo ""

kubectl get svc -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO DEPLOYMENT MYSQL"
echo "====================================================="
echo ""

kubectl get deployment -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO LOGS MYSQL"
echo "====================================================="
echo ""

MYSQL_POD=$(kubectl get pods -n $NAMESPACE \
  -o jsonpath="{.items[0].metadata.name}")

kubectl logs -n $NAMESPACE $MYSQL_POD --tail=20 || true

echo ""
echo "====================================================="
echo " DESPLIEGUE MYSQL COMPLETADO"
echo "====================================================="
echo ""

echo "Imagen utilizada:"
echo "$IMAGE_URI"

echo ""
echo "====================================================="
echo " PROCESO FINALIZADO"
echo "====================================================="
echo ""
