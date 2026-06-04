#!/bin/bash
# ==================================================================
# ETAPA 12 — Limpieza total del laboratorio
# ==================================================================

REGION="us-east-1"
CLUSTER="laboratorio-eks"
NAMESPACE="tienda"

echo ""
echo "============================================================="
echo " ETAPA 12 — Limpieza total del laboratorio"
echo "============================================================="
echo ""

# ==================================================================
# 1. Borrar namespace tienda (Pods, Services, Deployments, ELB)
# ==================================================================
echo "[1/5] Borrando namespace tienda..."
kubectl delete namespace $NAMESPACE --ignore-not-found
echo "  OK"
echo ""

# ==================================================================
# 2. Borrar stack EKS
# ==================================================================
echo "[2/5] Borrando stack laboratorio-eks..."
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
echo "[3/5] Borrando stack laboratorio-vpc-completa..."
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
echo "[4/5] Borrando repositorios ECR..."
for repo in tienda-db tienda-backend tienda-frontend; do
  aws ecr delete-repository \
    --repository-name $repo \
    --region $REGION \
    --force 2>/dev/null && echo "  $repo: ELIMINADO" || echo "  $repo: ya no existia"
done
echo ""

# ==================================================================
# 5. Limpiar kubeconfig local
# ==================================================================
echo "[5/5] Limpiando kubeconfig local..."
kubectl config delete-context "arn:aws:eks:$REGION:$(aws sts get-caller-identity --query Account --output text):cluster/$CLUSTER" 2>/dev/null || true
kubectl config delete-cluster "arn:aws:eks:$REGION:$(aws sts get-caller-identity --query Account --output text):cluster/$CLUSTER" 2>/dev/null || true
kubectl config delete-user "arn:aws:eks:$REGION:$(aws sts get-caller-identity --query Account --output text):cluster/$CLUSTER" 2>/dev/null || true
echo "  OK"
echo ""

# ==================================================================
# FIN
# ==================================================================
echo "============================================================="
echo " ETAPA 12 COMPLETADA — Laboratorio limpio"
echo "============================================================="
echo ""
echo "  Borrado:"
echo "    [X] Namespace tienda (Pods, Services, ELB, HPA)"
echo "    [X] Stack laboratorio-eks (EKS + NodeGroup)"
echo "    [X] Stack laboratorio-vpc-completa (VPC + subnets)"
echo "    [X] Repositorios ECR (tienda-db, tienda-backend, tienda-frontend)"
echo ""
echo "  Si quieres rehacer el laboratorio, vuelve a la etapa01."
echo ""
