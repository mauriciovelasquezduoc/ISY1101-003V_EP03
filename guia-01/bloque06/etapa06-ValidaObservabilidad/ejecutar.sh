#!/bin/bash
# ==================================================================
# ETAPA 06 — Validar Metrics Server + CloudWatch
# ==================================================================
set -e

REGION="us-east-1"
CLUSTER_NAME="laboratorio-eks"

echo ""
echo "============================================================="
echo " ETAPA 06 — Validar Metrics Server + CloudWatch"
echo "============================================================="
echo ""

echo "=== METRICS SERVER ==="
echo ""
echo "[1] Validando nodos..."
kubectl get nodes

echo ""
echo "[2] Validando pods metrics-server..."
kubectl get pods -n kube-system | grep metrics || echo "  (buscando...)"

echo ""
echo "[3] Validando metrics API..."
kubectl get apiservices | grep metrics || echo "  (buscando...)"

echo ""
echo "[4] Metricas de nodos (kubectl top)..."
kubectl top nodes 2>/dev/null || echo "  (puede tardar unos segundos en aparecer)"

echo ""
echo "[5] Metricas de pods..."
kubectl top pods -A 2>/dev/null || echo "  (puede tardar unos segundos)"

echo ""
echo "=== CLOUDWATCH ==="
echo ""
echo "[6] Validando VPC Endpoint CloudWatch..."
aws ec2 describe-vpc-endpoints --region $REGION --query "VpcEndpoints[*].[ServiceName,State]" --output table | grep logs

echo ""
echo "[7] Logging del cluster EKS..."
aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query "cluster.logging"

echo ""
echo "[8] Log Groups en CloudWatch..."
aws logs describe-log-groups --region $REGION --query "logGroups[*].logGroupName" --output table 2>/dev/null | grep -i eks || echo "  (puede tardar en aparecer)"

echo ""
echo "============================================================="
echo " ETAPA 06 COMPLETADA — Metrics + CloudWatch validados"
echo "============================================================="
echo "Continua con: cd ../etapa07"
echo ""
