#!/bin/bash
# ==================================================================
# ETAPA 11 — Auditoria / Reporte completo del laboratorio
# ==================================================================

REGION="us-east-1"
CLUSTER="laboratorio-eks"
NAMESPACE="tienda"
REPORTE="/root/work/bloque06/etapa11/reporte.txt"

echo ""
echo "============================================================="
echo " ETAPA 11 — Auditoria completa del laboratorio"
echo "============================================================="
echo ""

{
echo "================================================================="
echo "  REPORTE DE LABORATORIO — $(date)"
echo "  Alumno: ________________________"
echo "================================================================="
echo ""

# --- AWS ---
echo "=== 1. IDENTIDAD AWS ==="
aws sts get-caller-identity
echo ""

# --- VPC ---
echo "=== 2. VPC ==="
aws cloudformation describe-stacks --stack-name laboratorio-vpc-completa --region $REGION --query "Stacks[0].StackStatus" --output text 2>/dev/null || echo "NO ENCONTRADA"
echo ""

echo "=== 3. SUBNETS ==="
aws ec2 describe-subnets --region $REGION --filters "Name=tag:Name,Values=*laboratorio*" --query "Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key=='Name'].Value|[0]]" --output table
echo ""

echo "=== 4. VPC ENDPOINTS ==="
aws ec2 describe-vpc-endpoints --region $REGION --query "VpcEndpoints[*].[ServiceName,State]" --output table
echo ""

# --- EKS ---
echo "=== 5. CLUSTER EKS ==="
aws eks describe-cluster --name $CLUSTER --region $REGION --query "cluster.{Name:name,Status:status,Version:version}" --output table 2>/dev/null || echo "NO ENCONTRADO"
echo ""

echo "=== 6. NODEGROUP ==="
aws eks describe-nodegroup --cluster-name $CLUSTER --nodegroup-name laboratorio-nodegroup --region $REGION --query "nodegroup.{Name:nodegroupName,Status:status,Type:instanceTypes[0],Capacity:capacityType,Min:scalingConfig.minSize,Max:scalingConfig.maxSize}" --output table 2>/dev/null || echo "NO ENCONTRADO"
echo ""

echo "=== 7. NODOS KUBERNETES ==="
kubectl get nodes -o wide 2>/dev/null || echo "SIN CONEXION"
echo ""

# --- ECR ---
echo "=== 8. REPOSITORIOS ECR ==="
for repo in tienda-db tienda-backend tienda-frontend; do
  echo "--- $repo ---"
  aws ecr describe-repositories --repository-names $repo --region $REGION --query "repositories[0].repositoryUri" --output text 2>/dev/null || echo "  NO ENCONTRADO"
  aws ecr list-images --repository-name $repo --region $REGION --query "imageIds[*].imageTag" --output table 2>/dev/null
done
echo ""

# --- Kubernetes ---
echo "=== 9. NAMESPACE TIENDA ==="
kubectl get namespace $NAMESPACE 2>/dev/null || echo "NO EXISTE"
echo ""

echo "=== 10. DEPLOYMENTS ==="
kubectl get deployment -n $NAMESPACE 2>/dev/null || echo "SIN DEPLOYMENTS"
echo ""

echo "=== 11. SERVICES ==="
kubectl get svc -n $NAMESPACE 2>/dev/null || echo "SIN SERVICES"
echo ""

echo "=== 12. PODS ==="
kubectl get pods -n $NAMESPACE -o wide 2>/dev/null || echo "SIN PODS"
echo ""

echo "=== 13. HPA ==="
kubectl get hpa -n $NAMESPACE 2>/dev/null || echo "SIN HPA"
echo ""

echo "=== 14. STRESS TEST - RESULTADOS ==="
STRESS_REPORT=$(kubectl get events -n $NAMESPACE --sort-by=.metadata.creationTimestamp 2>/dev/null | grep -i "ScaledUp\|ScaledDown" | tail -5)
if [ -n "$STRESS_REPORT" ]; then
  echo "  Eventos de escalamiento detectados:"
  echo "$STRESS_REPORT"
else
  echo "  No se detectaron eventos de escalamiento (HPA puede no haber actuado aun)"
fi
echo ""

echo "=== 15. URL DE LA APLICACION ==="
HOSTNAME=$(kubectl get svc tienda-frontend -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
if [ -z "$HOSTNAME" ] || [ "$HOSTNAME" = "null" ]; then
  echo "  LoadBalancer no disponible"
else
  echo "  http://$HOSTNAME"
fi
echo ""

# --- RESUMEN CHECKLIST ---
echo "================================================================="
echo "  CHECKLIST DE EVALUACION"
echo "================================================================="
echo ""

check() {
  if [ "$2" != "" ] && [ "$2" != "NO ENCONTRADO" ] && [ "$2" != "NO ENCONTRADA" ] && [ "$2" != "NO EXISTE" ] && [ "$2" != "SIN CONEXION" ] && [ "$2" != "SIN DEPLOYMENTS" ] && [ "$2" != "SIN SERVICES" ] && [ "$2" != "SIN PODS" ] && [ "$2" != "SIN HPA" ]; then
    echo "  [X] $1"
  else
    echo "  [ ] $1"
  fi
}

VPC_OK=$(aws cloudformation describe-stacks --stack-name laboratorio-vpc-completa --region $REGION --query "Stacks[0].StackStatus" --output text 2>/dev/null)
EKS_OK=$(aws eks describe-cluster --name $CLUSTER --region $REGION --query "cluster.status" --output text 2>/dev/null)
NG_OK=$(aws eks describe-nodegroup --cluster-name $CLUSTER --nodegroup-name laboratorio-nodegroup --region $REGION --query "nodegroup.status" --output text 2>/dev/null)
DB_OK=$(aws ecr describe-repositories --repository-names tienda-db --region $REGION --query "repositories[0].repositoryUri" --output text 2>/dev/null)
DEPLOY_OK=$(kubectl get deployment -n $NAMESPACE 2>/dev/null | grep -c "tienda" || echo "0")
HPA_OK=$(kubectl get hpa -n $NAMESPACE 2>/dev/null | tail -n +2 | wc -l || echo "0")
STRESS_OK=$(kubectl get events -n $NAMESPACE 2>/dev/null | grep -c "ScaledUp" || echo "0")
URL_OK=$HOSTNAME

check "VPC laboratorio-vpc-completa          ($VPC_OK)" "$VPC_OK"
check "Cluster EKS ACTIVE                   ($EKS_OK)" "$EKS_OK"
check "NodeGroup ACTIVE                     ($NG_OK)" "$NG_OK"
check "ECR: tienda-db                       ($DB_OK)" "$DB_OK"
check "Deployments en namespace tienda       ($DEPLOY_OK encontrados)" "$DEPLOY_OK"
check "HPA configurados                     ($HPA_OK HPA activos)" "$HPA_OK"
check "Escalamiento automatico (stress)      ($STRESS_OK eventos)" "$STRESS_OK"
check "App accesible via LoadBalancer        ($URL_OK)" "$URL_OK"

echo ""
echo "================================================================="
echo "  FIN DEL REPORTE"
echo "================================================================="

} | tee "$REPORTE"

echo ""
echo "El reporte se guardo en:"
echo "  $REPORTE"
echo ""
echo "============================================================="
echo " ETAPA 11 COMPLETADA"
echo "============================================================="
echo "Continua con: cd ../etapa12-LimpiezaTotal"
echo ""
