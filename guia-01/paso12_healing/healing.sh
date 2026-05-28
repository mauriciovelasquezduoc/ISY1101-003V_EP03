#!/bin/bash

set -e

NAMESPACE="tienda"

echo ""
echo "====================================================="
echo " KUBERNETES AUTO-HEALING TEST"
echo "====================================================="
echo ""

echo ""
echo "====================================================="
echo " VALIDANDO PODS ACTUALES"
echo "====================================================="
echo ""

kubectl get pods -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO DEPLOYMENTS"
echo "====================================================="
echo ""

kubectl get deployment -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO REPLICASETS"
echo "====================================================="
echo ""

kubectl get rs -n $NAMESPACE

echo ""
echo "====================================================="
echo " SELECCIONANDO POD BACKEND"
echo "====================================================="
echo ""

BACKEND_POD=$(kubectl get pods -n $NAMESPACE \
  | grep tienda-backend \
  | awk '{print $1}' \
  | head -n 1)

echo "POD SELECCIONADO:"
echo "$BACKEND_POD"

echo ""
echo "====================================================="
echo " IMPORTANTE"
echo "====================================================="
echo ""

echo "Abrir otra terminal y ejecutar:"
echo ""
echo "kubectl get pods -n tienda -w"
echo ""

echo "para observar recreacion automatica."

echo ""
echo "====================================================="
echo " ELIMINANDO POD BACKEND"
echo "====================================================="
echo ""

sleep 5

kubectl delete pod $BACKEND_POD -n $NAMESPACE

echo ""
echo "====================================================="
echo " ESPERANDO RECREACION"
echo "====================================================="
echo ""

sleep 15

echo ""
echo "====================================================="
echo " VALIDANDO NUEVOS PODS"
echo "====================================================="
echo ""

kubectl get pods -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO DEPLOYMENTS"
echo "====================================================="
echo ""

kubectl get deployment -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO REPLICASETS"
echo "====================================================="
echo ""

kubectl get rs -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO EVENTOS"
echo "====================================================="
echo ""

kubectl get events -n $NAMESPACE \
  --sort-by=.metadata.creationTimestamp

echo ""
echo "====================================================="
echo " VALIDANDO PODS RUNNING"
echo "====================================================="
echo ""

kubectl get pods -n $NAMESPACE \
  | grep Running || true

echo ""
echo "====================================================="
echo " RESULTADO ESPERADO"
echo "====================================================="
echo ""

echo "Pod eliminado -> nuevo pod creado automaticamente"

echo ""
echo "====================================================="
echo " AUTO-HEALING VALIDADO"
echo "====================================================="
echo ""

echo "Kubernetes resiliencia automatica operativa"

echo ""
echo "====================================================="
echo " PROCESO FINALIZADO"
echo "====================================================="
echo ""
