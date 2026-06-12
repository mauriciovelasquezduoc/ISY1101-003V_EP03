#!/bin/bash

set -e

NAMESPACE="alumnos"
BACKEND_SERVICE="alumnos-backend"
MAX_WAIT_SCALE=300  # 5 minutos max para escalar
SLEEP_CHECK=10

echo ""
echo "====================================================="
echo " VALIDANDO HPA KUBERNETES"
echo "====================================================="
echo ""

# ==================================================================
# PASO 1 — Validar Metrics Server
# ==================================================================
echo ""
echo "====================================================="
echo " [1/8] VALIDANDO METRICS SERVER"
echo "====================================================="
echo ""

kubectl get apiservices | grep metrics || true

# ==================================================================
# PASO 2 — Validar metricas de nodos
# ==================================================================
echo ""
echo "====================================================="
echo " [2/8] VALIDANDO METRICAS NODOS"
echo "====================================================="
echo ""

kubectl top nodes || true

# ==================================================================
# PASO 3 — Validar metricas de pods
# ==================================================================
echo ""
echo "====================================================="
echo " [3/8] VALIDANDO METRICAS PODS"
echo "====================================================="
echo ""

kubectl top pods -n $NAMESPACE || true

# ==================================================================
# PASO 4 — Validar HPA existentes
# ==================================================================
echo ""
echo "====================================================="
echo " [4/8] VALIDANDO HPA EXISTENTES"
echo "====================================================="
echo ""

kubectl get hpa -n $NAMESPACE

echo ""
echo "  Verificando que los HPA esten configurados..."
HPA_COUNT=$(kubectl get hpa -n $NAMESPACE --no-headers 2>/dev/null | wc -l)
if [ "$HPA_COUNT" -lt 2 ]; then
  echo "  ERROR: Se esperaban al menos 2 HPA (backend + frontend)."
  echo "  Ejecuta primero: kubectl apply -f backend-hpa.yaml -f frontend-hpa.yaml"
  exit 1
fi
echo "  ✔ $HPA_COUNT HPA encontrados."

# ==================================================================
# PASO 5 — Validar pods backend estan Running
# ==================================================================
echo ""
echo "====================================================="
echo " [5/8] VALIDANDO PODS BACKEND RUNNING"
echo "====================================================="
echo ""

echo "  Esperando pods de alumnos-backend esten Ready..."
kubectl wait --for=condition=Ready pod -l app=alumnos-backend -n $NAMESPACE --timeout=120s
echo "  ✔ Backend pods Ready."

echo ""
echo "  Verificando replicas iniciales..."
INITIAL_REPLICAS=$(kubectl get deployment alumnos-backend -n $NAMESPACE -o jsonpath='{.status.availableReplicas}')
echo "  Replicas iniciales: $INITIAL_REPLICAS"

# ==================================================================
# PASO 6 — Prueba de carga
# ==================================================================
echo ""
echo "====================================================="
echo " [6/8] INICIANDO PRUEBA DE CARGA BACKEND"
echo "====================================================="
echo ""

echo "  Eliminando pod stress anterior (si existe)..."
kubectl delete pod hpa-test -n $NAMESPACE --ignore-not-found=true

echo ""
echo "  Creando pod de estres para generar carga HTTP..."
echo "  Target: http://$BACKEND_SERVICE:3001"
echo "  Usando imagen del backend (ya en ECR)"
echo ""

# Obtener la imagen del backend desde el deployment actual
BACKEND_IMAGE=$(kubectl get deployment alumnos-backend -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [ -z "$BACKEND_IMAGE" ]; then
  echo "  ERROR: No se pudo obtener la imagen del backend"
  exit 1
fi
echo "  Imagen: $BACKEND_IMAGE"

kubectl run hpa-test \
  --image="$BACKEND_IMAGE" \
  --restart=Never \
  -n $NAMESPACE \
  -- /bin/sh -c \
  "while true; do wget -q -O /dev/null http://$BACKEND_SERVICE:3001; done"

echo ""
echo "  Esperando que el pod stress este Running..."
kubectl wait --for=condition=Ready pod hpa-test -n $NAMESPACE --timeout=60s

echo "  ✔ Pod stress creado y generando trafico."

# ==================================================================
# PASO 7 — Esperar escalamiento automatico (HPA)
# ==================================================================
echo ""
echo "====================================================="
echo " [7/8] ESPERANDO ESCALAMIENTO AUTOMATICO (HPA)"
echo "====================================================="
echo ""

echo "  Monitoreando replicas de alumnos-backend (max $MAX_WAIT_SCALE seg)..."
echo ""

ELAPSED=0
SCALED=false
while [ $ELAPSED -lt $MAX_WAIT_SCALE ]; do
  CURRENT_REPLICAS=$(kubectl get deployment alumnos-backend -n $NAMESPACE -o jsonpath='{.status.availableReplicas}' 2>/dev/null || echo "0")
  HPA_STATUS=$(kubectl get hpa alumnos-backend-hpa -n $NAMESPACE -o jsonpath='{..currentReplicas}' 2>/dev/null || echo "?")

  printf "\r    elapsed: %3ds | replicas: %s | hpa-current: %s" "$ELAPSED" "$CURRENT_REPLICAS" "$HPA_STATUS"

  if [ "$CURRENT_REPLICAS" -gt "$INITIAL_REPLICAS" ] 2>/dev/null; then
    SCALED=true
    echo ""
    echo ""
    echo "  ✔ Escalamiento detectado!"
    echo "     Replicas: $INITIAL_REPLICAS → $CURRENT_REPLICAS"
    break
  fi

  sleep "$SLEEP_CHECK"
  ELAPSED=$((ELAPSED + SLEEP_CHECK))
done

echo ""

if [ "$SCALED" = false ]; then
  echo "  ⚠ No se detecto escalamiento en $MAX_WAIT_SCALE segundos."
  echo "  Posibles causas:"
  echo "    - Metrics Server aun recolectando datos (esperar 1-2 min extra)"
  echo "    - La carga no es suficiente para superar el threshold CPU"
  echo "    - El HPA no esta correctamente vinculado al deployment"
  echo ""
  echo "  Estado actual del HPA:"
  kubectl describe hpa alumnos-backend-hpa -n $NAMESPACE | grep -E "Metrics:|Reference:|Min replicas:|Max replicas:" || true
else
  echo ""
  echo "  Estado final del HPA:"
  kubectl get hpa alumnos-backend-hpa -n $NAMESPACE
fi

# ==================================================================
# PASO 8 — Resumen final
# ==================================================================
echo ""
echo "====================================================="
echo " [8/8] RESUMEN FINAL"
echo "====================================================="
echo ""

echo "--- HPA ---"
kubectl get hpa -n $NAMESPACE

echo ""
echo "--- PODS ---"
kubectl get pods -n $NAMESPACE

echo ""
echo "--- DEPLOYMENTS ---"
kubectl get deployment -n $NAMESPACE

echo ""
echo "--- EVENTOS RECIENTES ---"
kubectl get events -n $NAMESPACE --sort-by=.metadata.creationTimestamp | tail -20

echo ""
echo "====================================================="
echo " NOTA: Para detener la prueba de carga ejecuta:"
echo "   kubectl delete pod hpa-test -n alumnos"
echo "====================================================="
echo ""
echo "  Los pods extras se reduciran automaticamente"
echo "  cuando el CPU baje (aprox 5 min)."
echo ""
echo "====================================================="
echo " PROCESO FINALIZADO"
echo "====================================================="
echo ""
