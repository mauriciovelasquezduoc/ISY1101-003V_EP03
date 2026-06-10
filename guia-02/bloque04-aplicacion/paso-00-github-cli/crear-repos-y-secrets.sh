#!/bin/bash
set -e

# =====================================================
# Script: crear-repos-y-secrets.sh
# Crea 3 repositorios y configura 6 Secrets en GitHub
# usando GitHub CLI (gh).
#
# Los secretos se leen desde el archivo secrets.txt
# (formato key=value, una por línea). Las claves se
# mapean case-insensitive a los nombres de GitHub Secrets.
# =====================================================

# -----------------------------------------------------
# Configuración
# -----------------------------------------------------

REPOS=(
  "202601_ep03_frontend"
  "202601_ep03_backend"
  "202601_ep03_db"
)

SECRETS=(
  "AWS_ACCESS_KEY_ID"
  "AWS_REGION"
  "AWS_SECRET_ACCESS_KEY"
  "AWS_SESSION_TOKEN"
  "SNYK_TOKEN"
  "SONAR_TOKEN"
)

REPO_VISIBILITY="public"
COLLABORATOR="mauriciovelasquezduoc"
ORG=""  # dejar vacío para repos personales

# -----------------------------------------------------
# Funciones auxiliares
# -----------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# El archivo secrets.txt ahora está en la raíz del proyecto (guia-02/), al lado de pasos.md
SCRIPT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SECRETS_FILE="$SCRIPT_ROOT/secrets.txt"

banner() {
  echo ""
  echo "========================================="
  echo " $1"
  echo "========================================="
  echo ""
}

cargar_secrets_desde_archivo() {
  # Lee secrets.txt (formato key=value) y devuelve arrays
  # SECRETS_KEYS y SECRETS_VALS con los pares leídos.
  SECRETS_KEYS=()
  SECRETS_VALS=()

  if [ ! -f "$SECRETS_FILE" ]; then
    echo "ERROR: No se encontró el archivo $SECRETS_FILE"
    echo "       Créalo con el formato key=value (una por línea)."
    exit 1
  fi

  while IFS='=' read -r key value || [ -n "$key" ]; do
    # Saltar líneas vacías o comentarios
    [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)
    SECRETS_KEYS+=("$key")
    SECRETS_VALS+=("$value")
  done < "$SECRETS_FILE"
}

# Mapea claves de secrets.txt a nombres de GitHub Secrets.
# Las claves que no se encuentren quedan vacías.
mapear_secreto() {
  local github_name="$1"
  local result=""
  for i in "${!SECRETS_KEYS[@]}"; do
    local k="${SECRETS_KEYS[$i]}"
    # Mapeo case-insensitive + guiones bajos
    local k_upper
    k_upper=$(echo "$k" | tr '[:lower:]' '[:upper:]')
    if [ "$k_upper" = "$github_name" ]; then
      result="${SECRETS_VALS[$i]}"
      break
    fi
  done
  echo "$result"
}

# Busca una clave exacta (case-sensitive) en los arrays ya cargados
obtener_valor_raw() {
  local target="$1"
  for i in "${!SECRETS_KEYS[@]}"; do
    if [ "${SECRETS_KEYS[$i]}" = "$target" ]; then
      echo "${SECRETS_VALS[$i]}"
      return
    fi
  done
}

# -----------------------------------------------------
# INICIO
# -----------------------------------------------------

banner "CREACIÓN DE REPOSITORIOS Y SECRETS EN GITHUB"

# Validar que gh está instalado y autenticado
if ! command -v gh &> /dev/null; then
  echo "ERROR: GitHub CLI (gh) no está instalado."
  echo "       Instálalo desde: https://cli.github.com"
  exit 1
fi

# Cargar secrets.txt temprano para obtener GITHUB_TOKEN y autenticar no-interactivo
cargar_secrets_desde_archivo
GH_TOKEN=$(obtener_valor_raw "GITHUB_TOKEN")

unset GITHUB_TOKEN

if ! gh auth status &> /dev/null; then
  if [ -n "$GH_TOKEN" ]; then
    echo ""
    echo "Autenticando con GITHUB_TOKEN desde secrets.txt..."
    echo "$GH_TOKEN" | gh auth login --with-token
  else
    echo ""
    echo "No hay GITHUB_TOKEN en secrets.txt."
    echo "Iniciando autenticación interactiva..."
    gh auth login
  fi
fi

echo ""
gh auth status

# -----------------------------------------------------
# Configurar SSH key para GitHub (operar sin credenciales)
# -----------------------------------------------------
SSH_KEY="$HOME/.ssh/github_ed25519"
SSH_KEY_TITLE="$(hostname)-$(date +%Y%m%d)"

if [ -f "$SSH_KEY" ]; then
  echo ""
  echo "SSH key ya existe: $SSH_KEY"
else
  echo ""
  echo "Generando SSH key ed25519 para GitHub..."
  ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "github-$(hostname)"
  echo ""
  echo "Registrando SSH key pública en GitHub..."
  gh ssh-key add "$SSH_KEY.pub" --title "$SSH_KEY_TITLE"
  echo "SSH key registrada: $SSH_KEY_TITLE"
fi

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github_ed25519
ssh-add -l

# Obtener el owner (usuario autenticado o la org configurada)
if [ -n "$ORG" ]; then
  GH_OWNER="$ORG"
else
  GH_OWNER=$(gh api user -q '.login')
  echo ""
  echo "Usuario GitHub autenticado: $GH_OWNER"
fi

# -----------------------------------------------------
# PARTE 1 — Crear / verificar repositorios
# -----------------------------------------------------

banner "PARTE 1 — REPOSITORIOS"

REPO_DETAILS=()

for repo in "${REPOS[@]}"; do

  FULL_NAME="$GH_OWNER/$repo"

  echo ">>> Procesando: $FULL_NAME"

  if gh repo view "$FULL_NAME" &> /dev/null; then
    echo "    Ya existe. Continuando..."
  else
    echo "    Creando repositorio..."
    gh repo create "$FULL_NAME" \
      --"$REPO_VISIBILITY" \
      --clone \
      --description "Repositorio generado para $repo — ${REPO_VISIBILITY}" 2>/dev/null || \
    gh repo create "$FULL_NAME" \
      --"$REPO_VISIBILITY" \
      --description "Repositorio generado para $repo — ${REPO_VISIBILITY}"
  fi

  # Agregar colaborador como admin
  echo "    Agregando colaborador admin: $COLLABORATOR"
  gh api \
    -X PUT \
    "/repos/$FULL_NAME/collaborators/$COLLABORATOR" \
    -f permission=admin 2>/dev/null && \
    echo "    ✔ $COLLABORATOR agregado como admin" || \
    echo "    ⚠ No se pudo agregar a $COLLABORATOR (puede que ya esté o requiera aceptar invitación)"

  # Guardar URL para mostrar después
  REPO_URL=$(gh repo view "$FULL_NAME" --json url -q ".url" 2>/dev/null || echo "no disponible")
  REPO_DETAILS+=("$repo|$REPO_URL")

done

# -----------------------------------------------------
# PARTE 2 — Leer secretos desde secrets.txt
# -----------------------------------------------------

banner "PARTE 2 — LECTURA DE SECRETOS DESDE secrets.txt"

echo "Archivo leído: $SECRETS_FILE"
echo "Se encontraron ${#SECRETS_KEYS[@]} claves."
echo ""

# Construir SECRETS_VALUES mapeando desde el archivo
SECRETS_VALUES=()
for secret in "${SECRETS[@]}"; do
  valor=$(mapear_secreto "$secret")
  SECRETS_VALUES+=("$valor")
done

banner "RESUMEN DE SECRETOS A CONFIGURAR"

for i in "${!SECRETS[@]}"; do
  secret="${SECRETS[$i]}"
  valor="${SECRETS_VALUES[$i]}"
  if [ -n "$valor" ]; then
    printf "  %-30s ✔ (%d caracteres)\n" "$secret" "${#valor}"
  else
    printf "  %-30s ✗ (sin valor)\n" "$secret"
  fi
done

echo ""
echo "Aplicando secretos automaticamente..."

# -----------------------------------------------------
# PARTE 3 — Aplicar secretos a cada repositorio
# -----------------------------------------------------

banner "PARTE 3 — APLICANDO SECRETOS A CADA REPOSITORIO"

# Desactivar set -e para que un fallo en un repo no detenga los demás
set +e

for repo in "${REPOS[@]}"; do

  FULL_NAME="$GH_OWNER/$repo"

  echo ""
  echo ">>> Repositorio: $FULL_NAME"
  echo "─────────────────────────────────────────"

  for i in "${!SECRETS[@]}"; do
    secret="${SECRETS[$i]}"
    valor="${SECRETS_VALUES[$i]}"

    if [ -z "$valor" ]; then
      echo "  [$secret] ○ omitido (sin valor)"
      continue
    fi

    printf "  [%s] configurando... " "$secret"
    if gh secret set "$secret" --body "$valor" --repo "$FULL_NAME" 2>&1; then
      echo "✔"
    else
      echo "✗ ERROR (verifica conexión y permisos en $FULL_NAME)"
    fi

  done

done

set -e

# -----------------------------------------------------
# PARTE 4 — Resumen final
# -----------------------------------------------------

banner "PARTE 4 — RESUMEN DE LO CREADO"

echo "Repositorios:"
echo "-------------"
for entry in "${REPO_DETAILS[@]}"; do
  REPO_NAME=$(echo "$entry" | cut -d'|' -f1)
  REPO_URL=$(echo "$entry"  | cut -d'|' -f2)
  printf "  %-30s %s\n" "$REPO_NAME" "$REPO_URL"
done

echo ""
echo "Secrets configurados en cada repositorio:"
echo "----------------------------------------"
for repo in "${REPOS[@]}"; do
  FULL_NAME="$GH_OWNER/$repo"
  echo ""
  echo "  [$repo]"
  echo "  https://github.com/$FULL_NAME/settings/secrets/actions"
  gh secret list --repo "$FULL_NAME" 2>/dev/null || echo "    (no se pudo obtener la lista)"
done

echo ""
echo "========================================="
echo " PROCESO COMPLETADO"
echo "========================================="
echo ""
echo "Para ver los secretos en el navegador:"
for repo in "${REPOS[@]}"; do
  echo "  https://github.com/$GH_OWNER/$repo/settings/secrets/actions"
done
echo ""


gh ssh-key add ~/.ssh/github_ed25519.pub --title "$(hostname)-$(date +%Y%m%d)"