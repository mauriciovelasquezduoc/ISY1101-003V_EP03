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
echo " VALIDANDO FRONTEND DEPLOYMENT"
echo "====================================================="
echo ""

if [ ! -f frontend-deployment.yaml ]; then
  echo "ERROR: frontend-deployment.yaml no encontrado"
  exit 1
fi

echo "frontend-deployment.yaml OK"

echo ""
echo "====================================================="
echo " REEMPLAZANDO IMAGE ECR"
echo "====================================================="
echo ""

IMAGE_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/tienda-frontend:eks-v1"

echo "IMAGE_URI=$IMAGE_URI"

sed -i.bak "s|image: .*|image: $IMAGE_URI|g" frontend-deployment.yaml

echo ""
echo "====================================================="
echo " VALIDANDO REEMPLAZO"
echo "====================================================="
echo ""

grep image frontend-deployment.yaml

echo ""
echo "====================================================="
echo " VALIDANDO NAMESPACE"
echo "====================================================="
echo ""

kubectl apply -f namespace.yaml

echo ""
echo "====================================================="
echo " APLICANDO SERVICE FRONTEND"
echo "====================================================="
echo ""

kubectl apply -f frontend-service.yaml

echo ""
echo "====================================================="
echo " APLICANDO DEPLOYMENT FRONTEND"
echo "====================================================="
echo ""

kubectl apply -f frontend-deployment.yaml

echo ""
echo "====================================================="
echo " APLICANDO HPA FRONTEND"
echo "====================================================="
echo ""

kubectl apply -f frontend-hpa.yaml

echo ""
echo "====================================================="
echo " VALIDANDO RECURSOS"
echo "====================================================="
echo ""

kubectl get all -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO PODS FRONTEND"
echo "====================================================="
echo ""

kubectl get pods -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO SERVICE FRONTEND"
echo "====================================================="
echo ""

kubectl get svc -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO DEPLOYMENT FRONTEND"
echo "====================================================="
echo ""

kubectl get deployment -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO HPA FRONTEND"
echo "====================================================="
echo ""

kubectl get hpa -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO LOGS FRONTEND"
echo "====================================================="
echo ""

FRONTEND_POD=$(kubectl get pods -n $NAMESPACE \
  | grep tienda-frontend \
  | awk '{print $1}' \
  | head -n 1)

kubectl logs -n $NAMESPACE $FRONTEND_POD --tail=20 || true

echo ""
echo "====================================================="
echo " VALIDANDO ENDPOINTS FRONTEND"
echo "====================================================="
echo ""

kubectl get endpoints -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO LOADBALANCER"
echo "====================================================="
echo ""

kubectl get svc -n $NAMESPACE

echo ""
echo "====================================================="
echo " DESPLIEGUE FRONTEND COMPLETADO"
echo "====================================================="
echo ""

echo "Imagen utilizada:"
echo "$IMAGE_URI"

echo ""
echo "====================================================="
echo " IMPORTANTE"
echo "====================================================="
echo ""

echo "Si el Service es LoadBalancer,"
echo "esperar algunos minutos para que AWS cree el ELB."

echo ""
echo "Obtener URL pública:"
echo ""

echo "kubectl get svc -n $NAMESPACE"

echo ""
echo "====================================================="
echo " PROCESO FINALIZADO"
echo "====================================================="
echo ""
