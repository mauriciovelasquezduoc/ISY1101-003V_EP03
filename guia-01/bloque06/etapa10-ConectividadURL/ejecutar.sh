#!/bin/bash
# ==================================================================
# ETAPA 10 — Conectividad + URL de la aplicacion
# ==================================================================

REGION="us-east-1"
CLUSTER_NAME="laboratorio-eks"
NAMESPACE="tienda"

echo ""
echo "============================================================="
echo " ETAPA 10 — Conectividad + URL de la app"
echo "============================================================="
echo ""

# ==================================================================
# 1. Renovar credenciales si el token expiro
# ==================================================================
echo " Si el token AWS Academy expiro, renuevalo antes de seguir:"
echo ""
echo "   1. AWS Academy -> AWS Details -> Show (AWS CLI)"
echo "   2. aws configure"
echo "   3. aws configure set aws_session_token \"TOKEN_NUEVO\""
echo ""

# ==================================================================
# 2. Renovar kubeconfig
# ==================================================================
echo "[1] Renovando kubeconfig..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# ==================================================================
# 3. Conectividad
# ==================================================================
echo ""
echo "[2] Conectividad con el cluster..."
echo ""
kubectl get nodes -o wide

# ==================================================================
# 4. Servicios de la app
# ==================================================================
echo ""
echo "[3] Servicios en namespace tienda:"
echo ""
kubectl get svc -n $NAMESPACE

# ==================================================================
# 5. URL PUBLICA
# ==================================================================
HOSTNAME=$(kubectl get svc tienda-frontend -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

echo ""
if [ -z "$HOSTNAME" ] || [ "$HOSTNAME" = "null" ]; then
  echo "El LoadBalancer todavia se esta creando (2-3 min)."
  echo "Vuelve a ejecutar: kubectl get svc -n $NAMESPACE"
else
  echo "================================================================="
  echo ""
  echo "   APLICACION DISPONIBLE EN:"
  echo ""
  echo "   http://$HOSTNAME"
  echo ""
  echo "================================================================="
fi

echo ""
