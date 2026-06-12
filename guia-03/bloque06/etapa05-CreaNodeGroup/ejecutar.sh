#!/bin/bash
# ==================================================================
# ETAPA 05 — Validar / Crear NodeGroup SPOT
# ==================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../report_helper.sh"

REGION="us-east-1"
CLUSTER_NAME="laboratorio-eks"
NODEGROUP_NAME="laboratorio-nodegroup"

init_reporte "Validación/Creación de NodeGroup SPOT"

echo ""
echo "============================================================="
echo " ETAPA 05 — Validar / Crear NodeGroup SPOT"
echo "============================================================="
echo ""

# --- Verificar si el NodeGroup ya existe ---
echo "[1] Verificando si el NodeGroup ya existe..."
NG_EXISTS=$(aws eks describe-nodegroup \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name $NODEGROUP_NAME \
  --region $REGION \
  --query "nodegroup.status" \
  --output text 2>/dev/null || echo "NOEXISTE")

if [ "$NG_EXISTS" != "NOEXISTE" ]; then
  echo ""
  echo "  NodeGroup YA EXISTE (estado: $NG_EXISTS)"
  echo "  Fue creado automaticamente por CloudFormation en la etapa04."
  echo ""

  # Si no esta ACTIVE, esperar
  if [ "$NG_EXISTS" != "ACTIVE" ]; then
    echo "[2] Esperando a que el NodeGroup este ACTIVE..."
    while true; do
      STATUS=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $NODEGROUP_NAME --region $REGION --query "nodegroup.status" --output text)
      echo "  Estado: $STATUS"
      if [ "$STATUS" = "ACTIVE" ]; then
        break
      fi
      sleep 20
    done
  fi

else
  # --- NodeGroup no existe, crearlo ---
  echo ""
  echo "[2] Obteniendo Node Role..."
  NODE_ROLE_ARN=$(aws iam list-roles --query "Roles[?contains(RoleName, 'LabEksNodeRole')].Arn" --output text)
  echo "  NODE_ROLE_ARN=$NODE_ROLE_ARN"

  echo ""
  echo "[3] Obteniendo subnets privadas app..."
  PRIV_APP_A=$(aws ec2 describe-subnets --region $REGION --query "Subnets[?Tags[?Value=='private-app-a']].SubnetId" --output text)
  PRIV_APP_B=$(aws ec2 describe-subnets --region $REGION --query "Subnets[?Tags[?Value=='private-app-b']].SubnetId" --output text)
  echo "  private-app-a=$PRIV_APP_A"
  echo "  private-app-b=$PRIV_APP_B"

  echo ""
  echo "[4] Creando NodeGroup (tarda ~5-15 min)..."
  aws eks create-nodegroup \
    --region $REGION \
    --cluster-name $CLUSTER_NAME \
    --nodegroup-name $NODEGROUP_NAME \
    --node-role $NODE_ROLE_ARN \
    --subnets $PRIV_APP_A $PRIV_APP_B \
    --instance-types t3.large \
    --capacity-type SPOT \
    --disk-size 20 \
    --scaling-config minSize=1,maxSize=3,desiredSize=1

  echo ""
  echo "[5] Esperando a que el NodeGroup este ACTIVE..."
  echo "  (puede tomar 5-15 minutos)"
  while true; do
    STATUS=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $NODEGROUP_NAME --region $REGION --query "nodegroup.status" --output text 2>/dev/null || echo "CREATING")
    echo "  Estado: $STATUS"
    if [ "$STATUS" = "ACTIVE" ]; then
      break
    fi
    sleep 20
  done
fi

echo ""
echo "[6] Configurando kubectl..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

add_evidencia "Detalle del NodeGroup" "aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $NODEGROUP_NAME --region $REGION --query 'nodegroup.{Name:nodegroupName,Status:status,InstanceType:instanceTypes[0],Capacity:capacityType,ScalingMin:scalingConfig.minSize,ScalingMax:scalingConfig.maxSize,ScalingDesired:scalingConfig.desiredSize,Subnets:subnets[0]}' --output table" "IE1"

add_evidencia "Nodos Kubernetes Ready" "kubectl get nodes -o wide" "IE1"

add_evidencia "Pods del sistema saludables" "kubectl get pods -n kube-system -o wide" "IE1"

cerrar_reporte

echo ""
echo "============================================================="
echo " ETAPA 05 COMPLETADA — NodeGroup ACTIVE + Workers Ready"
echo "============================================================="
echo ""
echo "  📋 Reporte generado en: docs/reports/etapa05-CreaNodeGroup.md"
echo ""
echo "  💡 Para evidencia en README, copia el contenido de:"
echo "      docs/reports/etapa05-CreaNodeGroup.md"
echo "      y pégalo en la sección de Arquitectura del README de tu repo"
echo ""
echo "Continua con: cd ../etapa06-ValidaObservabilidad"
echo ""
