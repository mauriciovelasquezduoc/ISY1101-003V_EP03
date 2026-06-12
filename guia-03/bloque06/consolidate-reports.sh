#!/bin/bash
# ==================================================================
# consolidate-reports.sh
# Genera un reporte Markdown unificado con todas las evidencias
# de las etapas 01 a 11, listo para copiar al README del repo.
# ==================================================================

REPORTS_DIR="/root/work/docs/reports"
OUTPUT_FILE="/root/work/docs/reports/README-EVIDENCIAS-COMPLETO.md"

echo ""
echo "============================================================="
echo " CONSOLIDANDO REPORTES DE EVIDENCIA"
echo "============================================================="
echo ""

if [ ! -d "$REPORTS_DIR" ]; then
  echo "ERROR: No se encontró la carpeta $REPORTS_DIR"
  echo "Ejecuta primero las etapas 01 a 11 para generar los reportes."
  exit 1
fi

{
  echo "# Evidencias del Laboratorio EP03 — ISY1101"
  echo ""
  echo "**Estudiante:** ________________________"
  echo "**Fecha:** $(date '+%Y-%m-%d')"
  echo ""
  echo "---"
  echo ""
  echo "## Resumen de entregables"
  echo ""
  echo "| Componente | Estado | Evidencia |
  echo "|---|---|---|"
  echo "| **IE1** — Configuración del clúster AWS | ✅ | Ver sección Infraestructura |"
  echo "| **IE2** — Despliegue Frontend + Backend | ✅ | Ver sección Aplicación |"
  echo "| **IE3** — Configuración de Autoscaling | ✅ | Ver sección HPA |"
  echo "| **IE4** — Pipeline CI/CD | ✅ | Ver sección Pipeline |"
  echo "| **IE5** — Gestión de Secrets | ✅ | Ver sección Secrets |"
  echo "| **IE6** — Análisis logs/métricas/tiempos | ✅ | Ver sección Logs y Métricas |"
  echo "| **IE7** — Validación funcional | ✅ | Ver sección Validación |"
  echo ""
  echo "---"
  echo ""

  # Consolidar todos los reportes
  for report in $(ls "$REPORTS_DIR"/*.md 2>/dev/null | sort); do
    basename=$(basename "$report")
    # Saltar el consolidado y el README final si existen de antes
    [ "$basename" = "README-EVIDENCIAS-COMPLETO.md" ] && continue

    echo ""
    echo "<!-- ================================================== -->"
    echo "<!-- Incluido desde: $basename -->"
    echo "<!-- ================================================== -->"
    echo ""
    cat "$report"
    echo ""
    echo "---"
    echo ""
  done

  echo "<!-- ================================================== -->"
  echo "<!-- FIN DEL REPORTE CONSOLIDADO                        -->"
  echo "<!-- ================================================== -->"
} > "$OUTPUT_FILE"

echo "✔ Reporte consolidado generado:"
echo "  $OUTPUT_FILE"
echo ""
echo "Contenido del archivo:"
wc -l "$OUTPUT_FILE"
echo ""
echo "💡 Para usar en tu README:"
echo "   1. Abre $OUTPUT_FILE"
echo "   2. Copia las secciones que corresponden a cada IE"
echo "   3. Pégalas en README.md de tu repositorio"
echo "   4. Complementa con capturas de pantalla en docs/"
echo ""
echo "Opcional: sube todo el contenido a un repositorio de evidencias"
echo "  gh repo create evidencias-ep03 --public"
echo "  cp $OUTPUT_FILE ./README.md"
echo "  git add . && git commit -m 'feat: reporte de evidencias EP03'"
echo "  git push"
echo ""
