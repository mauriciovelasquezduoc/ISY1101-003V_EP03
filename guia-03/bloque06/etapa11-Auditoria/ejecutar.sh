#!/bin/bash
# ==================================================================
# ETAPA 11 — Auditoria / Reporte completo del laboratorio
# ==================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../report_helper.sh"

REGION="us-east-1"
CLUSTER="laboratorio-eks"
NAMESPACE="alumnos"

REPORTE_CONSOLIDADO="/root/work/docs/reports/REPORTE-FINAL-LABORATORIO.md"

init_reporte "Auditoría completa del laboratorio"

echo ""
echo "============================================================="
echo " ETAPA 11 — Auditoria completa del laboratorio"
echo "============================================================="
echo ""

# ==================================================================
# 1. IDENTIDAD AWS
# ==================================================================
add_evidencia "Identidad AWS" "aws sts get-caller-identity" "IE1"

# ==================================================================
# 2. VPC
# ==================================================================
add_evidencia "Estado del stack VPC" "aws cloudformation describe-stacks --stack-name laboratorio-vpc-completa --region $REGION --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo 'NO ENCONTRADA'" "IE1"

add_evidencia "Subnets de laboratorio" "aws ec2 describe-subnets --region $REGION --filters 'Name=tag:Name,Values=*laboratorio*' --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key==\"/Name\"].Value|[0]]' --output table" "IE1"

add_evidencia "VPC Endpoints" "aws ec2 describe-vpc-endpoints --region $REGION --query 'VpcEndpoints[*].[ServiceName,State]' --output table" "IE1"

# ==================================================================
# 3. EKS
# ==================================================================
add_evidencia "Cluster EKS" "aws eks describe-cluster --name $CLUSTER --region $REGION --query 'cluster.{Name:name,Status:status,Version:version}' --output table 2>/dev/null || echo 'NO ENCONTRADO'" "IE1"

add_evidencia "NodeGroup" "aws eks describe-nodegroup --cluster-name $CLUSTER --nodegroup-name laboratorio-nodegroup --region $REGION --query 'nodegroup.{Name:nodegroupName,Status:status,Type:instanceTypes[0],Capacity:capacityType,Min:scalingConfig.minSize,Max:scalingConfig.maxSize}' --output table 2>/dev/null || echo 'NO ENCONTRADO'" "IE1"

add_evidencia "Nodos Kubernetes" "kubectl get nodes -o wide 2>/dev/null || echo 'SIN CONEXION'" "IE1"

# ==================================================================
# 4. ECR
# ==================================================================
add_evidencia "Repositorios ECR e imágenes" "for repo in alumnos-db alumnos-backend alumnos-frontend; do echo '---'; echo \$repo; aws ecr describe-repositories --repository-names \$repo --region $REGION --query 'repositories[0].repositoryUri' --output text 2>/dev/null || echo 'NO ENCONTRADO'; aws ecr list-images --repository-name \$repo --region $REGION --query 'imageIds[*].imageTag' --output table 2>/dev/null; done" "IE2"

# ==================================================================
# 5. KUBERNETES
# ==================================================================
add_evidencia "Namespace alumnos" "kubectl get namespace $NAMESPACE 2>/dev/null || echo 'NO EXISTE'" "IE2"

add_evidencia "Deployments en alumnos" "kubectl get deployment -n $NAMESPACE 2>/dev/null || echo 'SIN DEPLOYMENTS'" "IE2"

add_evidencia "Services en alumnos" "kubectl get svc -n $NAMESPACE 2>/dev/null || echo 'SIN SERVICES'" "IE2"

add_evidencia "Pods en alumnos" "kubectl get pods -n $NAMESPACE -o wide 2>/dev/null || echo 'SIN PODS'" "IE2 + IE7"

add_evidencia "HPA en alumnos" "kubectl get hpa -n $NAMESPACE 2>/dev/null || echo 'SIN HPA'" "IE3"

# ==================================================================
# 6. EVENTOS DE ESCALAMIENTO
# ==================================================================
add_logs_evidencia "Eventos de escalamiento (stress test)" "kubectl get events -n $NAMESPACE --sort-by=.metadata.creationTimestamp 2>/dev/null | grep -i 'ScaledUp\\|ScaledDown' | tail -10 || echo 'No se detectaron eventos de escalamiento (HPA puede no haber actuado aun)'" "IE3"

# ==================================================================
# 7. URL
# ==================================================================
HOSTNAME=$(kubectl get svc alumnos-frontend -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
if [ -z "$HOSTNAME" ] || [ "$HOSTNAME" = "null" ]; then
  add_texto_evidencia "### URL de la aplicación\n\nLoadBalancer no disponible aún."
else
  add_texto_evidencia "### URL de la aplicación\n\n\`\`\`\nhttp://${HOSTNAME}\n\`\`\`"
fi

# ==================================================================
# 8. LOGS DE APLICACIÓN
# ==================================================================
add_evidencia "Logs del backend (últimas 15 líneas)" "kubectl logs -n $NAMESPACE -l app=alumnos-backend --tail=15 2>/dev/null || echo '(logs no disponibles)'" "IE6 + IE7"

add_evidencia "Logs del frontend (últimas 15 líneas)" "kubectl logs -n $NAMESPACE -l app=alumnos-frontend --tail=15 2>/dev/null || echo '(logs no disponibles)'" "IE6 + IE7"

# ==================================================================
# 9. MÉTRICAS
# ==================================================================
add_evidencia "Métricas de nodos (CPU/Mem)" "kubectl top nodes 2>/dev/null || echo '(metrics-server puede tardar)'" "IE6"
add_evidencia "Métricas de pods (CPU/Mem)" "kubectl top pods -n $NAMESPACE 2>/dev/null || echo '(metrics-server puede tardar)'" "IE6"

# ==================================================================
# CHECKLIST DE EVALUACIÓN
# ==================================================================
echo ""
echo "============================================================="
echo " GENERANDO CHECKLIST DE EVALUACION..."
echo "============================================================="

VPC_OK=$(aws cloudformation describe-stacks --stack-name laboratorio-vpc-completa --region $REGION --query "Stacks[0].StackStatus" --output text 2>/dev/null)
EKS_OK=$(aws eks describe-cluster --name $CLUSTER --region $REGION --query "cluster.status" --output text 2>/dev/null)
NG_OK=$(aws eks describe-nodegroup --cluster-name $CLUSTER --nodegroup-name laboratorio-nodegroup --region $REGION --query "nodegroup.status" --output text 2>/dev/null)
DEPLOY_OK=$(kubectl get deployment -n $NAMESPACE 2>/dev/null | grep -c "alumnos" || echo "0")
HPA_COUNT=$(kubectl get hpa -n $NAMESPACE 2>/dev/null | tail -n +2 | wc -l || echo "0")
STRESS_OK=$(kubectl get events -n $NAMESPACE 2>/dev/null | grep -c "ScaledUp" || echo "0")

add_texto_evidencia "## ✅ Checklist de Evaluación

### Infraestructura Base
| Ítem | Estado |
|---|---|
| VPC laboratorio-vpc-completa | $([ "$VPC_OK" = "CREATE_COMPLETE" ] && echo '✅' || echo '❌') $VPC_OK |
| Cluster EKS ACTIVE | $([ "$EKS_OK" = "ACTIVE" ] && echo '✅' || echo '❌') $EKS_OK |
| NodeGroup ACTIVE | $([ "$NG_OK" = "ACTIVE" ] && echo '✅' || echo '❌') $NG_OK |

### Aplicación
| Ítem | Estado |
|---|---|
| ECR: alumnos-db | $(aws ecr describe-repositories --repository-names alumnos-db --region $REGION &>/dev/null && echo '✅' || echo '❌') |
| ECR: alumnos-backend | $(aws ecr describe-repositories --repository-names alumnos-backend --region $REGION &>/dev/null && echo '✅' || echo '❌') |
| ECR: alumnos-frontend | $(aws ecr describe-repositories --repository-names alumnos-frontend --region $REGION &>/dev/null && echo '✅' || echo '❌') |
| Deployments en alumnos | $([ "$DEPLOY_OK" -ge 2 ] && echo '✅' || echo '❌') ($DEPLOY_OK encontrados) |
| HPA configurados | $([ "$HPA_COUNT" -ge 1 ] && echo '✅' || echo '❌') ($HPA_COUNT HPA activos) |
| Escalamiento automático | $([ "$STRESS_OK" -ge 1 ] && echo '✅' || echo '❌') ($STRESS_OK eventos) |
| App accesible via LoadBalancer | $([ -n "$HOSTNAME" ] && [ "$HOSTNAME" != "null" ] && echo '✅' || echo '❌') |
| Logs de aplicación visibles | $(kubectl logs -n $NAMESPACE -l app=alumnos-backend --tail=1 &>/dev/null && echo '✅' || echo '❌') |
| kubectl top nodes funciona | $(kubectl top nodes &>/dev/null && echo '✅' || echo '❌') |"

echo ""
echo "============================================================="
echo " GENERANDO REPORTE CONSOLIDADO..."
echo "============================================================="

# Copiar todos los reportes al consolidado
{
  echo "# Reporte Consolidado del Laboratorio EP03"
  echo ""
  echo "**Fecha de generación:** $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""
  echo "---"
  echo ""

  for report in "$REPORTS_DIR"/*.md; do
    [ "$report" = "$REPORTE_FILE" ] && continue
    echo ""
    cat "$report"
    echo ""
    echo "---"
    echo ""
  done

  echo ""
  cat "$REPORTE_FILE"
  echo ""

  echo "<!-- ================================================== -->"
  echo "<!-- FIN DEL REPORTE CONSOLIDADO                        -->"
  echo "<!-- ================================================== -->"
} > "$REPORTE_CONSOLIDADO"

echo ""
echo "============================================================="
echo " ETAPA 11 COMPLETADA"
echo "============================================================="
echo ""
echo "  📋 Reportes generados:"
echo ""
ls -la "$REPORTS_DIR/"*.md 2>/dev/null
echo ""
echo "  📋 Reporte CONSOLIDADO:"
echo "     $REPORTE_CONSOLIDADO"
echo ""
echo "  💡 Para subir evidencias a tu repositorio:"
echo "     1. Cada reporte individual (etapaXX.md) contiene evidencia"
echo "        específica para una o más IE's"
echo "     2. El reporte consolidado tiene TODO junto"
echo "     3. Copia las secciones relevantes a tu README.md"
echo ""
echo "Continua con: cd ../etapa12-LimpiezaTotal"
echo ""
