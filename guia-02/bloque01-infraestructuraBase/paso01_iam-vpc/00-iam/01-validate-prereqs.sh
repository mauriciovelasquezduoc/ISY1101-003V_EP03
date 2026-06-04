#!/bin/bash

# =====================================================
# SCRIPT: 01-validate-prereqs.sh
# OBJETIVO:
# Validar entorno AWS Academy / EKS antes
# de crear el cluster
# =====================================================

set -e

REGION="us-east-1"

echo ""
echo "=================================================="
echo " VALIDACION PRE-REQUISITOS AWS / EKS"
echo "=================================================="
echo ""

# =====================================================
# 1. Validar AWS CLI
# =====================================================

echo "[1/7] Validando AWS CLI..."

if command -v aws >/dev/null 2>&1; then
    echo "✅ AWS CLI instalado"
    aws --version
else
    echo "❌ AWS CLI NO instalado"
    exit 1
fi

echo ""

# =====================================================
# 2. Validar kubectl
# =====================================================

echo "[2/7] Validando kubectl..."

if command -v kubectl >/dev/null 2>&1; then
    echo "✅ kubectl instalado"
    kubectl version --client
else
    echo "❌ kubectl NO instalado"
    exit 1
fi

echo ""

# =====================================================
# 3. Validar Docker
# =====================================================

echo "[3/7] Validando Docker..."

if command -v docker >/dev/null 2>&1; then
    echo "✅ Docker instalado"
    docker --version
else
    echo "❌ Docker NO instalado"
    exit 1
fi

echo ""

# =====================================================
# 4. Validar credenciales AWS
# =====================================================

echo "[4/7] Validando credenciales AWS..."

if aws sts get-caller-identity --region $REGION > /tmp/aws_identity.json 2>/dev/null
then
    echo "✅ Credenciales AWS validas"

    ACCOUNT_ID=$(jq -r '.Account' /tmp/aws_identity.json)
    ARN=$(jq -r '.Arn' /tmp/aws_identity.json)

    echo ""
    echo "ACCOUNT_ID: $ACCOUNT_ID"
    echo "ARN:        $ARN"

else
    echo "❌ Credenciales AWS invalidas o token expirado"
    echo ""
    echo "AWS Academy utiliza credenciales temporales."
    echo "Debes volver a copiar:"
    echo ""
    echo "- AWS_ACCESS_KEY_ID"
    echo "- AWS_SECRET_ACCESS_KEY"
    echo "- AWS_SESSION_TOKEN"
    echo ""
    echo "Luego ejecutar:"
    echo ""
    echo "aws configure"
    echo "aws configure set aws_session_token \"TOKEN\""
    echo ""

    exit 1
fi

echo ""

# =====================================================
# 5. Validar acceso IAM
# =====================================================

echo "[5/7] Validando acceso IAM..."

if aws iam list-roles --max-items 1 >/dev/null 2>&1
then
    echo "✅ Acceso IAM correcto"
else
    echo "❌ Sin permisos IAM"
    exit 1
fi

echo ""

# =====================================================
# 6. Buscar roles EKS del laboratorio
# AWS Academy usa nombres dinamicos
# =====================================================

echo "[6/7] Buscando roles EKS del laboratorio..."

echo ""

echo "Cluster Roles encontrados:"
aws iam list-roles \
  --query "Roles[?contains(RoleName, 'LabEksClusterRole')].RoleName" \
  --output table

echo ""

echo "Node Roles encontrados:"
aws iam list-roles \
  --query "Roles[?contains(RoleName, 'LabEksNodeRole')].RoleName" \
  --output table

echo ""

# =====================================================
# 7. Validar acceso EKS
# =====================================================

echo "[7/7] Validando acceso EKS..."

if aws eks list-clusters --region $REGION >/dev/null 2>&1
then
    echo "✅ Acceso EKS correcto"
else
    echo "❌ Sin permisos EKS"
    exit 1
fi

echo ""

# =====================================================
# RESUMEN FINAL
# =====================================================

echo "=================================================="
echo " VALIDACION FINALIZADA"
echo "=================================================="
echo ""

echo "Si todos los checks aparecen correctamente:"
echo ""
echo "✅ AWS CLI operativo"
echo "✅ Credenciales AWS validas"
echo "✅ Token AWS Academy activo"
echo "✅ Roles IAM EKS encontrados"
echo "✅ Acceso EKS correcto"
echo ""
echo "El entorno esta listo para continuar con:"
echo ""
echo "- Creacion Cluster EKS"
echo "- Node Groups"
echo "- kubectl"
echo "- ECR"
echo "- Kubernetes"
echo ""
