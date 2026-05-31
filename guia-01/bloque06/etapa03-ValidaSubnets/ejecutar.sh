#!/bin/bash
# ==================================================================
# ETAPA 03 — Validar subnets EKS (tags para LoadBalancer)
# ==================================================================
set -e

REGION="us-east-1"

echo ""
echo "============================================================="
echo " ETAPA 03 — Validar Tags EKS en Subnets"
echo "============================================================="
echo ""

echo "[1] Obteniendo VPC..."
VPC_ID=$(aws ec2 describe-vpcs \
  --region $REGION \
  --filters "Name=tag:Name,Values=laboratorio-vpc" \
  --query "Vpcs[0].VpcId" \
  --output text)
echo "  VPC_ID=$VPC_ID"

echo ""
echo "[2] Verificando subnets y tags..."
aws ec2 describe-subnets \
  --region $REGION \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query "Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key=='Name'].Value|[0]]" \
  --output table

echo ""
echo "[3] Validando tags EKS requeridos..."
echo "  Tags necesarios:"
echo "    - kubernetes.io/cluster/laboratorio-eks = shared"
echo "    - kubernetes.io/role/elb = 1 (subnets publicas)"
echo "    - kubernetes.io/role/internal-elb = 1 (subnets privadas app)"

aws ec2 describe-subnets \
  --region $REGION \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --output json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for s in data['Subnets']:
    tags = {t['Key']: t['Value'] for t in s.get('Tags', [])}
    name = tags.get('Name', 'sin-nombre')
    cluster = tags.get('kubernetes.io/cluster/laboratorio-eks', 'FALTA')
    elb = tags.get('kubernetes.io/role/elb', '-')
    internal = tags.get('kubernetes.io/role/internal-elb', '-')
    print(f'  {name:25s} cluster={cluster:10s} elb={elb:5s} internal-elb={internal:5s}')
"

echo ""
echo "[4] Validando VPC Endpoints..."
aws ec2 describe-vpc-endpoints \
  --region $REGION \
  --query "VpcEndpoints[*].[ServiceName,State]" \
  --output table

echo ""
echo "============================================================="
echo " ETAPA 03 COMPLETADA — Tags EKS validados"
echo "============================================================="
echo "Continua con: cd ../etapa04"
echo ""
