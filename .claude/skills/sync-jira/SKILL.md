---
name: sync-jira
description: Sincroniza el estado de tasks entre AXIS y Jira. Push de progreso local a Jira, pull de cambios de Jira a AXIS.
triggers: |
  Cuando el usuario dice:
  - `/sync-jira` — sync push de todos los issues trackeados
  - `/sync-jira pull` / `/sync-jira full` — con modo explicito
  - `/sync-jira PROJ-123` — sync de un issue especifico (y sus hijos)
  - `/sync-jira https://...atlassian.net/browse/PROJ-123` — issue por URL
  - `/sync-jira https://...atlassian.net/.../boards/N` — board completo
  - Combinaciones: `/sync-jira pull PROJ-123`, `/sync-jira PROJ-123 pull`, `/sync-jira full https://...`
  - O pide "sincronizar con Jira", "actualizar Jira", o "traer cambios de Jira".
dependencies: WORKING_STATE.md, .product/context/ROADMAP.md, .product/context/PRODUCT.md, .product/memory/MEMORY.md
---

## Prerequisito

Este skill requiere MCP de Atlassian configurado. Si no esta disponible, indicar al usuario que actualice manualmente los issues en Jira.

## Modos de uso

Dos dimensiones ortogonales:

### Direccion

- `/sync-jira` — **push** (default): detecta cambios locales y los empuja a Jira
- `/sync-jira pull` — **pull**: detecta cambios en Jira y los trae a AXIS
- `/sync-jira full` — **bidireccional**: pull + push, presenta conflictos si hay

### Scope

- **Sin argumento** — todos los issues trackeados en archivos AXIS
- **Issue key o URL** — esa issue especifica + sus hijos
- **Board URL** — issues del board (sprint activo o recientes)

El orden de los tokens es flexible: `/sync-jira PROJ-123 pull` y `/sync-jira pull PROJ-123` son equivalentes.

## Mapeo de estados

| Ubicacion en AXIS | Marcador | Status AXIS | Match en Jira (fuzzy) |
|---|---|---|---|
| `Proxima Sesion` con `- [ ]` | — | TODO | To Do, Open, Backlog |
| `En Progreso` | (sin marcador) | IN_PROGRESS | In Progress, In Development |
| `En Progreso` | `[REVIEW]` | REQUIRES_REVIEW | In Review, Code Review |
| `Blockers` o con `[BLOCKED]` | `[BLOCKED]` | BLOCKED | Blocked, On Hold |
| Con `[WAITING]` o `[PENDING]` | `[WAITING]` | PENDING_INFO | Waiting, Pending, Awaiting Info |
| `Completado en Ultima Sesion` con `[x]` | — | DONE | Done, Closed, Resolved |

## Que hacer

### Paso 0 — Resolver input

Separar los tokens del argumento en **modo** y **scope**:

1. Tokenizar el argumento (split por espacios)
2. Si algun token es `push`, `pull`, o `full` → asignarlo como **modo** (default: `push`)
3. El token restante (si hay) es el **scope argument**
4. Seguir el procedimiento en `.claude/skills/_shared/jira-url-parsing.md` con el scope argument
5. Segun el resultado:
   - `NONE` → continuar a **Paso 1** (escaneo completo)
   - `KEY` o `ISSUE_URL` → continuar a **Paso 1-A** (issue especifico)
   - `BOARD_URL` → continuar a **Paso 1-B** (board)

Si el Paso 0 ya resolvio un Cloud ID, reutilizarlo en Paso 2 (no resolver de nuevo).

---

### Paso 1 — Escanear archivos AXIS (scope: todos)

> Solo aplica cuando el tipo del Paso 0 es `NONE` (sin argumento de scope).

Buscar keys de Jira (patron `[A-Z][A-Z0-9]+-\d+`) en:
- `WORKING_STATE.md` — fuente principal de estado
- `.product/context/ROADMAP.md` — objetivos con keys
- `.product/context/PRODUCT.md` — funcionalidades con keys

Extraer cada key con su status AXIS segun la seccion donde aparece y los marcadores (ver tabla de mapeo).

Continuar a **Paso 2**.

---

### Paso 1-A — Issue especifico (scope: key o issue URL)

1. Usar `getJiraIssue` con la key obtenida del Paso 0 (campos: summary, status, issuetype, priority)
2. Si el issue es Epic o Story: buscar hijos con `searchJiraIssuesUsingJql`:
   ```
   jql: "parent = {KEY} ORDER BY rank ASC"
   fields: ["summary", "status", "issuetype"]
   maxResults: 50
   ```
3. Cruzar la key principal + keys de hijos con archivos AXIS (`WORKING_STATE.md`, `ROADMAP.md`, `PRODUCT.md`)
4. Particionar en:
   - **Trackeadas en AXIS** — extraer su status AXIS (segun seccion y marcadores)
   - **No trackeadas** — reportar "X issues no estan en AXIS" y preguntar si importar (sugerir `/import-jira {KEY}`)
5. La lista de keys trackeadas es el input para los pasos siguientes

Continuar a **Paso 2**.

---

### Paso 1-B — Board (scope: board URL)

1. Usar `searchJiraIssuesUsingJql` con el project del Paso 0:
   ```
   jql: "project = {PROJECT} AND sprint in openSprints() ORDER BY rank ASC"
   fields: ["summary", "status", "issuetype", "priority"]
   maxResults: 50
   ```
2. **Fallback** si la query falla (ej: board Kanban sin sprints):
   ```
   jql: "project = {PROJECT} AND status != Done ORDER BY updated DESC"
   maxResults: 50
   ```
3. Si 0 issues encontrados: reportar "No se encontraron issues en el sprint activo del board" y terminar
4. Cruzar keys con archivos AXIS → particionar en:
   - **Ya en AXIS** — extraer su status AXIS
   - **No en AXIS** — listar separadamente
5. Presentar al usuario:
   ```
   ## Board {PROJECT} — {N} issues encontrados

   ### Ya trackeados en AXIS ({X})
   | Key | Summary | Status Jira | Status AXIS |
   ...

   ### No trackeados en AXIS ({Y})
   | Key | Summary | Status Jira |
   ...

   Opciones:
   1. Sincronizar solo los trackeados
   2. Sincronizar trackeados + importar los nuevos
   3. Seleccionar cuales sincronizar/importar
   ```
6. Si el usuario elige importar: usar `/import-jira` para cada key seleccionada, luego continuar sync
7. La lista de keys trackeadas (+ recien importadas) es el input para los pasos siguientes

Continuar a **Paso 2**.

---

### Paso 2 — Obtener Cloud ID

Si el Paso 0 ya resolvio un Cloud ID, reutilizarlo — no resolver de nuevo.

Si no, buscar en `.product/memory/MEMORY.md` el Cloud ID de Jira (reutilizar el guardado por `import-jira`).
Si no existe, pedir al usuario el Cloud ID o site URL y guardarlo en MEMORY.md.

### Paso 3 — Consultar status actual en Jira

Usar `searchJiraIssuesUsingJql` con todas las keys encontradas:
```
jql: "key in (PROJ-123, PROJ-456, PROJ-789)"
fields: ["summary", "status"]
maxResults: 50
```

### Paso 4 — Detectar discrepancias

Comparar el status AXIS de cada issue con su status en Jira usando fuzzy match (ver tabla de mapeo).
Solo reportar issues donde el status difiere.

### Paso 5 — Presentar cambios propuestos

Mostrar tabla al usuario — NUNCA ejecutar sin aprobacion:

```
## Sync Push: cambios detectados

| Key | Summary | Status AXIS | Status Jira | Accion propuesta |
|-----|---------|-------------|-------------|------------------|
| PROJ-123 | Login flow | DONE | In Progress | Transicionar a Done |
| PROJ-456 | API auth | BLOCKED | To Do | Transicionar a Blocked + comentario |
| PROJ-789 | Dashboard | IN_PROGRESS | To Do | Transicionar a In Progress |

Sin cambios: PROJ-111, PROJ-222 (ya sincronizados)

Aprobar sync? (si/no/seleccionar)
```

Si el usuario dice "seleccionar", permitir elegir cuales aplicar.

### Paso 6 — Ejecutar transiciones aprobadas

Para cada cambio aprobado:
1. Llamar `getTransitionsForJiraIssue` para obtener transiciones disponibles
2. Hacer fuzzy match entre las transiciones disponibles y el status destino (ver tabla de mapeo)
3. Si hay match: ejecutar `transitionJiraIssue` con el transition ID encontrado
4. Si NO hay match (ej: Jira no tiene status "Blocked"): agregar comentario via `addCommentToJiraIssue` indicando el status en AXIS
5. Opcionalmente agregar comentario con contexto del cambio (activado por default)

**Fuzzy match de transiciones:** Comparar el nombre de cada transicion disponible contra los nombres en la columna "Match en Jira" de la tabla de mapeo. Usar comparacion case-insensitive y match parcial (ej: "Move to Done" matchea con "Done"). Si hay multiples matches, preferir el mas especifico.

### Paso 7 — Reportar resultados

```
## Sync completado

Transiciones exitosas: X
Comentarios (sin transicion disponible): Y
Fallidos: Z

Detalle:
- PROJ-123: Done (transicionado)
- PROJ-456: Blocked (comentario — transicion no disponible)
- PROJ-789: In Progress (transicionado)
```

### Modo Pull

#### Pasos 0-3 — Identicos al push

Resolver input (Paso 0), escanear segun scope (Paso 1/1-A/1-B), obtener Cloud ID, consultar Jira.

#### Paso 4 — Detectar avances en Jira

Comparar status de Jira vs AXIS. Solo reportar issues donde Jira avanzo mas que AXIS (ej: Jira dice "Done" pero AXIS aun dice "En Progreso").

#### Paso 5 — Proponer movimientos en AXIS

Presentar tabla de cambios propuestos en WORKING_STATE.md:

```
## Sync Pull: cambios detectados en Jira

| Key | Summary | Status Jira | Ubicacion actual AXIS | Mover a |
|-----|---------|-------------|----------------------|---------|
| PROJ-123 | Login flow | Done | En Progreso | Completado en Ultima Sesion |
| PROJ-456 | API auth | In Progress | Proxima Sesion | En Progreso |

Aprobar sync? (si/no/seleccionar)
```

#### Paso 6 — Aplicar cambios aprobados

Mover los items entre secciones de WORKING_STATE.md segun lo aprobado.

#### Paso 7 — Reportar resultados

Mismo formato que push, indicando los movimientos realizados en AXIS.

### Modo Full

1. Ejecutar pull primero (Jira -> AXIS)
2. Luego ejecutar push (AXIS -> Jira)
3. Si hay conflictos (ambos lados cambiaron el mismo issue), presentarlos al usuario para resolucion manual

## Reglas

1. NUNCA transicionar issues en Jira sin aprobacion explicita del usuario — siempre presentar la tabla primero
2. Reutilizar el Cloud ID guardado en MEMORY.md por `import-jira` — no pedir de nuevo si ya existe
3. Maximo 50 issues por sync — si hay mas, paginar y preguntar al usuario
4. Agregar comentario en Jira por default en cada transicion con el contexto del cambio desde AXIS. El usuario puede desactivar esto diciendo "sin comentarios"
5. Si no hay MCP de Atlassian disponible, generar un resumen de cambios que el usuario pueda aplicar manualmente en Jira
6. No hardcodear IDs de transiciones — siempre usar `getTransitionsForJiraIssue` en runtime y hacer fuzzy match por nombre
7. Si una transicion falla, continuar con las demas y reportar el fallo al final — no abortar todo el sync
8. En modo full, si ambos lados cambiaron el mismo issue, NUNCA resolver automaticamente — siempre preguntar al usuario
9. Si un issue tiene status en Jira que no mapea a ninguna seccion de AXIS, reportarlo como "status desconocido" y sugerir mapeo
10. Incluir siempre la key de Jira (PROJ-XXX) al mover items en WORKING_STATE.md para mantener trazabilidad
