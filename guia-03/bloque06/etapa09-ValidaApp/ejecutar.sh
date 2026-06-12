#!/bin/bash
# ==================================================================
# ETAPA 09 — Validacion final + Operacion Avanzada (HPA, Healing, Metricas)
# ==================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../report_helper.sh"

NAMESPACE="alumnos"
REGION="us-east-1"

init_reporte "Validación final y operación avanzada (HPA, Healing, Métricas)"

echo ""
echo "============================================================="
echo " ETAPA 09 — Validacion final + Operacion Avanzada"
echo "============================================================="
echo ""

# ==================================================================
# Configurar kubeconfig para EKS (por si el contexto expiró)
# ==================================================================
echo "  Configurando kubeconfig para EKS..."
CLUSTER=$(aws eks list-clusters --region "$REGION" --query 'clusters[0]' --output text 2>/dev/null || echo "")
if [ -n "$CLUSTER" ] && [ "$CLUSTER" != "None" ]; then
  aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER" 2>/dev/null
  echo "  ✔ kubeconfig configurado: $CLUSTER"
else
  echo "  ⚠ No se pudo detectar cluster EKS"
fi
echo ""

# ==================================================================
# Validaciones base
# ==================================================================
add_evidencia "Nodos del cluster" "kubectl get nodes -o wide" "IE1"
add_evidencia "Pods en namespace alumnos" "kubectl get pods -n $NAMESPACE -o wide" "IE2 + IE7"
add_evidencia "Services en alumnos" "kubectl get svc -n $NAMESPACE" "IE2"
add_evidencia "HPA en alumnos" "kubectl get hpa -n $NAMESPACE" "IE3"
add_evidencia "Deployments en alumnos" "kubectl get deployment -n $NAMESPACE" "IE2"
add_evidencia "Endpoints" "kubectl get endpoints -n $NAMESPACE" "IE7"
add_evidencia "Pods del sistema (kube-system)" "kubectl get pods -n kube-system" "IE1"
add_evidencia "Métricas de nodos" "kubectl top nodes 2>/dev/null || echo '(metrics-server puede tardar)'" "IE3"
add_evidencia "Métricas de pods" "kubectl top pods -n $NAMESPACE 2>/dev/null || echo '(metrics-server puede tardar)'" "IE3"

# --- URL del LoadBalancer ---
echo ""
echo "============================================================="
echo " URL DE LA APLICACION"
echo "============================================================="

LB_URL=$(kubectl get svc alumnos-frontend -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [ -n "$LB_URL" ]; then
  add_texto_evidencia "### URL pública de la aplicación

\`\`\`
http://${LB_URL}
\`\`\`"
  echo ""
  echo "  LoadBalancer URL:"
  echo "  http://$LB_URL"
else
  echo ""
  echo "  El LoadBalancer aun se esta creando..."
fi

# ==================================================================
# SCRIPTS DE OPERACIÓN AVANZADA
# ==================================================================
echo ""
echo "============================================================="
echo " SCRIPTS DE OPERACION AVANZADA"
echo "============================================================="

# Auto-healing
add_texto_evidencia "### Auto-Healing (paso12)

El script elimina un Pod y verifica que Kubernetes lo recrea automáticamente.
Esto demuestra la capacidad de **self-healing** del clúster."

HEALING_SCRIPT="../../bloque05-operacionAvanzada/paso12_healing/healing.sh"
if [ -x "$HEALING_SCRIPT" ]; then
  echo ""
  echo "--- [Auto-Healing] ---"
  cd "$(dirname "$HEALING_SCRIPT")"
  bash "$(basename "$HEALING_SCRIPT")" 2>&1 | tee -a "$REPORTE_FILE"
  cd "$SCRIPT_DIR"
fi

# HPA + Stress
add_texto_evidencia "### HPA y Stress Test (paso10 + paso11)

Se valida que el HPA responde a carga y se ejecuta un stress test
contra el backend para ver el escalado en tiempo real."

HPA_SCRIPT="../../bloque05-operacionAvanzada/paso10_hpa/validar-demostrar.sh"
if [ -x "$HPA_SCRIPT" ]; then
  echo ""
  echo "--- [HPA - Validacion] ---"
  cd "$(dirname "$HPA_SCRIPT")"
  bash "$(basename "$HPA_SCRIPT")" 2>&1 | tee -a "$REPORTE_FILE"
  cd "$SCRIPT_DIR"
fi

# Stress test externo
STRESS_SCRIPT="../../bloque05-operacionAvanzada/paso11_stress_test/stress-test.sh"
if [ -x "$STRESS_SCRIPT" ]; then
  echo ""
  echo "--- [Stress Test Externo] ---"
  timeout 30 bash "$STRESS_SCRIPT" 20 2>/dev/null || true
  echo ""
  echo "  ✔ Stress test completado."
fi

# Métricas
add_texto_evidencia "### Métricas y Observabilidad (paso13)

Se consolidan las métricas del clúster: kubectl top, CloudWatch y estado general."

METRICAS_SCRIPT="../../bloque05-operacionAvanzada/paso13_metricas/metricas.sh"
if [ -x "$METRICAS_SCRIPT" ]; then
  echo ""
  echo "--- [Metricas] ---"
  cd "$(dirname "$METRICAS_SCRIPT")"
  bash "$(basename "$METRICAS_SCRIPT")" 2>&1 | tee -a "$REPORTE_FILE"
  cd "$SCRIPT_DIR"
fi

cerrar_reporte

echo ""
echo "============================================================="
echo " ETAPA 09 COMPLETADA"
echo "============================================================="
echo ""
echo "  📋 Reporte generado en: docs/reports/etapa09-ValidaApp.md"
echo ""
echo "  💡 Para evidencia en README:"
echo "     - Copia la sección 'URL pública' para el README del frontend"
echo "     - Copia la sección 'HPA' para la sección de autoscaling"
echo "     - Copia la sección 'Auto-Healing' para la validación funcional"
echo ""
echo "Continua con: cd ../etapa10-ConectividadURL"
echo ""
