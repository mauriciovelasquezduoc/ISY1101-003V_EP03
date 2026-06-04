#!/bin/bash
set -e

# =====================================================
# Script: crear-repos-y-secrets.sh
# Crea 3 repositorios y configura 6 Secrets en GitHub
# usando GitHub CLI (gh) de forma interactiva.
#
# Flujo: primero pide los 6 secretos UNA sola vez,
# luego los aplica a cada uno de los 3 repositorios.
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

banner() {
  echo ""
  echo "========================================="
  echo " $1"
  echo "========================================="
  echo ""
}

leer_secreto() {
  local name="$1"
  local mensaje="$2"
  SECRETO_VALOR=""
  read -r -s -p "$mensaje" SECRETO_VALOR || true
  echo ""
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

if ! gh auth status &> /dev/null; then
  echo ""
  echo "No hay sesión activa en GitHub CLI."
  echo "Iniciando autenticación interactiva..."
  gh auth login
fi

echo ""
gh auth status

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
# PARTE 2 — Pedir los 6 secretos UNA sola vez
# -----------------------------------------------------

banner "PARTE 2 — INGRESO DE SECRETOS (una vez para todos los repos)"

echo "A continuación ingresa los 6 secretos."
echo "Se aplicarán automáticamente a los 3 repositorios."
echo "Si dejas un valor vacío, ese secreto no se configurará."
echo ""

SECRETS_VALUES=()

for secret in "${SECRETS[@]}"; do
  echo "─────────────────────────────────────────"
  leer_secreto "$secret" "  Ingresa el valor para $secret: "
  SECRETS_VALUES+=("$SECRETO_VALOR")
  if [ -n "$SECRETO_VALOR" ]; then
    echo "  ✔ Valor registrado (${#SECRETO_VALOR} caracteres)"
  else
    echo "  ○ Vacío — se omitirá este secreto"
  fi
  echo ""
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
read -r -p "¿Aplicar estos secretos a los 3 repositorios? (s/n): " CONFIRMAR || true
if [ "$CONFIRMAR" != "s" ] && [ "$CONFIRMAR" != "S" ]; then
  echo "Cancelado por el usuario."
  exit 0
fi

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
