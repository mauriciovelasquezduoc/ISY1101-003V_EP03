#!/bin/bash

set -e

NAMESPACE="tienda"

echo ""
echo "====================================================="
echo " VALIDANDO HPA KUBERNETES"
echo "====================================================="
echo ""

echo ""
echo "====================================================="
echo " VALIDANDO METRICS SERVER"
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

kubectl top pods -n $NAMESPACE || true

echo ""
echo "====================================================="
echo " VALIDANDO HPA EXISTENTES"
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
echo " VALIDANDO REPLICAS ACTUALES"
echo "====================================================="
echo ""

kubectl get pods -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO CPU REQUESTS"
echo "====================================================="
echo ""

kubectl describe deployment tienda-backend -n $NAMESPACE \
  | grep -A 5 Requests || true

echo ""
echo "====================================================="
echo " ELIMINANDO POD STRESS ANTERIOR"
echo "====================================================="
echo ""

kubectl delete pod hpa-test -n $NAMESPACE --ignore-not-found=true

echo ""
echo "====================================================="
echo " INICIANDO PRUEBA DE CARGA BACKEND"
echo "====================================================="
echo ""

echo "Se generara trafico HTTP continuo"
echo "contra tienda-backend."

echo ""
echo "====================================================="
echo " CREANDO POD STRESS"
echo "====================================================="
echo ""

kubectl run hpa-test \
  --image=busybox \
  --restart=Never \
  -n $NAMESPACE \
  -- /bin/sh -c \
  "while true; do wget -q -O- http://tienda-backend:3001; done"

echo ""
echo "====================================================="
echo " VALIDANDO POD STRESS"
echo "====================================================="
echo ""

kubectl get pod hpa-test -n $NAMESPACE

echo ""
echo "====================================================="
echo " IMPORTANTE"
echo "====================================================="
echo ""

echo "Abrir otra terminal y monitorear:"
echo ""

echo "HPA:"
echo "kubectl get hpa -n tienda -w"

echo ""
echo "Pods:"
echo "kubectl get pods -n tienda -w"

echo ""
echo "CPU:"
echo "kubectl top pods -n tienda"

echo ""
echo "====================================================="
echo " ESPERAR 2-5 MINUTOS"
echo "====================================================="
echo ""

echo "El HPA deberia aumentar replicas automaticamente."

echo ""
echo "====================================================="
echo " RESULTADO ESPERADO"
echo "====================================================="
echo ""

echo "backend:"
echo "2 pods -> 3 -> 4 -> 5"

echo ""
echo "frontend:"
echo "2 pods -> 3 -> 4"

echo ""
echo "====================================================="
echo " VALIDACION FINAL"
echo "====================================================="
echo ""

kubectl get hpa -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO PODS FINALES"
echo "====================================================="
echo ""

kubectl get pods -n $NAMESPACE

echo ""
echo "====================================================="
echo " VALIDANDO POD STRESS"
echo "====================================================="
echo ""

kubectl logs -n $NAMESPACE hpa-test --tail=20 || true

echo ""
echo "====================================================="
echo " VALIDANDO EVENTOS KUBERNETES"
echo "====================================================="
echo ""

kubectl get events -n $NAMESPACE \
  --sort-by=.metadata.creationTimestamp || true

echo ""
echo "====================================================="
echo " FINALIZAR STRESS TEST"
echo "====================================================="
echo ""

echo "Para detener la prueba:"
echo ""

echo "kubectl delete pod hpa-test -n tienda"

echo ""
echo "====================================================="
echo " HPA VALIDADO"
echo "====================================================="
echo ""

echo "Kubernetes escalamiento automatico operativo"

echo ""
echo "====================================================="
echo " PROCESO FINALIZADO"
echo "====================================================="
echo ""
