#!/bin/bash
set -e

# =====================================================
# Script: github-action.sh
# Publica los 3 microservicios en GitHub usando SSH.
# Dinámico: obtiene el usuario de gh auth y configura
# el remote en formato git@github.com:$USER/$repo.git.
# Totalmente no-interactivo.
# =====================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# -----------------------------------------------------
# Obtener usuario GitHub autenticado (dinámico)
# -----------------------------------------------------
if ! command -v gh &> /dev/null; then
  echo "ERROR: GitHub CLI (gh) no está instalado."
  exit 1
fi

USER_GITHUB=$(gh api user --jq '.login' 2>/dev/null)
if [ -z "$USER_GITHUB" ]; then
  echo "ERROR: No se pudo obtener el usuario GitHub. Verifica gh auth status."
  exit 1
fi

echo ""
echo "============================================================="
echo " DEPLOY A GITHUB — Usuario: $USER_GITHUB"
echo "============================================================="
echo ""

# Agregar github.com a known_hosts para evitar prompt interactivo
if ! ssh-keygen -F github.com &>/dev/null; then
  echo "Agregando github.com a known_hosts..."
  ssh-keyscan -H github.com >> ~/.ssh/known_hosts 2>/dev/null || true
fi

# -----------------------------------------------------
# Obtener ID de cuenta AWS y reemplazar en k8s manifests
# -----------------------------------------------------
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
if [ -n "$AWS_ACCOUNT_ID" ]; then
  echo "AWS Account ID: $AWS_ACCOUNT_ID"
  echo "Reemplazando CAMBIAR_CUENTA por $AWS_ACCOUNT_ID en los k8s manifests..."

  K8S_FILES=(
    "$SCRIPT_DIR/202601_ep03_db/k8s/mysql-deployment.yaml"
    "$SCRIPT_DIR/202601_ep03_backend/k8s/backend-deployment.yaml"
    "$SCRIPT_DIR/202601_ep03_frontend/k8s/frontend-deployment.yaml"
  )

  for yaml_file in "${K8S_FILES[@]}"; do
    if [ -f "$yaml_file" ]; then
      sed -i.bak "s/CAMBIAR_CUENTA/$AWS_ACCOUNT_ID/g" "$yaml_file" && rm -f "$yaml_file.bak"
      echo "  ✔ $(basename "$(dirname "$(dirname "$yaml_file")")")/k8s/$(basename "$yaml_file")"
    else
      echo "  ⚠ No encontrado: $yaml_file"
    fi
  done
  echo ""
else
  echo "⚠ No se pudo obtener AWS Account ID. Verifica credenciales AWS."
  echo "  CAMBIAR_CUENTA NO será reemplazado en los manifests."
  echo ""
fi

# -----------------------------------------------------
# Repositorios a publicar
# -----------------------------------------------------
REPOS=(
  "202601_ep03_db"
  "202601_ep03_backend"
  "202601_ep03_frontend"
)

for repo in "${REPOS[@]}"; do

  echo "========================================="
  echo " Procesando: $repo"
  echo "========================================="

  if [ ! -d "$SCRIPT_DIR/$repo" ]; then
    echo "  ⚠ Directorio $repo no encontrado. Saltando..."
    continue
  fi

  cd "$SCRIPT_DIR/$repo"

  # [0] Crear repositorio en GitHub si no existe
  echo "[0] Verificando repositorio en GitHub..."
  if gh repo view "$USER_GITHUB/$repo" &>/dev/null; then
    echo "    Repositorio $USER_GITHUB/$repo ya existe en GitHub."
  else
    echo "    Creando repositorio $USER_GITHUB/$repo..."
    gh repo create "$USER_GITHUB/$repo" --public 2>&1 || {
      echo "    ⚠ No se pudo crear el repositorio. ¿gh auth token válido?"
    }
  fi

  # [1] Inicializar git si no existe
  if [ ! -d ".git" ]; then
    echo "[1] Inicializando repositorio git..."
    git init
    git branch -M main
  else
    echo "[1] Repositorio git ya inicializado."
  fi

  # [2] Configurar remote SSH dinámico
  REMOTE_URL="git@github.com:$USER_GITHUB/$repo.git"
  if git remote get-url origin &>/dev/null; then
    echo "[2] Actualizando remote origin..."
    git remote set-url origin "$REMOTE_URL"
  else
    echo "[2] Agregando remote origin..."
    git remote add origin "$REMOTE_URL"
  fi
  echo "    Remote → $REMOTE_URL"

  # [3] Agregar archivos
  echo "[3] Agregando archivos..."
  git add .

  # [4] Commit (no-interactivo)
  echo "[4] Haciendo commit..."
  git commit -m "Deploy inicial - $repo" 2>&1 || echo "    (sin cambios nuevos que commitear)"

  # [5] Push a main (detecta si es reset o primer push)
  echo "[5] Subiendo a GitHub (SSH)..."

  # Desactivar set -e temporalmente para que un fallo de red/SSH no mate el script
  set +e

  REMOTE_HAS_CONTENT=$(GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10" \
    git ls-remote origin main 2>/dev/null)
  LS_EXIT=$?

  PUSH_OK=0
  if [ $LS_EXIT -ne 0 ]; then
    echo "    ⚠ No se pudo contactar el remoto (¿SSH key configurada?)."
    echo "    Saltando push para $repo — revisa ~/.ssh/config y gh ssh-key add."
  elif [ -n "$REMOTE_HAS_CONTENT" ]; then
    echo "    Repositorio remoto ya existe → haciendo push --force (reset)..."
    if GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10" \
         git push --force -u origin main 2>&1; then
      echo "    ✔ Repositorio remoto pisado con la nueva versión."
      PUSH_OK=1
    else
      echo "    ✗ Falló el push --force."
    fi
  else
    echo "    Primer push a repositorio vacío..."
    if GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10" \
         git push -u origin main 2>&1; then
      echo "    ✔ Código publicado."
      PUSH_OK=1
    else
      echo "    ✗ Falló el push."
    fi
  fi

  set -e

  if [ $PUSH_OK -eq 0 ]; then
    echo ""
    echo "============================================================="
    echo " ERROR CRÍTICO: $repo — push a GitHub falló."
    echo " Motivo: problema de SSH o conexión con GitHub."
    echo ""
    echo " Soluciones:"
    echo "   1. Verifica que tu SSH key esté registrada en GitHub:"
    echo "      gh ssh-key list"
    echo "   2. Verifica la conexión SSH:"
    echo "      ssh -T git@github.com"
    echo "   3. Revisa ~/.ssh/config"
    echo "============================================================="
    exit 1
  fi

  echo ""
  echo "✔ $repo completado."
  echo ""

  # Esperar 60s entre repos (db → backend → frontend), excepto el último
  if [ "$repo" != "${REPOS[-1]}" ]; then
    echo "⏳ Esperando 60 segundos antes del siguiente repositorio..."
    for sec in $(seq 60 -1 1); do
      printf "\r    %2d segundos restantes... " "$sec"
      sleep 1
    done
    printf "\r    Continuando...                    \n"
    echo ""
  fi

done

# -----------------------------------------------------
# Generar README automático con lo realizado
# -----------------------------------------------------
cat > "$SCRIPT_DIR/README.md" << 'README_EOF'
# Deploy de aplicaciones a GitHub

## Qué hace este script

`github-action.sh` automatiza la publicación inicial de los 3 microservicios
en GitHub usando SSH, de forma completamente **no-interactiva** y **dinámica**.

## Flujo

1. Obtiene dinámicamente el usuario GitHub autenticado (`gh api user --jq '.login'`)
2. Agrega `github.com` a `known_hosts` para evitar prompts SSH
3. Para cada repositorio (`202601_ep03_db`, `202601_ep03_backend`, `202601_ep03_frontend`):
   - Inicializa git (si no existe `.git`)
   - Configura/actualiza el remote SSH: `git@github.com:$USER/$repo.git`
   - `git add .` + `git commit -m "Deploy inicial"`
   - Detecta si el repo remoto ya existe (`git ls-remote`):
     - Si existe → `git push --force` (reset, pisa el remoto)
     - Si no existe → `git push -u origin main` (primer push)

## Requisitos

- GitHub CLI (`gh`) autenticado con token
- SSH key ed25519 registrada en GitHub (`gh ssh-key add`)
- Código fuente en los directorios correspondientes

## Uso

```bash
cd bloque04-aplicacion/paso-01-deploy-aws
bash github-action.sh
```
README_EOF

echo "============================================================="
echo " DEPLOY COMPLETADO"
echo "============================================================="
echo ""
echo "Repositorios publicados:"
for repo in "${REPOS[@]}"; do
  echo "  https://github.com/$USER_GITHUB/$repo"
done
echo ""
echo "README actualizado: $SCRIPT_DIR/README.md"
echo ""
