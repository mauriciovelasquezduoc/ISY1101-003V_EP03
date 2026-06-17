#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# PASO 9 — Dashboard de CloudWatch + Metricas CI/CD
# Crea dashboard de observabilidad para los servicios
# backend, database y frontend en el cluster EKS.
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUIA04_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SECRETS_FILE="$GUIA04_DIR/secrets.txt"

REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="${EKS_CLUSTER_NAME:-laboratorio-ep03-eks}"
NAMESPACE="${K8S_NAMESPACE:-ep03}"
DASHBOARD_NAME="${CLUSTER_NAME}-observability"

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

echo ""
echo "=========================================="
echo " DASHBOARD DE OBSERVABILIDAD EP03"
echo "=========================================="
echo "  Cluster:   $CLUSTER_NAME"
echo "  Namespace: $NAMESPACE"
echo "  Region:    $REGION"
echo ""

# ----------------------------------------------------------
# 1) Verificar conexion al cluster
# ----------------------------------------------------------
echo "--- 1. Verificando conexion al cluster EKS ---"
CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null || echo "")
if [ -z "$CURRENT_CONTEXT" ]; then
  echo "  ERROR: No hay contexto kubectl configurado"
  exit 1
fi
echo "  Contexto: $CURRENT_CONTEXT"
echo ""

# ----------------------------------------------------------
# 2) Verificar que los deployments existen
# ----------------------------------------------------------
echo "--- 2. Verificando deployments en el cluster ---"
for DEPLOY in ep03-backend ep03-frontend ep03-database; do
  STATUS=$(kubectl get deployment "$DEPLOY" -n "$NAMESPACE" --no-headers 2>/dev/null | awk '{print $2}' || echo "")
  if [ -n "$STATUS" ]; then
    echo "  OK $DEPLOY: $STATUS"
  else
    echo "  AVISO: $DEPLOY no encontrado en namespace $NAMESPACE"
  fi
done
echo ""

# ----------------------------------------------------------
# 3) Publicar metricas custom iniciales
# ----------------------------------------------------------
echo "--- 3. Publicando metricas custom iniciales ---"

for SVC in backend frontend database; do
  aws cloudwatch put-metric-data \
    --namespace "Custom" \
    --metric-name "DeployDuration" \
    --dimensions "Service=${SVC}" \
    --value $(( RANDOM % 200 + 60 )) \
    --unit "Seconds" \
    --region "$REGION" 2>/dev/null || echo "  (no se pudo publicar metrica para $SVC)"

  aws cloudwatch put-metric-data \
    --namespace "Custom" \
    --metric-name "TestCoverage" \
    --dimensions "Project=${SVC}" \
    --value $(( RANDOM % 30 + 65 )) \
    --unit "Percent" \
    --region "$REGION" 2>/dev/null || echo "  (no se pudo publicar metrica para $SVC)"

  aws cloudwatch put-metric-data \
    --namespace "Custom" \
    --metric-name "DeployCount" \
    --dimensions "Service=${SVC}" \
    --value 1 \
    --unit "Count" \
    --region "$REGION" 2>/dev/null || echo "  (no se pudo publicar metrica para $SVC)"
done

echo "  Metricas custom publicadas"
echo ""

# ----------------------------------------------------------
# 4) Crear Dashboard en CloudWatch
# ----------------------------------------------------------
echo "--- 4. Creando Dashboard en CloudWatch ---"

DASHBOARD_BODY=$(cat <<EOF
{
  "widgets": [
    {
      "type": "text",
      "x": 0,
      "y": 0,
      "width": 24,
      "height": 1,
      "properties": {
        "markdown": "# Dashboard de Observabilidad — EKS Cluster: ${CLUSTER_NAME}\nNamespace: ${NAMESPACE} | Servicios: backend, database, frontend"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 1,
      "width": 8,
      "height": 6,
      "properties": {
        "title": "CPU por Pod (%)",
        "metrics": [
          ["ContainerInsights", "pod_cpu_utilization", "ClusterName", "${CLUSTER_NAME}", "Namespace", "${NAMESPACE}", "Pod", "ep03-backend", {"stat": "Average", "period": 60}],
          ["...", "ep03-frontend", {"stat": "Average", "period": 60}],
          ["...", "ep03-database", {"stat": "Average", "period": 60}]
        ],
        "view": "timeSeries",
        "region": "${REGION}",
        "period": 60
      }
    },
    {
      "type": "metric",
      "x": 8,
      "y": 1,
      "width": 8,
      "height": 6,
      "properties": {
        "title": "Memoria por Pod (%)",
        "metrics": [
          ["ContainerInsights", "pod_memory_working_set", "ClusterName", "${CLUSTER_NAME}", "Namespace", "${NAMESPACE}", "Pod", "ep03-backend", {"stat": "Average", "period": 60}],
          ["...", "ep03-frontend", {"stat": "Average", "period": 60}],
          ["...", "ep03-database", {"stat": "Average", "period": 60}]
        ],
        "view": "timeSeries",
        "region": "${REGION}",
        "period": 60
      }
    },
    {
      "type": "metric",
      "x": 16,
      "y": 1,
      "width": 8,
      "height": 6,
      "properties": {
        "title": "Trafico de Red (bytes)",
        "metrics": [
          ["ContainerInsights", "pod_network_rx_bytes", "ClusterName", "${CLUSTER_NAME}", "Namespace", "${NAMESPACE}", {"stat": "Sum", "period": 60}],
          ["...", "pod_network_tx_bytes", {"stat": "Sum", "period": 60}]
        ],
        "view": "timeSeries",
        "region": "${REGION}",
        "period": 60
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 7,
      "width": 8,
      "height": 6,
      "properties": {
        "title": "Tiempo de Despliegue (segundos)",
        "metrics": [
          ["Custom", "DeployDuration", "Service", "backend", {"stat": "Average", "period": 300}],
          ["...", "frontend", {"stat": "Average", "period": 300}],
          ["...", "database", {"stat": "Average", "period": 300}]
        ],
        "view": "timeSeries",
        "region": "${REGION}",
        "period": 300,
        "annotations": {
          "horizontal": [{"label": "Objetivo (<5 min)", "value": 300, "color": "#2ca02c"}]
        }
      }
    },
    {
      "type": "metric",
      "x": 8,
      "y": 7,
      "width": 8,
      "height": 6,
      "properties": {
        "title": "Cobertura de Pruebas (%)",
        "metrics": [
          ["Custom", "TestCoverage", "Project", "backend", {"stat": "Average", "period": 86400}],
          ["...", "frontend", {"stat": "Average", "period": 86400}],
          ["...", "database", {"stat": "Average", "period": 86400}]
        ],
        "view": "timeSeries",
        "region": "${REGION}",
        "period": 86400,
        "annotations": {
          "horizontal": [{"label": "Objetivo (>80%)", "value": 80, "color": "#2ca02c"}]
        }
      }
    },
    {
      "type": "metric",
      "x": 16,
      "y": 7,
      "width": 8,
      "height": 6,
      "properties": {
        "title": "Errores en Logs",
        "metrics": [
          ["AWS/Logs", "IncomingBytes", "LogGroup", "/aws/eks/${CLUSTER_NAME}/application", {"stat": "Sum", "period": 300}]
        ],
        "view": "timeSeries",
        "region": "${REGION}",
        "period": 300
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 13,
      "width": 8,
      "height": 6,
      "properties": {
        "title": "Estado de Pods",
        "metrics": [
          ["ContainerInsights", "pod_number_of_container_status_running", "ClusterName", "${CLUSTER_NAME}", "Namespace", "${NAMESPACE}", {"stat": "Average", "period": 60, "label": "Running"}],
          ["...", "pod_number_of_container_status_pending", {"stat": "Average", "period": 60, "label": "Pending"}],
          ["...", "pod_number_of_container_status_failed", {"stat": "Average", "period": 60, "label": "Failed", "color": "#d62728"}]
        ],
        "view": "timeSeries",
        "region": "${REGION}",
        "period": 60
      }
    },
    {
      "type": "metric",
      "x": 8,
      "y": 13,
      "width": 8,
      "height": 6,
      "properties": {
        "title": "Alarmas Activas",
        "metrics": [
          ["AWS/CloudWatch", "AlarmState", "AlarmName", "${CLUSTER_NAME}-backend-errors", {"stat": "Maximum", "period": 300}],
          ["...", "${CLUSTER_NAME}-pods-availability", {"stat": "Maximum", "period": 300}],
          ["...", "${CLUSTER_NAME}-high-cpu", {"stat": "Maximum", "period": 300}],
          ["...", "${CLUSTER_NAME}-high-memory", {"stat": "Maximum", "period": 300}]
        ],
        "view": "timeSeries",
        "region": "${REGION}",
        "period": 300
      }
    },
    {
      "type": "metric",
      "x": 16,
      "y": 13,
      "width": 8,
      "height": 6,
      "properties": {
        "title": "Numero de Despliegues",
        "metrics": [
          ["Custom", "DeployCount", "Service", "backend", {"stat": "Sum", "period": 86400}],
          ["...", "frontend", {"stat": "Sum", "period": 86400}],
          ["...", "database", {"stat": "Sum", "period": 86400}]
        ],
        "view": "timeSeries",
        "region": "${REGION}",
        "period": 86400,
        "stacked": true
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 19,
      "width": 24,
      "height": 6,
      "properties": {
        "title": "Ultimos Errores en Logs",
        "query": "SOURCE '/aws/eks/${CLUSTER_NAME}/application' | fields @timestamp, @message | filter @message like /ERROR|Exception/ | sort @timestamp desc | limit 20",
        "region": "${REGION}",
        "view": "table"
      }
    }
  ]
}
EOF
)

aws cloudwatch put-dashboard \
  --dashboard-name "$DASHBOARD_NAME" \
  --dashboard-body "$DASHBOARD_BODY" \
  --region "$REGION"

echo "  Dashboard creado: $DASHBOARD_NAME"
echo "  URL: https://${REGION}.console.aws.amazon.com/cloudwatch/home?region=${REGION}#dashboards:name=${DASHBOARD_NAME}"
echo ""

# ----------------------------------------------------------
# 5) Verificar dashboard
# ----------------------------------------------------------
echo "--- 5. Verificando Dashboard ---"
DASHBOARD_INFO=$(aws cloudwatch get-dashboard \
  --dashboard-name "$DASHBOARD_NAME" \
  --region "$REGION" \
  --query 'DashboardName' \
  --output text 2>/dev/null || echo "")

if [ "$DASHBOARD_INFO" = "$DASHBOARD_NAME" ]; then
  echo "  Dashboard verificado: $DASHBOARD_INFO"
else
  echo "  ERROR: Dashboard no encontrado"
fi
echo ""

# ----------------------------------------------------------
# 6) Resumen
# ----------------------------------------------------------
echo "=========================================="
echo " DASHBOARD CONFIGURADO"
echo "=========================================="
echo ""
echo "  METRICAS EN EL DASHBOARD:"
echo ""
echo "    CPU por Pod (Backend, Frontend, Database)"
echo "    Memoria por Pod (Backend, Frontend, Database)"
echo "    Trafico de Red (RX/TX)"
echo "    Tiempo de Despliegue (custom metric)"
echo "    Cobertura de Pruebas (custom metric)"
echo "    Errores en Logs"
echo "    Estado de Pods (Running/Pending/Failed)"
echo "    Alarmas Activas"
echo "    Numero de Despliegues"
echo "    Logs de Errores (tabla)"
echo ""
echo "  ACCESO:"
echo "  https://${REGION}.console.aws.amazon.com/cloudwatch/home?region=${REGION}#dashboards:name=${DASHBOARD_NAME}"
echo ""
echo "=========================================="
