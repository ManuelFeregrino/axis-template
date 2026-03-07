---
name: session-protocol
description: Protocolo de inicio de sesion, actualizacion de estado tras cada tarea, y memory flush.
triggers: Al iniciar una sesion de trabajo o cuando se pide memory flush.
dependencies: WORKING_STATE.md, .product/memory/
---

## Contexto
Este skill define como el agente gestiona el estado del proyecto durante una sesion. El principio clave: actualizar `WORKING_STATE.md` despues de cada tarea completada, no al cierre de sesion (porque al cerrar sesion el agente ya no puede escribir).

## Protocolo de Inicio

1. CLAUDE.md ya se cargo automaticamente
2. Leer `WORKING_STATE.md` — entender que esta en progreso, que se completo, que sigue
3. Si existe `.product/memory/[fecha-de-hoy].md`, leerlo para contexto del dia
4. Esperar instrucciones para la primera tarea
5. Cargar skills y documentos de `.product/` segun lo que la tarea requiera

**NO cargar todo de golpe.** Seguir el mapa de progressive disclosure en AGENT_CONTEXT.md.

## Actualizacion de Estado (despues de cada tarea)

Despues de completar cada tarea, actualizar `WORKING_STATE.md`:
1. Mover la tarea completada a "Completado en Ultima Sesion"
2. Actualizar "En Progreso" con el estado real
3. Ajustar "Proxima Sesion" si cambio la prioridad
4. Agregar blockers si aparecieron

Tambien:
- Anadir entrada a `.product/memory/YYYY-MM-DD.md` (append, no sobrescribir)
- Si hay hechos duraderos nuevos -> proponer actualizacion de MEMORY.md
- Si hubo decision arquitectonica -> proponer ADR en DECISIONS.md

## Protocolo de Memory Flush

Ejecutar cuando:
- La sesion ha sido larga (>20 turnos de conversacion)
- Se completo un milestone significativo
- El responsable dice "memory flush", "guarda estado", o "guarda el progreso"
- Antes de cambiar de contexto a otra area del producto

Que hacer:
1. Anadir entrada a `.product/memory/YYYY-MM-DD.md` con formato:
```markdown
## HH:MM — [Area de trabajo]
- **Completado:** [que se hizo, archivos afectados]
- **Decisiones:** [que se decidio y por que]
- **Pendientes:** [que falta, contexto para retomar]
- **Lecciones:** [errores, patrones descubiertos]
```
2. Si hay algo que deba recordarse siempre -> proponer actualizacion de `.product/memory/MEMORY.md`
3. Verificar que `WORKING_STATE.md` este al dia

## Reglas
1. NUNCA sobrescribir entradas anteriores en logs diarios — solo append
2. WORKING_STATE.md se sobrescribe completo (es estado actual, no historial)
3. MEMORY.md se propone como diff — el responsable decide que se queda
4. Si no hay nada significativo que reportar, decir "sesion sin cambios relevantes"
5. No esperar al cierre de sesion para actualizar estado — hacerlo despues de cada tarea
