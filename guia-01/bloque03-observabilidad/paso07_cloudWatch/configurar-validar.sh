#!/bin/bash

set -e

REGION="us-east-1"
CLUSTER_NAME="laboratorio-eks"

echo ""
echo "====================================================="
echo " VALIDANDO CLOUDWATCH ENDPOINT"
echo "====================================================="
echo ""

aws ec2 describe-vpc-endpoints \
  --region $REGION \
  --query "VpcEndpoints[*].[ServiceName,State]" \
  --output table

echo ""
echo "====================================================="
echo " VALIDANDO LOGGING EKS"
echo "====================================================="
echo ""

aws eks describe-cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --query "cluster.logging"

echo ""
echo "====================================================="
echo " VALIDANDO LOG GROUPS CLOUDWATCH"
echo "====================================================="
echo ""

aws logs describe-log-groups \
  --region $REGION \
  --query "logGroups[*].logGroupName" \
  --output table

echo ""
echo "====================================================="
echo " VALIDANDO LOG STREAMS"
echo "====================================================="
echo ""

aws logs describe-log-streams \
  --log-group-name /aws/eks/$CLUSTER_NAME/cluster \
  --region $REGION \
  --output table || true

echo ""
echo "====================================================="
echo " VALIDANDO NODOS"
echo "====================================================="
echo ""

kubectl get nodes

echo ""
echo "====================================================="
echo " VALIDANDO METRICAS NODOS"
echo "====================================================="
echo ""

kubectl top nodes || true

echo ""
echo "====================================================="
echo " VALIDANDO METRICAS PODS"
echo "====================================================="
echo ""

kubectl top pods -A || true

echo ""
echo "====================================================="
echo " VALIDANDO EVENTOS KUBERNETES"
echo "====================================================="
echo ""

kubectl get events -A || true

echo ""
echo "====================================================="
echo " VALIDANDO KUBE-SYSTEM"
echo "====================================================="
echo ""

kubectl get pods -n kube-system

echo ""
echo "====================================================="
echo " VALIDACION CLOUDWATCH COMPLETA"
echo "====================================================="
echo ""
