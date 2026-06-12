#!/bin/bash
# ==================================================================
# ETAPA 10 — Conectividad + URL de la aplicacion
# ==================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../report_helper.sh"

REGION="us-east-1"
CLUSTER_NAME="laboratorio-eks"
NAMESPACE="alumnos"

init_reporte "Conectividad y URL de la aplicación"

echo ""
echo "============================================================="
echo " ETAPA 10 — Conectividad + URL de la app"
echo "============================================================="
echo ""

# ==================================================================
# 1. Renovar kubeconfig
# ==================================================================
echo "[1] Renovando kubeconfig..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

add_evidencia "Conectividad con el clúster" "kubectl get nodes -o wide" "IE1"

add_evidencia "Servicios en namespace alumnos" "kubectl get svc -n $NAMESPACE" "IE2"

HOSTNAME=$(kubectl get svc alumnos-frontend -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [ -z "$HOSTNAME" ] || [ "$HOSTNAME" = "null" ]; then
  add_texto_evidencia "### URL Pública
El LoadBalancer todavía se está creando (2-3 min).
Vuelve a ejecutar: \`kubectl get svc -n $NAMESPACE\`"
  echo "El LoadBalancer todavia se esta creando (2-3 min)."
else
  add_texto_evidencia "### URL Pública

La aplicación está disponible en:

\`\`\`
http://${HOSTNAME}
\`\`\`

> Esta URL debe funcionar en el navegador. Si no carga, espera 2-3 min
> adicionales para que el LoadBalancer de AWS se aprovisione completamente."

  echo ""
  echo "================================================================="
  echo ""
  echo "   APLICACION DISPONIBLE EN:"
  echo ""
  echo "   http://$HOSTNAME"
  echo ""
  echo "================================================================="
fi

# Logs de la aplicación como evidencia
add_evidencia "Logs del backend (últimas líneas)" "kubectl logs -n $NAMESPACE -l app=alumnos-backend --tail=10 2>/dev/null || echo '(logs no disponibles)'" "IE6 + IE7"

add_evidencia "Logs del frontend (últimas líneas)" "kubectl logs -n $NAMESPACE -l app=alumnos-frontend --tail=10 2>/dev/null || echo '(logs no disponibles)'" "IE6 + IE7"

cerrar_reporte

echo ""
echo "============================================================="
echo " ETAPA 10 COMPLETADA"
echo "============================================================="
echo ""
echo "  📋 Reporte generado en: docs/reports/etapa10-ConectividadURL.md"
echo ""
echo "  💡 Para README del frontend, copia la URL pública y"
echo "     los logs de la aplicación como evidencia de funcionamiento."
echo ""
echo "Continua con: cd ../etapa11-Auditoria"
echo ""
