#!/bin/bash

set -e

REGION="us-east-1"
CLUSTER_NAME="laboratorio-eks"
NODEGROUP_NAME="laboratorio-nodegroup"

echo ""
echo "====================================================="
echo " VALIDANDO NODEGROUP"
echo "====================================================="
echo ""

aws eks describe-nodegroup \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name $NODEGROUP_NAME \
  --region $REGION \
  --query "nodegroup.status"

echo ""
echo "====================================================="
echo " CONFIGURANDO KUBECONFIG"
echo "====================================================="
echo ""

aws eks update-kubeconfig \
  --region $REGION \
  --name $CLUSTER_NAME

echo ""
echo "====================================================="
echo " VALIDANDO NODOS"
echo "====================================================="
echo ""

kubectl get nodes -o wide

echo ""
echo "====================================================="
echo " VALIDANDO PODS KUBE-SYSTEM"
echo "====================================================="
echo ""

kubectl get pods -n kube-system

echo ""
echo "====================================================="
echo " VALIDACION COMPLETA"
echo "====================================================="
echo ""
