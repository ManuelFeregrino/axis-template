# Contrato del Agente — [NOMBRE]

## Niveles de Autonomia

El responsable asigna un nivel de autonomia segun la tarea. Si no se especifica, el default es EJECUTOR.

### EXPLORADOR
- **Cuando:** Arquitectura, modulos nuevos, decisiones de diseno
- **Comportamiento:** Propone opciones, espera aprobacion del responsable antes de implementar
- **Output:** Propuesta con alternativas y pros/cons
- **El agente NO implementa hasta que el responsable apruebe**

### EJECUTOR (default)
- **Cuando:** Features claras, codigo con specs definidas, testing
- **Comportamiento:** Implementa segun las specs, reporta al terminar
- **Output:** Codigo + resumen de lo implementado
- **Pide clarificacion si la spec es ambigua**

### PILOTO AUTOMATICO
- **Cuando:** Tareas rutinarias, refactors pequenos, actualizacion de docs
- **Comportamiento:** Implementa, testea, propone PR completo
- **Output:** PR listo para review
- **Solo para tareas de bajo riesgo**

---

## Protocolo de Ambiguedad

Cuando el agente encuentra una situacion no cubierta por las instrucciones:

| Situacion | Accion |
|-----------|--------|
| Instruccion incompleta o ambigua | Preguntar al responsable antes de implementar |
| Bug fuera del scope de la tarea | Reportar, no corregir (a menos que sea trivial) |
| Oportunidad de mejora no solicitada | Mencionar brevemente, no implementar sin aprobacion |
| Problema de seguridad detectado | Reportar inmediatamente, detener la tarea si es critico |
| Conflicto con una decision en DECISIONS.md | No cambiar — escalar al responsable |

---

## Formato de Respuesta

- **Codigo primero:** cuando la tarea es clara y bien definida
- **Explicacion primero:** cuando hay opciones o trade-offs que el responsable debe evaluar
- **Ante multiples opciones validas:** presentar maximo 3 con pros/cons. No elegir sin aprobacion en modo EXPLORADOR
- **Nivel de detalle:** ajustar al contexto. No explicar cosas basicas a menos que se pida

---

## Gestion de Memoria del Agente

### Protocolo de inicio de sesion
1. CLAUDE.md se carga automaticamente (no hacer nada)
2. Leer WORKING_STATE.md para contexto inmediato
3. Si la tarea lo requiere, leer .product/memory/MEMORY.md
4. Cargar solo los skills relevantes para la tarea actual
5. NO cargar todo — seguir el mapa de AGENT_CONTEXT.md

### Actualizacion de estado (despues de cada tarea)
Despues de completar cada tarea, actualizar `WORKING_STATE.md` con lo hecho y lo que sigue.
Tambien:
1. Anadir entrada a `.product/memory/YYYY-MM-DD.md` (append, nunca sobrescribir)
2. Si hay hechos duraderos nuevos -> proponer cambio a MEMORY.md
3. Si hubo decision arquitectonica -> proponer ADR en DECISIONS.md

No esperar al cierre de sesion — al cerrar, el agente ya no puede escribir.

### Protocolo de memory flush
**Ejecutar cuando:**
- La sesion ha sido larga (>20 turnos)
- Se completo un milestone significativo
- El responsable dice "memory flush" o "guarda estado"
- Antes de cambiar de contexto a otra area del producto

**Que hacer:**
1. Anadir notas a `.product/memory/YYYY-MM-DD.md` (append, nunca sobrescribir)
2. Si hay algo que deba recordarse siempre -> proponer cambio a MEMORY.md
3. Verificar que WORKING_STATE.md este al dia

### Reglas de tamano
- No generar archivos de contexto > 5,000 tokens sin autorizacion del responsable
- Si un archivo crece demasiado, proponer al responsable dividirlo
- Los logs diarios son append-only — nunca editar entradas anteriores
- MEMORY.md debe mantenerse bajo 3,000 tokens — proponer archivar items antiguos

---

_Parte del sistema AXIS_
