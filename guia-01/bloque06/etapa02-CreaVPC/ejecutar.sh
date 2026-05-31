#!/bin/bash
# ==================================================================
# ETAPA 02 — Desplegar VPC con CloudFormation
# ==================================================================
set -e

REGION="us-east-1"
STACK_NAME="laboratorio-vpc-completa"

echo ""
echo "============================================================="
echo " ETAPA 02 — Crear VPC Multi-AZ con CloudFormation"
echo "============================================================="
echo ""

echo "[1] Desplegando VPC via CloudFormation..."
echo "  Stack: $STACK_NAME"
echo "  Region: $REGION"
echo "  Template: ../../bloque01-infraestructuraBase/paso01_iam-vpc/01-vpc/vpc.yaml"
echo ""

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

echo ""
echo "[3] Validando recursos creados..."
echo ""
echo "=== VPC ==="
aws ec2 describe-vpcs \
  --region $REGION \
  --filters "Name=tag:Name,Values=laboratorio-vpc" \
  --query "Vpcs[*].[VpcId,CidrBlock,State]" \
  --output table

echo ""
echo "=== Subnets ==="
aws ec2 describe-subnets \
  --region $REGION \
  --filters "Name=vpc-id,Values=$(aws ec2 describe-vpcs --region $REGION --filters Name=tag:Name,Values=laboratorio-vpc --query 'Vpcs[0].VpcId' --output text)" \
  --query "Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key=='Name'].Value|[0]]" \
  --output table

echo ""
echo "=== VPC Endpoints ==="
aws ec2 describe-vpc-endpoints \
  --region $REGION \
  --query "VpcEndpoints[*].[ServiceName,State]" \
  --output table

echo ""
echo "============================================================="
echo " ETAPA 02 COMPLETADA — VPC desplegada"
echo "============================================================="
echo "Continua con: cd ../etapa03"
echo ""
