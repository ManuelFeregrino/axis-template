#!/bin/bash
# init-project.sh
# Wizard interactivo de configuración para AXIS.
# Llena los placeholders, detecta tu stack, y sugiere + instala skills desde skills.sh.
#
# Uso (desde la raíz de tu proyecto con AXIS instalado):
#   bash scripts/init-project.sh

set -euo pipefail

SKILLS_DIR=".claude/skills"

# ─── Colores ─────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Helpers ──────────────────────────────────────────────────────────────────
print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}══════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  AXIS — Project Setup Wizard${NC}"
    echo -e "${BOLD}${BLUE}══════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    echo ""
    echo -e "${CYAN}${BOLD}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

ask() {
    local prompt="$1"
    local default="${2:-}"
    local var_name="$3"

    if [ -n "$default" ]; then
        echo -ne "${BOLD}$prompt${NC} ${YELLOW}[$default]${NC}: "
    else
        echo -ne "${BOLD}$prompt${NC}: "
    fi

    read -r input
    if [ -z "$input" ] && [ -n "$default" ]; then
        eval "$var_name=\"$default\""
    else
        eval "$var_name=\"$input\""
    fi
}

ask_multiselect() {
    local prompt="$1"
    shift
    local options=("$@")

    echo -e "${BOLD}$prompt${NC}"
    for i in "${!options[@]}"; do
        echo -e "  ${CYAN}$((i+1))${NC}) ${options[$i]}"
    done
    echo -ne "${BOLD}Elige números separados por espacio (Enter para ninguno)${NC}: "
    read -r selection
    MULTISELECT_RESULT="$selection"
}

# ─── Verificaciones previas ───────────────────────────────────────────────────
check_requirements() {
    if [ ! -f "CLAUDE.md" ]; then
        print_error "No se encontró CLAUDE.md. ¿Estás en la raíz de un proyecto con AXIS instalado?"
        echo "Instala AXIS primero:"
        echo "  curl -fsSL https://raw.githubusercontent.com/ManuelFeregrino/axis-template/main/scripts/install-axis.sh | bash"
        exit 1
    fi

    if ! command -v node &> /dev/null; then
        print_warning "Node.js no encontrado. La búsqueda de skills requiere Node.js + npx."
        SKILLS_CLI_AVAILABLE=false
    else
        SKILLS_CLI_AVAILABLE=true
    fi
}

# ─── Buscar skills en skills.sh via CLI ───────────────────────────────────────
search_skills() {
    local query="$1"
    # Retorna lista de "owner/repo@skill (N installs)" limpia
    npx --yes skills find "$query" 2>/dev/null \
        | grep -E '@' \
        | grep -v '└' \
        | sed 's/\x1b\[[0-9;]*m//g' \
        | awk '{print $1}' \
        | head -5 \
        || true
}

# ─── Instalar un skill con npx skills add ────────────────────────────────────
install_skill() {
    local skill_ref="$1"  # formato: owner/repo@skill-name
    local skill_name
    skill_name=$(echo "$skill_ref" | sed 's/.*@//')
    local target_dir="$SKILLS_DIR/$skill_name"

    if [ -d "$target_dir" ]; then
        print_warning "Skill '$skill_name' ya existe — omitido (no se sobreescribe)"
        return 0
    fi

    echo -e "  Instalando ${CYAN}$skill_ref${NC}..."
    if npx --yes skills add "$skill_ref" 2>/dev/null; then
        print_success "Skill '$skill_name' instalado"
    else
        print_warning "No se pudo instalar '$skill_ref'"
    fi
}

# ─── Buscar y mostrar skills para un término ─────────────────────────────────
suggest_skills_for_query() {
    local query="$1"
    local label="$2"

    echo ""
    echo -e "  ${BOLD}Skills para ${CYAN}$label${NC}${BOLD}:${NC}"

    local results
    results=$(search_skills "$query")

    if [ -z "$results" ]; then
        echo -e "  ${YELLOW}Sin resultados para '$query'${NC}"
        return
    fi

    local i=1
    while IFS= read -r skill_ref; do
        [ -z "$skill_ref" ] && continue
        skill_name=$(echo "$skill_ref" | sed 's/.*@//')
        existing=""
        [ -d "$SKILLS_DIR/$skill_name" ] && existing=" ${YELLOW}(ya instalado)${NC}"
        echo -e "    ${CYAN}$i${NC}) $skill_ref$existing"
        SKILL_SEARCH_RESULTS+=("$skill_ref")
        ((i++)) || true
    done <<< "$results"
}

# ─── Reemplazar placeholders en archivos ─────────────────────────────────────
replace_placeholders() {
    local file="$1"
    local product_name="$2"
    local phase="$3"
    local author_name="$4"

    [ ! -f "$file" ] && return 0

    sed -i \
        -e "s/\[NOMBRE DEL PRODUCTO\]/$product_name/g" \
        -e "s/\[NOMBRE\]/$author_name/g" \
        -e "s/\[Construccion \/ Validacion \/ Produccion\]/$phase/g" \
        -e "s/\[que estamos haciendo ahora\]/Configuración inicial del proyecto/g" \
        -e "s|\[fecha + que cambio\]|$(date '+%Y-%m-%d') — Setup inicial|g" \
        -e "s|\[que sigue\]|Implementar primera feature|g" \
        "$file" 2>/dev/null || true
}

# ─── Crear archivos .product/ ────────────────────────────────────────────────
setup_product_files() {
    local product_name="$1"
    local product_desc="$2"
    local target_audience="$3"
    local stack_str="$4"

    mkdir -p ".product/context" ".product/architecture"

    # PRODUCT.md
    cat > ".product/context/PRODUCT.md" << EOF
# $product_name

## Qué es
$product_desc

## Para quién
$target_audience

## Stack
$stack_str

## Generado
$(date '+%Y-%m-%d') via init-project.sh
EOF
    print_success "Creado .product/context/PRODUCT.md"

    # OVERVIEW.md (solo si no existe)
    if [ ! -f ".product/architecture/OVERVIEW.md" ]; then
        cat > ".product/architecture/OVERVIEW.md" << EOF
# $product_name — Architecture Overview

## Stack
$stack_str

## Estructura
\`\`\`
(llenar con la estructura real del proyecto)
\`\`\`

## Patrones principales
(describir patrones arquitectónicos usados)

## Generado
$(date '+%Y-%m-%d') via init-project.sh — completar manualmente
EOF
        print_success "Creado .product/architecture/OVERVIEW.md (completar manualmente)"
    else
        print_warning ".product/architecture/OVERVIEW.md ya existe — no sobreescrito"
    fi
}

# ─── MAIN ─────────────────────────────────────────────────────────────────────
main() {
    print_header
    check_requirements

    # ── Paso 1: Info del proyecto ──────────────────────────────────────────
    print_step "1/4 — Información del proyecto"

    ask "Nombre del producto" "" PRODUCT_NAME
    [ -z "$PRODUCT_NAME" ] && print_error "El nombre es obligatorio." && exit 1

    ask "Descripción corta (qué hace y para quién)" "" PRODUCT_DESC
    ask "Audiencia objetivo" "desarrolladores / pequeñas empresas" TARGET_AUDIENCE
    ask "Tu nombre" "" AUTHOR_NAME

    echo ""
    echo -e "${BOLD}Fase del proyecto:${NC}"
    echo "  1) Construccion"
    echo "  2) Validacion"
    echo "  3) Produccion"
    ask "Fase" "1" PHASE_NUM
    case "$PHASE_NUM" in
        1) PHASE="Construccion" ;;
        2) PHASE="Validacion" ;;
        3) PHASE="Produccion" ;;
        *) PHASE="Construccion" ;;
    esac

    # ── Paso 2: Stack tecnológico ──────────────────────────────────────────
    print_step "2/4 — Stack tecnológico"

    TECH_OPTIONS=(
        "Next.js"
        "React"
        "React Native"
        "Node.js / NestJS"
        "TypeScript"
        "PostgreSQL"
        "Stripe"
        "Auth (Clerk/NextAuth)"
        "AWS"
        "Vercel"
        "Docker / DevOps"
        "Testing"
        "Design System / UI"
        "Web3 / Blockchain"
    )

    # Queries de búsqueda para cada tech
    TECH_QUERIES=(
        "react nextjs"
        "react"
        "react native"
        "node typescript api"
        "typescript"
        "postgres database"
        "stripe billing"
        "auth authentication"
        "aws deploy"
        "vercel deploy"
        "docker devops ci-cd"
        "testing"
        "design ui"
        "web3 blockchain"
    )

    ask_multiselect "¿Qué tecnologías usas?" "${TECH_OPTIONS[@]}"

    SELECTED_INDICES=()
    STACK_DISPLAY=""
    for num in $MULTISELECT_RESULT; do
        idx=$((num - 1))
        if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#TECH_OPTIONS[@]}" ]; then
            SELECTED_INDICES+=("$idx")
            STACK_DISPLAY="$STACK_DISPLAY ${TECH_OPTIONS[$idx]},"
        fi
    done
    STACK_STR="${STACK_DISPLAY%,}"
    echo ""
    echo -e "Stack: ${GREEN}${STACK_STR}${NC}"

    # ── Paso 3: Skills desde skills.sh ────────────────────────────────────
    print_step "3/4 — Buscando skills en skills.sh para tu stack"

    declare -a ALL_FOUND_SKILLS=()

    if [ "$SKILLS_CLI_AVAILABLE" = true ] && [ "${#SELECTED_INDICES[@]}" -gt 0 ]; then
        declare -a SKILL_SEARCH_RESULTS=()

        for idx in "${SELECTED_INDICES[@]}"; do
            query="${TECH_QUERIES[$idx]}"
            label="${TECH_OPTIONS[$idx]}"
            suggest_skills_for_query "$query" "$label"
        done

        ALL_FOUND_SKILLS=("${SKILL_SEARCH_RESULTS[@]:-}")

        if [ "${#ALL_FOUND_SKILLS[@]}" -gt 0 ]; then
            echo ""
            ask "¿Instalar todos los skills encontrados? (s/n)" "s" INSTALL_ALL

            if [[ "$INSTALL_ALL" =~ ^[sS]$ ]]; then
                SKILLS_TO_INSTALL=("${ALL_FOUND_SKILLS[@]}")
            else
                echo ""
                ask_multiselect "¿Cuáles instalar? (números del listado de arriba)" "${ALL_FOUND_SKILLS[@]}"
                SKILLS_TO_INSTALL=()
                for num in $MULTISELECT_RESULT; do
                    idx=$((num - 1))
                    [ "$idx" -ge 0 ] && [ "$idx" -lt "${#ALL_FOUND_SKILLS[@]}" ] && \
                        SKILLS_TO_INSTALL+=("${ALL_FOUND_SKILLS[$idx]}")
                done
            fi

            echo ""
            echo -e "${BOLD}Instalando skills...${NC}"
            for skill_ref in "${SKILLS_TO_INSTALL[@]:-}"; do
                [ -n "$skill_ref" ] && install_skill "$skill_ref"
            done
        else
            print_warning "No se encontraron skills — revisa tu conexión o busca manualmente con: npx skills find <query>"
        fi
    else
        print_warning "Sin Node.js disponible o sin stack seleccionado — saltando skills."
        echo -e "Puedes instalar skills manualmente después: ${CYAN}npx skills find <query>${NC}"
    fi

    # ── Paso 4: Aplicar configuración ─────────────────────────────────────
    print_step "4/4 — Aplicando configuración"

    for f in "CLAUDE.md" "AGENT_CONTEXT.md" "WORKING_STATE.md"; do
        replace_placeholders "$f" "$PRODUCT_NAME" "$PHASE" "$AUTHOR_NAME"
        [ -f "$f" ] && print_success "$f actualizado"
    done

    setup_product_files "$PRODUCT_NAME" "$PRODUCT_DESC" "$TARGET_AUDIENCE" "$STACK_STR"

    # ── Resumen ────────────────────────────────────────────────────────────
    echo ""
    echo -e "${BOLD}${GREEN}══════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${GREEN}  ✓ Proyecto configurado: $PRODUCT_NAME${NC}"
    echo -e "${BOLD}${GREEN}══════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${BOLD}Fase:${NC}   $PHASE"
    echo -e "  ${BOLD}Stack:${NC}  $STACK_STR"
    echo -e "  ${BOLD}Skills instalados:${NC} $(ls $SKILLS_DIR 2>/dev/null | wc -l) en total"
    echo ""
    echo -e "  ${BOLD}Próximos pasos:${NC}"
    echo -e "  1. Revisa ${CYAN}CLAUDE.md${NC} → ajusta las Reglas Inquebrantables"
    echo -e "  2. Completa ${CYAN}.product/context/PRODUCT.md${NC} con más detalle"
    echo -e "  3. Llena ${CYAN}.product/architecture/OVERVIEW.md${NC} con tu estructura real"
    echo -e "  4. ${CYAN}git add . && git commit -m 'init: configure AXIS for $PRODUCT_NAME'${NC}"
    echo ""
    echo -e "  Buscar más skills: ${CYAN}npx skills find <query>${NC}"
    echo -e "  Instalar skill:    ${CYAN}npx skills add owner/repo@skill-name${NC}"
    echo ""
}

main "$@"
