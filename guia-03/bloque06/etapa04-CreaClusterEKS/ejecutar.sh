#!/bin/bash
# ==================================================================
# ETAPA 04 — Crear Cluster EKS + Conectar kubectl
# ==================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../report_helper.sh"

REGION="us-east-1"
CLUSTER_NAME="laboratorio-eks"
VPC_STACK="laboratorio-vpc-completa"
EKS_STACK="laboratorio-eks"
TEMPLATE="../../bloque02-clusterKubernetes/paso03_eks/fase_4_cluster_eks.yaml"

init_reporte "Creación de Cluster EKS y conexión kubectl"

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

EKS_CLUSTER_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'LabEksClusterRole')].Arn" --output text)
EKS_NODE_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName, 'LabEksNodeRole')].Arn" --output text)

add_texto_evidencia "**Parámetros del clúster:**  
- **Cluster:** \`${CLUSTER_NAME}\`
- **VPC:** \`${VPC_ID}\`
- **Subnets Públicas:** \`${PUBLIC_A}\`, \`${PUBLIC_B}\`
- **Subnets Privadas App:** \`${PRIV_APP_A}\`, \`${PRIV_APP_B}\`
- **Cluster Role:** \`${EKS_CLUSTER_ROLE}\`
- **Node Role:** \`${EKS_NODE_ROLE}\`
- **Región:** \`${REGION}\`
- **Template:** \`${TEMPLATE}\`"

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

add_evidencia "Estado del cluster EKS" "aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint,Role:roleArn}' --output table" "IE1"

add_evidencia "Addons EKS instalados" "aws eks list-addons --cluster-name $CLUSTER_NAME --region $REGION --output table" "IE1"

add_logs_evidencia "Namespaces de Kubernetes" "kubectl get namespaces" "IE2"

add_logs_evidencia "Pods del sistema (kube-system)" "kubectl get pods -n kube-system" "IE2"

cerrar_reporte

echo ""
echo "============================================================="
echo " ETAPA 04 COMPLETADA — Cluster EKS creado + kubectl conectado"
echo "============================================================="
echo ""
echo "  📋 Reporte generado en: docs/reports/etapa04-CreaClusterEKS.md"
echo ""
echo "Continua con: cd ../etapa05-CreaNodeGroup"
echo ""
