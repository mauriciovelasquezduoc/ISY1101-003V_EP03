#!/bin/bash
# ==================================================================
# ETAPA 01 — Docker, AWS CLI y Validar Prerequisitos
# ==================================================================
set -e

echo ""
echo "============================================================="
echo " ETAPA 01 — Entorno Docker + Validar prerequisitos AWS"
echo "============================================================="
echo ""

# --- Corregir CRLF si estas en Windows ---
echo "[1] Corrigiendo CRLF (Windows → Unix)..."
fix-crlf 2>/dev/null || echo "  Omitido (fix-crlf no disponible)"

# --- AWS Academy: validar credenciales ---
echo ""
echo "[2] Validando credenciales AWS..."
aws sts get-caller-identity

echo ""
echo "[3] Validando herramientas..."
aws --version
kubectl version --client
docker --version

echo ""
echo "[4] Validando acceso IAM..."
aws iam list-roles --max-items 1 >/dev/null 2>&1 && echo "  OK: acceso IAM" || echo "  ERROR: sin permisos IAM"

echo ""
echo "[5] Buscando roles EKS del laboratorio..."
aws iam list-roles --query "Roles[?contains(RoleName, 'LabEksClusterRole')].RoleName" --output table
aws iam list-roles --query "Roles[?contains(RoleName, 'LabEksNodeRole')].RoleName" --output table

echo ""
echo "[6] Validando acceso EKS..."
aws eks list-clusters --region us-east-1

echo ""
echo "============================================================="
echo " ETAPA 01 COMPLETADA"
echo "============================================================="
echo "Si todos los checks pasaron, continua con: cd ../etapa02"
echo ""
