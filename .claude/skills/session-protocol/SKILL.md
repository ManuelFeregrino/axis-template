---
name: session-protocol
description: Protocolo de inicio y cierre de sesion de trabajo. Incluye memory flush y ritual de cierre.
triggers: Al iniciar una sesion de trabajo o cuando se pide cerrar sesion / memory flush.
dependencies: WORKING_STATE.md, .product/memory/
---

## Contexto
Este skill define como el agente debe iniciar y cerrar cada sesion de trabajo para garantizar continuidad entre sesiones. Sin este protocolo, el contexto se pierde y cada sesion empieza de cero.

## Protocolo de Inicio

1. CLAUDE.md ya se cargo automaticamente
2. Leer `WORKING_STATE.md` — entender que esta en progreso, que se completo, que sigue
3. Si existe `.product/memory/[fecha-de-hoy].md`, leerlo para contexto del dia
4. Esperar instrucciones para la primera tarea
5. Cargar skills y documentos de `.product/` segun lo que la tarea requiera

**NO cargar todo de golpe.** Seguir el mapa de progressive disclosure en AGENT_CONTEXT.md.

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
3. Actualizar `WORKING_STATE.md`

## Protocolo de Cierre de Sesion

Al final de cada sesion, generar:

```markdown
## Resumen de sesion — [fecha HH:MM]

### Completado
- [tarea: resultado concreto y archivos modificados]

### Pendiente
- [tarea: contexto especifico para retomar sin friccion]

### Decisiones tomadas
- [decision: razon — ADR pendiente si/no]

### Propuesta: Log diario (.product/memory/YYYY-MM-DD.md)
[Entrada append para el log diario]

### Propuesta: WORKING_STATE.md
[Contenido actualizado]

### Propuesta: MEMORY.md
[Diff o "sin cambios necesarios"]

### Propuesta: AGENT_CONTEXT.md
[Diff o "sin cambios necesarios"]
```

El responsable revisa, ajusta y hace commit. El agente NO hace commit directamente.

## Reglas
1. NUNCA sobrescribir entradas anteriores en logs diarios — solo append
2. WORKING_STATE.md se sobrescribe completo (es estado actual, no historial)
3. MEMORY.md se propone como diff — el responsable decide que se queda
4. Si no hay nada significativo que reportar, decir "sesion sin cambios relevantes"
