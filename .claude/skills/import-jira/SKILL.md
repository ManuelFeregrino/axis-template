---
name: import-jira
description: Importa un Epic de Jira con sus User Stories y Tasks, y los mapea a los archivos AXIS correspondientes.
triggers: Cuando el usuario dice /import-jira, o pide traer trabajo de Jira para planear.
dependencies: WORKING_STATE.md, .product/context/ROADMAP.md, .product/context/PRODUCT.md
---

## Prerequisito

Este skill requiere MCP de Atlassian configurado. Si no esta disponible, indicar al usuario que copie manualmente la informacion del Epic y sus Stories/Tasks.

## Que hacer

### Paso 1 — Obtener el Epic

Preguntar al usuario:
- **Epic key** (ej: PROJ-123) — obligatorio
- **Cloud ID o site URL** de Jira — obligatorio la primera vez, luego guardar en MEMORY.md

Usar `getJiraIssue` para obtener el Epic con campos: summary, description, status, priority.

### Paso 2 — Obtener User Stories hijas

Usar `searchJiraIssuesUsingJql` con:
```
jql: "parent = PROJ-123 ORDER BY rank ASC"
fields: ["summary", "description", "status", "priority", "issuetype"]
maxResults: 50
```

### Paso 3 — Obtener Tasks de cada Story

Para cada User Story encontrada, buscar sus Tasks hijas:
```
jql: "parent = PROJ-456 ORDER BY rank ASC"
fields: ["summary", "description", "status", "priority", "issuetype", "assignee"]
maxResults: 50
```

### Paso 4 — Presentar resumen al usuario

Antes de tocar archivos, mostrar lo que se encontro:

```
## Import de Jira: [Epic summary]

### Epic: PROJ-123
[descripcion breve]

### User Stories (X encontradas)
1. PROJ-456: [summary] — [status]
   - PROJ-789: [task summary] — [status]
   - PROJ-790: [task summary] — [status]
2. PROJ-457: [summary] — [status]
   ...

### Mapeo propuesto a AXIS
- ROADMAP.md → Epic como objetivo principal
- PRODUCT.md → User Stories como funcionalidades
- WORKING_STATE.md → Tasks con status "In Progress" o "To Do" del sprint actual

¿Apruebas este mapeo?
```

### Paso 5 — Persistir en archivos AXIS (con aprobacion)

**ROADMAP.md** — Agregar/actualizar el Epic como objetivo:
```markdown
## Dia 30 — [Epic summary]
- [ ] [Story 1 summary] (PROJ-456)
- [ ] [Story 2 summary] (PROJ-457)
Metricas: [extraer de la descripcion del Epic si las hay]
```

**PRODUCT.md** — Agregar User Stories como funcionalidades en "Funcionalidades actuales":
```markdown
- [ ] [Story summary] — [descripcion en 1 linea] (PROJ-456)
```

**WORKING_STATE.md** — Mapear tasks activas:
```markdown
## En Progreso
- [Task summary] (PROJ-789) — [assignee si hay]

## Proxima Sesion
- [ ] [Task summary] (PROJ-790)
- [ ] [Task summary] (PROJ-791)
```

**MEMORY.md** — Registrar la fuente:
```markdown
## Contexto de Negocio Activo
- Epic activo: [summary] (PROJ-123) — importado de Jira [fecha]
```

### Paso 6 — Confirmar

Reportar al usuario:
```
## Import completado

- ROADMAP.md: Epic mapeado como objetivo
- PRODUCT.md: X User Stories como funcionalidades
- WORKING_STATE.md: Y Tasks activas importadas
- MEMORY.md: Fuente registrada

Fuente: Jira > [Project] > PROJ-123
Proximo: /session-start para comenzar a trabajar
```

## Reglas

1. NUNCA modificar archivos sin aprobacion del usuario — siempre mostrar el mapeo primero
2. Incluir siempre la key de Jira (PROJ-XXX) en cada item para trazabilidad
3. Solo importar tasks con status relevante (To Do, In Progress) a WORKING_STATE.md — ignorar Done/Closed
4. Si el Epic tiene mas de 10 Stories, agrupar por prioridad y preguntar cuales importar
5. Si no hay MCP disponible, pedir al usuario que pegue la informacion y seguir el mismo mapeo
6. Registrar en MEMORY.md el cloud ID de Jira para no pedirlo de nuevo
7. Si los archivos destino ya tienen contenido, proponer donde insertar — no sobrescribir lo existente
