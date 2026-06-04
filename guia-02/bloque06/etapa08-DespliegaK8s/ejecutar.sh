#!/bin/bash
# ==================================================================
# ETAPA 08 — Desplegar aplicacion en Kubernetes (DB + Backend + Frontend)
# ==================================================================
set -e

REGION="us-east-1"
NAMESPACE="tienda"

echo ""
echo "============================================================="
echo " ETAPA 08 — Desplegar aplicacion 3-capas en Kubernetes"
echo "============================================================="
echo ""

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_BASE="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
echo "  ACCOUNT_ID=$ACCOUNT_ID"

# ==================================================================
# 1. DATABASE
# ==================================================================
echo ""
echo "============================================================="
echo " [1/3] DESPLEGANDO MySQL DATABASE"
echo "============================================================="

DB_DIR="../../bloque04-aplicacion/paso09_Desplegar_YAML_Kubernetes/db/k8s"
cd "$DB_DIR"

echo "  Reemplazando imagen ECR en mysql-deployment.yaml..."
sed -i.bak "s|image: .*|image: $ECR_BASE/tienda-db:eks-v1|g" mysql-deployment.yaml
grep image mysql-deployment.yaml

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
kubectl get pods -n $NAMESPACE | grep tienda-db

cd - > /dev/null

# ==================================================================
# 2. BACKEND
# ==================================================================
echo ""
echo "============================================================="
echo " [2/3] DESPLEGANDO BACKEND API"
echo "============================================================="

BACK_DIR="../../bloque04-aplicacion/paso09_Desplegar_YAML_Kubernetes/backend/k8s"
cd "$BACK_DIR"

echo "  Reemplazando imagen ECR en backend-deployment.yaml..."
sed -i.bak "s|image: .*|image: $ECR_BASE/tienda-backend:eks-v1|g" backend-deployment.yaml
grep image backend-deployment.yaml

echo "  Aplicando namespace..."
kubectl apply -f namespace.yaml

echo "  Aplicando service..."
kubectl apply -f backend-service.yaml

echo "  Aplicando deployment..."
kubectl apply -f backend-deployment.yaml

echo "  Aplicando HPA..."
kubectl apply -f backend-hpa.yaml

echo "  Esperando a que Backend este Running..."
kubectl wait --for=condition=Ready pod -l app=tienda-backend -n $NAMESPACE --timeout=120s 2>/dev/null || echo "  (espera manual si tarda mas de 2 min)"

echo "  Estado Backend:"
kubectl get pods -n $NAMESPACE | grep tienda-backend

cd - > /dev/null

# ==================================================================
# 3. FRONTEND
# ==================================================================
echo ""
echo "============================================================="
echo " [3/3] DESPLEGANDO FRONTEND WEB"
echo "============================================================="

FRONT_DIR="../../bloque04-aplicacion/paso09_Desplegar_YAML_Kubernetes/frontend/k8s"
cd "$FRONT_DIR"

echo "  Reemplazando imagen ECR en frontend-deployment.yaml..."
sed -i.bak "s|image: .*|image: $ECR_BASE/tienda-frontend:eks-v1|g" frontend-deployment.yaml
grep image frontend-deployment.yaml

echo "  Aplicando namespace..."
kubectl apply -f namespace.yaml

echo "  Aplicando service (LoadBalancer)..."
kubectl apply -f frontend-service.yaml

echo "  Aplicando deployment..."
kubectl apply -f frontend-deployment.yaml

echo "  Aplicando HPA..."
kubectl apply -f frontend-hpa.yaml

echo "  Esperando a que Frontend este Running..."
kubectl wait --for=condition=Ready pod -l app=tienda-frontend -n $NAMESPACE --timeout=120s 2>/dev/null || echo "  (espera manual si tarda mas de 2 min)"

echo "  Estado Frontend:"
kubectl get pods -n $NAMESPACE | grep tienda-frontend

cd - > /dev/null

# ==================================================================
# RESUMEN FINAL
# ==================================================================
echo ""
echo "============================================================="
echo " ETAPA 08 COMPLETADA — App 3-capas desplegada"
echo "============================================================="
echo ""
echo "=== Todos los Pods ==="
kubectl get pods -n $NAMESPACE
echo ""
echo "=== Services ==="
kubectl get svc -n $NAMESPACE
echo ""
echo "=== HPA ==="
kubectl get hpa -n $NAMESPACE
echo ""
echo "=== Deployments ==="
kubectl get deployment -n $NAMESPACE
echo ""
echo "============================================================="
echo " Continua con: cd ../etapa09 (validacion final)"
echo "============================================================="
echo ""
