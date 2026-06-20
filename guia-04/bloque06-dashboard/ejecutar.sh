#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUIA04_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SECRETS_FILE="$GUIA04_DIR/secrets.txt"

REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="${EKS_CLUSTER_NAME:-laboratorio-ep03-eks}"
NAMESPACE="${K8S_NAMESPACE:-ep03}"

if [ -f "$SECRETS_FILE" ]; then
  while IFS='=' read -r key value || [ -n "${key:-}" ]; do
    key="${key%$'\r'}"
    value="${value%$'\r'}"
    [ -z "$key" ] && continue
    [[ "$key" == \#* ]] && continue
    export "$key=$value"
  done < "$SECRETS_FILE"
  REGION="${AWS_REGION:-$REGION}"
  CLUSTER_NAME="${EKS_CLUSTER_NAME:-$CLUSTER_NAME}"
  NAMESPACE="${K8S_NAMESPACE:-$NAMESPACE}"
fi

DASHBOARD_NAME="${CLUSTER_NAME}-observability"
CLUSTER_LOG_GROUP="/aws/eks/${CLUSTER_NAME}/cluster"

echo "Creando dashboard: $DASHBOARD_NAME"

DASHBOARD_BODY=$(cat <<EOF
{
  "start": "-PT3H",
  "periodOverride": "inherit",
  "widgets": [
    {
      "type": "text",
      "x": 0, "y": 0, "width": 24, "height": 2,
      "properties": {
        "markdown": "# Observabilidad EKS — ${CLUSTER_NAME}\nNamespace: **${NAMESPACE}**. Compatible con AWS Academy: CPU, memoria y réplicas se publican desde kubectl en EP03/Kubernetes."
      }
    },
    {
      "type": "metric",
      "x": 0, "y": 2, "width": 8, "height": 6,
      "properties": {
        "title": "CPU por servicio (millicores)",
        "metrics": [
          ["EP03/Kubernetes", "CPUUsageMillicores", "Service", "backend", {"stat": "Average", "period": 60}],
          ["...", "frontend", {"stat": "Average", "period": 60}],
          ["...", "database", {"stat": "Average", "period": 60}]
        ],
        "view": "timeSeries", "region": "${REGION}", "period": 60, "stat": "Average"
      }
    },
    {
      "type": "metric",
      "x": 8, "y": 2, "width": 8, "height": 6,
      "properties": {
        "title": "Memoria por servicio (MiB)",
        "metrics": [
          ["EP03/Kubernetes", "MemoryWorkingSetMiB", "Service", "backend", {"stat": "Average", "period": 60}],
          ["...", "frontend", {"stat": "Average", "period": 60}],
          ["...", "database", {"stat": "Average", "period": 60}]
        ],
        "view": "timeSeries", "region": "${REGION}", "period": 60, "stat": "Average"
      }
    },
    {
      "type": "metric",
      "x": 16, "y": 2, "width": 8, "height": 6,
      "properties": {
        "title": "Réplicas disponibles",
        "metrics": [
          ["EP03/Kubernetes", "AvailableReplicas", "Service", "backend", {"stat": "Average", "period": 60}],
          ["...", "frontend", {"stat": "Average", "period": 60}],
          ["...", "database", {"stat": "Average", "period": 60}]
        ],
        "view": "timeSeries", "region": "${REGION}", "period": 60
      }
    },
    {
      "type": "metric",
      "x": 0, "y": 8, "width": 8, "height": 6,
      "properties": {
        "title": "Stress — Requests por segundo",
        "metrics": [
          ["Custom", "RequestsPerSecond", "Service", "frontend", {"stat": "Average", "period": 60}],
          ["...", "backend", {"stat": "Average", "period": 60}]
        ],
        "view": "timeSeries", "region": "${REGION}", "period": 60
      }
    },
    {
      "type": "metric",
      "x": 8, "y": 8, "width": 8, "height": 6,
      "properties": {
        "title": "Stress — Tasa de éxito (%)",
        "metrics": [
          ["Custom", "SuccessRate", "Service", "frontend", {"stat": "Average", "period": 60}],
          ["...", "backend", {"stat": "Average", "period": 60}]
        ],
        "view": "timeSeries", "region": "${REGION}", "period": 60,
        "yAxis": {"left": {"min": 0, "max": 100}}
      }
    },
    {
      "type": "metric",
      "x": 16, "y": 8, "width": 8, "height": 6,
      "properties": {
        "title": "Stress — Total de requests",
        "metrics": [
          ["Custom", "TotalRequests", "Service", "frontend", {"stat": "Sum", "period": 60}],
          ["...", "backend", {"stat": "Sum", "period": 60}]
        ],
        "view": "timeSeries", "region": "${REGION}", "period": 60
      }
    },
    {
      "type": "metric",
      "x": 0, "y": 14, "width": 8, "height": 6,
      "properties": {
        "title": "Duración de despliegue/stress (s)",
        "metrics": [
          ["Custom", "DeployDuration", "Service", "backend", {"stat": "Average", "period": 60}],
          ["...", "frontend", {"stat": "Average", "period": 60}],
          ["...", "database", {"stat": "Average", "period": 60}]
        ],
        "view": "timeSeries", "region": "${REGION}", "period": 60
      }
    },
    {
      "type": "metric",
      "x": 8, "y": 14, "width": 8, "height": 6,
      "properties": {
        "title": "Cobertura de pruebas (%)",
        "metrics": [
          ["Custom", "TestCoverage", "Project", "backend", {"stat": "Average", "period": 300}],
          ["...", "frontend", {"stat": "Average", "period": 300}],
          ["...", "database", {"stat": "Average", "period": 300}]
        ],
        "view": "timeSeries", "region": "${REGION}", "period": 300,
        "yAxis": {"left": {"min": 0, "max": 100}}
      }
    },
    {
      "type": "metric",
      "x": 16, "y": 14, "width": 8, "height": 6,
      "properties": {
        "title": "Número de despliegues",
        "metrics": [
          ["Custom", "DeployCount", "Service", "backend", {"stat": "Sum", "period": 300}],
          ["...", "frontend", {"stat": "Sum", "period": 300}],
          ["...", "database", {"stat": "Sum", "period": 300}]
        ],
        "view": "timeSeries", "region": "${REGION}", "period": 300, "stacked": true
      }
    },
    {
      "type": "metric",
      "x": 0, "y": 20, "width": 12, "height": 6,
      "properties": {
        "title": "Stress activo",
        "metrics": [
          ["Custom", "StressTestActive", "Service", "frontend", {"stat": "Maximum", "period": 60}],
          ["...", "backend", {"stat": "Maximum", "period": 60}]
        ],
        "view": "timeSeries", "region": "${REGION}", "period": 60
      }
    },
    {
      "type": "metric",
      "x": 12, "y": 20, "width": 12, "height": 6,
      "properties": {
        "title": "Volumen de logs del control plane",
        "metrics": [
          ["AWS/Logs", "IncomingBytes", "LogGroupName", "${CLUSTER_LOG_GROUP}", {"stat": "Sum", "period": 300}]
        ],
        "view": "timeSeries", "region": "${REGION}", "period": 300
      }
    },
    {
      "type": "log",
      "x": 0, "y": 26, "width": 24, "height": 6,
      "properties": {
        "title": "Errores recientes del control plane",
        "query": "SOURCE '${CLUSTER_LOG_GROUP}' | fields @timestamp, @logStream, @message | filter @message like /ERROR|Exception|error|failed/ | sort @timestamp desc | limit 50",
        "region": "${REGION}", "view": "table"
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

echo "Dashboard actualizado:"
echo "https://${REGION}.console.aws.amazon.com/cloudwatch/home?region=${REGION}#dashboards:name=${DASHBOARD_NAME}"
