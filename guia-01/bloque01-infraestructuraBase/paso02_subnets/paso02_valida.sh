#!/bin/bash

set -e

REGION="us-east-1"

echo ""
echo "====================================================="
echo " VALIDANDO SUBNETS EKS"
echo "====================================================="
echo ""

echo ""
echo "====================================================="
echo " OBTENIENDO VPC EKS"
echo "====================================================="
echo ""

VPC_ID=$(aws ec2 describe-vpcs \
  --region $REGION \
  --filters "Name=tag:Name,Values=laboratorio-vpc" \
  --query "Vpcs[0].VpcId" \
  --output text)

echo "VPC_ID=$VPC_ID"

echo ""
echo "====================================================="
echo " SUBNETS DETECTADAS"
echo "====================================================="
echo ""

aws ec2 describe-subnets \
  --region $REGION \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query "Subnets[*].[SubnetId,AvailabilityZone,CidrBlock]" \
  --output table

echo ""
echo "====================================================="
echo " VALIDANDO TAGS EKS"
echo "====================================================="
echo ""

aws ec2 describe-subnets \
  --region $REGION \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --output json

echo ""
echo "====================================================="
echo " VALIDANDO VPC ENDPOINTS"
echo "====================================================="
echo ""

aws ec2 describe-vpc-endpoints \
  --region $REGION \
  --query "VpcEndpoints[*].[VpcEndpointId,ServiceName,VpcEndpointType,State]" \
  --output table

echo ""
echo "====================================================="
echo " VALIDANDO LOAD BALANCER READINESS"
echo "====================================================="
echo ""

echo "Las subnets deben contener:"
echo ""
echo "- kubernetes.io/role/elb"
echo "- kubernetes.io/role/internal-elb"
echo "- kubernetes.io/cluster/laboratorio-eks"
echo ""

echo ""
echo "====================================================="
echo " VALIDACION COMPLETA"
echo "====================================================="
echo ""