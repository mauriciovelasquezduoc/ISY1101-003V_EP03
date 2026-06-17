#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Stress Test Real — Genera carga HTTP contra los servicios
# para que las metricas del dashboard se muevan.
#
# Opciones:
#   bash stress_test.sh                    # 60s, 50 workers, frontend
#   bash stress_test.sh backend 120 100    # 120s, 100 workers, backend
#
# Servicios: frontend (LoadBalancer), backend (port-forward)
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUIA04_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SECRETS_FILE="$GUIA04_DIR/secrets.txt"

REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="${EKS_CLUSTER_NAME:-laboratorio-ep03-eks}"
NAMESPACE="${K8S_NAMESPACE:-ep03}"

TARGET="${1:-frontend}"
DURATION="${2:-60}"
WORKERS="${3:-50}"
CONCURRENCY="${4:-10}"

if [ -f "$SECRETS_FILE" ]; then
  while IFS='=' read -r key value || [ -n "$key" ]; do
    [ -z "${key:-}" ] && continue
    [[ "$key" == \#* ]] && continue
    export "$key=$value"
  done < "$SECRETS_FILE"
  [ -n "${EKS_CLUSTER_NAME:-}" ] && CLUSTER_NAME="$EKS_CLUSTER_NAME"
  [ -n "${AWS_REGION:-}" ] && REGION="$AWS_REGION"
fi

echo ""
echo "============================================================="
echo " STRESS TEST EP03"
echo "============================================================="
echo ""
echo "  Servicio:    $TARGET"
echo "  Duracion:    ${DURATION}s"
echo "  Workers:     $WORKERS"
echo "  Concurrency: $CONCURRENCY por worker"
echo ""

# ----------------------------------------------------------
# Determinar URL target
# ----------------------------------------------------------
URL=""

if [ "$TARGET" = "frontend" ]; then
  echo "--- Obteniendo URL del LoadBalancer ---"
  for i in $(seq 1 30); do
    URL=$(kubectl get svc ep03-frontend -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    if [ -n "$URL" ]; then
      break
    fi
    printf "\r  esperando LoadBalancer... %d/30" "$i"
    sleep 5
  done
  echo ""

  if [ -z "$URL" ]; then
    echo "  ERROR: No se pudo obtener URL del LoadBalancer"
    kubectl get svc ep03-frontend -n "$NAMESPACE" 2>/dev/null
    exit 1
  fi
  URL="http://$URL"

elif [ "$TARGET" = "backend" ]; then
  echo "--- Configurando port-forward al backend ---"
  # Matar port-forward anterior si existe
  pkill -f "kubectl port-forward.*ep03-backend" 2>/dev/null || true
  sleep 1

  kubectl port-forward svc/ep03-backend -n "$NAMESPACE" 18080:8080 &
  PF_PID=$!
  sleep 3
  URL="http://localhost:18080"
  echo "  Port-forward activo (PID: $PF_PID)"
  echo "  URL: $URL"

elif [ "$TARGET" = "database" ]; then
  echo "--- Configurando port-forward a la database ---"
  pkill -f "kubectl port-forward.*ep03-database" 2>/dev/null || true
  sleep 1

  kubectl port-forward svc/ep03-database -n "$NAMESPACE" 15432:5432 &
  PF_PID=$!
  sleep 3
  URL="localhost:15432"
  echo "  Port-forward activo (PID: $PF_PID)"
  echo "  URL: $URL"

else
  echo "  ERROR: Servicio '$TARGET' no reconocido"
  echo "  Uso: bash stress_test.sh [frontend|backend|database] [duracion] [workers] [concurrency]"
  exit 1
fi

# ----------------------------------------------------------
# Preparar metricas de inicio en CloudWatch
# ----------------------------------------------------------
echo ""
echo "--- Publicando marca de inicio en CloudWatch ---"
DEPLOY_START=$(date +%s)

aws cloudwatch put-metric-data \
  --namespace "Custom" \
  --metric-name "StressTestActive" \
  --dimensions "Service=${TARGET}" \
  --value 1 \
  --unit "Count" \
  --region "$REGION" 2>/dev/null || true

# ----------------------------------------------------------
# Ejecutar carga real
# ----------------------------------------------------------
echo ""
echo "============================================================="
echo " INICIANDO CARGA — ${DURATION}s"
echo "============================================================="
echo ""
echo "  Target: $URL"
echo ""

# Archivos temporales para resultados
RESULT_DIR=$(mktemp -d)
TOTAL_REQUESTS=0
SUCCESS_REQUESTS=0
ERROR_REQUESTS=0
START_TIME=$(date +%s)

# Funcion de limpieza
cleanup() {
  echo ""
  echo "--- Limpiando ---"
  if [ -n "${PF_PID:-}" ]; then
    kill "$PF_PID" 2>/dev/null || true
    echo "  Port-forward detenido"
  fi
  rm -rf "$RESULT_DIR"
}
trap cleanup EXIT

# Lanzar workers
echo "  Lanzando $WORKERS workers..."
PIDS=()

for w in $(seq 1 "$WORKERS"); do
  (
    w_total=0
    w_ok=0
    w_err=0
    w_id=$w

    while true; do
      elapsed=$(($(date +%s) - START_TIME))
      if [ "$elapsed" -ge "$DURATION" ]; then
        break
      fi

      # Hacer requests con concurrencia interna
      for c in $(seq 1 "$CONCURRENCY"); do
        (
          CODE=$(curl -o /dev/null -s -w "%{http_code}" \
            --connect-timeout 3 \
            --max-time 10 \
            "$URL" 2>/dev/null || echo "000")
          echo "$CODE" >> "$RESULT_DIR/worker_${w_id}"
        ) &
      done

      # Pequena pausa para no saturar
      w_total=$((w_total + CONCURRENCY))
      sleep 0.1
    done

    # Contar resultados del worker
    if [ -f "$RESULT_DIR/worker_${w_id}" ]; then
      w_ok=$(grep -cE "^2[0-9][0-9]$" "$RESULT_DIR/worker_${w_id}" 2>/dev/null || echo "0")
      w_err=$(grep -cE "^[45][0-9][0-9]$|^000$" "$RESULT_DIR/worker_${w_id}" 2>/dev/null || echo "0")
    fi

    echo "$w_total $w_ok $w_err" > "$RESULT_DIR/summary_${w_id}"
  ) &
  PIDS+=($!)
done

# Barra de progreso
echo ""
while true; do
  elapsed=$(($(date +%s) - START_TIME))
  if [ "$elapsed" -ge "$DURATION" ]; then
    break
  fi
  bar_len=$((elapsed * 40 / DURATION))
  bar=$(printf '%0.s#' $(seq 1 $bar_len 2>/dev/null) || echo "")
  pad=$(printf '%0.s ' $(seq 1 $((40 - bar_len)) 2>/dev/null) || echo "")
  printf "\r  [%s%s] %3ds / %ds" "$bar" "$pad" "$elapsed" "$DURATION"
  sleep 1
done
printf "\r  [%s] %3ds / %3ds\n" "$(printf '%0.s#' $(seq 1 40))" "$DURATION" "$DURATION"

# Esperar workers
echo ""
echo "  Esperando workers..."
for pid in "${PIDS[@]}"; do
  wait "$pid" 2>/dev/null || true
done

# ----------------------------------------------------------
# Recopilar resultados
# ----------------------------------------------------------
echo ""
echo "============================================================="
echo " RESULTADOS"
echo "============================================================="
echo ""

TOTAL_REQUESTS=0
SUCCESS_REQUESTS=0
ERROR_REQUESTS=0

for f in "$RESULT_DIR"/summary_*; do
  if [ -f "$f" ]; then
    read -r t ok err < "$f"
    TOTAL_REQUESTS=$((TOTAL_REQUESTS + t))
    SUCCESS_REQUESTS=$((SUCCESS_REQUESTS + ok))
    ERROR_REQUESTS=$((ERROR_REQUESTS + err))
  fi
done

DEPLOY_END=$(date +%s)
ACTUAL_DURATION=$(( DEPLOY_END - DEPLOY_START ))

if [ "$TOTAL_REQUESTS" -gt 0 ]; then
  SUCCESS_RATE=$(( SUCCESS_REQUESTS * 100 / TOTAL_REQUESTS ))
  RPS=$(( TOTAL_REQUESTS / (ACTUAL_DURATION > 0 ? ACTUAL_DURATION : 1) ))
else
  SUCCESS_RATE=0
  RPS=0
fi

echo "  Duracion real:      ${ACTUAL_DURATION}s"
echo "  Total requests:     $TOTAL_REQUESTS"
echo "  Exitosos (2xx):     $SUCCESS_REQUESTS"
echo "  Errores (4xx/5xx):  $ERROR_REQUESTS"
echo "  Tasa de exito:      ${SUCCESS_RATE}%"
echo "  Requests/segundo:   $RPS"

# ----------------------------------------------------------
# Publicar metricas a CloudWatch
# ----------------------------------------------------------
echo ""
echo "--- Publicando metricas a CloudWatch ---"

# Tiempo de despliegue simulado (durante stress = "deploy" activo)
aws cloudwatch put-metric-data \
  --namespace "Custom" \
  --metric-name "DeployDuration" \
  --dimensions "Service=${TARGET}" \
  --value "$ACTUAL_DURATION" \
  --unit "Seconds" \
  --region "$REGION" 2>/dev/null && echo "  DeployDuration: ${ACTUAL_DURATION}s" || true

# Requests por segundo como metrica custom
aws cloudwatch put-metric-data \
  --namespace "Custom" \
  --metric-name "RequestsPerSecond" \
  --dimensions "Service=${TARGET}" \
  --value "$RPS" \
  --unit "Count/Second" \
  --region "$REGION" 2>/dev/null && echo "  RequestsPerSecond: $RPS" || true

# Tasa de exito
aws cloudwatch put-metric-data \
  --namespace "Custom" \
  --metric-name "SuccessRate" \
  --dimensions "Service=${TARGET}" \
  --value "$SUCCESS_RATE" \
  --unit "Percent" \
  --region "$REGION" 2>/dev/null && echo "  SuccessRate: ${SUCCESS_RATE}%" || true

# Total de requests
aws cloudwatch put-metric-data \
  --namespace "Custom" \
  --metric-name "TotalRequests" \
  --dimensions "Service=${TARGET}" \
  --value "$TOTAL_REQUESTS" \
  --unit "Count" \
  --region "$REGION" 2>/dev/null && echo "  TotalRequests: $TOTAL_REQUESTS" || true

# Marca de fin
aws cloudwatch put-metric-data \
  --namespace "Custom" \
  --metric-name "StressTestActive" \
  --dimensions "Service=${TARGET}" \
  --value 0 \
  --unit "Count" \
  --region "$REGION" 2>/dev/null || true

# ----------------------------------------------------------
# Estado post-stress del cluster
# ----------------------------------------------------------
echo ""
echo "============================================================="
echo " ESTADO POST-STRESS"
echo "============================================================="
echo ""
echo "--- HPA ---"
kubectl get hpa -n "$NAMESPACE" 2>/dev/null || echo "  (sin HPA)"
echo ""
echo "--- Pods ---"
kubectl get pods -n "$NAMESPACE" 2>/dev/null || echo "  (sin pods)"
echo ""
echo "--- Deployments ---"
kubectl get deployment -n "$NAMESPACE" -o wide 2>/dev/null || echo "  (sin deployments)"

# ----------------------------------------------------------
# Verificar escalamiento
# ----------------------------------------------------------
echo ""
echo "--- Verificando escalamiento ---"
for DEPLOY in ep03-backend ep03-frontend; do
  REPLICAS=$(kubectl get deployment "$DEPLOY" -n "$NAMESPACE" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || echo "0")
  DESIRED=$(kubectl get deployment "$DEPLOY" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
  echo "  $DEPLOY: replicas=$REPLICAS desired=$DESIRED"
done

# ----------------------------------------------------------
# Resumen
# ----------------------------------------------------------
echo ""
echo "============================================================="
echo " STRESS TEST COMPLETADO"
echo "============================================================="
echo ""
echo "  Metricas publicadas a CloudWatch:"
echo "    Custom/DeployDuration    ($TARGET) = ${ACTUAL_DURATION}s"
echo "    Custom/RequestsPerSecond ($TARGET) = $RPS"
echo "    Custom/SuccessRate       ($TARGET) = ${SUCCESS_RATE}%"
echo "    Custom/TotalRequests     ($TARGET) = $TOTAL_REQUESTS"
echo ""
echo "  Ve el dashboard en CloudWatch para ver los datos."
echo ""
echo "============================================================="
