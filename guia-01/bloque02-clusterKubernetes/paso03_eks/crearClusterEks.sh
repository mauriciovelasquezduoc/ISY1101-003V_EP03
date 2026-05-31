#!/bin/bash

set -e

REGION="us-east-1"
VPC_STACK="laboratorio-vpc-completa"
EKS_STACK="laboratorio-eks"
TEMPLATE_FILE="fase_4_cluster_eks.yaml"

echo ""
echo "====================================================="
echo " OBTENIENDO RECURSOS DESDE CLOUDFORMATION"
echo "====================================================="
echo ""

VPC_ID=$(aws cloudformation describe-stacks   --stack-name $VPC_STACK   --region $REGION   --query "Stacks[0].Outputs[?OutputKey=='VpcId'].OutputValue"   --output text)

PUBLIC_SUBNET_A=$(aws cloudformation describe-stacks   --stack-name $VPC_STACK   --region $REGION   --query "Stacks[0].Outputs[?OutputKey=='PublicSubnetA'].OutputValue"   --output text)

PUBLIC_SUBNET_B=$(aws cloudformation describe-stacks   --stack-name $VPC_STACK   --region $REGION   --query "Stacks[0].Outputs[?OutputKey=='PublicSubnetB'].OutputValue"   --output text)

PRIVATE_APP_SUBNET_A=$(aws cloudformation describe-stacks   --stack-name $VPC_STACK   --region $REGION   --query "Stacks[0].Outputs[?OutputKey=='PrivateAppSubnetA'].OutputValue"   --output text)

PRIVATE_APP_SUBNET_B=$(aws cloudformation describe-stacks   --stack-name $VPC_STACK   --region $REGION   --query "Stacks[0].Outputs[?OutputKey=='PrivateAppSubnetB'].OutputValue"   --output text)

echo "VPC_ID=$VPC_ID"
echo "PUBLIC_SUBNET_A=$PUBLIC_SUBNET_A"
echo "PUBLIC_SUBNET_B=$PUBLIC_SUBNET_B"
echo "PRIVATE_APP_SUBNET_A=$PRIVATE_APP_SUBNET_A"
echo "PRIVATE_APP_SUBNET_B=$PRIVATE_APP_SUBNET_B"

EKS_CLUSTER_ROLE=$(aws iam list-roles   --query "Roles[?contains(RoleName, 'LabEksClusterRole')].Arn"   --output text)

EKS_NODE_ROLE=$(aws iam list-roles   --query "Roles[?contains(RoleName, 'LabEksNodeRole')].Arn"   --output text)

echo ""
echo "EKS_CLUSTER_ROLE=$EKS_CLUSTER_ROLE"
echo "EKS_NODE_ROLE=$EKS_NODE_ROLE"

aws cloudformation deploy   --template-file $TEMPLATE_FILE   --stack-name $EKS_STACK   --region $REGION   --capabilities CAPABILITY_NAMED_IAM   --parameter-overrides     VPCId=$VPC_ID     PublicSubnetA=$PUBLIC_SUBNET_A     PublicSubnetB=$PUBLIC_SUBNET_B     PrivateAppSubnetA=$PRIVATE_APP_SUBNET_A     PrivateAppSubnetB=$PRIVATE_APP_SUBNET_B     EksClusterRoleArn=$EKS_CLUSTER_ROLE     EksNodeRoleArn=$EKS_NODE_ROLE

aws eks update-kubeconfig   --region $REGION   --name laboratorio-eks

kubectl get nodes
