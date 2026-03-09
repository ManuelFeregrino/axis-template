---
name: session-start
description: Carga el contexto necesario para iniciar una sesion de trabajo y reporta el estado actual.
triggers: Al iniciar una sesion, o cuando el usuario dice /session-start.
dependencies: WORKING_STATE.md, .product/memory/MEMORY.md
---

## Que hacer

1. Leer `WORKING_STATE.md` completo
2. Leer `.product/memory/MEMORY.md` completo
3. Si existe `.product/memory/[fecha-de-hoy].md`, leerlo tambien
4. Leer `AGENT_CONTEXT.md` para tener el mapa de progressive disclosure

## Que reportar

Presentar un resumen al usuario con este formato:

```
## Estado del proyecto

**En progreso:** [tareas activas]
**Completado recientemente:** [ultima sesion]
**Siguiente:** [proximos pasos]
**Blockers:** [si hay]

## Memoria activa
[Resumen de 2-3 puntos clave de MEMORY.md que sean relevantes]

## Listo para trabajar
Contexto cargado. ¿Cual es la tarea?
```

## Reglas

1. NO cargar archivos de `.product/` mas alla de MEMORY.md — eso se hace bajo demanda segun la tarea
2. Si WORKING_STATE.md esta vacio o tiene solo placeholders, decirlo claramente
3. Si MEMORY.md esta vacio, no inventar contenido — solo reportar "sin memoria activa"
4. Ser conciso — este reporte no debe exceder 300 tokens
