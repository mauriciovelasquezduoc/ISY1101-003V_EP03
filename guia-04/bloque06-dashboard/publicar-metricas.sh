#!/usr/bin/env bash
# ============================================================
# Script para publicar metricas del pipeline CI/CD a CloudWatch
# Ejecutar despues de cada deploy exitoso
#
# Uso:
#   bash publicar-metricas.sh <service> <deploy_start> <deploy_end> <coverage> <status>
#
# Ejemplo:
#   bash publicar-metricas.sh backend 1718000000 1718000180 85 success
# ============================================================

set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
SERVICE="${1:-backend}"
DEPLOY_START="${2:-$(date -v-3M +%s 2>/dev/null || date -d '3 minutes ago' +%s)}"
DEPLOY_END="${3:-$(date +%s)}"
TEST_COVERAGE="${4:-0}"
DEPLOY_STATUS="${5:-success}"

echo "Publicando metricas para: $SERVICE"

DEPLOY_DURATION=$(( DEPLOY_END - DEPLOY_START ))

# Metrica 1: Tiempo de despliegue
aws cloudwatch put-metric-data \
  --namespace "Custom" \
  --metric-name "DeployDuration" \
  --dimensions "Service=${SERVICE}" \
  --value "$DEPLOY_DURATION" \
  --unit "Seconds" \
  --region "$REGION"
echo "  Tiempo de despliegue: ${DEPLOY_DURATION}s"

# Metrica 2: Cobertura de pruebas
if [ "$TEST_COVERAGE" -gt 0 ]; then
  aws cloudwatch put-metric-data \
    --namespace "Custom" \
    --metric-name "TestCoverage" \
    --dimensions "Project=${SERVICE}" \
    --value "$TEST_COVERAGE" \
    --unit "Percent" \
    --region "$REGION"
  echo "  Cobertura de pruebas: ${TEST_COVERAGE}%"
fi

# Metrica 3: Conteo de despliegues
aws cloudwatch put-metric-data \
  --namespace "Custom" \
  --metric-name "DeployCount" \
  --dimensions "Service=${SERVICE}" \
  --value 1 \
  --unit "Count" \
  --region "$REGION"
echo "  Despliegue registrado"

# Metrica 4: Estado del despliegue
if [ "$DEPLOY_STATUS" = "success" ]; then
  aws cloudwatch put-metric-data \
    --namespace "Custom" \
    --metric-name "DeploySuccess" \
    --dimensions "Service=${SERVICE}" \
    --value 1 \
    --unit "Count" \
    --region "$REGION"
  echo "  Estado: exitoso"
else
  aws cloudwatch put-metric-data \
    --namespace "Custom" \
    --metric-name "DeployFailure" \
    --dimensions "Service=${SERVICE}" \
    --value 1 \
    --unit "Count" \
    --region "$REGION"
  echo "  Estado: fallido"
fi

echo ""
echo "Metricas publicadas correctamente"
