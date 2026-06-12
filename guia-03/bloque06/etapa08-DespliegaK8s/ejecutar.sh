#!/bin/bash
# ==================================================================
# ETAPA 08 — Publicar en GitHub + Desplegar en Kubernetes
# ==================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../report_helper.sh"

REGION="us-east-1"
NAMESPACE="alumnos"

# Para limpiar todos los recursos (ECR + K8s + GitHub) antes de ejecutar:
#   bash borrar-repos.sh


# ==================================================================
# Validar conectividad AWS antes de empezar
# ==================================================================
echo ""
echo "============================================================="
echo " VALIDANDO CONECTIVIDAD AWS"
echo "============================================================="
echo ""

if ! AWS_CALLER=$(aws sts get-caller-identity 2>&1); then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║   ERROR: Sin conexión a AWS                                ║"
  echo "║                                                            ║"
  echo "║   Las credenciales AWS han expirado o no están             ║"
  echo "║   configuradas.                                            ║"
  echo "║                                                            ║"
  echo "║   A continuación se te solicitarán las nuevas              ║"
  echo "║   credenciales. Tenelas a mano.                            ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""

  # Solicitar nuevas credenciales AWS al usuario
  echo "============================================================="
  echo " CONFIGURACIÓN DE CREDENCIALES AWS"
  echo "============================================================="
  echo ""
  echo "Ingresa tus nuevas credenciales AWS:"
  echo ""

  read -r -p "  AWS Access Key ID: " NEW_AWS_ACCESS_KEY_ID
  read -r -s -p "  AWS Secret Access Key: " NEW_AWS_SECRET_ACCESS_KEY
  echo ""
  read -r -s -p "  AWS Session Token (opcional, dejar vacío si no): " NEW_AWS_SESSION_TOKEN
  echo ""
  echo ""

  if [ -z "$NEW_AWS_ACCESS_KEY_ID" ] || [ -z "$NEW_AWS_SECRET_ACCESS_KEY" ]; then
    echo "❌  ERROR: AWS Access Key ID y AWS Secret Access Key son obligatorios."
    exit 1
  fi

  # Exportar las nuevas credenciales
  export AWS_ACCESS_KEY_ID="$NEW_AWS_ACCESS_KEY_ID"
  export AWS_SECRET_ACCESS_KEY="$NEW_AWS_SECRET_ACCESS_KEY"
  if [ -n "$NEW_AWS_SESSION_TOKEN" ]; then
    export AWS_SESSION_TOKEN="$NEW_AWS_SESSION_TOKEN"
  fi

  # Verificar que las nuevas credenciales funcionen
  echo "  Verificando nuevas credenciales..."
  if ! AWS_CALLER=$(aws sts get-caller-identity 2>&1); then
    echo ""
    echo "❌  ERROR: Las credenciales proporcionadas no son válidas."
    echo "  Detalle del error:"
    echo "  $AWS_CALLER" | sed 's/^/  /'
    echo ""
    echo "  Vuelve a ejecutar el script e ingresa las credenciales correctas."
    exit 1
  fi
  echo "  ✅ Nuevas credenciales válidas."
  echo ""
fi

ACCOUNT_ID=$(echo "$AWS_CALLER" | jq -r '.Account')
echo "  ✅ Conectado a AWS — Account ID: $ACCOUNT_ID"
echo ""

init_reporte "Publicación en GitHub y Despliegue en Kubernetes"

echo ""
echo "============================================================="
echo " ETAPA 08 — Publicar en GitHub + Desplegar en Kubernetes"
echo "============================================================="
echo ""

echo "  AWS Account ID: $ACCOUNT_ID"

# ==================================================================
# [PRE-ECR] Crear repositorios ECR si no existen
# ==================================================================
echo ""
echo "  Verificando repositorios ECR ..."
for repo in alumnos-db alumnos-backend alumnos-frontend; do
  if aws ecr describe-repositories --repository-names "$repo" --region "$REGION" &>/dev/null; then
    echo "    ✅ ECR $repo ya existe"
  else
    echo "    Creando ECR $repo ..."
    aws ecr create-repository --repository-name "$repo" --region "$REGION" --query 'repository.repositoryUri' --output text 2>/dev/null && echo "    ✅ ECR $repo creado" || echo "    ⚠ No se pudo crear ECR $repo"
  fi
done
echo "  ✔ Repositorios ECR verificados."
echo ""

# ==================================================================
# [PRE-DEPLOY] Reemplazar Account ID dinámicamente en los manifests
# ==================================================================
echo ""
echo "  Actualizando Account ID en manifests k8s ..."
for manifest in \
  "$SCRIPT_DIR/../../bloque04-aplicacion/paso-01-deploy-aws/202601_ep03_backend/k8s/backend-deployment.yaml" \
  "$SCRIPT_DIR/../../bloque04-aplicacion/paso-01-deploy-aws/202601_ep03_frontend/k8s/frontend-deployment.yaml" \
  "$SCRIPT_DIR/../../bloque04-aplicacion/paso-01-deploy-aws/202601_ep03_db/k8s/postgres-deployment.yaml"; do
  if [ -f "$manifest" ]; then
    # Reemplazar cualquier Account ID de 12 dígitos por el actual
    # Usando perl que es más compatible en todos los sistemas
    perl -i -pe "s/\d{12}\.dkr\.ecr/$ACCOUNT_ID.dkr.ecr/g" "$manifest"
    echo "    ✅ $(basename "$manifest")"
  else
    echo "    ⚠ No se encontró $(basename "$manifest")"
  fi
done
echo "  ✔ Account ID actualizado en manifests."

# ==================================================================
# [PRE-SECRETS] Cargar secrets desde bloque06/secrets.txt
# ==================================================================
SECRETS_FILE="$SCRIPT_DIR/../secrets.txt"
if [ -f "$SECRETS_FILE" ]; then
  echo "  Cargando secrets desde $SECRETS_FILE ..."
  while IFS='=' read -r key value; do
    # Saltar líneas vacías y comentarios
    [ -z "$key" ] && continue
    [[ "$key" == \#* ]] && continue
    # Exportar como variable de entorno
    export "$key=$value"
  done < "$SECRETS_FILE"
  # Instalar gh si no está disponible
  if ! command -v gh &>/dev/null; then
    echo "  Instalando GitHub CLI (gh)..."
    apt-get update -qq && apt-get install -y -qq gh 2>/dev/null && echo "  ✅ gh instalado" || echo "  ⚠ No se pudo instalar gh"
  fi

  # Exportar GH_TOKEN globalmente para que gh lo use en todos los comandos
  if [ -n "$GITHUB_TOKEN" ]; then
    echo "  Configurando GitHub CLI con token..."
    export GH_TOKEN="$GITHUB_TOKEN"
    echo "  ✅ GH_TOKEN configurado para gh"
  else
    echo "  ⚠ GITHUB_TOKEN no disponible, los comandos gh pueden fallar"
  fi
  echo "  ✅ Secrets cargados desde secrets.txt"
else
  echo "  ⚠ No se encontró $SECRETS_FILE"
fi

add_texto_evidencia "**AWS Account ID:** \`${ACCOUNT_ID}\`  
**Región:** \`${REGION}\`  
**Namespace Kubernetes:** \`${NAMESPACE}\`"

# ==================================================================
# Configurar kubeconfig para EKS (si no está configurado)
# ==================================================================
if ! kubectl cluster-info 2>/dev/null | grep -q "controlplane\|eks"; then
  echo "============================================================="
  echo " Configurando kubeconfig para EKS..."
  echo "============================================================="
  CLUSTER=$(aws eks list-clusters --region "$REGION" --query 'clusters[0]' --output text)
  if [ -n "$CLUSTER" ] && [ "$CLUSTER" != "None" ]; then
    aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER"
    echo "  ✔ kubeconfig configurado para el cluster: $CLUSTER"
  else
    echo "  ⚠ No se encontró ningún cluster EKS en la región $REGION"
  fi
  echo ""
fi

# ==================================================================
# [PRE] Borrar .git de los repos locales para forzar push limpio
# ==================================================================
echo "============================================================="
echo " [PRE] LIMPIANDO .git DE REPOS LOCALES"
echo "============================================================="
echo ""

K8S_BASE="../../bloque04-aplicacion/paso-01-deploy-aws"
for repo in 202601_ep03_db 202601_ep03_backend 202601_ep03_frontend; do
  REPO_DIR="$SCRIPT_DIR/$K8S_BASE/$repo"
  if [ -d "$REPO_DIR/.git" ]; then
    echo "  Eliminando .git de $repo ..."
    rm -rf "$REPO_DIR/.git"
  else
    echo "  $repo ya no tiene .git (limpio)"
  fi
done
echo ""
echo "✔ .git eliminado de los 3 repos locales."
echo ""

# ==================================================================
# PARTE A — Verificar/crear repos en GitHub y configurar secrets
# ==================================================================
echo "============================================================="
echo " [A] VERIFICANDO REPOSITORIOS EN GITHUB"
echo "============================================================="
echo ""

GH_USER="mauriciovelasquezduoc"
for repo in 202601_ep03_db 202601_ep03_backend 202601_ep03_frontend; do
  if gh repo view "$GH_USER/$repo" --json name &>/dev/null; then
    echo "  ✔ $repo ya existe en GitHub"
  else
    echo "  Creando $repo ..."
    gh repo create "$repo" --public --description "Gestor de Alumnos EKS"
  fi
done

# Actualizar secrets en los 3 repos (siempre se sobreescriben con valor actual)
for repo in 202601_ep03_db 202601_ep03_backend 202601_ep03_frontend; do
  echo ""
  echo "  Actualizando secrets en $repo ..."
  if [ -n "$aws_access_key_id" ]; then
    gh secret set AWS_ACCESS_KEY_ID --body "$aws_access_key_id" --repo "$GH_USER/$repo" && echo "    ✅ AWS_ACCESS_KEY_ID" || echo "    ⚠ No se pudo actualizar AWS_ACCESS_KEY_ID"
  fi
  if [ -n "$aws_secret_access_key" ]; then
    gh secret set AWS_SECRET_ACCESS_KEY --body "$aws_secret_access_key" --repo "$GH_USER/$repo" && echo "    ✅ AWS_SECRET_ACCESS_KEY" || echo "    ⚠ No se pudo actualizar AWS_SECRET_ACCESS_KEY"
  fi
  if [ -n "$aws_session_token" ]; then
    gh secret set AWS_SESSION_TOKEN --body "$aws_session_token" --repo "$GH_USER/$repo" && echo "    ✅ AWS_SESSION_TOKEN" || echo "    ⚠ No se pudo actualizar AWS_SESSION_TOKEN"
  fi
  if [ -n "$AWS_REGION" ]; then
    gh secret set AWS_REGION --body "$AWS_REGION" --repo "$GH_USER/$repo" && echo "    ✅ AWS_REGION" || echo "    ⚠ No se pudo actualizar AWS_REGION"
  fi
  if [ -n "$SONAR_TOKEN" ]; then
    gh secret set SONAR_TOKEN --body "$SONAR_TOKEN" --repo "$GH_USER/$repo" && echo "    ✅ SONAR_TOKEN" || echo "    ⚠ No se pudo actualizar SONAR_TOKEN"
  fi
  if [ -n "$SNYK_TOKEN" ]; then
    gh secret set SNYK_TOKEN --body "$SNYK_TOKEN" --repo "$GH_USER/$repo" && echo "    ✅ SNYK_TOKEN" || echo "    ⚠ No se pudo actualizar SNYK_TOKEN"
  fi
done
cd "$SCRIPT_DIR"

echo ""
echo "✔ Repositorios y secrets configurados en GitHub."
echo ""

# ==================================================================
# PARTE B — Push del código local a GitHub (dispara CI/CD → ECR)
# ==================================================================
echo "============================================================="
echo " [B] PUBLICANDO CÓDIGO LOCAL EN GITHUB (CI/CD → ECR)"
echo "============================================================="
echo ""

for repo in 202601_ep03_db 202601_ep03_backend 202601_ep03_frontend; do
  REPO_DIR="$SCRIPT_DIR/$K8S_BASE/$repo"
  echo "--- $repo ---"

  cd "$REPO_DIR"

  # Inicializar git
  git init -b main 2>/dev/null
  git config user.name "github-actions[bot]"
  git config user.email "github-actions[bot]@users.noreply.github.com"

  # Usar HTTPS con token en vez de SSH (no requiere llave SSH)
  GIT_REPO_URL="https://x-access-token:${GH_TOKEN}@github.com/${GH_USER}/${repo}.git"
  git remote add origin "${GIT_REPO_URL}" 2>/dev/null || git remote set-url origin "${GIT_REPO_URL}"

  # Agregar y commitear
  git add -A
  git commit -m "feat: Gestor de Alumnos EKS" 2>/dev/null || echo "  (sin cambios nuevos)"

  # Push forzado
  git push -f origin main 2>&1 || {
    echo "  Intentando con master..."
    git branch -m main master 2>/dev/null
    git push -f origin master 2>&1 || echo "  ⚠ Error al hacer push de $repo"
  }

  # Limpiar URL para no exponer token en el remote
  git remote set-url origin "https://github.com/${GH_USER}/${repo}.git" 2>/dev/null

  echo ""
done

cd "$SCRIPT_DIR"

echo ""
echo "✔ Código local publicado en GitHub. GitHub Actions construirá las imágenes."
echo ""

# ==================================================================
# PARTE C — Esperar a que las imágenes estén disponibles en ECR
# ==================================================================
echo "============================================================="
echo " [C] ESPERANDO IMÁGENES EN ECR (máx 10 min)"
echo "============================================================="
echo ""

IMAGES=("alumnos-db:latest" "alumnos-backend:latest" "alumnos-frontend:latest")
MAX_RETRIES=60
SLEEP_SECS=10

for IMAGE in "${IMAGES[@]}"; do
  echo ""
  echo "  Esperando imagen: $IMAGE ..."
  RETRY=0
  FOUND=false
  while [ $RETRY -lt $MAX_RETRIES ]; do
    REPO_NAME="${IMAGE%%:*}"
    if aws ecr describe-images --repository-name "$REPO_NAME" --image-ids imageTag=latest --region "$REGION" &>/dev/null; then
      echo "  ✔ Imagen $IMAGE encontrada en ECR (intento $((RETRY+1)))"
      FOUND=true
      break
    fi
    RETRY=$((RETRY+1))
    printf "\r    intento %2d/%d — esperando..." "$RETRY" "$MAX_RETRIES"
    sleep "$SLEEP_SECS"
  done
  if [ "$FOUND" = false ]; then
    echo ""
    echo "ERROR: Imagen $IMAGE no apareció en ECR tras 10 minutos."
    echo "Revisa los GitHub Actions en:"
    echo "  https://github.com/<tu-usuario>/202601_ep03_$REPO_NAME/actions"
    exit 1
  fi
done

add_evidencia "Imágenes disponibles en ECR" "for repo in alumnos-db alumnos-backend alumnos-frontend; do echo '---'; echo \$repo; aws ecr describe-images --repository-name \$repo --region $REGION --query 'imageDetails[*].imageTags' --output table 2>/dev/null; done" "IE2"

echo ""
echo "✔ Las 3 imágenes están disponibles en ECR."
echo ""

# ==================================================================
# PARTE D — Desplegar en Kubernetes (DB → Backend → Frontend)
# ==================================================================
echo "============================================================="
echo " [D] DESPLEGANDO EN KUBERNETES (DB → Backend → Frontend)"
echo "============================================================="

K8S_BASE="../../bloque04-aplicacion/paso-01-deploy-aws"

# D1. DATABASE
echo ""
echo "--- [D1/3] DESPLEGANDO POSTGRES DATABASE ---"

DB_DIR="$K8S_BASE/202601_ep03_db/k8s"
cd "$DB_DIR"

kubectl apply -f namespace.yaml
kubectl apply -f postgres-secret.yaml
kubectl apply -f postgres-service.yaml
kubectl apply -f postgres-deployment.yaml
kubectl wait --for=condition=Ready pod -l app=alumnos-db -n $NAMESPACE --timeout=120s 2>/dev/null || echo "  (espera manual si tarda mas de 2 min)"

cd "$SCRIPT_DIR"

# D2. BACKEND
echo ""
echo "--- [D2/3] DESPLEGANDO BACKEND API ---"

BACK_DIR="$K8S_BASE/202601_ep03_backend/k8s"
cd "$BACK_DIR"

kubectl apply -f namespace.yaml
kubectl apply -f backend-service.yaml
kubectl apply -f backend-deployment.yaml
if [ -f backend-hpa.yaml ]; then kubectl apply -f backend-hpa.yaml; fi
kubectl wait --for=condition=Ready pod -l app=alumnos-backend -n $NAMESPACE --timeout=120s 2>/dev/null || echo "  (espera manual si tarda mas de 2 min)"

cd "$SCRIPT_DIR"

# D3. FRONTEND
echo ""
echo "--- [D3/3] DESPLEGANDO FRONTEND WEB ---"

FRONT_DIR="$K8S_BASE/202601_ep03_frontend/k8s"
cd "$FRONT_DIR"

kubectl apply -f namespace.yaml
kubectl apply -f frontend-service.yaml
kubectl apply -f frontend-deployment.yaml
if [ -f frontend-hpa.yaml ]; then kubectl apply -f frontend-hpa.yaml; fi
kubectl wait --for=condition=Ready pod -l app=alumnos-frontend -n $NAMESPACE --timeout=120s 2>/dev/null || echo "  (espera manual si tarda mas de 2 min)"

cd "$SCRIPT_DIR"

# ==================================================================
# PARTE E — Auto-reparación: detectar ImagePullBackOff y corregir
# ==================================================================
echo ""
echo "============================================================="
echo " [E] VERIFICANDO PODS Y CORRIGIENDO ERRORES COMUNES"
echo "============================================================="
echo ""

NODE_ROLE_ARN=$(aws eks describe-nodegroup --cluster-name "$(aws eks list-clusters --region $REGION --query 'clusters[0]' --output text)" --nodegroup-name "$(aws eks list-nodegroups --cluster-name "$(aws eks list-clusters --region $REGION --query 'clusters[0]' --output text)" --region $REGION --query 'nodegroups[0]' --output text)" --region $REGION --query 'nodegroup.nodeRole' --output text 2>/dev/null || echo "")

for app in alumnos-db alumnos-backend alumnos-frontend; do
  POD_STATUS=$(kubectl get pods -n $NAMESPACE -l app=$app --no-headers 2>/dev/null | awk '{print $3}')
  echo ""
  echo "  Verificando $app (status: ${POD_STATUS:-sin pods}) ..."

  # Caso 1: ImagePullBackOff -> configurar política ECR y borrar pod
  if echo "$POD_STATUS" | grep -q "ImagePullBackOff\|ErrImagePull\|ImagePull"; then
    echo "    ⚠ Detectedo ImagePullBackOff en $app"
    echo "    Configurando política ECR para el NodeGroup..."

    if [ -n "$NODE_ROLE_ARN" ]; then
      aws ecr set-repository-policy \
        --repository-name "$app" \
        --region $REGION \
        --policy-text "{
          \"Version\": \"2008-10-17\",
          \"Statement\": [{
            \"Sid\": \"AllowNodeGroupPull\",
            \"Effect\": \"Allow\",
            \"Principal\": {\"AWS\": \"$NODE_ROLE_ARN\"},
            \"Action\": [\"ecr:BatchCheckLayerAvailability\",\"ecr:BatchGetImage\",\"ecr:GetDownloadUrlForLayer\"]
          }]
        }" >/dev/null 2>&1 && echo "    ✅ Política ECR actualizada para $app" || echo "    ⚠ No se pudo actualizar política ECR"
    fi

    echo "    Eliminando pod $app para forzar recreación..."
    kubectl delete pod -n $NAMESPACE -l app=$app --grace-period=0 --force 2>/dev/null || true
    echo "    ✅ Pod $app eliminado, Kubernetes lo recreará automáticamente"
  fi

  # Caso 2: Pending (posiblemente por taints)
  if echo "$POD_STATUS" | grep -q "Pending"; then
    echo "    ⚠ Pod en estado Pending, puede ser por taints o recursos"
    echo "    Eliminando pod $app para forzar rescheduling..."
    kubectl delete pod -n $NAMESPACE -l app=$app --grace-period=0 --force 2>/dev/null || true
    echo "    ✅ Pod $app eliminado"
  fi

  # Caso 3: Sin pods (el deployment no creó ninguno)
  if [ -z "$POD_STATUS" ]; then
    echo "    ⚠ No hay pods para $app, puede que el deployment esté arrancando"
  fi
done

# Esperar unos segundos y verificar estado final
echo ""
echo "  Esperando 10s para que los pods se estabilicen..."
sleep 10

echo ""
echo "  Estado actual de pods:"
kubectl get pods -n $NAMESPACE -o wide 2>/dev/null || true
echo ""

echo "✔ Auto-reparación completada."
echo ""

# Si aún hay pods en ImagePullBackOff, mostrar mensaje con solución manual
REMAINING_ISSUES=$(kubectl get pods -n $NAMESPACE --no-headers 2>/dev/null | grep -c "ImagePullBackOff\|ErrImagePull" || true)
if [ "$REMAINING_ISSUES" -gt 0 ]; then
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║   ⚠  Aún hay $REMAINING_ISSUES pod(s) con problemas de imagen.        ║"
  echo "║   Puedes intentar borrarlos manualmente con:               ║"
  echo "║     kubectl delete pod -n $NAMESPACE -l app=alumnos-backend  ║"
  echo "║     kubectl delete pod -n $NAMESPACE -l app=alumnos-db      ║"
  echo "║     kubectl delete pod -n $NAMESPACE -l app=alumnos-frontend ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
fi

# ==================================================================
# EVIDENCIAS POST-DEPLOY
# ==================================================================
add_evidencia "Pods desplegados en namespace alumnos" "kubectl get pods -n $NAMESPACE -o wide" "IE2"

add_evidencia "Services en namespace alumnos" "kubectl get svc -n $NAMESPACE" "IE2"

add_evidencia "HPA configurados" "kubectl get hpa -n $NAMESPACE 2>/dev/null || echo '(sin HPAs configurados)'" "IE3"

add_evidencia "Deployments activos" "kubectl get deployment -n $NAMESPACE" "IE2"

cerrar_reporte

echo ""
echo "============================================================="
echo " ETAPA 08 COMPLETADA — GitHub + K8s desplegado"
echo "============================================================="
echo ""
echo "  📋 Reporte generado en: docs/reports/etapa08-DespliegaK8s.md"
echo ""
echo "  💡 Para evidencia en README de tus repos, copia las secciones:"
echo "     - Services para frontend (LoadBalancer URL)"
echo "     - Deployments para backend"
echo "     - HPA para autoscaling"
echo ""
echo "Continua con: cd ../etapa09-ValidaApp"
echo ""
