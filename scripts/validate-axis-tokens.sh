#!/bin/bash
# validate-axis-tokens.sh
# Valida que los archivos bootstrap de AXIS no excedan los limites de tokens.
#
# AXIS se basa en el principio de que los archivos auto-cargados (bootstrap)
# se pagan en CADA turno de conversacion. Este script detecta archivos que
# exceden los limites recomendados.
#
# Uso:
#   ./scripts/validate-axis-tokens.sh              # Validar
#   ./scripts/validate-axis-tokens.sh --verbose     # Validar con detalle
#   ./scripts/validate-axis-tokens.sh --ci          # Para CI (exit code 1 si falla)

set -euo pipefail

MODE="normal"
EXIT_CODE=0

case "${1:-}" in
    --verbose) MODE="verbose" ;;
    --ci)      MODE="ci" ;;
    --help|-h)
        echo "Uso: $0 [--verbose|--ci|--help]"
        echo ""
        echo "  (sin args)   Validar limites de tokens"
        echo "  --verbose    Mostrar conteo por archivo"
        echo "  --ci         Para CI — exit code 1 si algun archivo excede"
        echo "  --help       Mostrar esta ayuda"
        exit 0
        ;;
esac

# Funcion: estimar tokens de un archivo
# Regla: ~3.5 caracteres por token en espanol, ~4 en ingles
# Usamos 3.5 como estimacion conservadora
estimate_tokens() {
    local file="$1"
    if [ -f "$file" ]; then
        local chars
        chars=$(wc -c < "$file" | tr -d ' ')
        echo $(( chars * 10 / 35 ))  # chars / 3.5, usando aritmetica entera
    else
        echo 0
    fi
}

# Funcion: validar un archivo contra su limite
check_file() {
    local file="$1"
    local max_tokens="$2"
    local label="$3"
    local is_bootstrap="$4"  # "bootstrap" si se paga en cada turno

    if [ ! -f "$file" ]; then
        if [ "$MODE" = "verbose" ]; then
            echo "  - $label — no existe (OK)"
        fi
        return
    fi

    local tokens
    tokens=$(estimate_tokens "$file")

    if [ "$tokens" -gt "$max_tokens" ]; then
        local overage=$(( tokens - max_tokens ))
        echo "  X $label — ~${tokens} tokens (excede por ~${overage})"
        if [ "$is_bootstrap" = "bootstrap" ]; then
            echo "     CRITICO: Este archivo se paga en CADA turno de conversacion"
        fi
        suggest_fix "$file"
        EXIT_CODE=1
    elif [ "$tokens" -gt $(( max_tokens * 80 / 100 )) ]; then
        echo "  ! $label — ~${tokens} tokens (>80% del limite de ${max_tokens})"
    else
        if [ "$MODE" = "verbose" ]; then
            echo "  OK $label — ~${tokens} tokens (limite: ${max_tokens})"
        fi
    fi
}

# Funcion: sugerir como reducir un archivo que excede el limite
suggest_fix() {
    local file="$1"
    case "$file" in
        "CLAUDE.md"|".cursorrules")
            echo "     SUGERENCIA: Mueve secciones no-criticas a AGENT_CONTEXT.md o .product/"
            echo "     Solo identidad, estado actual y reglas inquebrantables deben estar aqui."
            ;;
        "WORKING_STATE.md")
            echo "     SUGERENCIA: Mueve detalles a MEMORY.md (duraderos) o reduce scope."
            echo "     Solo debe tener: en progreso, siguiente, bloqueantes."
            ;;
        "AGENT_CONTEXT.md")
            echo "     SUGERENCIA: Reduce descripciones. Este archivo es un indice, no un contenedor."
            ;;
        ".product/memory/MEMORY.md")
            echo "     SUGERENCIA: Archiva items resueltos a .product/memory/MEMORY_ARCHIVE.md"
            echo "     o elimina items que ya no aplican."
            ;;
        .product/memory/????-??-??.md)
            echo "     SUGERENCIA: Mueve hechos duraderos a MEMORY.md y reduce detalles."
            ;;
        .product/*)
            echo "     SUGERENCIA: Divide este archivo o mueve contenido estable a un archivo complementario."
            ;;
        .claude/skills/*)
            echo "     SUGERENCIA: Extrae ejemplos largos a archivos auxiliares en la carpeta del skill."
            ;;
    esac
}

echo ""
echo "AXIS Token Validator"
echo "============================================"
echo ""

echo "Capa 0 — Bootstrap (se paga en CADA turno)"
echo "--------------------------------------------"
check_file "CLAUDE.md" 3000 "CLAUDE.md" "bootstrap"
check_file ".cursorrules" 3000 ".cursorrules" "bootstrap"
echo ""

echo "Capa 1 — Archivos de sesion"
echo "--------------------------------------------"
check_file "WORKING_STATE.md" 2000 "WORKING_STATE.md" "session"
check_file "AGENT_CONTEXT.md" 2000 "AGENT_CONTEXT.md" "session"
echo ""

echo "Capa 2 — Cerebro del producto (.product/)"
echo "--------------------------------------------"
check_file ".product/context/PRODUCT.md" 4000 "PRODUCT.md" "on-demand"
check_file ".product/context/BUSINESS.md" 3000 "BUSINESS.md" "on-demand"
check_file ".product/context/ROADMAP.md" 2000 "ROADMAP.md" "on-demand"
check_file ".product/architecture/OVERVIEW.md" 4000 "OVERVIEW.md" "on-demand"
check_file ".product/architecture/COMPONENTS.md" 4000 "COMPONENTS.md" "on-demand"
check_file ".product/architecture/RISKS.md" 2000 "RISKS.md" "on-demand"
check_file ".product/memory/MEMORY.md" 3000 "MEMORY.md" "on-demand"
echo ""

echo "Capa 3 — Skills (.claude/skills/)"
echo "--------------------------------------------"
if [ -d ".claude/skills" ]; then
    for skill_dir in .claude/skills/*/; do
        if [ -f "${skill_dir}SKILL.md" ]; then
            skill_name=$(basename "$skill_dir")
            check_file "${skill_dir}SKILL.md" 5000 "skill: $skill_name" "on-demand"
        fi
    done
else
    echo "  - No hay skills instaladas"
fi
echo ""

# Log diario de hoy
TODAY=$(date +%Y-%m-%d)
if [ -f ".product/memory/${TODAY}.md" ]; then
    echo "Log diario de hoy"
    echo "--------------------------------------------"
    check_file ".product/memory/${TODAY}.md" 3000 "Log ${TODAY}" "session"
    echo ""
fi

# Validar referencias en AGENT_CONTEXT.md
if [ -f "AGENT_CONTEXT.md" ]; then
    echo "Referencias en AGENT_CONTEXT.md"
    echo "--------------------------------------------"
    BROKEN_REFS=0
    while IFS= read -r ref; do
        if [ ! -f "$ref" ] && [ ! -d "$ref" ]; then
            echo "  X $ref — no existe"
            BROKEN_REFS=$((BROKEN_REFS + 1))
            EXIT_CODE=1
        elif [ "$MODE" = "verbose" ]; then
            echo "  OK $ref"
        fi
    done < <(grep -oE '\.[a-zA-Z_/]+\.(md|sh)' "AGENT_CONTEXT.md" | sort -u)
    if [ "$BROKEN_REFS" -eq 0 ]; then
        if [ "$MODE" = "verbose" ]; then
            echo "  Todas las referencias son validas"
        fi
    else
        echo "  $BROKEN_REFS referencia(s) rota(s) — actualiza AGENT_CONTEXT.md"
    fi
    echo ""
fi

# Resumen
echo "============================================"
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "OK - Todos los archivos dentro de los limites"
else
    echo "ERROR - Hay archivos que exceden los limites recomendados"
    echo ""
    echo "   Revisa las SUGERENCIAS arriba para cada archivo que excede."
fi
echo ""

if [ "$MODE" = "ci" ]; then
    exit $EXIT_CODE
fi
