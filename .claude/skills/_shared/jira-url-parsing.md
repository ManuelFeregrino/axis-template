# Jira URL Parsing — Procedimiento compartido

> Este archivo NO es un skill standalone. Es un procedimiento utilitario referenciado por `import-jira` y `sync-jira`.

## Paso 1 — Clasificar input

Dado un argumento (string o vacio), clasificar como:

| Condicion | Tipo | Ejemplo |
|-----------|------|---------|
| Vacio o ausente | `NONE` | `/sync-jira` |
| Match `https?://` | `URL` → continuar a Paso 2 | `https://mycompany.atlassian.net/browse/PROJ-123` |
| Match `^[A-Z][A-Z0-9]+-\d+$` | `KEY` → saltar a Paso 3 | `PROJ-123` |
| Otro | `UNKNOWN` → pedir al usuario una key o URL valida | `algo-raro` |

**Resultado parcial:** `{ type: NONE | KEY | URL | UNKNOWN, rawInput }`

Si `type` es `KEY`, asignar `key = rawInput` y saltar a Paso 3.

---

## Paso 2 — Parsear URL

Intentar match en este orden (el primero que matchee gana):

### Patron A — Browse URL
```
https://{site}.atlassian.net/browse/{KEY}
```
- Tipo resultado: `ISSUE_URL`
- Extraer: `site`, `key`

### Patron B — Board con selectedIssue (query param)
```
https://{site}.atlassian.net/jira/software/projects/{PROJECT}/boards/{N}?selectedIssue={KEY}
```
- Tipo resultado: `ISSUE_URL` (selectedIssue tiene precedencia sobre board)
- Extraer: `site`, `project`, `boardId`, `key` (del query param `selectedIssue`)

### Patron C — Project issues URL
```
https://{site}.atlassian.net/jira/software/projects/{PROJECT}/issues/{KEY}
```
- Tipo resultado: `ISSUE_URL`
- Extraer: `site`, `project`, `key`

### Patron D — Board URL (sin selectedIssue)
```
https://{site}.atlassian.net/jira/software/projects/{PROJECT}/boards/{N}
```
- Tipo resultado: `BOARD_URL`
- Extraer: `site`, `project`, `boardId`
- **No hay key** — este tipo representa un board completo

### Sin match
Si ninguno matchea → reportar "URL no reconocida" y pedir al usuario una key directamente.

---

## Paso 3 — Resolver Cloud ID

1. **Buscar en MEMORY.md** un Cloud ID previamente guardado. Formato esperado:
   ```
   - Jira site: {site}.atlassian.net (Cloud ID: {id}) — detectado {fecha}
   ```

2. **Si hay Cloud ID guardado** y el site coincide (o no se conoce el site porque el input fue solo una key), reutilizarlo.

3. **Si no hay Cloud ID** (o el site es diferente al guardado):
   - Llamar `getAccessibleAtlassianResources` para listar sites accesibles
   - Buscar el site que matchee con el dominio extraido de la URL
   - Si el input fue solo una `KEY` (sin site), usar el primer/unico site accesible. Si hay multiples, preguntar al usuario cual usar.
   - Tomar el `id` del recurso como Cloud ID

4. **Guardar en MEMORY.md** (sin sobrescribir otros sites):
   ```markdown
   - Jira site: {site}.atlassian.net (Cloud ID: {id}) — detectado {fecha}
   ```

---

## Resultado final

Retornar un objeto conceptual con:

```
{
  type: NONE | KEY | ISSUE_URL | BOARD_URL,
  site?: string,         // dominio del site (ej: "mycompany")
  key?: string,          // issue key (ej: "PROJ-123")
  project?: string,      // project key (ej: "PROJ")
  boardId?: string,      // board number (ej: "42")
  cloudId?: string       // Cloud ID resuelto
}
```

## Errores

| Caso | Accion |
|------|--------|
| URL no reconocida | Informar y pedir key directamente |
| Site no accesible (no aparece en `getAccessibleAtlassianResources`) | Reportar "No tienes acceso a {site}. Verifica la URL o tu conexion MCP de Atlassian." |
| Multiples sites y input fue solo KEY | Preguntar al usuario cual site usar |
