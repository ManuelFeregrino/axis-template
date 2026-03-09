#!/bin/bash
# update-axis.sh
# Actualiza los archivos framework de AXIS desde el template oficial
# sin tocar el contenido del proyecto (CLAUDE.md, .product/, etc.).
#
# Uso:
#   ./scripts/update-axis.sh             # Actualizar
#   ./scripts/update-axis.sh --dry-run   # Ver que cambiaria sin aplicar

set -euo pipefail

TEMPLATE_REPO="https://github.com/ManuelFeregrino/axis-template.git"
TEMP_DIR=""
DRY_RUN=false

case "${1:-}" in
    --dry-run) DRY_RUN=true ;;
    --help|-h)
        echo "Uso: $0 [--dry-run|--help]"
        echo ""
        echo "  (sin args)   Actualizar archivos framework de AXIS"
        echo "  --dry-run    Ver que cambiaria sin aplicar"
        echo "  --help       Mostrar esta ayuda"
        exit 0
        ;;
    "") ;;
    *)
        echo "Error: Opcion desconocida '$1'"
        echo "Uso: $0 [--dry-run|--help]"
        exit 1
        ;;
esac

# Limpiar directorio temporal al salir
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# Contadores
UPDATED=0
ADDED=0
UNCHANGED=0
UNCHANGED_FILES=()
NEW_PRODUCT=0

echo ""
echo "AXIS Update"
echo "============================================"

if [ "$DRY_RUN" = true ]; then
    echo "(modo dry-run — no se aplicaran cambios)"
fi

echo "Descargando ultima version..."
echo ""

TEMP_DIR=$(mktemp -d)
git clone --depth 1 --quiet "$TEMPLATE_REPO" "$TEMP_DIR" 2>/dev/null

# Funcion: comparar y copiar un archivo framework
sync_file() {
    local src="$1"
    local dest="$2"

    if [ ! -f "$src" ]; then
        return
    fi

    if [ ! -f "$dest" ]; then
        # Archivo nuevo
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$(dirname "$dest")"
            cp "$src" "$dest"
        fi
        echo "  A $dest"
        ADDED=$((ADDED + 1))
    elif ! diff -q "$src" "$dest" > /dev/null 2>&1; then
        # Archivo modificado
        if [ "$DRY_RUN" = false ]; then
            cp "$src" "$dest"
        fi
        echo "  M $dest"
        UPDATED=$((UPDATED + 1))
    else
        # Sin cambios
        UNCHANGED=$((UNCHANGED + 1))
        UNCHANGED_FILES+=("$dest")
    fi
}

# --- Scripts ---
echo "Actualizados:"

for script in "$TEMP_DIR"/scripts/*.sh; do
    script_name=$(basename "$script")
    sync_file "$script" "scripts/$script_name"
done

# --- Git hooks ---
sync_file "$TEMP_DIR/git-hooks/pre-commit" "git-hooks/pre-commit"

# --- Skills base ---
for skill_dir in "$TEMP_DIR"/.claude/skills/*/; do
    skill_name=$(basename "$skill_dir")
    if [ -f "${skill_dir}SKILL.md" ]; then
        sync_file "${skill_dir}SKILL.md" ".claude/skills/$skill_name/SKILL.md"
    fi
done

# --- README-AXIS.md (documentacion del template) ---
sync_file "$TEMP_DIR/README.md" "README-AXIS.md"

# --- Archivos .product/ nuevos (solo si NO existen localmente) ---
if [ -d "$TEMP_DIR/.product" ]; then
    while IFS= read -r product_file; do
        local_path="${product_file#"$TEMP_DIR/"}"
        if [ ! -f "$local_path" ]; then
            if [ "$DRY_RUN" = false ]; then
                mkdir -p "$(dirname "$local_path")"
                cp "$product_file" "$local_path"
            fi
            echo "  A $local_path (nuevo en template)"
            NEW_PRODUCT=$((NEW_PRODUCT + 1))
        fi
    done < <(find "$TEMP_DIR/.product" -type f -name "*.md")
fi

# Mostrar separaciones solo si hubo output
if [ "$UPDATED" -eq 0 ] && [ "$ADDED" -eq 0 ] && [ "$NEW_PRODUCT" -eq 0 ]; then
    echo "  (ningun archivo cambiado)"
fi

# --- Resumen de sin cambios ---
if [ "$UNCHANGED" -gt 0 ]; then
    echo ""
    echo "Sin cambios:"
    # Mostrar hasta 5 archivos, resumir el resto
    SHOWN=0
    for f in "${UNCHANGED_FILES[@]}"; do
        if [ "$SHOWN" -lt 5 ]; then
            echo "  = $f"
        fi
        SHOWN=$((SHOWN + 1))
    done
    if [ "$UNCHANGED" -gt 5 ]; then
        echo "  = ($((UNCHANGED - 5)) archivos mas)"
    fi
fi

# --- Reinstalar hooks ---
if [ "$DRY_RUN" = false ]; then
    echo ""
    if [ -f "scripts/install-git-hooks.sh" ]; then
        chmod +x scripts/*.sh
        ./scripts/install-git-hooks.sh > /dev/null 2>&1
        echo "Hooks reinstalados."
    fi
else
    echo ""
    echo "Hooks: se reinstalarian."
fi

# --- Recordatorio de archivos no tocados ---
echo ""
echo "No tocados (contenido del proyecto):"
echo "  CLAUDE.md, .cursorrules, WORKING_STATE.md,"
echo "  .product/*, MEMORY.md"

echo ""
echo "============================================"
if [ "$DRY_RUN" = true ]; then
    echo "Dry run completo. Corre sin --dry-run para aplicar."
else
    echo "AXIS actualizado."
fi
echo ""
