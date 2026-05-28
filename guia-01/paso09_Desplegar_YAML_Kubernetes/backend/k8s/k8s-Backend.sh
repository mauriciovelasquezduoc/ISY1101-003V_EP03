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
echo " VALIDANDO BACKEND DEPLOYMENT"
echo "====================================================="
echo ""

if [ ! -f backend-deployment.yaml ]; then
  echo "ERROR: backend-deployment.yaml no encontrado"
  exit 1
fi

echo "backend-deployment.yaml OK"

echo ""
echo "====================================================="
echo " REEMPLAZANDO IMAGE ECR"
echo "====================================================="
echo ""

IMAGE_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/tienda-backend:eks-v1"

echo "IMAGE_URI=$IMAGE_URI"

sed -i.bak "s|image: .*|image: $IMAGE_URI|g" backend-deployment.yaml

echo ""
echo "====================================================="
echo " VALIDANDO REEMPLAZO"
echo "====================================================="
echo ""

grep image backend-deployment.yaml

echo ""
echo "====================================================="
echo " VALIDANDO NAMESPACE"
echo "====================================================="
echo ""

kubectl apply -f namespace.yaml

echo ""
echo "====================================================="
echo " APLICANDO SERVICE BACKEND"
echo "====================================================="
echo ""

kubectl apply -f backend-service.yaml

echo ""
echo "====================================================="
echo " APLICANDO DEPLOYMENT BACKEND"
echo "====================================================="
echo ""

kubectl apply -f backend-deployment.yaml

echo ""
echo "====================================================="
echo " APLICANDO HPA BACKEND"
echo "====================================================="
echo ""

kubectl apply -f backend-hpa.yaml

echo ""
echo "====================================================="
echo " VALIDANDO RECURSOS"
echo "====================================================="
echo ""

kubectl get all -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO PODS BACKEND"
echo "====================================================="
echo ""

kubectl get pods -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO SERVICE BACKEND"
echo "====================================================="
echo ""

kubectl get svc -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO DEPLOYMENT BACKEND"
echo "====================================================="
echo ""

kubectl get deployment -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO HPA"
echo "====================================================="
echo ""

kubectl get hpa -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO LOGS BACKEND"
echo "====================================================="
echo ""

BACKEND_POD=$(kubectl get pods -n $NAMESPACE \
  | grep tienda-backend \
  | awk '{print $1}' \
  | head -n 1)

kubectl logs -n $NAMESPACE $BACKEND_POD --tail=20 || true

echo ""
echo "====================================================="
echo " VALIDANDO ENDPOINT BACKEND"
echo "====================================================="
echo ""

kubectl get endpoints -n $NAMESPACE

echo ""
echo "====================================================="
echo " DESPLIEGUE BACKEND COMPLETADO"
echo "====================================================="
echo ""

echo "Imagen utilizada:"
echo "$IMAGE_URI"

echo ""
echo "====================================================="
echo " PROCESO FINALIZADO"
echo "====================================================="
echo ""
