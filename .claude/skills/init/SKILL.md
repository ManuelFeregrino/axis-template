---
name: init
description: Ejecuta el wizard interactivo de configuración de AXIS. Llena placeholders, detecta stack, sugiere skills desde skills.sh y genera el prompt inicial para el agente.
triggers:
  - /init
  - "inicializar proyecto"
  - "configurar axis"
  - "setup del proyecto"
---

## Qué hacer

Ejecutar el wizard de configuración en la terminal:

```bash
bash scripts/init-project.sh
```

O con los alias disponibles:

```bash
make init
# o
npm run init
```

## Qué hace el wizard

El wizard guía al usuario por 5 pasos:

1. **Info del proyecto** — nombre, descripción, audiencia, fase (Construcción / Validación / Producción)
2. **Reglas + autonomía** — 3 reglas inquebrantables que se inyectan en `CLAUDE.md` + nivel de autonomía del agente guardado en `.product/contracts/AGENT_CONTRACT.md`
3. **Stack tecnológico** — pregunta si es Frontend / Backend / FullStack y muestra opciones contextuales. Permite agregar tecnologías extra no incluidas en la lista.
4. **Skills desde skills.sh** — busca hasta 3 skills por tecnología con número de installs, secciona por stack, instala los elegidos localmente en `.claude/skills/` (no de forma global)
5. **Prompt para el agente** — genera un prompt listo para copiar y pegar en Claude Code según la fase del proyecto

## Al terminar

El wizard deja todo configurado:
- `CLAUDE.md` — identidad, reglas y protocolo actualizados
- `AGENT_CONTEXT.md` — TL;DR del proyecto
- `WORKING_STATE.md` — estado inicial
- `.product/contracts/AGENT_CONTRACT.md` — nivel de autonomía
- `.product/memory/MEMORY.md` — memoria inicial con el stack
- `.product/memory/SESSION-STATE.md` — WAL listo
- `.product/context/PRODUCT.md` — descripción del producto
- `.product/architecture/OVERVIEW.md` — stack y estructura inicial
- Skills relevantes instalados en `.claude/skills/`

## Cuándo usar este skill

- Al clonar el template por primera vez
- Al adoptar AXIS en un proyecto existente
- Cuando `CLAUDE.md` tiene placeholders sin rellenar (`[NOMBRE DEL PRODUCTO]`, etc.)

## Referencia

Ver `HOW-IT-WORKS.md` para documentación completa del sistema AXIS.
