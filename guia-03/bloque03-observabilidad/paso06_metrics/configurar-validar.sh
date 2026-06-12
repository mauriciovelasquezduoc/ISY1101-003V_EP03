#!/bin/bash

set -e

echo ""
echo "====================================================="
echo " VALIDANDO METRICS SERVER"
echo "====================================================="
echo ""

echo ""
echo "====================================================="
echo " VALIDANDO NODOS"
echo "====================================================="
echo ""

kubectl get nodes

echo ""
echo "====================================================="
echo " VALIDANDO PODS METRICS SERVER"
echo "====================================================="
echo ""

kubectl get pods -n kube-system | grep metrics || true

echo ""
echo "====================================================="
echo " VALIDANDO DEPLOYMENT"
echo "====================================================="
echo ""

kubectl get deployment metrics-server -n kube-system || true

echo ""
echo "====================================================="
echo " VALIDANDO METRICS API"
echo "====================================================="
echo ""

kubectl get apiservices | grep metrics || true

echo ""
echo "====================================================="
echo " VALIDANDO METRICAS NODOS"
echo "====================================================="
echo ""

kubectl top nodes || true

echo ""
echo "====================================================="
echo " VALIDANDO METRICAS PODS"
echo "====================================================="
echo ""

kubectl top pods -A || true

echo ""
echo "====================================================="
echo " VALIDANDO LOGS METRICS SERVER"
echo "====================================================="
echo ""

kubectl logs -n kube-system deployment/metrics-server --tail=20 || true

echo ""
echo "====================================================="
echo " VALIDACION COMPLETA"
echo "====================================================="
echo ""
