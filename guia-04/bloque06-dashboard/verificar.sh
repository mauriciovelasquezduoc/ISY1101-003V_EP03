#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Verificacion del Dashboard de CloudWatch - EP03
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUIA04_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SECRETS_FILE="$GUIA04_DIR/secrets.txt"

REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="${EKS_CLUSTER_NAME:-laboratorio-ep03-eks}"
NAMESPACE="${K8S_NAMESPACE:-ep03}"
DASHBOARD_NAME="${CLUSTER_NAME}-observability"

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
echo "=========================================="
echo " VERIFICACION DEL DASHBOARD EP03"
echo "=========================================="
echo ""

# ----------------------------------------------------------
# 1) Verificar que el dashboard existe
# ----------------------------------------------------------
echo "--- 1. Verificando Dashboard ---"
DASHBOARD_EXISTS=$(aws cloudwatch get-dashboard \
  --dashboard-name "$DASHBOARD_NAME" \
  --region "$REGION" \
  --query 'DashboardName' \
  --output text 2>/dev/null || echo "")

if [ "$DASHBOARD_EXISTS" = "$DASHBOARD_NAME" ]; then
  echo "  Dashboard existe: $DASHBOARD_NAME"
  WIDGET_COUNT=$(aws cloudwatch get-dashboard \
    --dashboard-name "$DASHBOARD_NAME" \
    --region "$REGION" \
    --query 'DashboardBody' \
    --output text 2>/dev/null | \
    python3 -c "import sys,json; print(len(json.load(sys.stdin).get('widgets',[])))" 2>/dev/null || echo "0")
  echo "  Widgets: $WIDGET_COUNT"
else
  echo "  Dashboard no encontrado"
fi
echo ""

# ----------------------------------------------------------
# 2) Verificar metricas custom
# ----------------------------------------------------------
echo "--- 2. Verificando Metricas Custom ---"

for METRIC in DeployDuration TestCoverage DeployCount DeploySuccess DeployFailure; do
  FOUND=$(aws cloudwatch list-metrics \
    --namespace "Custom" \
    --metric-name "$METRIC" \
    --region "$REGION" \
    --query 'Metrics[].MetricName' \
    --output text 2>/dev/null || echo "")
  if [ -n "$FOUND" ]; then
    echo "  $METRIC: disponible"
  else
    echo "  $METRIC: no encontrada"
  fi
done
echo ""

# ----------------------------------------------------------
# 3) Verificar metricas de Container Insights
# ----------------------------------------------------------
echo "--- 3. Verificando Container Insights ---"
CI_METRICS=$(aws cloudwatch list-metrics \
  --namespace "ContainerInsights" \
  --dimensions "Name=ClusterName,Value=$CLUSTER_NAME" \
  --region "$REGION" \
  --query 'Metrics[].MetricName' \
  --output text 2>/dev/null || echo "")

if [ -n "$CI_METRICS" ]; then
  echo "  Container Insights: metricas disponibles"
  echo "$CI_METRICS" | tr '\t' '\n' | sort -u | head -5 | sed 's/^/    /'
else
  echo "  Container Insights: metricas pendientes (puede tardar en aparecer)"
fi
echo ""

# ----------------------------------------------------------
# 4) Verificar que los pods estan corriendo
# ----------------------------------------------------------
echo "--- 4. Verificando Pods en Cluster ---"
for POD_LABEL in ep03-backend ep03-frontend ep03-database; do
  POD_STATUS=$(kubectl get pods -n "$NAMESPACE" -l "app=$POD_LABEL" --no-headers 2>/dev/null | awk '{print $3}' | head -1 || echo "")
  if [ -n "$POD_STATUS" ]; then
    echo "  $POD_LABEL: $POD_STATUS"
  else
    echo "  $POD_LABEL: sin pods"
  fi
done
echo ""

# ----------------------------------------------------------
# 5) Verificar logs en CloudWatch
# ----------------------------------------------------------
echo "--- 5. Verificando Logs ---"
LOG_GROUP="/aws/eks/${CLUSTER_NAME}/application"
LOG_STREAMS=$(aws logs describe-log-streams \
  --log-group-name "$LOG_GROUP" \
  --order-by "LastEventTime" \
  --descending \
  --limit 3 \
  --region "$REGION" \
  --query 'logStreams[].logStreamName' \
  --output text 2>/dev/null || echo "")

if [ -n "$LOG_STREAMS" ]; then
  echo "  Logs disponibles:"
  echo "$LOG_STREAMS" | tr '\t' '\n' | head -3 | sed 's/^/    /'
else
  echo "  Logs: sin streams recientes"
fi
echo ""

# ----------------------------------------------------------
# 6) Resumen
# ----------------------------------------------------------
echo "=========================================="
echo " RESUMEN DE VERIFICACION"
echo "=========================================="
echo ""
echo "  DASHBOARD: https://${REGION}.console.aws.amazon.com/cloudwatch/home?region=${REGION}#dashboards:name=${DASHBOARD_NAME}"
echo ""
echo "  Metricas incluidas:"
echo "    Tiempo de despliegue (Custom/DeployDuration)"
echo "    Cobertura de pruebas (Custom/TestCoverage)"
echo "    Uso de CPU por pod (ContainerInsights)"
echo "    Uso de memoria por pod (ContainerInsights)"
echo "    Trafico de red (ContainerInsights)"
echo "    Errores en logs (AWS/Logs)"
echo "    Estado de pods (ContainerInsights)"
echo "    Alarmas activas (AWS/CloudWatch)"
echo "    Numero de despliegues (Custom/DeployCount)"
echo ""
echo "=========================================="
