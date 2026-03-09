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
- Si hay hechos duraderos nuevos -> proponer actualizacion de MEMORY.md
- Si hubo decision arquitectonica -> proponer ADR en DECISIONS.md
- (Opcional) Anadir entrada a `.product/memory/YYYY-MM-DD.md` si el equipo usa logs diarios

## Protocolo de Memory Flush

Ejecutar cuando:
- La sesion ha sido larga (>20 turnos de conversacion)
- Se completo un milestone significativo
- El responsable dice "memory flush", "guarda estado", o "guarda el progreso"
- Antes de cambiar de contexto a otra area del producto

Que hacer:
1. Actualizar `.product/memory/MEMORY.md` con hechos duraderos nuevos (mantener < 3,000 tokens)
2. Verificar que `WORKING_STATE.md` este al dia
3. Si hubo decision arquitectonica -> registrar ADR en `.product/context/DECISIONS.md`
4. (Opcional) Si el equipo usa logs diarios, anadir entrada a `.product/memory/YYYY-MM-DD.md`

## Reglas
1. Si el equipo usa logs diarios: nunca sobrescribir entradas anteriores — solo append
2. WORKING_STATE.md se sobrescribe completo (es estado actual, no historial)
3. MEMORY.md se propone como diff — el responsable decide que se queda
4. Si no hay nada significativo que reportar, decir "sesion sin cambios relevantes"
5. No esperar al cierre de sesion para actualizar estado — hacerlo despues de cada tarea
6. Ante conflicto entre fuentes de memoria: ADRs > MEMORY.md > logs diarios > WORKING_STATE.md (ver AGENT_CONTRACT.md)
