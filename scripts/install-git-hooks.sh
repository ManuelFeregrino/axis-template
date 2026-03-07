#!/bin/bash
# install-git-hooks.sh
# Instala los git hooks de AXIS en el repositorio.
#
# Por que este script?
# Git hooks viven en .git/hooks/ que NO se versiona.
# Los hooks de AXIS viven en git-hooks/ (versionado).
# Este script los copia al lugar correcto.
#
# Uso:
#   ./scripts/install-git-hooks.sh
#
# Se ejecuta una vez despues de clonar el repo o
# despues de agregar/actualizar hooks en git-hooks/

set -euo pipefail

HOOKS_SOURCE="git-hooks"
HOOKS_DEST=".git/hooks"

if [ ! -d ".git" ]; then
    echo "Error: No estas en la raiz de un repositorio Git"
    exit 1
fi

if [ ! -d "$HOOKS_SOURCE" ]; then
    echo "Error: No se encontro el directorio $HOOKS_SOURCE"
    exit 1
fi

echo "Instalando git hooks de AXIS..."

for hook in "$HOOKS_SOURCE"/*; do
    hook_name=$(basename "$hook")

    # Saltar archivos que no son hooks (README, etc.)
    if [[ "$hook_name" == *.md ]] || [[ "$hook_name" == .* ]]; then
        continue
    fi

    cp "$hook" "$HOOKS_DEST/$hook_name"
    chmod +x "$HOOKS_DEST/$hook_name"
    echo "  $hook_name instalado"
done

echo ""
echo "Git hooks de AXIS instalados"
echo ""
echo "Hooks activos:"
echo "  pre-commit -> Sincroniza WORKING_STATE.md -> CLAUDE.md automaticamente"
echo ""
echo "Para verificar: git hook run pre-commit"
