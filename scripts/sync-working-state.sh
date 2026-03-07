#!/bin/bash
# sync-working-state.sh
# Sincroniza el estado de WORKING_STATE.md en la seccion "Estado Actual" de CLAUDE.md
#
# Por que existe este script?
# Claude Code SOLO auto-carga CLAUDE.md. WORKING_STATE.md NO se auto-carga —
# depende de que el agente siga la instruccion y lo lea activamente.
# Este script inyecta las primeras lineas de WORKING_STATE.md directamente
# en CLAUDE.md para que el estado siempre este en el bootstrap auto-cargado.
#
# Cuando se ejecuta:
# - Automaticamente como git pre-commit hook
# - Manualmente: ./scripts/sync-working-state.sh
#
# Que hace:
# 1. Lee las secciones clave de WORKING_STATE.md
# 2. Genera un resumen compacto (max ~300 tokens)
# 3. Reemplaza la seccion "## Estado Actual" en CLAUDE.md
# 4. Si CLAUDE.md cambio, lo agrega al commit automaticamente
#
# Uso:
#   ./scripts/sync-working-state.sh              # Sincronizar
#   ./scripts/sync-working-state.sh --dry-run     # Ver que cambiaria
#   ./scripts/sync-working-state.sh --check        # Solo verificar si esta desincronizado

set -euo pipefail

CLAUDE_FILE="CLAUDE.md"
WORKING_STATE_FILE="WORKING_STATE.md"
MODE="sync"

case "${1:-}" in
    --dry-run) MODE="dry-run" ;;
    --check)   MODE="check" ;;
    --help|-h)
        echo "Uso: $0 [--dry-run|--check|--help]"
        echo ""
        echo "  (sin args)   Sincronizar WORKING_STATE.md -> CLAUDE.md"
        echo "  --dry-run    Ver que cambiaria sin aplicar"
        echo "  --check      Verificar si estan desincronizados (exit 1 si si)"
        echo "  --help       Mostrar esta ayuda"
        exit 0
        ;;
esac

# Verificar que los archivos existen
if [ ! -f "$CLAUDE_FILE" ]; then
    echo "  $CLAUDE_FILE no encontrado — omitiendo sync"
    exit 0
fi

if [ ! -f "$WORKING_STATE_FILE" ]; then
    echo "  $WORKING_STATE_FILE no encontrado — omitiendo sync"
    exit 0
fi

# Verificar que CLAUDE.md tiene la seccion "## Estado Actual"
if ! grep -q "^## Estado Actual" "$CLAUDE_FILE"; then
    echo "  CLAUDE.md no tiene seccion '## Estado Actual' — omitiendo sync"
    exit 0
fi

# Extraer resumen compacto de WORKING_STATE.md

# Extraer contenido entre headers de WORKING_STATE.md
extract_section() {
    local file="$1"
    local header="$2"
    sed -n "/^## ${header}/,/^## /{ /^## ${header}/d; /^## /d; p; }" "$file" | head -5 | sed '/^$/d' | sed 's/^[[:space:]]*//'
}

EN_PROGRESO=$(extract_section "$WORKING_STATE_FILE" "En Progreso")
PROXIMA=$(extract_section "$WORKING_STATE_FILE" "Proxima Sesion")
BLOCKERS=$(extract_section "$WORKING_STATE_FILE" "Blockers")

# Si no hay contenido util, usar defaults
[ -z "$EN_PROGRESO" ] && EN_PROGRESO="- Sin tareas en progreso"
[ -z "$PROXIMA" ] && PROXIMA="- Sin proximos pasos definidos"

# Construir el bloque de estado (compacto, ~300 tokens max)
NEW_STATE="## Estado Actual"
NEW_STATE+="\n- En progreso: $(echo "$EN_PROGRESO" | head -1 | sed 's/^- //')"
NEW_STATE+="\n- Proximo: $(echo "$PROXIMA" | head -1 | sed 's/^- \[ \] //')"

# Solo agregar blockers si existen y no son "Ninguno"
if [ -n "$BLOCKERS" ] && ! echo "$BLOCKERS" | grep -qi "ningun"; then
    NEW_STATE+="\n- Blocker: $(echo "$BLOCKERS" | head -1 | sed 's/^- //')"
fi

NEW_STATE+="\n- Ultimo sync: $(date +%Y-%m-%d)"

# Extraer el bloque actual de CLAUDE.md
CURRENT_STATE=$(sed -n '/^## Estado Actual/,/^## /{ /^## Estado Actual/p; /^## [^E]/d; /^## Estado Actual/d; p; }' "$CLAUDE_FILE")

case "$MODE" in
    "check")
        CURRENT_NORMALIZED=$(echo "$CURRENT_STATE" | sed '/^$/d' | sed 's/^[[:space:]]*//')
        NEW_NORMALIZED=$(echo -e "$NEW_STATE" | sed '/^$/d' | sed 's/^[[:space:]]*//' | tail -n +2)

        if [ "$CURRENT_NORMALIZED" = "$NEW_NORMALIZED" ]; then
            echo "CLAUDE.md esta sincronizado con WORKING_STATE.md"
            exit 0
        else
            echo "CLAUDE.md esta desincronizado con WORKING_STATE.md"
            echo ""
            echo "Estado actual en CLAUDE.md:"
            echo "$CURRENT_NORMALIZED" | head -5
            echo ""
            echo "Estado en WORKING_STATE.md:"
            echo "$NEW_NORMALIZED" | head -5
            exit 1
        fi
        ;;

    "dry-run")
        echo "Modo dry-run — cambios que se aplicarian a CLAUDE.md:"
        echo ""
        echo "Seccion '## Estado Actual' se reemplazaria con:"
        echo "----------------------------------------"
        echo -e "$NEW_STATE"
        echo "----------------------------------------"
        ;;

    "sync")
        TMP_FILE=$(mktemp)

        awk -v new_state="$(echo -e "$NEW_STATE")" '
        /^## Estado Actual/ {
            print new_state
            skip = 1
            next
        }
        /^## / && skip {
            skip = 0
        }
        !skip {
            print
        }
        ' "$CLAUDE_FILE" > "$TMP_FILE"

        if diff -q "$CLAUDE_FILE" "$TMP_FILE" > /dev/null 2>&1; then
            echo "CLAUDE.md ya esta sincronizado — sin cambios"
            rm "$TMP_FILE"
        else
            mv "$TMP_FILE" "$CLAUDE_FILE"
            echo "CLAUDE.md actualizado con estado de WORKING_STATE.md"

            if [ -n "${GIT_INDEX_FILE:-}" ]; then
                git add "$CLAUDE_FILE"
                echo "   -> CLAUDE.md agregado al commit automaticamente"
            fi
        fi
        ;;
esac
