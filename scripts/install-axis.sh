#!/bin/bash
# install-axis.sh
# Instala AXIS en un proyecto existente con un solo comando.
#
# Uso (desde la raiz de tu proyecto):
#   curl -fsSL https://raw.githubusercontent.com/ManuelFeregrino/axis-template/main/scripts/install-axis.sh | bash
#
# O si ya clonaste el template:
#   bash /tmp/axis-template/scripts/install-axis.sh

set -euo pipefail

TEMPLATE_REPO="https://github.com/ManuelFeregrino/axis-template.git"
TEMP_DIR=""
FORCE=false

case "${1:-}" in
    --force|--overwrite) FORCE=true ;;
    --help|-h)
        echo "Uso: $0 [--force|--help]"
        echo ""
        echo "  (sin args)   Instalar AXIS (falla si ya esta instalado)"
        echo "  --force      Reinstalar AXIS sobreescribiendo todo"
        echo "  --help       Mostrar esta ayuda"
        exit 0
        ;;
    "") ;;
    *)
        echo "Error: Opcion desconocida '$1'"
        echo "Uso: $0 [--force|--help]"
        exit 1
        ;;
esac

cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# Verificar que estamos en un repo git
if [ ! -d ".git" ]; then
    echo "Error: No estas en la raiz de un repositorio Git."
    echo "Navega a tu proyecto y vuelve a correr este script."
    exit 1
fi

# Detectar si AXIS ya esta instalado
if [ -f "CLAUDE.md" ] && [ -d ".product" ] && [ -d ".claude/skills" ] && [ "$FORCE" = false ]; then
    echo ""
    echo "AXIS ya esta instalado en este proyecto."
    echo ""
    echo "Para actualizar los archivos framework sin perder tu contenido:"
    echo "  ./scripts/update-axis.sh"
    echo ""
    echo "Para ver que cambiaria sin aplicar:"
    echo "  ./scripts/update-axis.sh --dry-run"
    echo ""
    echo "Para reinstalar desde cero (sobreescribe CLAUDE.md, .product/, etc.):"
    echo "  ./scripts/install-axis.sh --force"
    echo ""
    exit 0
fi

echo ""
echo "AXIS Installer"
echo "============================================"
echo "Instalando AXIS en: $(pwd)"
echo ""

# Clonar template a temp
echo "Descargando AXIS template..."
TEMP_DIR=$(mktemp -d)
git clone --depth 1 --quiet "$TEMPLATE_REPO" "$TEMP_DIR" 2>/dev/null

# Copiar estructura
echo "Copiando estructura AXIS..."

# Directorios
for dir in .product .claude scripts git-hooks; do
    if [ -d "$TEMP_DIR/$dir" ]; then
        cp -r "$TEMP_DIR/$dir" .
        echo "  + $dir/"
    fi
done

# Archivos raiz
for file in CLAUDE.md .cursorrules AGENT_CONTEXT.md WORKING_STATE.md CHANGELOG.md .gitignore; do
    if [ -f "$TEMP_DIR/$file" ]; then
        # No sobreescribir .gitignore si ya existe — mergear
        if [ "$file" = ".gitignore" ] && [ -f ".gitignore" ]; then
            echo "  ~ .gitignore (existente — agregando reglas de AXIS)"
            # Agregar lineas del template que no existan en el local
            while IFS= read -r line; do
                if [ -n "$line" ] && ! grep -qxF "$line" .gitignore 2>/dev/null; then
                    echo "$line" >> .gitignore
                fi
            done < "$TEMP_DIR/.gitignore"
        else
            cp "$TEMP_DIR/$file" .
            echo "  + $file"
        fi
    fi
done

# Hacer ejecutables los scripts
chmod +x scripts/*.sh

# Instalar git hooks
echo ""
./scripts/install-git-hooks.sh

echo ""
echo "============================================"
echo "AXIS instalado."
echo ""
echo "Siguiente paso:"
echo "  Reemplaza los placeholders [NOMBRE DEL PRODUCTO], [NOMBRE], etc."
echo "  en CLAUDE.md, WORKING_STATE.md, y los archivos en .product/"
echo ""
echo "Cuando estes listo:"
echo "  git add . && git commit -m 'init: inicializa proyecto con AXIS'"
echo ""
echo "Para futuras actualizaciones:"
echo "  ./scripts/update-axis.sh"
echo ""
