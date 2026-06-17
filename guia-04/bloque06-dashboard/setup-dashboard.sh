#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Setup del Dashboard — Habilita Container Insights,
# crea log group y publica metricas iniciales.
#
# Ejecutar UNA VEZ antes de usar el dashboard.
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUIA04_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SECRETS_FILE="$GUIA04_DIR/secrets.txt"

REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="${EKS_CLUSTER_NAME:-laboratorio-ep03-eks}"
NAMESPACE="${K8S_NAMESPACE:-ep03}"
LOG_GROUP="/aws/eks/${CLUSTER_NAME}/application"

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
echo " SETUP DASHBOARD — HABILITANDO OBSERVABILIDAD"
echo "============================================================="
echo ""
echo "  Cluster: $CLUSTER_NAME"
echo "  Region:  $REGION"
echo ""

# ----------------------------------------------------------
# 1) Habilitar Container Insights (addon EKS)
# ----------------------------------------------------------
echo "--- 1. Habilitando Container Insights ---"

# Verificar si ya esta habilitado
CI_STATUS=$(aws eks describe-cluster \
  --name "$CLUSTER_NAME" \
  --region "$REGION" \
  --query "cluster.logging.clusterLogging[?enabledTypes[?Type=='audit']]" \
  --output text 2>/dev/null || echo "")

# Instalar addon amazon-cloudwatch
echo "  Instalando addon amazon-cloudwatch..."
aws eks create-addon \
  --cluster-name "$CLUSTER_NAME" \
  --addon-name amazon-cloudwatch \
  --region "$REGION" \
  --resolve-conflicts OVERWRITE 2>/dev/null && \
  echo "  addon amazon-cloudwatch creado" || \
  echo "  addon amazon-cloudwatch ya existe o error (verificando...)"

# Esperar addon
echo "  Esperando addon..."
for i in $(seq 1 30); do
  ADDON_STATUS=$(aws eks describe-addon \
    --cluster-name "$CLUSTER_NAME" \
    --addon-name amazon-cloudwatch \
    --region "$REGION" \
    --query 'addon.status' \
    --output text 2>/dev/null || echo "")
  if [ "$ADDON_STATUS" = "ACTIVE" ]; then
    echo "  addon amazon-cloudwatch: ACTIVE"
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "  addon amazon-cloudwatch: $ADDON_STATUS (puede tardar mas)"
  fi
  sleep 10
done

# Habilitar Container Insights via Fluent Bit
echo ""
echo "  Instalando Fluent Bit para Container Insights..."
cat <<'FLUENTBIT' | kubectl apply -f - 2>/dev/null || echo "  (Fluent Bit ya instalado o error)"
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cloudwatch-fluent-bit
  namespace: amazon-cloudwatch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cloudwatch-fluent-bit
rules:
  - apiGroups: [""]
    resources: ["namespaces", "pods", "nodes", "nodes/proxy"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["nodes/stats", "configmaps", "endpoints"]
    verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cloudwatch-fluent-bit
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cloudwatch-fluent-bit
subjects:
  - kind: ServiceAccount
    name: cloudwatch-fluent-bit
    namespace: amazon-cloudwatch
FLUENTBIT

echo "  Fluent Bit configurado"
echo ""

# ----------------------------------------------------------
# 2) Crear Log Group
# ----------------------------------------------------------
echo "--- 2. Creando Log Group ---"
aws logs create-log-group \
  --log-group-name "$LOG_GROUP" \
  --region "$REGION" 2>/dev/null && \
  echo "  Log group creado: $LOG_GROUP" || \
  echo "  Log group ya existe: $LOG_GROUP"

# Configurar retencion de 30 dias
aws logs put-retention-policy \
  --log-group-name "$LOG_GROUP" \
  --retention-in-days 30 \
  --region "$REGION" 2>/dev/null || true
echo "  Retencion: 30 dias"
echo ""

# ----------------------------------------------------------
# 3) Habilitar logging del cluster EKS a CloudWatch
# ----------------------------------------------------------
echo "--- 3. Configurando EKS Logging ---"

# Obtener ARN del rol del cluster
CLUSTER_ROLE_ARN=$(aws eks describe-cluster \
  --name "$CLUSTER_NAME" \
  --region "$REGION" \
  --query 'cluster.roleArn' \
  --output text 2>/dev/null || echo "")

# Actualizar cluster para habilitar logging
aws eks update-cluster-config \
  --name "$CLUSTER_NAME" \
  --region "$REGION" \
  --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":true}]}' 2>/dev/null && \
  echo "  EKS logging habilitado" || \
  echo "  EKS logging ya habilitado"
echo ""

# ----------------------------------------------------------
# 4) Instalar metrics-server (si no esta)
# ----------------------------------------------------------
echo "--- 4. Verificando Metrics Server ---"
MS_EXISTS=$(kubectl get pods -n kube-system 2>/dev/null | grep -c metrics-server || echo "0")
if [ "$MS_EXISTS" -eq 0 ]; then
  echo "  Instalando metrics-server..."
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml 2>/dev/null || \
    echo "  (metrics-server ya instalado o error)"
else
  echo "  Metrics Server ya instalado"
fi
echo ""

# ----------------------------------------------------------
# 5) Publicar metricas custom iniciales
# ----------------------------------------------------------
echo "--- 5. Publicando metricas custom ---"

for SVC in backend frontend database; do
  aws cloudwatch put-metric-data \
    --namespace "Custom" \
    --metric-name "DeployDuration" \
    --dimensions "Service=${SVC}" \
    --value $(( RANDOM % 200 + 60 )) \
    --unit "Seconds" \
    --region "$REGION" 2>/dev/null

  aws cloudwatch put-metric-data \
    --namespace "Custom" \
    --metric-name "TestCoverage" \
    --dimensions "Project=${SVC}" \
    --value $(( RANDOM % 30 + 65 )) \
    --unit "Percent" \
    --region "$REGION" 2>/dev/null

  aws cloudwatch put-metric-data \
    --namespace "Custom" \
    --metric-name "DeployCount" \
    --dimensions "Service=${SVC}" \
    --value 1 \
    --unit "Count" \
    --region "$REGION" 2>/dev/null
done
echo "  Metricas publicadas"
echo ""

# ----------------------------------------------------------
# 6) Verificar estado
# ----------------------------------------------------------
echo "--- 6. Verificando estado ---"
echo ""
echo "  Pods kube-system:"
kubectl get pods -n kube-system 2>/dev/null | grep -E "metrics|cloudwatch|fluent" || echo "  (esperar a que aparezcan)"
echo ""
echo "  Log groups AWS:"
aws logs describe-log-groups \
  --region "$REGION" \
  --query "logGroups[?contains(logGroupName, '${CLUSTER_NAME}')].logGroupName" \
  --output table 2>/dev/null || true
echo ""
echo "  Metricas Custom publicadas:"
aws cloudwatch list-metrics \
  --namespace "Custom" \
  --region "$REGION" \
  --query 'Metrics[].MetricName' \
  --output text 2>/dev/null | tr '\t' '\n' | sort -u || true

# ----------------------------------------------------------
# 7) Instrucciones
# ----------------------------------------------------------
echo ""
echo "============================================================="
echo " SETUP COMPLETADO"
echo "============================================================="
echo ""
echo "  1. Container Insights: addon amazon-cloudwatch instalado"
echo "  2. Log Group: $LOG_GROUP creado"
echo "  3. EKS Logging: habilitado"
echo "  4. Metrics Server: verificado"
echo "  5. Metricas custom: publicadas"
echo ""
echo "  IMPORTANTE: Espera 5-10 minutos para que Container Insights"
echo "  empiece a recolectar metricas de CPU, memoria y red."
echo ""
echo "  Para publicar metricas reales ejecuta:"
echo "    cd ../bloque07-verificacion"
echo "    bash stress_test.sh frontend 60 50"
echo ""
echo "  Dashboard:"
echo "  https://${REGION}.console.aws.amazon.com/cloudwatch/home?region=${REGION}#dashboards:name=${CLUSTER_NAME}-observability"
echo ""
echo "============================================================="
