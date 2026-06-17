#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# PASO 10 — Verificacion integral de Operacion Avanzada
# Ejecuta las 4 pruebas de validacion del cluster:
#   1. HPA (escalado automatico)
#   2. Stress Test (carga al frontend)
#   3. Auto-Healing (recuperacion de pods)
#   4. Metricas y Observabilidad
#
# Genera reporte en reports/verificacion-YYYYMMDD-HHMMSS.md
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUIA04_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPORT_DIR="$SCRIPT_DIR/reports"
SECRETS_FILE="$GUIA04_DIR/secrets.txt"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_FILE="$REPORT_DIR/verificacion-$TIMESTAMP.md"

REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="${EKS_CLUSTER_NAME:-laboratorio-ep03-eks}"
NAMESPACE="${K8S_NAMESPACE:-ep03}"
STRESS_DURATION="${STRESS_DURATION:-60}"
STRESS_WORKERS="${STRESS_WORKERS:-30}"

mkdir -p "$REPORT_DIR"

# Cargar secrets.txt si existe
if [ -f "$SECRETS_FILE" ]; then
  while IFS='=' read -r key value || [ -n "$key" ]; do
    [ -z "${key:-}" ] && continue
    [[ "$key" == \#* ]] && continue
    export "$key=$value"
  done < "$SECRETS_FILE"
  [ -n "${EKS_CLUSTER_NAME:-}" ] && CLUSTER_NAME="$EKS_CLUSTER_NAME"
  [ -n "${AWS_REGION:-}" ] && REGION="$AWS_REGION"
fi

# Variables de reporte
REPORT_LINES=()
STEP_RESULTS=()
OVERALL_STATUS="OK"

add_report() { REPORT_LINES+=("$*"); }
record_step() {
  local name="$1" status="$2" detail="$3"
  STEP_RESULTS+=("| $name | $status | $detail |")
  if [ "$status" = "FALLA" ]; then OVERALL_STATUS="FALLA"; fi
}

banner() {
  echo ""
  echo "=========================================="
  echo " $1"
  echo "=========================================="
  echo ""
}

log() { echo "[$(date '+%H:%M:%S')] $*"; }

# ----------------------------------------------------------
# INICIO
# ----------------------------------------------------------
echo ""
echo "============================================================="
echo " VERIFICACION INTEGRAL — OPERACION AVANZADA EP03"
echo "============================================================="
echo ""
echo "  Cluster:   $CLUSTER_NAME"
echo "  Namespace: $NAMESPACE"
echo "  Region:    $REGION"
echo "  Reporte:   $REPORT_FILE"
echo ""

add_report "# Reporte de Verificacion Integral"
add_report ""
add_report "Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
add_report "Cluster: \`$CLUSTER_NAME\`"
add_report "Namespace: \`$NAMESPACE\`"
add_report "Region: \`$REGION\`"
add_report ""
add_report "## Resumen"
add_report ""
add_report "| Prueba | Estado | Detalle |"
add_report "|--------|--------|---------|"

# ============================================================
# PRUEBA 1: HPA — Escalado automatico
# ============================================================
banner "PRUEBA 1/4: HPA — ESCALADO AUTOMATICO"

HPA_OK=true
HPA_DETAIL=""

# 1.1 Metrics Server
log "Verificando Metrics Server..."
MS_STATUS=$(kubectl get pods -n kube-system 2>/dev/null | grep metrics-server | awk '{print $3}' || echo "")
if [ -n "$MS_STATUS" ]; then
  echo "  Metrics Server: $MS_STATUS"
else
  echo "  Metrics Server: no encontrado"
  HPA_OK=false
fi

# 1.2 API metrics
log "Verificando API metrics.k8s.io..."
API_READY=false
for i in $(seq 1 15); do
  if kubectl get apiservices 2>/dev/null | grep -q "metrics.k8s.io.*True"; then
    API_READY=true
    break
  fi
  sleep 2
done
if [ "$API_READY" = true ]; then
  echo "  API metrics.k8s.io: disponible"
else
  echo "  API metrics.k8s.io: no disponible"
  HPA_OK=false
fi

# 1.3 HPA configurados
log "Verificando HPA en namespace $NAMESPACE..."
HPA_COUNT=$(kubectl get hpa -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l | xargs)
echo "  HPA encontrados: $HPA_COUNT"
kubectl get hpa -n "$NAMESPACE" 2>/dev/null || echo "  (no hay HPA)"

if [ "$HPA_COUNT" -lt 2 ]; then
  echo "  AVISO: Se esperaban al menos 2 HPA (backend + frontend)"
  HPA_OK=false
fi

# 1.4 Pods backend running
log "Verificando pods backend..."
BACKEND_READY=$(kubectl get pods -n "$NAMESPACE" -l app=ep03-backend --no-headers 2>/dev/null | grep -c "Running" || echo "0")
FRONTEND_READY=$(kubectl get pods -n "$NAMESPACE" -l app=ep03-frontend --no-headers 2>/dev/null | grep -c "Running" || echo "0")
DATABASE_READY=$(kubectl get pods -n "$NAMESPACE" -l app=ep03-database --no-headers 2>/dev/null | grep -c "Running" || echo "0")
echo "  Pods Running: backend=$BACKEND_READY frontend=$FRONTEND_READY database=$DATABASE_READY"

if [ "$HPA_OK" = true ]; then
  record_step "HPA" "OK" "Metrics Server OK, API OK, $HPA_COUNT HPA configurados"
  HPA_DETAIL="HPA funcionando correctamente"
else
  record_step "HPA" "FALLA" "Revise Metrics Server o HPA"
  HPA_DETAIL="HPA con problemas"
fi

# ============================================================
# PRUEBA 2: STRESS TEST — Carga al frontend
# ============================================================
banner "PRUEBA 2/4: STRESS TEST — CARGA AL FRONTEND"

STRESS_OK=true
STRESS_DETAIL=""

# 2.1 Obtener URL del frontend
log "Obteniendo URL del LoadBalancer..."
FRONTEND_URL=""
for i in $(seq 1 30); do
  FRONTEND_URL=$(kubectl get svc ep03-frontend -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
  if [ -n "$FRONTEND_URL" ]; then
    break
  fi
  sleep 5
done

if [ -z "$FRONTEND_URL" ]; then
  echo "  No se pudo obtener URL del LoadBalancer"
  echo "  Service ep03-frontend:"
  kubectl get svc ep03-frontend -n "$NAMESPACE" 2>/dev/null || echo "  (no encontrado)"
  STRESS_OK=false
  STRESS_DETAIL="LoadBalancer no disponible"
  record_step "Stress Test" "FALLA" "LoadBalancer no disponible"
else
  echo "  URL: http://$FRONTEND_URL"

  # 2.2 Ejecutar carga por tiempo limitado
  log "Ejecutando stress test por $STRESS_DURATION segundos con $STRESS_WORKERS workers..."
  echo "  Iniciando carga..."

  PIDS=()
  TOTAL_REQUESTS=0
  SUCCESS_REQUESTS=0

  END_TIME=$((SECONDS + STRESS_DURATION))

  for i in $(seq 1 "$STRESS_WORKERS"); do
    (
      count=0
      ok=0
      while [ $SECONDS -lt $END_TIME ]; do
        CODE=$(curl -o /dev/null -s -w "%{http_code}" --connect-timeout 5 --max-time 10 "http://$FRONTEND_URL" 2>/dev/null || echo "000")
        count=$((count + 1))
        if [ "$CODE" -ge 200 ] && [ "$CODE" -lt 400 ]; then
          ok=$((ok + 1))
        fi
      done
      echo "$count $ok" > "/tmp/stress_$i"
    ) &
    PIDS+=($!)
  done

  # Esperar a que terminen
  for pid in "${PIDS[@]}"; do
    wait "$pid" 2>/dev/null || true
  done

  # Recopilar resultados
  for i in $(seq 1 "$STRESS_WORKERS"); do
    if [ -f "/tmp/stress_$i" ]; then
      READ_TOTAL=$(awk '{print $1}' "/tmp/stress_$i" 2>/dev/null || echo "0")
      READ_OK=$(awk '{print $2}' "/tmp/stress_$i" 2>/dev/null || echo "0")
      TOTAL_REQUESTS=$((TOTAL_REQUESTS + READ_TOTAL))
      SUCCESS_REQUESTS=$((SUCCESS_REQUESTS + READ_OK))
      rm -f "/tmp/stress_$i"
    fi
  done

  if [ "$TOTAL_REQUESTS" -gt 0 ]; then
    SUCCESS_RATE=$(( SUCCESS_REQUESTS * 100 / TOTAL_REQUESTS ))
    echo ""
    echo "  Resultados del stress test:"
    echo "    Duracion:        ${STRESS_DURATION}s"
    echo "    Workers:         $STRESS_WORKERS"
    echo "    Total requests:  $TOTAL_REQUESTS"
    echo "    Exitosos:        $SUCCESS_REQUESTS"
    echo "    Tasa de exito:   ${SUCCESS_RATE}%"

    if [ "$SUCCESS_RATE" -ge 90 ]; then
      record_step "Stress Test" "OK" "${TOTAL_REQUESTS} requests, ${SUCCESS_RATE}% exito"
      STRESS_DETAIL="Tasa de exito: ${SUCCESS_RATE}%"
    else
      record_step "Stress Test" "AVISO" "${TOTAL_REQUESTS} requests, ${SUCCESS_RATE}% exito (bajo)"
      STRESS_DETAIL="Tasa de exito baja: ${SUCCESS_RATE}%"
      STRESS_OK=false
    fi
  else
    record_step "Stress Test" "FALLA" "No se completaron requests"
    STRESS_DETAIL="Sin requests exitosos"
    STRESS_OK=false
  fi

  # Verificar si hubo escalamiento
  echo ""
  echo "  Estado post-stress:"
  kubectl get hpa -n "$NAMESPACE" 2>/dev/null || true
  kubectl get pods -n "$NAMESPACE" 2>/dev/null || true
fi

# ============================================================
# PRUEBA 3: AUTO-HEALING — Recuperacion de pods
# ============================================================
banner "PRUEBA 3/4: AUTO-HEALING — RECUPERACION DE PODS"

HEALING_OK=true
HEALING_DETAIL=""

# 3.1 Seleccionar pod backend
log "Seleccionando pod backend para prueba de healing..."
BACKEND_POD=$(kubectl get pods -n "$NAMESPACE" \
  -l app=ep03-backend \
  --no-headers 2>/dev/null \
  | grep "Running" \
  | awk '{print $1}' \
  | head -n 1)

if [ -z "$BACKEND_POD" ]; then
  echo "  No se encontro pod backend Running"
  HEALING_OK=false
  HEALING_DETAIL="Sin pods backend Running"
  record_step "Auto-Healing" "FALLA" "Sin pods backend Running"
else
  echo "  Pod seleccionado: $BACKEND_POD"

  # 3.2 Estado antes
  echo ""
  echo "  Estado ANTES de eliminar:"
  REPLICAS_BEFORE=$(kubectl get deployment ep03-backend -n "$NAMESPACE" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || echo "0")
  echo "    Replicas disponibles: $REPLICAS_BEFORE"

  # 3.3 Eliminar pod
  log "Eliminando pod $BACKEND_POD..."
  kubectl delete pod "$BACKEND_POD" -n "$NAMESPACE" 2>/dev/null
  echo "  Pod eliminado: $BACKEND_POD"

  # 3.4 Esperar recreacion
  log "Esperando recreacion del pod..."
  NEW_POD=""
  for i in $(seq 1 30); do
    sleep 5
    NEW_POD=$(kubectl get pods -n "$NAMESPACE" \
      -l app=ep03-backend \
      --no-headers 2>/dev/null \
      | grep "Running" \
      | awk '{print $1}' \
      | grep -v "$BACKEND_POD" \
      | head -n 1)
    if [ -n "$NEW_POD" ]; then
      break
    fi
    printf "\r    esperando recreacion... intento %d/30" "$i"
  done
  echo ""

  if [ -n "$NEW_POD" ]; then
    echo "  Nuevo pod: $NEW_POD"

    # 3.5 Verificar estado
    echo ""
    echo "  Estado DESPUES de recrear:"
    REPLICAS_AFTER=$(kubectl get deployment ep03-backend -n "$NAMESPACE" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || echo "0")
    echo "    Replicas disponibles: $REPLICAS_AFTER"

    echo ""
    echo "  Pods actuales:"
    kubectl get pods -n "$NAMESPACE" -l app=ep03-backend 2>/dev/null

    echo ""
    echo "  Eventos recientes:"
    kubectl get events -n "$NAMESPACE" --sort-by=.metadata.creationTimestamp 2>/dev/null | tail -10

    if [ "$REPLICAS_AFTER" -ge "$REPLICAS_BEFORE" ]; then
      record_step "Auto-Healing" "OK" "Pod $BACKEND_POD eliminado, recreado como $NEW_POD"
      HEALING_DETAIL="Recreacion exitosa en <150s"
    else
      record_step "Auto-Healing" "AVISO" "Pod recreado pero replicas incompleto ($REPLICAS_BEFORE -> $REPLICAS_AFTER)"
      HEALING_DETAIL="Recreacion parcial"
      HEALING_OK=false
    fi
  else
    record_step "Auto-Healing" "FALLA" "Pod no fue recreado en 150s"
    HEALING_DETAIL="Recreacion fallida"
    HEALING_OK=false
  fi
fi

# ============================================================
# PRUEBA 4: METRICAS Y OBSERVABILIDAD
# ============================================================
banner "PRUEBA 4/4: METRICAS Y OBSERVABILIDAD"

METRICAS_OK=true
METRICAS_DETAIL=""

# 4.1 Metricas de nodos
log "Verificando metricas de nodos..."
echo "  Nodos:"
kubectl get nodes -o wide 2>/dev/null || echo "  (no se pudieron obtener nodos)"

echo ""
echo "  Metricas de nodos:"
for i in $(seq 1 5); do
  if kubectl top nodes 2>/dev/null; then
    break
  fi
  sleep 3
done

# 4.2 Metricas de pods
log "Verificando metricas de pods..."
echo ""
echo "  Metricas de pods en $NAMESPACE:"
for i in $(seq 1 5); do
  if kubectl top pods -n "$NAMESPACE" 2>/dev/null; then
    break
  fi
  sleep 3
done

# 4.3 Estado del cluster
echo ""
echo "  Estado del cluster:"
echo "    --- Deployments ---"
kubectl get deployment -n "$NAMESPACE" 2>/dev/null || echo "    (no disponibles)"
echo ""
echo "    --- Services ---"
kubectl get svc -n "$NAMESPACE" 2>/dev/null || echo "    (no disponibles)"
echo ""
echo "    --- Pods ---"
kubectl get pods -n "$NAMESPACE" 2>/dev/null || echo "    (no disponibles)"

# 4.4 CloudWatch
echo ""
echo "  CloudWatch Log Groups:"
aws logs describe-log-groups \
  --region "$REGION" \
  --query "logGroups[?contains(logGroupName, 'eks')].logGroupName" \
  --output table 2>/dev/null || echo "  (no se pudieron obtener log groups)"

echo ""
echo "  EKS Logging Config:"
aws eks describe-cluster \
  --name "$CLUSTER_NAME" \
  --region "$REGION" \
  --query "cluster.logging" \
  --output table 2>/dev/null || echo "  (no se pudo obtener config)"

# 4.5 Resumen metricas
echo ""
MS_STATUS_FINAL=$(kubectl get pods -n kube-system 2>/dev/null | grep metrics-server | awk '{print $3}' || echo "N/A")
HPA_COUNT_FINAL=$(kubectl get hpa -n "$NAMESPACE" 2>/dev/null | tail -n +2 | wc -l | xargs)
POD_COUNT_FINAL=$(kubectl get pods -n "$NAMESPACE" 2>/dev/null | tail -n +2 | wc -l | xargs)
NODE_COUNT_FINAL=$(kubectl get nodes 2>/dev/null | tail -n +2 | wc -l | xargs)

echo "  Resumen de Observabilidad:"
echo "    Metrics Server:    $MS_STATUS_FINAL"
echo "    HPA configurados:  $HPA_COUNT_FINAL"
echo "    Pods totales:      $POD_COUNT_FINAL"
echo "    Nodos disponibles: $NODE_COUNT_FINAL"

METRICAS_DETAIL="MS=$MS_STATUS_FINAL, HPA=$HPA_COUNT_FINAL, Pods=$POD_COUNT_FINAL, Nodes=$NODE_COUNT_FINAL"
record_step "Metricas" "OK" "$METRICAS_DETAIL"

# ============================================================
# GENERAR REPORTE
# ============================================================
add_report ""
for line in "${STEP_RESULTS[@]}"; do add_report "$line"; done

add_report ""
add_report "## Detalle por Prueba"
add_report ""
add_report "### 1. HPA (Escalado Automatico)"
add_report ""
add_report "- Metrics Server: \`$MS_STATUS_FINAL\`"
add_report "- API metrics.k8s.io: $( [ "$API_READY" = true ] && echo "disponible" || echo "no disponible" )"
add_report "- HPA configurados: \`$HPA_COUNT_FINAL\`"
add_report "- Pods backend Running: \`$BACKEND_READY\`"
add_report "- Pods frontend Running: \`$FRONTEND_READY\`"
add_report "- Pods database Running: \`$DATABASE_READY\`"
add_report ""

add_report "### 2. Stress Test"
add_report ""
if [ -n "$FRONTEND_URL" ]; then
  add_report "- URL: \`http://$FRONTEND_URL\`"
  add_report "- Workers: \`$STRESS_WORKERS\`"
  add_report "- Duracion: \`${STRESS_DURATION}s\`"
  add_report "- Total requests: \`$TOTAL_REQUESTS\`"
  add_report "- Exitosos: \`$SUCCESS_REQUESTS\`"
  add_report "- Tasa de exito: \`${SUCCESS_RATE:-0}%\`"
else
  add_report "- Estado: LoadBalancer no disponible"
fi
add_report ""

add_report "### 3. Auto-Healing"
add_report ""
if [ -n "${BACKEND_POD:-}" ]; then
  add_report "- Pod eliminado: \`$BACKEND_POD\`"
  add_report "- Pod recreado: \`${NEW_POD:-no recreado}\`"
  add_report "- Replicas antes: \`$REPLICAS_BEFORE\`"
  add_report "- Replicas despues: \`${REPLICAS_AFTER:-N/A}\`"
else
  add_report "- Estado: Sin pods backend para probar"
fi
add_report ""

add_report "### 4. Metricas y Observabilidad"
add_report ""
add_report "- Metrics Server: \`$MS_STATUS_FINAL\`"
add_report "- HPA configurados: \`$HPA_COUNT_FINAL\`"
add_report "- Pods totales: \`$POD_COUNT_FINAL\`"
add_report "- Nodos: \`$NODE_COUNT_FINAL\`"
add_report ""

add_report "## Comandos de Evidencia"
add_report ""
add_report "\`\`\`bash"
add_report "kubectl get nodes -o wide"
add_report "kubectl get pods -n $NAMESPACE"
add_report "kubectl get hpa -n $NAMESPACE"
add_report "kubectl top nodes"
add_report "kubectl top pods -n $NAMESPACE"
add_report "kubectl get events -n $NAMESPACE --sort-by=.metadata.creationTimestamp | tail -20"
add_report "aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query 'cluster.logging' --output table"
add_report "\`\`\`"

{
  printf '%s\n' "${REPORT_LINES[@]}"
} > "$REPORT_FILE"

# ============================================================
# RESUMEN FINAL
# ============================================================
echo ""
echo "============================================================="
echo " RESUMEN DE VERIFICACION INTEGRAL"
echo "============================================================="
echo ""
echo "  HPA:          ${STEP_RESULTS[0]}"
echo "  Stress Test:  ${STEP_RESULTS[1]}"
echo "  Auto-Healing: ${STEP_RESULTS[2]}"
echo "  Metricas:     ${STEP_RESULTS[3]}"
echo ""
echo "  Estado general: $OVERALL_STATUS"
echo ""
echo "  Reporte: $REPORT_FILE"
echo ""
echo "============================================================="
echo " VERIFICACION COMPLETADA"
echo "============================================================="
echo ""
