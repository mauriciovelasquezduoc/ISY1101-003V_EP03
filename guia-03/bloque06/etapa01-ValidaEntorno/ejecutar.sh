#!/bin/bash
# ==================================================================
# ETAPA 01 — Docker, AWS CLI y Validar Prerequisitos
# ==================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../report_helper.sh"

# ==================================================================
# Función: valida_comando
# Ejecuta un comando, muestra resultado en pantalla.
# Si falla, muestra mensaje claro con instrucciones y detiene el script.
# ==================================================================
valida_comando() {
    local descripcion="$1"
    local comando="$2"

    echo -n "  ▶ $descripcion ... "
    local output
    output=$(eval "$comando" 2>&1)
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        echo "❌  ERROR"
        echo ""
        echo "═══════════════════════════════════════════════════════════"
        echo "  ✘  FALLÓ: $descripcion"
        echo ""
        echo "  Salida del comando:"
        echo "    $comando"
        echo ""
        echo "  $output" | sed 's/^/    /'
        echo ""
        echo "  ▶  Solución: Ejecuta 'aws configure' para configurar"
        echo "     tus credenciales AWS (AWS Access Key ID,"
        echo "     AWS Secret Access Key, región por defecto y formato)."
        echo ""
        echo "     También verifica que tengas conectividad a Internet"
        echo "     y que el perfil de AWS tenga los permisos necesarios."
        echo ""
        echo "  ▶  Una vez configurado, vuelve a ejecutar este script."
        echo "═══════════════════════════════════════════════════════════"
        echo ""
        exit 1
    else
        echo "✅  OK"
    fi
}

init_reporte "Validación de Entorno y Prerrequisitos"

echo ""
echo "============================================================="
echo " ETAPA 01 — Entorno Docker + Validar prerequisitos AWS"
echo "============================================================="
echo ""

# --- Corregir CRLF si estas en Windows ---
echo "[1] Corrigiendo CRLF (Windows → Unix)..."
fix-crlf 2>/dev/null || echo "  Omitido (fix-crlf no disponible)"

# --- Validaciones críticas de conexión AWS ---
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   VALIDACIONES DE CONEXIÓN AWS                             ║"
echo "║                                                            ║"
echo "║   A continuación se verificará que AWS CLI tenga           ║"
echo "║   credenciales válidas y acceso a los servicios            ║"
echo "║   necesarios (STS, IAM, EKS).                              ║"
echo "║                                                            ║"
echo "║   ⚠ Si alguna validación falla, el script se detendrá     ║"
echo "║     y deberás ejecutar 'aws configure' para configurar     ║"
echo "║     tus credenciales de AWS.                               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

valida_comando "Verificar credenciales AWS (STS)" "aws sts get-caller-identity"
valida_comando "Verificar acceso IAM" "aws iam list-roles --max-items 1"
valida_comando "Verificar acceso EKS" "aws eks list-clusters --region us-east-1"

echo ""
echo "  ✅  Todas las validaciones de conexión AWS pasaron correctamente."
echo ""

# --- Evidencias para el reporte ---
add_evidencia "Validar credenciales AWS" "aws sts get-caller-identity" "IE1"

add_evidencia "Versión de herramientas" "echo '--- AWS CLI ---'; aws --version; echo '--- kubectl ---'; kubectl version --client; echo '--- Docker ---'; docker --version" "IE1"

add_logs_evidencia "Validar acceso IAM" "aws iam list-roles --max-items 1 >/dev/null 2>&1 && echo 'OK: acceso IAM' || echo 'ERROR: sin permisos IAM'" "IE1"

add_evidencia "Buscar roles EKS del laboratorio" "echo '--- LabEKSClusterRole ---'; aws iam list-roles --query \"Roles[?contains(RoleName, 'LabEksClusterRole')].RoleName\" --output table; echo '--- LabEKSNodeRole ---'; aws iam list-roles --query \"Roles[?contains(RoleName, 'LabEksNodeRole')].RoleName\" --output table" "IE1"

add_evidencia "Validar acceso EKS" "aws eks list-clusters --region us-east-1" "IE1"

cerrar_reporte

echo ""
echo "============================================================="
echo " ETAPA 01 COMPLETADA"
echo "============================================================="
echo ""
echo "  📋 Reporte generado en: docs/reports/etapa01-ValidaEntorno.md"
echo ""
echo "  ➡️  Para subir evidencia al README del repo, copia el contenido de:"
echo "      docs/reports/etapa01-ValidaEntorno.md"
echo "      y pégalo en la sección de Prerrequisitos del README."
echo ""
echo "Continua con: cd ../etapa02-CreaVPC"
echo ""
