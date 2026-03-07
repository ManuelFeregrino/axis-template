---
name: adr
description: Formato y proceso para Architecture Decision Records (ADR). Como documentar decisiones arquitectonicas.
triggers: Cuando se toma una decision de arquitectura, diseno de sistema, o eleccion de tecnologia.
dependencies: .product/context/DECISIONS.md
---

## Contexto
Cada decision arquitectonica relevante se registra como ADR en `.product/context/DECISIONS.md`. Los ADRs son append-only — nunca se borran, solo se cambia su estado.

## Cuando crear un ADR

- Eleccion de tecnologia o framework
- Cambio en la estructura de capas o modulos
- Decision de patron de comunicacion entre componentes
- Trade-off significativo (performance vs. simplicidad, etc.)
- Cambio que afecta como otros agentes o personas trabajan en el producto

**NO crear ADR para:** preferencias de estilo, elecciones triviales (nombre de variable), o decisiones que no afectan a nadie mas.

## Formato estandar

```markdown
## ADR-[NNN]: [Titulo descriptivo de la decision]

**Estado:** Pendiente / Aceptada / Reemplazada por ADR-XXX
**Fecha:** YYYY-MM-DD
**Contexto:** [Que situacion requiere una decision. 2-3 lineas.]

**Opciones consideradas:**
1. [Opcion A] — [pros/cons en 1 linea]
2. [Opcion B] — [pros/cons en 1 linea]
3. [Opcion C] — [pros/cons en 1 linea] (si aplica)

**Decision:** [Que se eligio y la razon principal]

**Consecuencias:**
- [Que implica esta decision — positivo]
- [Que implica — negativo o trade-off]

**Impacto para agentes futuros:**
[Que debe saber un agente antes de trabajar en areas afectadas.
Esta seccion existe para que agentes de AI que lleguen en sesiones
futuras no contradigan esta decision.]
```

## Proceso

1. El agente propone el ADR como parte del ritual de cierre (si aplica)
2. El responsable revisa y aprueba
3. Se agrega al indice al inicio de DECISIONS.md
4. Se actualiza AGENT_CONTEXT.md si la decision cambia el mapa de contexto
5. Se actualiza MEMORY.md con un resumen de 1 linea

## Reglas
1. Numeracion secuencial: ADR-001, ADR-002, etc.
2. Nunca borrar un ADR — solo cambiar estado a "Reemplazada por ADR-XXX"
3. El campo "Impacto para agentes futuros" es OBLIGATORIO
4. El indice al inicio de DECISIONS.md siempre debe estar actualizado
5. En nivel EXPLORADOR: el agente propone, el responsable aprueba. En nivel EJECUTOR: el agente puede crear el ADR pero el responsable lo valida antes del merge
