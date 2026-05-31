#!/bin/bash
# ==================================================================
# ETAPA 09 — Validacion final + Obtener URL de la app
# ==================================================================
set -e

NAMESPACE="tienda"

echo ""
echo "============================================================="
echo " ETAPA 09 — Validacion final de la aplicacion"
echo "============================================================="
echo ""

echo "=== 1. Nodos del cluster ==="
kubectl get nodes -o wide

echo ""
echo "=== 2. Todos los Pods en tienda ==="
kubectl get pods -n $NAMESPACE -o wide

echo ""
echo "=== 3. Services en tienda ==="
kubectl get svc -n $NAMESPACE

echo ""
echo "=== 4. HPA en tienda ==="
kubectl get hpa -n $NAMESPACE

echo ""
echo "=== 5. Deployments en tienda ==="
kubectl get deployment -n $NAMESPACE

echo ""
echo "=== 6. Endpoints ==="
kubectl get endpoints -n $NAMESPACE

echo ""
echo "=== 7. kube-system ==="
kubectl get pods -n kube-system

echo ""
echo "=== 8. Metricas de nodos ==="
kubectl top nodes 2>/dev/null || echo "  (metrics-server puede tardar)"

echo ""
echo "=== 9. Metricas de pods ==="
kubectl top pods -n $NAMESPACE 2>/dev/null || echo "  (metrics-server puede tardar)"

# --- URL del LoadBalancer ---
echo ""
echo "============================================================="
echo " URL DE LA APLICACION"
echo "============================================================="

LB_URL=$(kubectl get svc tienda-frontend -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [ -n "$LB_URL" ]; then
  echo ""
  echo "  LoadBalancer URL:"
  echo "  http://$LB_URL"
  echo ""
  echo "  (puede tardar unos minutos en estar disponible)"
else
  echo ""
  echo "  El LoadBalancer aun se esta creando..."
  echo "  Vuelve a ejecutar: kubectl get svc -n $NAMESPACE"
  echo "  Cuando aparezca un hostname en EXTERNAL-IP, usalo en el navegador."
fi

echo ""
echo "============================================================="
echo " ETAPA 09 COMPLETADA"
echo "============================================================="
echo ""
echo "RESUMEN:"
echo "  Docker → VPC → EKS → NodeGroup → Metrics → CloudWatch"
echo "  → ECR → Deploy (DB + Backend + Frontend) → LoadBalancer"
echo ""
echo "La aplicacion esta corriendo en Amazon EKS."
echo ""
echo ""
echo "============================================================="
echo " Continua con: cd ../etapa10 "
echo "============================================================="
echo ""