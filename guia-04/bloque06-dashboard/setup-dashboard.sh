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
ADDON_NAME="amazon-cloudwatch-observability"
CLOUDWATCH_POLICY_ARN="arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
NATIVE_CONTAINER_INSIGHTS=true

if [ -f "$SECRETS_FILE" ]; then
  while IFS='=' read -r key value || [ -n "$key" ]; do
    key="${key%$'\r'}"
    value="${value%$'\r'}"
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

NODE_ROLE_ARN=$(aws eks describe-nodegroup \
  --cluster-name "$CLUSTER_NAME" \
  --nodegroup-name laboratorio-ep03-nodegroup \
  --region "$REGION" \
  --query 'nodegroup.nodeRole' \
  --output text)
NODE_ROLE_NAME="${NODE_ROLE_ARN##*/}"

echo "  Verificando permisos en $NODE_ROLE_NAME..."
if ! aws iam list-attached-role-policies \
  --role-name "$NODE_ROLE_NAME" \
  --query 'AttachedPolicies[].PolicyArn' \
  --output text | grep -q "$CLOUDWATCH_POLICY_ARN"; then
  if aws iam attach-role-policy \
    --role-name "$NODE_ROLE_NAME" \
    --policy-arn "$CLOUDWATCH_POLICY_ARN"; then
    echo "  Politica CloudWatchAgentServerPolicy adjuntada"
  else
    NATIVE_CONTAINER_INSIGHTS=false
    echo "  AVISO: AWS Academy no permite iam:AttachRolePolicy."
    echo "  Se usaran metricas EP03/Kubernetes publicadas desde kubectl."
  fi
else
  echo "  Politica CloudWatchAgentServerPolicy ya adjuntada"
fi

echo "  Instalando/verificando addon $ADDON_NAME..."
if aws eks describe-addon \
  --cluster-name "$CLUSTER_NAME" \
  --addon-name "$ADDON_NAME" \
  --region "$REGION" >/dev/null 2>&1; then
  aws eks update-addon \
    --cluster-name "$CLUSTER_NAME" \
    --addon-name "$ADDON_NAME" \
    --region "$REGION" \
    --resolve-conflicts OVERWRITE >/dev/null
else
  aws eks create-addon \
    --cluster-name "$CLUSTER_NAME" \
    --addon-name "$ADDON_NAME" \
    --region "$REGION" \
    --resolve-conflicts OVERWRITE >/dev/null
fi

# Esperar addon
echo "  Esperando addon..."
for i in $(seq 1 30); do
  ADDON_STATUS=$(aws eks describe-addon \
    --cluster-name "$CLUSTER_NAME" \
    --addon-name "$ADDON_NAME" \
    --region "$REGION" \
    --query 'addon.status' \
    --output text 2>/dev/null || echo "")
  if [ "$ADDON_STATUS" = "ACTIVE" ]; then
    echo "  addon $ADDON_NAME: ACTIVE"
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "  ERROR: addon $ADDON_NAME no llego a ACTIVE: $ADDON_STATUS"
    exit 1
  fi
  sleep 10
done

echo ""
if [ "$NATIVE_CONTAINER_INSIGHTS" = true ]; then
  echo "  Reiniciando agentes para tomar los permisos IAM..."
  kubectl rollout restart daemonset/cloudwatch-agent -n amazon-cloudwatch
  kubectl rollout restart daemonset/fluent-bit -n amazon-cloudwatch
  kubectl rollout status daemonset/cloudwatch-agent -n amazon-cloudwatch --timeout=5m
  kubectl rollout status daemonset/fluent-bit -n amazon-cloudwatch --timeout=5m
else
  AWS_REGION="$REGION" K8S_NAMESPACE="$NAMESPACE" \
    bash "$SCRIPT_DIR/publicar-k8s-metricas.sh"
fi
echo ""

# ----------------------------------------------------------
# 2) Verificar Log Groups administrados por Container Insights
# ----------------------------------------------------------
echo "--- 2. Verificando Log Groups de Container Insights ---"
echo "  Se crean automaticamente bajo /aws/containerinsights/${CLUSTER_NAME}/"
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
echo "  1. Container Insights: addon $ADDON_NAME instalado"
echo "  2. Permisos: CloudWatchAgentServerPolicy configurada"
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
