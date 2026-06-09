#!/bin/bash
# ==================================================================
# ETAPA 09 — Validacion final + Operacion Avanzada (HPA, Healing, Metricas)
# ==================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACE="tienda"
REGION="us-east-1"

echo ""
echo "============================================================="
echo " ETAPA 09 — Validacion final + Operacion Avanzada (HPA, Healing, Metricas)"
echo "============================================================="
echo ""

# ==================================================================
# Configurar kubeconfig para EKS (por si el contexto expiro)
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

echo "=== 1. Nodos del cluster ==="
kubectl get nodes -o wide

echo ""
echo "=== 2. Todos los Pods en tienda ==="
kubectl get pods -n $NAMESPACE -o wide

echo ""
echo "=== 3. Services en tienda ==="
kubectl get svc -n $NAMESPACE

echo ""
echo "=== 4. HPA en tienda ==="
kubectl get hpa -n $NAMESPACE

echo ""
echo "=== 5. Deployments en tienda ==="
kubectl get deployment -n $NAMESPACE

echo ""
echo "=== 6. Endpoints ==="
kubectl get endpoints -n $NAMESPACE

echo ""
echo "=== 7. kube-system ==="
kubectl get pods -n kube-system

echo ""
echo "=== 8. Metricas de nodos ==="
kubectl top nodes 2>/dev/null || echo "  (metrics-server puede tardar)"

echo ""
echo "=== 9. Metricas de pods ==="
kubectl top pods -n $NAMESPACE 2>/dev/null || echo "  (metrics-server puede tardar)"

# --- URL del LoadBalancer ---
echo ""
echo "============================================================="
echo " URL DE LA APLICACION"
echo "============================================================="

LB_URL=$(kubectl get svc tienda-frontend -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [ -n "$LB_URL" ]; then
  echo ""
  echo "  LoadBalancer URL:"
  echo "  http://$LB_URL"
  echo ""
  echo "  (puede tardar unos minutos en estar disponible)"
else
  echo ""
  echo "  El LoadBalancer aun se esta creando..."
  echo "  Vuelve a ejecutar: kubectl get svc -n $NAMESPACE"
  echo "  Cuando aparezca un hostname en EXTERNAL-IP, usalo en el navegador."
fi

# ==================================================================
# SCRIPTS DE OPERACION AVANZADA (bloque05)
# ==================================================================
echo ""
echo "============================================================="
echo " SCRIPTS DE OPERACION AVANZADA"
echo "============================================================="

# paso12 - Auto-healing primero (no requiere HPA)
HEALING_SCRIPT="../../bloque05-operacionAvanzada/paso12_healing/healing.sh"
if [ -x "$HEALING_SCRIPT" ]; then
  echo ""
  echo "--- [Auto-Healing] ---"
  cd "$(dirname "$HEALING_SCRIPT")"
  bash "$(basename "$HEALING_SCRIPT")"
  cd "$SCRIPT_DIR"
fi

# paso10 - HPA (requiere pods running)
HPA_SCRIPT="../../bloque05-operacionAvanzada/paso10_hpa/validar-demostrar.sh"
if [ -x "$HPA_SCRIPT" ]; then
  echo ""
  echo "--- [HPA - Validacion y Stress Test] ---"
  cd "$(dirname "$HPA_SCRIPT")"
  bash "$(basename "$HPA_SCRIPT")"
  cd "$SCRIPT_DIR"
fi

# paso13 - Metricas (requiere HPA funcionando)
METRICAS_SCRIPT="../../bloque05-operacionAvanzada/paso13_metricas/metricas.sh"
if [ -x "$METRICAS_SCRIPT" ]; then
  echo ""
  echo "--- [Metricas y Observabilidad] ---"
  cd "$(dirname "$METRICAS_SCRIPT")"
  bash "$(basename "$METRICAS_SCRIPT")"
  cd "$SCRIPT_DIR"
fi

# paso11 - Stress test externo contra el LoadBalancer
STRESS_SCRIPT="../../bloque05-operacionAvanzada/paso11_stress_test/stress-test.sh"
if [ -x "$STRESS_SCRIPT" ]; then
  echo ""
  echo "--- [Stress Test Externo] ---"
  echo "  Ejecutando prueba de carga contra el frontend..."
  echo "  (se ejecutara por 30 segundos con 20 workers)"
  echo ""
  timeout 30 bash "$STRESS_SCRIPT" 20 2>/dev/null || true
  echo ""
  echo "  ✔ Stress test completado."
fi

echo ""
echo "============================================================="
echo " ETAPA 09 COMPLETADA"
echo "============================================================="
echo ""
echo "RESUMEN:"
echo "  Docker → VPC → EKS → NodeGroup → Metrics → CloudWatch"
echo "  → ECR → Deploy (DB + Backend + Frontend) → LoadBalancer"
echo "  → HPA → Auto-Healing → Metricas"
echo ""
echo "La aplicacion esta corriendo en Amazon EKS."
echo ""

echo "============================================================="
echo " Continua con: cd ../etapa10-ConectividadURL"
echo "============================================================="
echo ""