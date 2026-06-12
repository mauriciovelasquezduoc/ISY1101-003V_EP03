#!/bin/bash
# ==================================================================
# ETAPA 03 — Validar subnets EKS (tags para LoadBalancer)
# ==================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../report_helper.sh"

REGION="us-east-1"

init_reporte "Validación de Tags EKS en Subnets"

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

add_evidencia "Listar subnets de la VPC" "aws ec2 describe-subnets --region $REGION --filters Name=vpc-id,Values=$VPC_ID --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key==\"/Name\"].Value|[0]]' --output table" "IE1"

add_logs_evidencia "Validar tags EKS requeridos" "echo 'Tags necesarios:'; echo '  - kubernetes.io/cluster/laboratorio-eks = shared'; echo '  - kubernetes.io/role/elb = 1 (subnets publicas)'; echo '  - kubernetes.io/role/internal-elb = 1 (subnets privadas app)'; echo ''; aws ec2 describe-subnets --region $REGION --filters Name=vpc-id,Values=$VPC_ID --output json | python3 -c \"import json, sys; data = json.load(sys.stdin); print(f'{'Subnet':25s} {'AZ':15s} {'cluster':15s} {'elb':8s} {'internal-elb':12s}'); print('-'*75); [print(f'{s[\"SubnetId\"]:25s} {s[\"AvailabilityZone\"]:15s} { {t[\"Key\"]: t[\"Value\"] for t in s.get(\"Tags\", [])}.get(\"kubernetes.io/cluster/laboratorio-eks\", \"FALTA\"):15s} { {t[\"Key\"]: t[\"Value\"] for t in s.get(\"Tags\", [])}.get(\"kubernetes.io/role/elb\", \"-\"):8s} { {t[\"Key\"]: t[\"Value\"] for t in s.get(\"Tags\", [])}.get(\"kubernetes.io/role/internal-elb\", \"-\"):12s}') for s in data['Subnets']]\"" "IE1"

add_evidencia "VPC Endpoints disponibles" "aws ec2 describe-vpc-endpoints --region $REGION --query 'VpcEndpoints[*].[ServiceName,State]' --output table" "IE1"

cerrar_reporte

echo ""
echo "============================================================="
echo " ETAPA 03 COMPLETADA — Tags EKS validados"
echo "============================================================="
echo ""
echo "  📋 Reporte generado en: docs/reports/etapa03-ValidaSubnets.md"
echo ""
echo "Continua con: cd ../etapa04-CreaClusterEKS"
echo ""
