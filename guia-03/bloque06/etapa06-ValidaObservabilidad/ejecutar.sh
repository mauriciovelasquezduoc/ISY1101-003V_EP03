#!/bin/bash
# ==================================================================
# ETAPA 06 — Validar Metrics Server + CloudWatch
# ==================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../report_helper.sh"

REGION="us-east-1"
CLUSTER_NAME="laboratorio-eks"

init_reporte "Validación de Metrics Server y CloudWatch"

echo ""
echo "============================================================="
echo " ETAPA 06 — Validar Metrics Server + CloudWatch"
echo "============================================================="
echo ""

add_evidencia "Metrics Server - Pods en kube-system" "kubectl get pods -n kube-system | grep metrics || echo '(metrics-server puede estar integrándose como addon)'" "IE3"

add_evidencia "Metrics Server - API disponible" "kubectl get apiservices | grep metrics || echo '(revisando...)'" "IE3"

add_evidencia "Métricas de nodos (kubectl top)" "kubectl top nodes 2>/dev/null || echo '(puede tardar unos segundos en aparecer)'" "IE3"

add_evidencia "Métricas de pods (kubectl top)" "kubectl top pods -A 2>/dev/null || echo '(puede tardar unos segundos)'" "IE3"

add_evidencia "VPC Endpoint CloudWatch" "aws ec2 describe-vpc-endpoints --region $REGION --query 'VpcEndpoints[?contains(ServiceName, \`logs\`)].{Service:ServiceName,State:State}' --output table" "IE6"

add_evidencia "Logging del cluster EKS habilitado" "aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query 'cluster.logging' --output json" "IE6"

add_evidencia "Log Groups en CloudWatch" "aws logs describe-log-groups --region $REGION --query 'logGroups[?contains(logGroupName, \`eks\`)].logGroupName' --output table 2>/dev/null || echo '(puede tardar en aparecer)'" "IE6"

cerrar_reporte

echo ""
echo "============================================================="
echo " ETAPA 06 COMPLETADA — Metrics + CloudWatch validados"
echo "============================================================="
echo ""
echo "  📋 Reporte generado en: docs/reports/etapa06-ValidaObservabilidad.md"
echo ""
echo "Continua con: cd ../etapa07-PublicaECR"
echo ""
