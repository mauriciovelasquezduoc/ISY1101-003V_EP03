#!/bin/bash
# ==================================================================
# ETAPA 02 — Desplegar VPC con CloudFormation
# ==================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../report_helper.sh"

REGION="us-east-1"
STACK_NAME="laboratorio-vpc-completa"

init_reporte "Despliegue de VPC Multi-AZ con CloudFormation"

echo ""
echo "============================================================="
echo " ETAPA 02 — Crear VPC Multi-AZ con CloudFormation"
echo "============================================================="
echo ""

add_texto_evidencia "**Stack CloudFormation:** \`${STACK_NAME}\`  
**Región:** ${REGION}  
**Template:** \`../../bloque01-infraestructuraBase/paso01_iam-vpc/01-vpc/vpc.yaml\`"

echo "[1] Desplegando VPC via CloudFormation..."
echo "  Stack: $STACK_NAME"
echo "  Region: $REGION"

aws cloudformation deploy \
  --template-file ../../bloque01-infraestructuraBase/paso01_iam-vpc/01-vpc/vpc.yaml \
  --stack-name $STACK_NAME \
  --region $REGION \
  --capabilities CAPABILITY_NAMED_IAM

echo ""
echo "[2] Esperando a que la VPC este lista..."
aws cloudformation wait stack-create-complete \
  --stack-name $STACK_NAME \
  --region $REGION

add_evidencia "VPC Creada" "aws ec2 describe-vpcs --region $REGION --filters 'Name=tag:Name,Values=laboratorio-vpc' --query 'Vpcs[*].[VpcId,CidrBlock,State]' --output table" "IE1"

add_evidencia "Subnets creadas" "VPC_ID=\$(aws ec2 describe-vpcs --region $REGION --filters Name=tag:Name,Values=laboratorio-vpc --query 'Vpcs[0].VpcId' --output text); aws ec2 describe-subnets --region $REGION --filters Name=vpc-id,Values=\$VPC_ID --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key==\"/Name\"].Value|[0]]' --output table" "IE1"

add_evidencia "VPC Endpoints creados" "aws ec2 describe-vpc-endpoints --region $REGION --query 'VpcEndpoints[*].[ServiceName,State]' --output table" "IE1"

cerrar_reporte

echo ""
echo "============================================================="
echo " ETAPA 02 COMPLETADA — VPC desplegada"
echo "============================================================="
echo ""
echo "  📋 Reporte generado en: docs/reports/etapa02-CreaVPC.md"
echo ""
echo "Continua con: cd ../etapa03-ValidaSubnets"
echo ""
