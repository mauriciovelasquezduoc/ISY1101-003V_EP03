#!/bin/bash

NAMESPACE="tienda"
FRONTEND_SERVICE="tienda-frontend"

# Obtener URL del frontend automaticamente desde el Service LoadBalancer
echo ""
echo "====================================================="
echo " KUBERNETES STRESS TEST"
echo "====================================================="
echo ""

echo "  Obteniendo URL del frontend..."
echo ""

# Intentar obtener el hostname del LoadBalancer
for i in $(seq 1 30); do
  FRONTEND_URL=$(kubectl get svc $FRONTEND_SERVICE -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
  if [ -n "$FRONTEND_URL" ]; then
    break
  fi
  printf "\r    esperando LoadBalancer... intento %d/30" "$i"
  sleep 5
done
echo ""

if [ -z "$FRONTEND_URL" ]; then
  echo "  ERROR: No se pudo obtener la URL del LoadBalancer para $FRONTEND_SERVICE."
  echo "  Verifica que el service este expuesto:"
  echo "    kubectl get svc $FRONTEND_SERVICE -n $NAMESPACE"
  exit 1
fi

URL="http://$FRONTEND_URL"
WORKERS=${1:-50}

echo ""
echo "  TARGET: $URL"
echo "  WORKERS: $WORKERS"
echo ""
echo "====================================================="
echo " INICIANDO STRESS TEST"
echo "====================================================="
echo ""

echo "  Presione CTRL+C para detener"
echo ""

for i in $(seq 1 $WORKERS)
do
(
  while true
  do
    HTTP_CODE=$(curl \
      -o /dev/null \
      -s \
      -w "%{http_code}" \
      $URL)

    echo "[Worker $i] HTTP=$HTTP_CODE"
  done
) &
done

wait
