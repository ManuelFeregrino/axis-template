# [NOMBRE DEL PRODUCTO]

[1-2 parrafos: que es, que hace, para quien]

## Quick Start

```bash
# Clonar
git clone [URL_DEL_REPO]
cd [nombre-del-proyecto]

# Instalar git hooks de AXIS (sincroniza WORKING_STATE -> CLAUDE.md automaticamente)
chmod +x scripts/*.sh
./scripts/install-git-hooks.sh

# Instalar dependencias del producto
[comando de instalacion segun el stack]
```

## Stack

| Componente | Tecnologia |
|-----------|-----------|
| [Lenguaje] | [version] |
| [Framework] | [version] |
| [Base de datos] | [version] |

## Estructura del Proyecto

```
├── src/               # Codigo fuente
├── .product/          # Cerebro interno del producto (AXIS)
├── .claude/skills/    # Skills para agentes AI
├── docs/              # Documentacion publica (si aplica)
└── scripts/           # Herramientas de desarrollo
```

## Para trabajar con agentes AI

Este repositorio usa el sistema **AXIS** para organizar contexto y memoria para agentes AI.
- Lee `CLAUDE.md` — se carga automaticamente en Claude Code
- Lee `WORKING_STATE.md` — estado actual del trabajo
- Lee `AGENT_CONTEXT.md` — mapa de todo el contexto disponible
