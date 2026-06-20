#!/usr/bin/env bash
# ==============================================================================
# GUIA 04 - Limpieza total
#
# Elimina los recursos creados o configurados por los bloques de guia-04:
#   - Namespace Kubernetes y LoadBalancer de la aplicacion
#   - RBAC auxiliar de CloudWatch creado por bloque06
#   - Dashboard y Log Groups de CloudWatch
#   - Stack EKS y stack VPC de CloudFormation
#   - Repositorios ECR definidos en bloque02-ecr/repositorios.yaml
#   - Repositorios GitHub definidos en secrets.txt
#   - Entradas del cluster en kubeconfig
#
# Las metricas publicadas con PutMetricData no tienen API de eliminacion en AWS.
# Dejan de aparecer cuando expiran por inactividad.
#
# Uso:
#   bash borrarTodo.sh
#   bash borrarTodo.sh --yes
#   bash borrarTodo.sh --dry-run
#   bash borrarTodo.sh --delete-github
# ==============================================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_FILE="$SCRIPT_DIR/secrets.txt"
ECR_REPOS_FILE="$SCRIPT_DIR/bloque02-ecr/repositorios.yaml"

REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="${EKS_CLUSTER_NAME:-laboratorio-ep03-eks}"
NAMESPACE="${K8S_NAMESPACE:-ep03}"
STACK_VPC="${VPC_STACK:-laboratorio-ep03-vpc}"
STACK_EKS="${EKS_STACK:-laboratorio-ep03-eks}"
DASHBOARD_NAME=""
CLOUDWATCH_POLICY_ARN="arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
NODEGROUP_NAME="${EKS_NODEGROUP_NAME:-laboratorio-ep03-nodegroup}"

ASSUME_YES=false
DRY_RUN=false
DELETE_GITHUB=false
ERRORS=0
WARNINGS=0
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
  sed -n '3,21p' "$0" | sed 's/^# \{0,1\}//'
}

for arg in "$@"; do
  case "$arg" in
    --yes|-y) ASSUME_YES=true ;;
    --dry-run) DRY_RUN=true ;;
    --delete-github) DELETE_GITHUB=true ;;
    --keep-github)
      printf 'AVISO: --keep-github ya no es necesario; GitHub se conserva por defecto.\n' >&2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Argumento desconocido: $arg" >&2
      usage
      exit 2
      ;;
  esac
done

log() { printf '%b\n' "${BLUE}$*${NC}"; }
ok() { printf '%b\n' "  ${GREEN}OK${NC} - $*"; }
warn() {
  WARNINGS=$((WARNINGS + 1))
  printf '%b\n' "  ${YELLOW}AVISO${NC} - $*"
}
error() {
  ERRORS=$((ERRORS + 1))
  printf '%b\n' "  ${RED}ERROR${NC} - $*"
}

run() {
  if [ "$DRY_RUN" = true ]; then
    printf '  [dry-run]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

load_config() {
  [ -f "$SECRETS_FILE" ] || return 0

  local file_access_key=""
  local file_secret_key=""
  local file_session_token=""

  while IFS='=' read -r key value || [ -n "${key:-}" ]; do
    key="${key%$'\r'}"
    value="${value%$'\r'}"
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    [ -z "$key" ] && continue
    [[ "$key" == \#* ]] && continue

    case "$key" in
      aws_access_key_id|AWS_ACCESS_KEY_ID)
        [ -n "$value" ] && file_access_key="$value"
        ;;
      aws_secret_access_key|AWS_SECRET_ACCESS_KEY)
        [ -n "$value" ] && file_secret_key="$value"
        ;;
      aws_session_token|AWS_SESSION_TOKEN)
        [ -n "$value" ] && file_session_token="$value"
        ;;
      AWS_REGION) [ -n "$value" ] && REGION="$value" ;;
      EKS_CLUSTER_NAME) [ -n "$value" ] && CLUSTER_NAME="$value" ;;
      K8S_NAMESPACE) [ -n "$value" ] && NAMESPACE="$value" ;;
      GITHUB_TOKEN)
        [ -n "$value" ] && [ -z "${GH_TOKEN:-}" ] && export GH_TOKEN="$value"
        ;;
    esac
  done < "$SECRETS_FILE"

  # No reemplazar una sesion AWS funcional (perfil, SSO, rol o variables del
  # entorno) por credenciales temporales posiblemente vencidas de secrets.txt.
  if aws sts get-caller-identity --region "$REGION" >/dev/null 2>&1; then
    return 0
  fi

  if [ -n "$file_access_key" ] && [ -n "$file_secret_key" ]; then
    export AWS_ACCESS_KEY_ID="$file_access_key"
    export AWS_SECRET_ACCESS_KEY="$file_secret_key"
    if [ -n "$file_session_token" ]; then
      export AWS_SESSION_TOKEN="$file_session_token"
    else
      unset AWS_SESSION_TOKEN
    fi
  fi
}

read_ecr_repositories() {
  ECR_REPOSITORIES=()
  [ -f "$ECR_REPOS_FILE" ] || return 0

  while IFS= read -r line; do
    if [[ "$line" =~ Name:[[:space:]]*([^[:space:]#]+) ]]; then
      local name="${BASH_REMATCH[1]}"
      name="${name%\"}"
      name="${name#\"}"
      ECR_REPOSITORIES+=("$name")
    fi
  done < "$ECR_REPOS_FILE"
}

read_github_repositories() {
  GITHUB_REPOSITORIES=()
  [ -f "$SECRETS_FILE" ] || return 0

  while IFS='=' read -r key value || [ -n "${key:-}" ]; do
    key="${key%$'\r'}"
    value="${value%$'\r'}"
    case "$key" in
      GITHUB_DATABASE|GITHUB_BACKEND|GITHUB_FRONTEND)
        [ -n "$value" ] || continue
        value="${value#https://github.com/}"
        value="${value#http://github.com/}"
        value="${value#git@github.com:}"
        value="${value%.git}"
        value="${value%/}"
        if [[ "$value" == */* ]] && [[ "$value" != *NOMBRE* ]]; then
          GITHUB_REPOSITORIES+=("$value")
        fi
        ;;
    esac
  done < "$SECRETS_FILE"
}

stack_status() {
  aws cloudformation describe-stacks \
    --stack-name "$1" \
    --region "$REGION" \
    --query 'Stacks[0].StackStatus' \
    --output text 2>/dev/null
}

stack_exists() {
  stack_status "$1" >/dev/null 2>&1
}

delete_stack() {
  local stack="$1"
  local label="$2"

  log "$label: eliminando stack $stack"
  if ! stack_exists "$stack"; then
    ok "Stack $stack no existe"
    return 0
  fi

  if [ "$DRY_RUN" = true ]; then
    run aws cloudformation delete-stack --stack-name "$stack" --region "$REGION"
    return 0
  fi

  if ! aws cloudformation delete-stack --stack-name "$stack" --region "$REGION"; then
    error "No se pudo iniciar la eliminacion de $stack"
    return 1
  fi

  if aws cloudformation wait stack-delete-complete \
    --stack-name "$stack" \
    --region "$REGION"; then
    ok "Stack $stack eliminado"
    return 0
  fi

  error "CloudFormation no pudo eliminar $stack"
  aws cloudformation describe-stack-events \
    --stack-name "$stack" \
    --region "$REGION" \
    --query 'StackEvents[?ResourceStatus==`DELETE_FAILED`] | [0:10].[LogicalResourceId,ResourceType,ResourceStatusReason]' \
    --output table 2>/dev/null || true
  return 1
}

wait_for_namespace_deletion() {
  local attempts=60
  local i

  for i in $(seq 1 "$attempts"); do
    if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
      ok "Namespace $NAMESPACE eliminado"
      return 0
    fi
    sleep 5
  done

  error "Namespace $NAMESPACE sigue presente despues de 5 minutos"
  kubectl get namespace "$NAMESPACE" -o yaml 2>/dev/null | \
    sed -n '/finalizers:/,/^[^ ]/p' || true
  return 1
}

tagged_load_balancers() {
  aws resourcegroupstaggingapi get-resources \
    --region "$REGION" \
    --resource-type-filters elasticloadbalancing:loadbalancer \
    --tag-filters "Key=kubernetes.io/cluster/$CLUSTER_NAME" \
    --query 'ResourceTagMappingList[].ResourceARN' \
    --output text 2>/dev/null || true
}

tagged_security_groups() {
  aws ec2 describe-security-groups \
    --region "$REGION" \
    --filters \
      "Name=tag:kubernetes.io/cluster/$CLUSTER_NAME,Values=owned,shared" \
    --query 'SecurityGroups[].GroupId' \
    --output text 2>/dev/null || true
}

cluster_network_interfaces() {
  aws ec2 describe-network-interfaces \
    --region "$REGION" \
    --filters "Name=description,Values=*$CLUSTER_NAME*" \
    --query 'NetworkInterfaces[].NetworkInterfaceId' \
    --output text 2>/dev/null || true
}

cluster_target_groups() {
  aws resourcegroupstaggingapi get-resources \
    --region "$REGION" \
    --resource-type-filters elasticloadbalancing:targetgroup \
    --tag-filters "Key=kubernetes.io/cluster/$CLUSTER_NAME" \
    --query 'ResourceTagMappingList[].ResourceARN' \
    --output text 2>/dev/null || true
}

delete_orphan_target_groups() {
  local target_groups
  local arn

  target_groups="$(cluster_target_groups)"
  if [ -z "$target_groups" ] || [ "$target_groups" = "None" ]; then
    ok "No se detectaron target groups etiquetados para $CLUSTER_NAME"
    return 0
  fi

  warn "Se detectaron target groups huerfanos asociados al cluster"
  for arn in $target_groups; do
    run aws elbv2 delete-target-group \
      --target-group-arn "$arn" \
      --region "$REGION" || error "No se pudo eliminar target group $arn"
  done

  [ "$DRY_RUN" = true ] && return 0
  sleep 10
  target_groups="$(cluster_target_groups)"
  if [ -n "$target_groups" ] && [ "$target_groups" != "None" ]; then
    error "Aun existen target groups asociados: $target_groups"
    return 1
  fi

  ok "Target groups asociados eliminados"
}

delete_orphan_load_balancers() {
  local load_balancers
  local arn
  local attempt

  log "  Esperando retiro de LoadBalancers de Kubernetes"
  if [ "$DRY_RUN" = true ]; then
    load_balancers="$(tagged_load_balancers)"
    if [ -z "$load_balancers" ] || [ "$load_balancers" = "None" ]; then
      ok "No se detectaron LoadBalancers etiquetados para $CLUSTER_NAME"
      return 0
    fi
    for arn in $load_balancers; do
      echo "  [dry-run] eliminaria LoadBalancer etiquetado: $arn"
    done
    return 0
  fi

  for attempt in $(seq 1 36); do
    load_balancers="$(tagged_load_balancers)"
    if [ -z "$load_balancers" ] || [ "$load_balancers" = "None" ]; then
      ok "No quedan LoadBalancers etiquetados para $CLUSTER_NAME"
      return 0
    fi
    sleep 5
  done

  warn "Persisten LoadBalancers; se intentara eliminarlos por su etiqueta de cluster"
  for arn in $load_balancers; do
    if [[ "$arn" == *":loadbalancer/app/"* ]] || \
       [[ "$arn" == *":loadbalancer/net/"* ]] || \
       [[ "$arn" == *":loadbalancer/gwy/"* ]]; then
      run aws elbv2 delete-load-balancer \
        --load-balancer-arn "$arn" \
        --region "$REGION" || error "No se pudo eliminar LoadBalancer $arn"
    else
      run aws elb delete-load-balancer \
        --load-balancer-name "${arn##*/}" \
        --region "$REGION" || error "No se pudo eliminar Classic LoadBalancer $arn"
    fi
  done

  [ "$DRY_RUN" = true ] && return 0
  sleep 30
  load_balancers="$(tagged_load_balancers)"
  if [ -n "$load_balancers" ] && [ "$load_balancers" != "None" ]; then
    error "Aun existen LoadBalancers asociados: $load_balancers"
    return 1
  fi

  ok "LoadBalancers asociados eliminados"
}

delete_kubernetes_resources() {
  log "[1/8] Eliminando recursos Kubernetes"

  local cluster_status
  cluster_status="$(aws eks describe-cluster \
    --name "$CLUSTER_NAME" \
    --region "$REGION" \
    --query 'cluster.status' \
    --output text 2>/dev/null || true)"

  if [ "$cluster_status" != "ACTIVE" ]; then
    warn "Cluster $CLUSTER_NAME no esta ACTIVE; se omite kubectl"
    delete_orphan_load_balancers
    delete_orphan_target_groups
    return 0
  fi

  if ! command_exists kubectl; then
    error "kubectl no esta instalado; no se puede retirar primero el LoadBalancer"
    return 1
  fi

  if [ "$DRY_RUN" = false ]; then
    if ! aws eks update-kubeconfig \
      --name "$CLUSTER_NAME" \
      --region "$REGION" >/dev/null; then
      error "No se pudo configurar kubeconfig para $CLUSTER_NAME"
      return 1
    fi
  else
    run aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION"
  fi

  if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    # El Service LoadBalancer se borra primero para dar tiempo al controlador de
    # AWS a retirar ELB/NLB, target groups, ENI y Security Groups antes de
    # eliminar la VPC.
    run kubectl delete service \
      --namespace "$NAMESPACE" \
      --all \
      --ignore-not-found \
      --wait=true \
      --timeout=5m || error "No se pudieron eliminar todos los Services"

    run kubectl delete namespace "$NAMESPACE" \
      --ignore-not-found \
      --wait=false || error "No se pudo solicitar la eliminacion del namespace"

    [ "$DRY_RUN" = true ] || wait_for_namespace_deletion
    delete_orphan_load_balancers
    delete_orphan_target_groups
  else
    ok "Namespace $NAMESPACE no existe"
    delete_orphan_load_balancers
    delete_orphan_target_groups
  fi

  # Estos dos recursos cluster-scoped son creados manualmente por
  # bloque06-dashboard/setup-dashboard.sh y no pertenecen al namespace ep03.
  run kubectl delete clusterrolebinding cloudwatch-fluent-bit \
    --ignore-not-found || warn "No se pudo eliminar ClusterRoleBinding cloudwatch-fluent-bit"
  run kubectl delete clusterrole cloudwatch-fluent-bit \
    --ignore-not-found || warn "No se pudo eliminar ClusterRole cloudwatch-fluent-bit"
}

delete_cloudwatch_resources() {
  log "[2/8] Eliminando recursos de CloudWatch"

  if aws cloudwatch get-dashboard \
    --dashboard-name "$DASHBOARD_NAME" \
    --region "$REGION" >/dev/null 2>&1; then
    run aws cloudwatch delete-dashboards \
      --dashboard-names "$DASHBOARD_NAME" \
      --region "$REGION" || error "No se pudo eliminar dashboard $DASHBOARD_NAME"
    [ "$DRY_RUN" = true ] || ok "Dashboard $DASHBOARD_NAME eliminado"
  else
    ok "Dashboard $DASHBOARD_NAME no existe"
  fi

  local log_groups
  log_groups="$(aws logs describe-log-groups \
    --region "$REGION" \
    --query "logGroups[?contains(logGroupName, '$CLUSTER_NAME')].logGroupName" \
    --output text 2>/dev/null || true)"

  if [ -z "$log_groups" ] || [ "$log_groups" = "None" ]; then
    ok "No hay Log Groups asociados a $CLUSTER_NAME"
  else
    local log_group
    for log_group in $log_groups; do
      run aws logs delete-log-group \
        --log-group-name "$log_group" \
        --region "$REGION" || error "No se pudo eliminar Log Group $log_group"
      [ "$DRY_RUN" = true ] || ok "Log Group $log_group eliminado"
    done
  fi

  local node_role_arn
  local node_role_name
  node_role_arn="$(aws eks describe-nodegroup \
    --cluster-name "$CLUSTER_NAME" \
    --nodegroup-name "$NODEGROUP_NAME" \
    --region "$REGION" \
    --query 'nodegroup.nodeRole' \
    --output text 2>/dev/null || true)"
  if [ -n "$node_role_arn" ] && [ "$node_role_arn" != "None" ]; then
    node_role_name="${node_role_arn##*/}"
    if aws iam list-attached-role-policies \
      --role-name "$node_role_name" \
      --query 'AttachedPolicies[].PolicyArn' \
      --output text 2>/dev/null | grep -q "$CLOUDWATCH_POLICY_ARN"; then
      run aws iam detach-role-policy \
        --role-name "$node_role_name" \
        --policy-arn "$CLOUDWATCH_POLICY_ARN" || \
        error "No se pudo retirar CloudWatchAgentServerPolicy de $node_role_name"
      [ "$DRY_RUN" = true ] || ok "CloudWatchAgentServerPolicy retirada del rol de nodos"
    fi
  fi
}

delete_ecr_repositories() {
  log "[4/8] Eliminando repositorios ECR"

  if [ "${#ECR_REPOSITORIES[@]}" -eq 0 ]; then
    warn "No se encontraron repositorios en $ECR_REPOS_FILE"
    return 0
  fi

  local repo
  for repo in "${ECR_REPOSITORIES[@]}"; do
    if aws ecr describe-repositories \
      --repository-names "$repo" \
      --region "$REGION" >/dev/null 2>&1; then
      run aws ecr delete-repository \
        --repository-name "$repo" \
        --region "$REGION" \
        --force || error "No se pudo eliminar ECR $repo"
      [ "$DRY_RUN" = true ] || ok "ECR $repo eliminado"
    else
      ok "ECR $repo no existe"
    fi
  done
}

delete_github_repositories() {
  log "[6/8] Eliminando repositorios GitHub configurados"

  if [ "$DELETE_GITHUB" = false ]; then
    ok "Repositorios GitHub conservados; usa --delete-github para eliminarlos"
    return 0
  fi

  if [ "${#GITHUB_REPOSITORIES[@]}" -eq 0 ]; then
    warn "No hay repositorios GitHub validos en secrets.txt"
    return 0
  fi

  if ! command_exists gh; then
    error "GitHub CLI (gh) no esta instalado; repositorios GitHub no eliminados"
    return 1
  fi
  if ! gh auth status >/dev/null 2>&1; then
    error "GitHub CLI no esta autenticado; repositorios GitHub no eliminados"
    return 1
  fi

  local repo
  for repo in "${GITHUB_REPOSITORIES[@]}"; do
    if gh repo view "$repo" >/dev/null 2>&1; then
      run gh repo delete "$repo" --yes || error "No se pudo eliminar GitHub $repo"
      [ "$DRY_RUN" = true ] || ok "GitHub $repo eliminado"
    else
      ok "GitHub $repo no existe o no es accesible"
    fi
  done
}

clean_kubeconfig() {
  log "[7/8] Limpiando kubeconfig"

  if ! command_exists kubectl; then
    warn "kubectl no esta instalado; kubeconfig no fue modificado"
    return 0
  fi

  local cluster_arn="arn:aws:eks:$REGION:$ACCOUNT_ID:cluster/$CLUSTER_NAME"
  run kubectl config delete-context "$cluster_arn" >/dev/null 2>&1 || true
  run kubectl config delete-cluster "$cluster_arn" >/dev/null 2>&1 || true
  run kubectl config delete-user "$cluster_arn" >/dev/null 2>&1 || true
  run kubectl config delete-context "$CLUSTER_NAME" >/dev/null 2>&1 || true
  run kubectl config delete-cluster "$CLUSTER_NAME" >/dev/null 2>&1 || true
  run kubectl config delete-user "$CLUSTER_NAME" >/dev/null 2>&1 || true
  [ "$DRY_RUN" = true ] || ok "Entradas de $CLUSTER_NAME retiradas de kubeconfig"
}

verify_cleanup() {
  log "[8/8] Verificando limpieza"

  local found=0
  local repo
  local remaining_load_balancers
  local remaining_target_groups
  local remaining_enis
  local remaining_security_groups

  if aws eks describe-cluster \
    --name "$CLUSTER_NAME" \
    --region "$REGION" >/dev/null 2>&1; then
    error "Cluster EKS $CLUSTER_NAME aun existe"
    found=1
  else
    ok "Cluster EKS eliminado"
  fi

  if stack_exists "$STACK_EKS"; then
    error "Stack $STACK_EKS aun existe: $(stack_status "$STACK_EKS")"
    found=1
  else
    ok "Stack $STACK_EKS eliminado"
  fi

  if stack_exists "$STACK_VPC"; then
    error "Stack $STACK_VPC aun existe: $(stack_status "$STACK_VPC")"
    found=1
  else
    ok "Stack $STACK_VPC eliminado"
  fi

  for repo in "${ECR_REPOSITORIES[@]}"; do
    if aws ecr describe-repositories \
      --repository-names "$repo" \
      --region "$REGION" >/dev/null 2>&1; then
      error "ECR $repo aun existe"
      found=1
    else
      ok "ECR $repo eliminado"
    fi
  done

  if aws cloudwatch get-dashboard \
    --dashboard-name "$DASHBOARD_NAME" \
    --region "$REGION" >/dev/null 2>&1; then
    error "Dashboard $DASHBOARD_NAME aun existe"
    found=1
  else
    ok "Dashboard $DASHBOARD_NAME eliminado"
  fi

  local remaining_logs
  remaining_logs="$(aws logs describe-log-groups \
    --region "$REGION" \
    --query "logGroups[?contains(logGroupName, '$CLUSTER_NAME')].logGroupName" \
    --output text 2>/dev/null || true)"
  if [ -n "$remaining_logs" ] && [ "$remaining_logs" != "None" ]; then
    error "Aun existen Log Groups: $remaining_logs"
    found=1
  else
    ok "Log Groups del cluster eliminados"
  fi

  remaining_load_balancers="$(tagged_load_balancers)"
  if [ -n "$remaining_load_balancers" ] && [ "$remaining_load_balancers" != "None" ]; then
    error "Aun existen Load Balancers asociados: $remaining_load_balancers"
    found=1
  else
    ok "Load Balancers asociados eliminados"
  fi

  remaining_target_groups="$(cluster_target_groups)"
  if [ -n "$remaining_target_groups" ] && [ "$remaining_target_groups" != "None" ]; then
    error "Aun existen target groups asociados: $remaining_target_groups"
    found=1
  else
    ok "Target groups asociados eliminados"
  fi

  remaining_enis="$(cluster_network_interfaces)"
  if [ -n "$remaining_enis" ] && [ "$remaining_enis" != "None" ]; then
    error "Aun existen interfaces de red asociadas: $remaining_enis"
    found=1
  else
    ok "Interfaces de red asociadas eliminadas"
  fi

  remaining_security_groups="$(tagged_security_groups)"
  if [ -n "$remaining_security_groups" ] && [ "$remaining_security_groups" != "None" ]; then
    error "Aun existen Security Groups asociados: $remaining_security_groups"
    found=1
  else
    ok "Security Groups asociados eliminados"
  fi

  if [ "$DELETE_GITHUB" = true ] && command_exists gh && gh auth status >/dev/null 2>&1; then
    for repo in "${GITHUB_REPOSITORIES[@]}"; do
      if gh repo view "$repo" >/dev/null 2>&1; then
        error "GitHub $repo aun existe"
        found=1
      else
        ok "GitHub $repo eliminado"
      fi
    done
  fi

  return "$found"
}

load_config
read_ecr_repositories
read_github_repositories
DASHBOARD_NAME="${CLUSTER_NAME}-observability"

printf '%b\n' "${BLUE}=============================================================${NC}"
printf '%b\n' "${BLUE} GUIA 04 - LIMPIEZA TOTAL${NC}"
printf '%b\n' "${BLUE}=============================================================${NC}"
echo "  Cuenta/region:  cuenta AWS actual / $REGION"
echo "  Cluster/stack:  $CLUSTER_NAME / $STACK_EKS"
echo "  VPC stack:      $STACK_VPC"
echo "  Namespace:      $NAMESPACE"
echo "  Dashboard:      $DASHBOARD_NAME"
echo "  ECR:            ${ECR_REPOSITORIES[*]:-(ninguno detectado)}"
echo "  GitHub:         ${GITHUB_REPOSITORIES[*]:-(ninguno detectado)}"
echo "  Borrar GitHub:  $DELETE_GITHUB"
echo ""

if [ "$DRY_RUN" = true ]; then
  warn "Modo --dry-run: no se modificara ningun recurso"
fi

for required in aws; do
  if ! command_exists "$required"; then
    echo "ERROR: falta la herramienta requerida: $required" >&2
    exit 1
  fi
done

if ! ACCOUNT_ID="$(aws sts get-caller-identity \
  --query Account \
  --output text 2>/dev/null)"; then
  echo "ERROR: credenciales AWS invalidas o vencidas." >&2
  exit 1
fi

echo "  AWS Account ID: $ACCOUNT_ID"
echo ""

if [ "$ASSUME_YES" = false ] && [ "$DRY_RUN" = false ]; then
  printf '%b\n' "${YELLOW}Esta accion elimina la infraestructura AWS configurada por guia-04.${NC}"
  if [ "$DELETE_GITHUB" = true ]; then
    printf '%b\n' "${RED}Tambien eliminara los repositorios GitHub configurados.${NC}"
  fi
  read -r -p "Escribe BORRAR para continuar: " confirmation
  if [ "$confirmation" != "BORRAR" ]; then
    echo "Operacion cancelada."
    exit 0
  fi
fi

delete_kubernetes_resources
delete_cloudwatch_resources
delete_stack "$STACK_EKS" "[3/8]"
delete_ecr_repositories
delete_stack "$STACK_VPC" "[5/8]"
delete_github_repositories
clean_kubeconfig

if [ "$DRY_RUN" = false ]; then
  verify_cleanup || true
else
  log "[8/8] Verificacion omitida en modo --dry-run"
fi

echo ""
printf '%b\n' "${BLUE}=============================================================${NC}"
if [ "$ERRORS" -eq 0 ]; then
  if [ "$DRY_RUN" = true ]; then
    printf '%b\n' "${GREEN} SIMULACION COMPLETADA${NC}"
  else
    printf '%b\n' "${GREEN} LIMPIEZA COMPLETADA${NC}"
  fi
else
  printf '%b\n' "${RED} LIMPIEZA INCOMPLETA: $ERRORS error(es)${NC}"
fi
printf '%b\n' "${BLUE}=============================================================${NC}"
echo "  Avisos: $WARNINGS"
echo "  Metricas custom de CloudWatch: AWS no permite borrarlas manualmente;"
echo "  expiran automaticamente cuando dejan de recibir datos."
echo ""

[ "$ERRORS" -eq 0 ]
