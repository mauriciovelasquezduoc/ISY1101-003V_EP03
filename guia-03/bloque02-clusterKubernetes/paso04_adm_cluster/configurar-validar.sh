#!/bin/bash

set -e

REGION="us-east-1"
CLUSTER_NAME="laboratorio-eks"

echo ""
echo "====================================================="
echo " VALIDANDO AWS CLI"
echo "====================================================="
echo ""

aws sts get-caller-identity

echo ""
echo "====================================================="
echo " VALIDANDO CLUSTER EKS"
echo "====================================================="
echo ""

aws eks list-clusters \
  --region $REGION

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
echo " VALIDANDO CONTEXTOS KUBERNETES"
echo "====================================================="
echo ""

kubectl config get-contexts

echo ""
echo "====================================================="
echo " CONTEXTO ACTUAL"
echo "====================================================="
echo ""

kubectl config current-context

echo ""
echo "====================================================="
echo " VALIDANDO NODOS"
echo "====================================================="
echo ""

kubectl get nodes -o wide

echo ""
echo "====================================================="
echo " VALIDANDO NAMESPACES"
echo "====================================================="
echo ""

kubectl get namespaces

echo ""
echo "====================================================="
echo " VALIDANDO KUBE-SYSTEM"
echo "====================================================="
echo ""

kubectl get pods -n kube-system

echo ""
echo "====================================================="
echo " VALIDANDO METRICAS"
echo "====================================================="
echo ""

kubectl top nodes || true

echo ""
echo "====================================================="
echo " VALIDACION COMPLETA"
echo "====================================================="
echo ""
