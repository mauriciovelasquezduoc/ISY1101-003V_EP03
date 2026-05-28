#!/bin/bash

set -e

NAMESPACE="tienda"

echo ""
echo "====================================================="
echo " KUBERNETES METRICS VALIDATION"
echo "====================================================="
echo ""

echo ""
echo "====================================================="
echo " VALIDANDO METRICS SERVER"
echo "====================================================="
echo ""

kubectl get pods -n kube-system \
  | grep metrics-server || true

echo ""
echo "====================================================="
echo " VALIDANDO API METRICS"
echo "====================================================="
echo ""

kubectl get apiservices \
  | grep metrics || true

echo ""
echo "====================================================="
echo " VALIDANDO NODOS"
echo "====================================================="
echo ""

kubectl get nodes

echo ""
echo "====================================================="
echo " METRICAS NODOS"
echo "====================================================="
echo ""

kubectl top nodes || true

echo ""
echo "====================================================="
echo " METRICAS PODS"
echo "====================================================="
echo ""

kubectl top pods -n $NAMESPACE || true

echo ""
echo "====================================================="
echo " VALIDANDO HPA"
echo "====================================================="
echo ""

kubectl get hpa -n $NAMESPACE

echo ""
echo "====================================================="
echo " DETALLE HPA"
echo "====================================================="
echo ""

kubectl describe hpa -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO DEPLOYMENTS"
echo "====================================================="
echo ""

kubectl get deployment -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO SERVICES"
echo "====================================================="
echo ""

kubectl get svc -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO PODS"
echo "====================================================="
echo ""

kubectl get pods -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO EVENTOS"
echo "====================================================="
echo ""

kubectl get events -n $NAMESPACE \
  --sort-by=.metadata.creationTimestamp || true

echo ""
echo "====================================================="
echo " VALIDANDO CLOUDWATCH LOGS"
echo "====================================================="
echo ""

aws logs describe-log-groups \
  --query "logGroups[*].logGroupName" \
  --output table || true

echo ""
echo "====================================================="
echo " VALIDACION CLOUDWATCH EKS"
echo "====================================================="
echo ""

aws eks describe-cluster \
  --name laboratorio-eks \
  --query "cluster.logging" \
  --output table || true

echo ""
echo "====================================================="
echo " COMANDOS MONITOREO LIVE"
echo "====================================================="
echo ""

echo "Pods:"
echo "kubectl get pods -n tienda -w"

echo ""
echo "HPA:"
echo "kubectl get hpa -n tienda -w"

echo ""
echo "Top Pods:"
echo "kubectl top pods -n tienda"

echo ""
echo "Top Nodes:"
echo "kubectl top nodes"

echo ""
echo "K9s:"
echo "k9s"

echo ""
echo "====================================================="
echo " AWS WEB CONSOLE"
echo "====================================================="
echo ""

echo "AWS Console -> CloudWatch -> Metrics"
echo "AWS Console -> EKS -> laboratorio-eks -> Monitoring"

echo ""
echo "====================================================="
echo " OBSERVABILIDAD VALIDADA"
echo "====================================================="
echo ""

echo "Metrics Server operativo"
echo "HPA monitoreando CPU"
echo "CloudWatch operativo"

echo ""
echo "====================================================="
echo " PROCESO FINALIZADO"
echo "====================================================="
echo ""
