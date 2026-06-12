#!/bin/bash
# ==================================================================
# Helper de reporte para scripts de bloque06
# Uso: source ../report_helper.sh
# Luego llama a: init_reporte "Nombre Etapa"
#                 add_evidencia "Título" "comando" "ie-ref"
#                 cerrar_reporte
# ==================================================================

SCRIPT_DIR_REAL="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
NOMBRE_ETAPA=$(basename "$SCRIPT_DIR_REAL")
REPORTS_DIR="/root/work/docs/reports"
mkdir -p "$REPORTS_DIR"

# Variables globales
REPORTE_FILE=""
FECHA_INICIO=""
STEP_COUNT=0

init_reporte() {
    local titulo="$1"
    FECHA_INICIO=$(date '+%Y-%m-%d %H:%M:%S')
    STEP_COUNT=0
    REPORTE_FILE="${REPORTS_DIR}/${NOMBRE_ETAPA}.md"

    # Backup del reporte anterior si existe
    [ -f "$REPORTE_FILE" ] && cp "$REPORTE_FILE" "${REPORTE_FILE}.bak"

    cat > "$REPORTE_FILE" << EOF
# Reporte de Evidencia: ${titulo}

**Fecha:** ${FECHA_INICIO}
**Etapa:** ${NOMBRE_ETAPA}

---

## Resumen

EOF
    echo "  📄 Reporte: $REPORTE_FILE"
}

add_hora_header() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    {
        echo ""
        echo "---"
        echo ""
        echo "### ⏱️ Ejecutado: ${timestamp}"
        echo ""
    } >> "$REPORTE_FILE"
}

add_evidencia() {
    local titulo="$1"
    local comando="$2"
    local ie_ref="$3"
    STEP_COUNT=$((STEP_COUNT + 1))
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    {
        echo ""
        echo "---"
        echo ""
        echo "### Paso ${STEP_COUNT}: ${titulo}"
        echo ""
        echo "**IE Relacionado:** ${ie_ref}"
        echo "**Hora ejecución:** ${timestamp}"
        echo ""
        echo '```'
        echo "\$ ${comando}"
        echo ""

        # Ejecutar comando y capturar output
        local output
        output=$(eval "$comando" 2>&1) || true
        echo "$output"

        echo '```'
        echo ""
        echo "**Estado:** ✅ Completado"
        echo ""
    } >> "$REPORTE_FILE"
}

add_logs_evidencia() {
    local titulo="$1"
    local comando="$2"
    local ie_ref="$3"
    STEP_COUNT=$((STEP_COUNT + 1))
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    {
        echo ""
        echo "---"
        echo ""
        echo "### Paso ${STEP_COUNT}: ${titulo}"
        echo ""
        echo "**IE Relacionado:** ${ie_ref}"
        echo "**Hora ejecución:** ${timestamp}"
        echo ""
        echo '```'
        echo "\$ ${comando}"
        echo ""

        local output
        output=$(eval "$comando" 2>&1) || true
        echo "$output"

        echo '```'
        echo ""
    } >> "$REPORTE_FILE"
}

add_texto_evidencia() {
    local texto="$1"
    {
        echo ""
        echo "$texto"
        echo ""
    } >> "$REPORTE_FILE"
}

add_checklist() {
    local item="$1"
    local estado="$2"  # ✅ o ❌
    {
        echo "  ${estado} ${item}"
    } >> "$REPORTE_FILE"
}

cerrar_reporte() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    {
        echo ""
        echo "---"
        echo ""
        echo "## Resumen final"
        echo ""
        echo "- **Inicio ejecución:** ${FECHA_INICIO}"
        echo "- **Fin ejecución:** ${timestamp}"
        echo "- **Total pasos ejecutados:** ${STEP_COUNT}"
        echo ""
        echo "### ⏱️ Línea de tiempo de la etapa"
        echo ""
        echo "| Evento | Hora |"
        echo "|---|---|"
        echo "| **Inicio** | ${FECHA_INICIO} |"
        echo "| **Fin** | ${timestamp} |"
        echo "| **Duración total** | $(calcular_duracion "$FECHA_INICIO" "$timestamp") |"
        echo ""
        echo "<!-- ================================================== -->"
        echo "<!-- Fin del reporte de evidencia                       -->"
        echo "<!-- ================================================== -->"
    } >> "$REPORTE_FILE"

    echo "  ✅ Reporte generado: $REPORTE_FILE"
    echo "     ($STEP_COUNT pasos documentados)"
}

calcular_duracion() {
    local inicio="$1"
    local fin="$2"
    local seg_inicio seg_fin diff

    if [[ "$OSTYPE" == "darwin"* ]]; then
        seg_inicio=$(date -j -f "%Y-%m-%d %H:%M:%S" "$inicio" +%s 2>/dev/null || echo 0)
        seg_fin=$(date -j -f "%Y-%m-%d %H:%M:%S" "$fin" +%s 2>/dev/null || echo 0)
    else
        seg_inicio=$(date -d "$inicio" +%s 2>/dev/null || echo 0)
        seg_fin=$(date -d "$fin" +%s 2>/dev/null || echo 0)
    fi

    diff=$(( seg_fin - seg_inicio ))
    if [ "$diff" -lt 0 ]; then diff=0; fi

    local minutos=$(( diff / 60 ))
    local segundos=$(( diff % 60 ))

    if [ "$minutos" -gt 0 ]; then
        echo "${minutos}m ${segundos}s"
    else
        echo "${segundos}s"
    fi
}
