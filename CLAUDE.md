# [NOMBRE DEL PRODUCTO] — Contexto para Claude Code

## Identidad
[Reemplazar con 1-2 lineas: que es, para quien, stack principal]

## Estado Actual
- Fase: [Construccion / Validacion / Produccion]
- Foco actual: [que estamos haciendo ahora]
- Ultimo cambio: [fecha + que cambio]
- Proximo objetivo: [que sigue]

## Reglas Inquebrantables
1. [Regla de seguridad mas critica]
2. [Restriccion arquitectonica fundamental]
3. [Convencion obligatoria mas importante]

## Protocolo de Sesion
1. Lee `WORKING_STATE.md` para saber donde quedamos
2. Lee `.product/memory/MEMORY.md` si necesitas contexto de largo plazo
3. Consulta segun la tarea:
   - Codigo nuevo -> skill `[code-patterns]` + `.product/architecture/OVERVIEW.md`
   - Debugging -> `.product/architecture/COMPONENTS.md`
   - Arquitectura -> `.product/context/DECISIONS.md` + `.product/architecture/OVERVIEW.md`
   - Testing -> skill `[testing]`
   - Deploy -> `.product/operations/RELEASE_CHECKLIST.md`
4. Al completar cada tarea -> actualiza `WORKING_STATE.md` con lo hecho y lo que sigue
5. Al hacer commit -> verifica que `WORKING_STATE.md` refleje el estado actual

## Skills Disponibles
| Skill | Cuando activarlo |
|-------|-----------------|
| session-protocol | Inicio y cierre de sesion |
| commit-and-pr | Hacer commits o PRs |
| adr | Documentar decisiones arquitectonicas |

Para activar: lee `.claude/skills/[nombre]/SKILL.md`
