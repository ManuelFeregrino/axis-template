---
name: sync-context
description: Verifica que AGENT_CONTEXT.md apunte a archivos validos y que los archivos bootstrap esten sincronizados.
triggers: Cuando el usuario dice /sync-context o pide verificar la integridad del contexto.
dependencies: AGENT_CONTEXT.md, CLAUDE.md, .cursorrules, WORKING_STATE.md
---

## Que hacer

### Paso 1 — Verificar referencias en AGENT_CONTEXT.md
Leer `AGENT_CONTEXT.md` y para cada archivo referenciado:
1. Verificar que existe en el filesystem
2. Si no existe, reportar como referencia rota

### Paso 2 — Verificar sync de bootstrap
Comparar la seccion "Estado Actual" de:
- `CLAUDE.md`
- `.cursorrules` (si existe)
- `WORKING_STATE.md` (fuente de verdad)

Reportar si estan desincronizados.

### Paso 3 — Verificar tokens y actualizaciones
Ejecutar `./scripts/validate-axis-tokens.sh --verbose` y reportar:
- Archivos que exceden limites
- Archivos por encima del 80% de su limite

Adicionalmente, ejecutar `./scripts/update-axis.sh --dry-run` para verificar si hay archivos framework desactualizados respecto al template oficial.

### Paso 4 — Reporte
Presentar al usuario:

```
## Estado del contexto AXIS

### Referencias en AGENT_CONTEXT.md
- [X archivos verificados, Y rotos]
- [lista de rotos si hay]

### Sync de bootstrap
- CLAUDE.md: [sincronizado / desincronizado]
- .cursorrules: [sincronizado / desincronizado / no existe]

### Tokens
- [archivos con problemas o "todos dentro de limites"]

### Acciones sugeridas
- [lista de correcciones si las hay, o "todo en orden"]
```

## Reglas

1. Este skill es de solo lectura — no modifica archivos, solo reporta
2. Si hay referencias rotas, sugerir si el archivo fue renombrado o eliminado
3. Si los bootstrap estan desincronizados, sugerir ejecutar `./scripts/sync-working-state.sh`
4. Ser conciso — solo reportar problemas y acciones, no listar todo lo que esta bien (a menos que todo este bien)
