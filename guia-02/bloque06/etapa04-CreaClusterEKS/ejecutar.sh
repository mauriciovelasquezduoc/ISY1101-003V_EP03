#!/bin/bash
# ==================================================================
# ETAPA 04 — Crear Cluster EKS + Conectar kubectl
# ==================================================================
set -e

REGION="us-east-1"
CLUSTER_NAME="laboratorio-eks"
VPC_STACK="laboratorio-vpc-completa"
EKS_STACK="laboratorio-eks"
TEMPLATE="../../bloque02-clusterKubernetes/paso03_eks/fase_4_cluster_eks.yaml"

echo ""
echo "============================================================="
echo " ETAPA 04 — Crear Cluster EKS + Conectar kubectl"
echo "============================================================="
echo ""

echo "[1] Obteniendo recursos desde CloudFormation..."
VPC_ID=$(aws cloudformation describe-stacks --stack-name $VPC_STACK --region $REGION --query "Stacks[0].Outputs[?OutputKey=='VpcId'].OutputValue" --output text)
PUBLIC_A=$(aws cloudformation describe-stacks --stack-name $VPC_STACK --region $REGION --query "Stacks[0].Outputs[?OutputKey=='PublicSubnetA'].OutputValue" --output text)
PUBLIC_B=$(aws cloudformation describe-stacks --stack-name $VPC_STACK --region $REGION --query "Stacks[0].Outputs[?OutputKey=='PublicSubnetB'].OutputValue" --output text)
PRIV_APP_A=$(aws cloudformation describe-stacks --stack-name $VPC_STACK --region $REGION --query "Stacks[0].Outputs[?OutputKey=='PrivateAppSubnetA'].OutputValue" --output text)
PRIV_APP_B=$(aws cloudformation describe-stacks --stack-name $VPC_STACK --region $REGION --query "Stacks[0].Outputs[?OutputKey=='PrivateAppSubnetB'].OutputValue" --output text)

echo "  VPC=$VPC_ID"
echo "  PublicSubnetA=$PUBLIC_A"
echo "  PublicSubnetB=$PUBLIC_B"
echo "  PrivateAppSubnetA=$PRIV_APP_A"
echo "  PrivateAppSubnetB=$PRIV_APP_B"

EKS_CLUSTER_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'LabEksClusterRole')].Arn" --output text)
EKS_NODE_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'LabEksNodeRole')].Arn" --output text)

echo "  ClusterRole=$EKS_CLUSTER_ROLE"
echo "  NodeRole=$EKS_NODE_ROLE"

echo ""
echo "[2] Creando cluster EKS (tarda ~15 min)..."
aws cloudformation deploy \
  --template-file $TEMPLATE \
  --stack-name $EKS_STACK \
  --region $REGION \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    VPCId=$VPC_ID \
    PublicSubnetA=$PUBLIC_A \
    PublicSubnetB=$PUBLIC_B \
    PrivateAppSubnetA=$PRIV_APP_A \
    PrivateAppSubnetB=$PRIV_APP_B \
    EksClusterRoleArn=$EKS_CLUSTER_ROLE \
    EksNodeRoleArn=$EKS_NODE_ROLE

echo ""
echo "[3] Configurando kubeconfig..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

echo ""
echo "[4] Validando cluster..."
echo ""
echo "  NOTA: El NodeGroup 'laboratorio-nodegroup' se crea como parte"
echo "  del stack CloudFormation. La etapa05 verificara que este ACTIVE."
echo ""
echo "=== Nodos ==="
kubectl get nodes -o wide 2>/dev/null || echo "  (nodos apareceran cuando el NodeGroup este ACTIVE)"
echo ""
echo "=== Addons EKS ==="
aws eks list-addons --cluster-name $CLUSTER_NAME --region $REGION
echo ""
echo "=== Namespaces ==="
kubectl get namespaces
echo ""
echo "=== kube-system ==="
kubectl get pods -n kube-system

echo ""
echo "============================================================="
echo " ETAPA 04 COMPLETADA — Cluster EKS creado + kubectl conectado"
echo "============================================================="
echo "Continua con: cd ../etapa05-CreaNodeGroup"
echo ""
