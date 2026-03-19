# HOW IT WORKS — AXIS Context System

> Cómo interactúan todos los archivos de contexto cuando programas con un agente AI (Claude Code, Cursor, Windsurf).

---

## Setup inicial — `init-project.sh`

Antes de empezar a programar, ejecuta el wizard de configuración:

```bash
bash scripts/init-project.sh
```

El wizard hace 5 cosas en orden:

1. **Info del proyecto** — nombre, descripción, audiencia, fase (Construcción/Validación/Producción)
2. **Reglas + autonomía** — 3 reglas inquebrantables inyectadas en `CLAUDE.md` + nivel de autonomía del agente (Explorador / Ejecutor / Piloto Automático) guardado en `AGENT_CONTRACT.md`
3. **Stack tecnológico** — pregunta si es Frontend / Backend / FullStack, muestra opciones contextuales, permite agregar tecnologías extra
4. **Skills desde skills.sh** — busca hasta 3 skills por tecnología, muestra installs y sección por stack, los instala localmente en `.claude/skills/` (no globalmente)
5. **Prompt para el agente** — genera un prompt listo para copiar y pegar en Claude Code según la fase del proyecto

Al terminar, todos los placeholders de `CLAUDE.md`, `AGENT_CONTEXT.md` y `WORKING_STATE.md` están reemplazados con tu información real.

---

## Al abrir Claude Code (cada sesión)

**Carga automática — sin que hagas nada:**

```
CLAUDE.md  →  El agente lo lee primero, siempre
```

Este archivo es el "sistema nervioso central". Contiene identidad del producto, fase, reglas inquebrantables, protocolo de sesión y lista de skills disponibles. Claude Code lo carga solo al iniciar.

---

## Al escribir `/session-start`

El skill `session-start` toma el control y:

**Paso 0 — Detectar compactación (PRIMERO)**
Si el mensaje tiene `<summary>` o el usuario dice "dónde estábamos" → activa el skill `working-buffer` en modo Recovery antes de cualquier otra cosa.

**Paso 1 — Cargar contexto base:**
```
WORKING_STATE.md                  →  ¿Dónde quedamos? ¿Qué está en progreso?
.product/memory/SESSION-STATE.md  →  WAL activo (correcciones y decisiones recientes)
.product/memory/MEMORY.md         →  Hechos duraderos del producto
AGENT_CONTEXT.md                  →  Mapa de progressive disclosure
```

**Paso 2 — Verificar working-buffer:**
Si `.product/memory/working-buffer.md` tiene contenido de sesión anterior, extraer contexto y limpiarlo para la nueva sesión.

**Paso 3 — Log diario:**
Si existe `.product/memory/[fecha-de-hoy].md`, leerlo para contexto fresco de hoy.

---

## Mientras programas (bajo demanda)

El agente carga **solo lo que necesita** según el tipo de tarea:

| Tipo de tarea | Archivos que se cargan |
|--------------|------------------------|
| Feature nueva | `.product/architecture/OVERVIEW.md` + `COMPONENTS.md` + skill relevante |
| Debugging | `.product/architecture/COMPONENTS.md` + `DECISIONS.md` |
| Decisión de arquitectura | `DECISIONS.md` + `RISKS.md` + `MEMORY.md` |
| Deploy / Release | `RELEASE_CHECKLIST.md` + `RUNBOOK.md` + `SECURITY.md` |

---

## WAL Protocol — Write-Ahead Log

Cuando el usuario dice algo con correcciones, nombres propios, decisiones o valores específicos, el agente escribe en `SESSION-STATE.md` **antes** de responder.

```
Usuario: "No, quiero usar Prisma no Drizzle"
→ Agente escribe en SESSION-STATE.md: "ORM: Prisma (no Drizzle)"
→ LUEGO responde
```

Esto evita perder detalles importantes cuando el contexto se compacta.

---

## Sistema de memoria anti-compactación (`working-buffer`)

Cuando la sesión es larga y el contexto está al límite:

### Activar buffer (`/danger-zone`)
El agente crea/sobrescribe `.product/memory/working-buffer.md` y empieza a registrar cada intercambio:

```markdown
## [HH:MM] Usuario
[Resumen de 1 línea]

## [HH:MM] Agente
[Lo que se hizo + detalles clave]
```

### Recovery post-compactación (`/recover`)
Si Claude Code compacta la sesión, el agente lee en este orden:

```
1. working-buffer.md   →  intercambios más recientes (la fuente más fresca)
2. SESSION-STATE.md    →  decisiones y correcciones del día
3. WORKING_STATE.md    →  estado general del proyecto
4. YYYY-MM-DD.md       →  log crudo de hoy
```

Y presenta un resumen con el último punto exacto donde quedaron, **sin preguntar "¿qué estábamos haciendo?"**

---

## Sistema de memoria en dos velocidades (`daily-log`)

```
Velocidad 1 — Log diario (crudo, append-only):
  .product/memory/YYYY-MM-DD.md
  → Todo lo que pasó hoy: tareas, decisiones, errores
  → Sin límite de tokens, sin editar el pasado
  → El agente escribe aquí durante y al final de cada sesión

Velocidad 2 — MEMORY.md (destilado, curado):
  .product/memory/MEMORY.md
  → Solo lo que vale recordar siempre
  → Máx ~3,000 tokens
  → Se actualiza por destilación, no por append
```

### Destilación (`/distill-memory`)
Cada 3-5 días de trabajo activo (o cuando MEMORY.md supera ~2,500 tokens):

1. El agente lee los últimos logs diarios
2. Identifica qué merece ir a MEMORY.md (decisiones vigentes, patrones, lecciones)
3. Propone el diff al usuario: qué añadir, actualizar, archivar
4. Solo aplica con aprobación explícita

---

## Al terminar una tarea

El agente actualiza:

```
WORKING_STATE.md                  →  Qué se hizo, qué sigue, qué bloquea
.product/memory/SESSION-STATE.md  →  WAL (correcciones/decisiones de la sesión)
```

Y si surgió algo importante:

```
.product/memory/MEMORY.md         →  Decisiones duraderas (requiere aprobación)
.product/context/DECISIONS.md     →  ADRs (decisiones arquitectónicas formales)
```

---

## Al hacer commit

El **git hook** `pre-commit` entra automáticamente:

```
WORKING_STATE.md  →  se sincroniza dentro de CLAUDE.md y .cursorrules
```

Así la próxima sesión (en cualquier IDE) arranca con el estado actual sin que hagas nada.

---

## Al escribir `/session-end`

Flush completo de memoria:

```
WORKING_STATE.md           →  Estado final del día
YYYY-MM-DD.md              →  Entrada de log con resumen de la sesión
working-buffer.md          →  Entrada de cierre, listo para próxima sesión
MEMORY.md                  →  Propuesta de hechos nuevos (si los hay)
```

Si MEMORY.md está cerca del límite, sugiere ejecutar `/distill-memory`.

---

## Niveles de autonomía del agente

Configurado en `.product/contracts/AGENT_CONTRACT.md` durante el wizard.

### 🧭 Explorador
**"Propone, no actúa"**

> *"Encontré 3 formas de estructurar el auth. ¿Cuál prefieres?"*

**Cuándo usarlo:** Proyectos nuevos, decisiones arquitectónicas abiertas, costo de error alto.

### ⚙️ Ejecutor *(recomendado)*
**"Implementa lo claro, pregunta lo ambiguo"**

> *"Implementé el CRUD con Zod. Hay una decisión sobre soft delete — ¿flag o tabla separada?"*

**Cuándo usarlo:** El 90% del tiempo. Stack definido, arquitectura clara.

### 🚀 Piloto Automático
**"Actúa, entrega, informa"**

> *"Feature de exportar CSV lista. Tests pasando. PR #12 abierto."*

**Cuándo usarlo:** Tareas rutinarias de bajo riesgo, confianza total establecida.

---

## El diagrama mental completo

```
Siempre activo:
  CLAUDE.md ──────────────────── Bootstrap (reglas, identidad, skills)

Al iniciar sesión:
  working-buffer.md ──────────── Detectar compactación (primero)
  WORKING_STATE.md ────────────── ¿Dónde quedamos?
  SESSION-STATE.md ────────────── WAL activo (correcciones del día)
  MEMORY.md ───────────────────── Historia destilada del producto
  AGENT_CONTEXT.md ────────────── Mapa de progressive disclosure

Bajo demanda (según tarea):
  .product/architecture/   ──────── Estructura, componentes, riesgos
  .product/context/        ──────── Negocio, decisiones, roadmap
  .product/security/       ──────── Solo cuando hay deploy o auth
  .product/operations/     ──────── Solo en release
  .claude/skills/          ──────── Solo cuando la tarea lo requiere

Se actualiza constantemente:
  WORKING_STATE.md ────────────── Después de cada tarea
  SESSION-STATE.md ────────────── WAL — antes de responder correcciones
  working-buffer.md ──────────── En zona de peligro: cada intercambio
  YYYY-MM-DD.md ──────────────── Log crudo append-only
  MEMORY.md ───────────────────── Por destilación, con aprobación
```

---

## Precedencia de memoria

Cuando dos fuentes tienen información contradictoria:

1. **ADRs en `DECISIONS.md`** — máxima autoridad (decisiones formales)
2. **`MEMORY.md`** — fuente de verdad para hechos duraderos
3. **Logs diarios `YYYY-MM-DD.md`** — registro temporal
4. **`SESSION-STATE.md`** — estado operativo de hoy
5. **`working-buffer.md`** — más reciente, solo para recovery

---

## Referencia rápida de archivos

| Archivo | Quién lo escribe | Cuándo se actualiza |
|---------|-----------------|---------------------|
| `CLAUDE.md` | Tú + git hook | Al inicializar y en cada commit |
| `WORKING_STATE.md` | El agente | Después de cada tarea |
| `AGENT_CONTEXT.md` | Tú / el agente | Cuando cambia el mapa de contexto |
| `.product/memory/MEMORY.md` | El agente (con aprobación) | Por destilación periódica |
| `.product/memory/SESSION-STATE.md` | El agente | WAL — antes de responder |
| `.product/memory/working-buffer.md` | El agente | En zona de peligro o recovery |
| `.product/memory/YYYY-MM-DD.md` | El agente | Append durante/al final de sesión |
| `.product/context/DECISIONS.md` | El agente | Al tomar decisiones arquitectónicas |
| `.product/contracts/AGENT_CONTRACT.md` | `init-project.sh` / tú | Al configurar nivel de autonomía |

## Comandos disponibles

| Comando | Qué hace |
|---------|----------|
| `/session-start` | Carga contexto, detecta compactación, reporta estado |
| `/session-end` | Flush de memoria, log diario, cierre de sesión |
| `/danger-zone` | Activa working buffer anti-compactación |
| `/recover` | Recovery post-compactación desde el buffer |
| `/daily-log` | Añade entrada al log del día |
| `/distill-memory` | Destila logs diarios a MEMORY.md (con aprobación) |
| `/update-memory` | Revisa y limpia MEMORY.md |
| `/sync-context` | Verifica integridad del contexto |
| `/import-jira` | Importa Epic/Stories/Tasks de Jira |
| `/sync-jira` | Sincroniza tasks con Jira |
| `/distill-memory` | Propone actualización de MEMORY.md desde logs |
| `commit-and-pr` | Hace commits y PRs con formato correcto |
| `adr` | Documenta decisiones arquitectónicas |
