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
| Conflicto entre fuentes de memoria | Aplicar Regla de Precedencia (ver seccion abajo) |

---

## Regla de Precedencia de Memoria

Cuando exista conflicto entre fuentes de informacion del proyecto:

1. **DECISIONS.md (ADRs aceptadas)** — maxima autoridad para decisiones arquitectonicas
2. **MEMORY.md** — fuente de verdad para hechos duraderos del producto
3. **Logs diarios** (si se usan) — registro temporal, NO prevalece sobre MEMORY.md
4. **WORKING_STATE.md** — estado operativo actual, no es fuente de verdad historica

| Conflicto | Que prevalece | Accion |
|-----------|--------------|--------|
| MEMORY.md vs ADR aceptada | La ADR | Actualizar MEMORY.md para reflejar la ADR |
| WORKING_STATE.md vs MEMORY.md | MEMORY.md | Corregir WORKING_STATE.md |
| Log diario vs MEMORY.md | MEMORY.md | Ignorar el dato del log |
| Cualquier conflicto no cubierto | Escalar al responsable | No asumir |

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
1. Si hay hechos duraderos nuevos -> proponer cambio a MEMORY.md
2. Si hubo decision arquitectonica -> proponer ADR en DECISIONS.md
3. (Opcional) Si el equipo usa logs diarios -> anadir entrada a `.product/memory/YYYY-MM-DD.md`

No esperar al cierre de sesion — al cerrar, el agente ya no puede escribir.

### Protocolo de memory flush
**Ejecutar cuando:**
- La sesion ha sido larga (>20 turnos)
- Se completo un milestone significativo
- El responsable dice "memory flush" o "guarda estado"
- Antes de cambiar de contexto a otra area del producto

**Que hacer:**
1. Actualizar `.product/memory/MEMORY.md` con hechos duraderos nuevos (< 3,000 tokens)
2. Verificar que `WORKING_STATE.md` este al dia
3. Si hubo decision arquitectonica -> registrar ADR en `.product/context/DECISIONS.md`

### Reglas de tamano
- No generar archivos de contexto > 5,000 tokens sin autorizacion del responsable
- Si un archivo crece demasiado, proponer al responsable dividirlo
- MEMORY.md debe mantenerse bajo 3,000 tokens — proponer archivar items antiguos

---

## Protocolo de Conocimiento Externo

Cuando el responsable mencione informacion de fuentes externas (Confluence, Notion, docs, wikis):

1. Si el dato es relevante para la tarea actual, usarlo normalmente
2. Si el dato parece duradero o reutilizable, **proponer al responsable** persistirlo en el archivo `.product/` correspondiente
3. No decidir por cuenta propia donde persistir — proponer ubicacion y esperar aprobacion
4. Al persistir, incluir la fuente como referencia (ej: "Fuente: Confluence > Proyecto X > Arquitectura")

---

_Parte del sistema AXIS_
