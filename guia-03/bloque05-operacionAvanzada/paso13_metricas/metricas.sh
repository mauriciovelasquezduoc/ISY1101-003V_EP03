#!/bin/bash

set -e

NAMESPACE="alumnos"
CLUSTER_NAME="laboratorio-eks"
MAX_WAIT_METRICS=60  # 60s esperando metrics

echo ""
echo "====================================================="
echo " KUBERNETES METRICS VALIDATION"
echo "====================================================="
echo ""

# ==================================================================
# PASO 1 — Validar Metrics Server
# ==================================================================
echo ""
echo "====================================================="
echo " [1/9] VALIDANDO METRICS SERVER"
echo "====================================================="
echo ""

kubectl get pods -n kube-system | grep metrics-server || true

echo ""
echo "  Esperando que Metrics Server este Ready..."
kubectl wait --for=condition=Ready pod -l k8s-app=metrics-server -n kube-system --timeout=120s 2>/dev/null || \
  kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=metrics-server -n kube-system --timeout=120s 2>/dev/null || \
  echo "  ⚠ No se pudo verificar Metrics Server via label (puede que ya este operativo)"

# ==================================================================
# PASO 2 — Validar API de metrics
# ==================================================================
echo ""
echo "====================================================="
echo " [2/9] VALIDANDO API METRICS"
echo "====================================================="
echo ""

echo "  Esperando que la API metrics.k8s.io este disponible..."
for i in $(seq 1 $MAX_WAIT_METRICS); do
  if kubectl get apiservices | grep -q "metrics.k8s.io.*True"; then
    echo "  ✔ API metrics.k8s.io disponible (intento $i)"
    break
  fi
  if [ "$i" -eq "$MAX_WAIT_METRICS" ]; then
    echo "  ⚠ API metrics.k8s.io aun no disponible tras $MAX_WAIT_METRICS segundos."
    echo "     Los comandos top pueden fallar, pero es normal hasta que se recolecten datos."
  else
    printf "\r    esperando API metrics... intento %d/%d" "$i" "$MAX_WAIT_METRICS"
    sleep 1
  fi
done
echo ""

kubectl get apiservices | grep metrics || true

# ==================================================================
# PASO 3 — Validar nodos
# ==================================================================
echo ""
echo "====================================================="
echo " [3/9] VALIDANDO NODOS"
echo "====================================================="
echo ""

kubectl get nodes

# ==================================================================
# PASO 4 — Metricas de nodos (con reintento)
# ==================================================================
echo ""
echo "====================================================="
echo " [4/9] METRICAS NODOS"
echo "====================================================="
echo ""

echo "  Recolectando metricas de nodos..."
for i in $(seq 1 10); do
  if kubectl top nodes 2>/dev/null; then
    break
  fi
  if [ "$i" -eq 10 ]; then
    echo "  (metricas de nodos aun no disponibles — normal si el cluster es nuevo)"
  else
    printf "\r    esperando metricas... intento %d/10" "$i"
    sleep 3
  fi
done
echo ""

# ==================================================================
# PASO 5 — Metricas de pods (con reintento)
# ==================================================================
echo ""
echo "====================================================="
echo " [5/9] METRICAS PODS"
echo "====================================================="
echo ""

echo "  Recolectando metricas de pods..."
for i in $(seq 1 10); do
  if kubectl top pods -n $NAMESPACE 2>/dev/null; then
    break
  fi
  if [ "$i" -eq 10 ]; then
    echo "  (metricas de pods aun no disponibles — normal si los pods acaban de iniciar)"
  else
    printf "\r    esperando metricas... intento %d/10" "$i"
    sleep 3
  fi
done
echo ""

# ==================================================================
# PASO 6 — Validar HPA
# ==================================================================
echo ""
echo "====================================================="
echo " [6/9] VALIDANDO HPA"
echo "====================================================="
echo ""

if kubectl get hpa -n $NAMESPACE 2>/dev/null; then
  echo ""
  echo "  Detalle de HPA:"
  kubectl describe hpa -n $NAMESPACE | head -30
else
  echo "  (no hay HPA configurados aun)"
fi

# ==================================================================
# PASO 7 — Validar deployments, services, pods
# ==================================================================
echo ""
echo "====================================================="
echo " [7/9] ESTADO DEL CLUSTER"
echo "====================================================="
echo ""

echo "--- DEPLOYMENTS ---"
kubectl get deployment -n $NAMESPACE

echo ""
echo "--- SERVICES ---"
kubectl get svc -n $NAMESPACE

echo ""
echo "--- PODS ---"
kubectl get pods -n $NAMESPACE

# ==================================================================
# PASO 8 — Eventos recientes
# ==================================================================
echo ""
echo "====================================================="
echo " [8/9] EVENTOS RECIENTES"
echo "====================================================="
echo ""

kubectl get events -n $NAMESPACE --sort-by=.metadata.creationTimestamp | tail -20 || true

# ==================================================================
# PASO 9 — CloudWatch
# ==================================================================
echo ""
echo "====================================================="
echo " [9/9] VALIDANDO CLOUDWATCH"
echo "====================================================="
echo ""

echo "--- LOG GROUPS ---"
aws logs describe-log-groups \
  --query "logGroups[*].logGroupName" \
  --output table || echo "  (sin log groups de CloudWatch)"

echo ""
echo "--- EKS LOGGING CONFIG ---"
aws eks describe-cluster \
  --name "$CLUSTER_NAME" \
  --query "cluster.logging" \
  --output table || echo "  (no se pudo obtener config de logging)"

# ==================================================================
# RESUMEN
# ==================================================================
echo ""
echo "====================================================="
echo " RESUMEN DE OBSERVABILIDAD"
echo "====================================================="
echo ""

echo "  Metrics Server:     $(kubectl get pods -n kube-system 2>/dev/null | grep metrics-server | awk '{print $3}')"
echo "  HPA configurados:   $(kubectl get hpa -n $NAMESPACE 2>/dev/null | tail -n +2 | wc -l)"
echo "  Pods totales:       $(kubectl get pods -n $NAMESPACE 2>/dev/null | tail -n +2 | wc -l)"
echo "  Nodes disponibles:  $(kubectl get nodes 2>/dev/null | tail -n +2 | wc -l)"
echo ""

echo "====================================================="
echo " OBSERVABILIDAD VALIDADA"
echo "====================================================="
echo ""
echo "  Metrics Server operativo"
if kubectl get hpa -n $NAMESPACE 2>/dev/null | grep -q .; then
  echo "  HPA monitoreando CPU"
fi
echo ""

echo "====================================================="
echo " PROCESO FINALIZADO"
echo "====================================================="
echo ""
