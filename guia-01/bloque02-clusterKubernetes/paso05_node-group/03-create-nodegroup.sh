#!/bin/bash

set -e

REGION="us-east-1"
CLUSTER_NAME="laboratorio-eks"
NODEGROUP_NAME="laboratorio-nodegroup"

echo ""
echo "====================================================="
echo " OBTENIENDO IAM ROLE NODEGROUP"
echo "====================================================="
echo ""

NODE_ROLE_ARN=$(aws iam list-roles \
  --query "Roles[?contains(RoleName, 'LabEksNodeRole')].Arn" \
  --output text)

echo "NODE_ROLE_ARN=$NODE_ROLE_ARN"

echo ""
echo "====================================================="
echo " OBTENIENDO SUBNETS PRIVADAS APP"
echo "====================================================="
echo ""

PRIVATE_APP_SUBNET_A=$(aws ec2 describe-subnets \
  --region $REGION \
  --query "Subnets[?Tags[?Value=='private-app-a']].SubnetId" \
  --output text)

PRIVATE_APP_SUBNET_B=$(aws ec2 describe-subnets \
  --region $REGION \
  --query "Subnets[?Tags[?Value=='private-app-b']].SubnetId" \
  --output text)

echo "PRIVATE_APP_SUBNET_A=$PRIVATE_APP_SUBNET_A"
echo "PRIVATE_APP_SUBNET_B=$PRIVATE_APP_SUBNET_B"

echo ""
echo "====================================================="
echo " CREANDO NODEGROUP EKS"
echo "====================================================="
echo ""

aws eks create-nodegroup \
  --region $REGION \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name $NODEGROUP_NAME \
  --node-role $NODE_ROLE_ARN \
  --subnets $PRIVATE_APP_SUBNET_A $PRIVATE_APP_SUBNET_B \
  --instance-types t3.large \
  --capacity-type SPOT \
  --disk-size 20 \
  --scaling-config minSize=1,maxSize=3,desiredSize=1

echo ""
echo "====================================================="
echo " NODEGROUP EN CREACION"
echo "====================================================="
echo ""
