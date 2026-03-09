# AXIS Template

**AXIS** (Agent eXperience & Information Structure) organiza el contexto de tu proyecto para que agentes de AI (Claude Code, Cursor, Windsurf) trabajen de forma efectiva desde el primer minuto. El agente carga solo lo que necesita, cuando lo necesita, y recuerda lo importante entre sesiones.

## Quick Start

### Proyecto nuevo

```bash
# 1. Clonar el template
git clone https://github.com/ManuelFeregrino/axis-template.git mi-proyecto
cd mi-proyecto

# 2. Empezar con historial limpio
rm -rf .git
git init

# 3. Instalar hooks y hacer scripts ejecutables
chmod +x scripts/*.sh
./scripts/install-git-hooks.sh

# 4. Reemplazar los placeholders [NOMBRE DEL PRODUCTO], [NOMBRE], etc.
#    en CLAUDE.md, WORKING_STATE.md, y los archivos en .product/

# 5. Primer commit
git add .
git commit -m "init: inicializa proyecto con AXIS"
```

### Proyecto existente

```bash
# Un solo comando desde la raiz de tu proyecto
curl -fsSL https://raw.githubusercontent.com/ManuelFeregrino/axis-template/main/scripts/install-axis.sh | bash
```

El script instala todo y te indica el siguiente paso: reemplazar los placeholders `[NOMBRE DEL PRODUCTO]`, `[NOMBRE]`, etc. en `CLAUDE.md`, `WORKING_STATE.md`, y `.product/`.

Si AXIS ya esta instalado, el script te lo dice y sugiere `update-axis.sh` para actualizar o `install-axis.sh --force` para reinstalar desde cero.

### Que llenar despues de instalar

Estos 3 archivos son los mas importantes para arrancar. Sin ellos, el agente trabaja a ciegas:

| Archivo | Que poner |
|---------|-----------|
| `CLAUDE.md` | Identidad del producto, reglas criticas, estado actual |
| `.product/context/PRODUCT.md` | Que hace el producto y para quien |
| `.product/architecture/OVERVIEW.md` | Stack, diagrama, patrones principales |

Los demas archivos en `.product/` los vas llenando tu conforme avanza el proyecto. No necesitas completar todo desde el dia uno.

> **Tip:** El agente puede proponerte drafts de estos archivos conforme trabajan juntos. Tu revisas y haces commit.

<details>
<summary>Lista completa de archivos que puedes llenar</summary>

Todos estos los llena el programador — es conocimiento del producto que el agente no puede inventar. El agente puede proponerte drafts, pero tu revisas y haces commit.

| Archivo | Que poner |
|---------|-----------|
| `CLAUDE.md` | Identidad del producto, reglas criticas, estado actual |
| `.cursorrules` | Lo mismo que CLAUDE.md (para Cursor/Windsurf) |
| `.product/context/PRODUCT.md` | Que hace el producto y para quien |
| `.product/context/BUSINESS.md` | Modelo de negocio, cliente, monetizacion |
| `.product/context/ROADMAP.md` | Objetivos a 30/60/90 dias |
| `.product/architecture/OVERVIEW.md` | Stack, diagrama, patrones |
| `.product/architecture/COMPONENTS.md` | Detalle de cada componente |
| `.product/architecture/RISKS.md` | Riesgos tecnicos y deuda conocida |
| `.product/security/SECURITY.md` | Politicas de seguridad, datos sensibles |
| `.product/security/THREAT_MODEL.md` | Superficie de ataque, amenazas |
| `.product/operations/RUNBOOK.md` | Procedimientos de deploy y rollback |
| `.product/operations/RELEASE_CHECKLIST.md` | Checklist pre-release |
| `.product/contracts/AGENT_CONTRACT.md` | Nivel de autonomia del agente |

</details>

---

## Uso diario

### Flujo de una sesion

```
1. Iniciar sesion     →  /session-start
2. Trabajar           →  el agente carga contexto segun la tarea
3. Completar tarea    →  el agente actualiza WORKING_STATE.md
4. Repetir 2-3
5. Cerrar sesion      →  /session-end
```

El agente actualiza `WORKING_STATE.md` despues de cada tarea. Un git hook sincroniza ese estado dentro de `CLAUDE.md` y `.cursorrules` en cada commit, para que la proxima sesion arranque con contexto fresco sin importar el IDE.

### Comandos disponibles

En Claude Code se invocan como `/nombre`:

| Comando | Que hace | Cuando usarlo |
|---------|----------|---------------|
| `/session-start` | Carga contexto y reporta estado del proyecto | Al iniciar cada sesion de trabajo |
| `/session-end` | Memory flush: guarda estado y conocimiento adquirido | Al terminar una sesion |
| `/update-memory` | Revisa MEMORY.md, archiva items obsoletos | Cuando la memoria crece o se siente desactualizada |
| `/sync-context` | Verifica integridad de referencias y sync de bootstrap | Cuando sospechas que algo esta desincronizado |
| `/import-jira` | Importa Epic/Stories/Tasks de Jira y los mapea a archivos AXIS | Al iniciar trabajo sobre un Epic de Jira |

---

## Actualizar AXIS

### `update-axis.sh` — Actualizar archivos framework

Actualiza scripts, hooks, skills y README sin tocar tu contenido:

```bash
./scripts/update-axis.sh             # Actualizar
./scripts/update-axis.sh --dry-run   # Ver que cambiaria sin aplicar
```

### `install-axis.sh --force` — Reinstalar desde cero

Sobreescribe todo, incluyendo `CLAUDE.md`, `.product/`, etc. Util si quieres empezar de cero con la ultima version del template:

```bash
./scripts/install-axis.sh --force
```

### Que se actualiza y que no

| | `update-axis.sh` | `install-axis.sh --force` |
|---|:---:|:---:|
| `scripts/*.sh` | Se actualiza | Se sobreescribe |
| `git-hooks/` | Se actualiza | Se sobreescribe |
| `.claude/skills/` | Se actualiza | Se sobreescribe |
| `README.md` | Se actualiza | Se sobreescribe |
| `CLAUDE.md` | **No se toca** | Se sobreescribe |
| `.cursorrules` | **No se toca** | Se sobreescribe |
| `WORKING_STATE.md` | **No se toca** | Se sobreescribe |
| `.product/*` | **No se toca** ¹ | Se sobreescribe |
| `.gitignore` | **No se toca** | Se mergea |

¹ Si el template agrega un archivo nuevo en `.product/` que no existe localmente, `update-axis.sh` lo crea.

---

## Como funciona (para curiosos)

### El problema que resuelve

Cuando trabajas con un agente de AI en un proyecto de software:

- **Sin contexto**, el agente genera codigo generico que no respeta la arquitectura existente.
- **Con demasiado contexto**, se desperdician tokens en cada turno y el agente pierde foco.
- **Sin memoria**, cada sesion empieza de cero: repites las mismas explicaciones una y otra vez.
- **Sin estructura**, el agente no sabe donde buscar ni que archivos importan.

AXIS resuelve esto con tres ideas:

1. **Progressive disclosure** — el agente carga contexto por capas segun la tarea, no todo de golpe.
2. **Token budgets** — cada archivo tiene un limite de tokens para evitar saturar la ventana de contexto.
3. **Memoria en capas** — estado actual (`WORKING_STATE.md`), hechos duraderos (`MEMORY.md`), y opcionalmente logs diarios.

### Capas de contexto

AXIS organiza la informacion en 4 capas. El agente solo carga lo que necesita:

```
Capa 0 - Bootstrap (se carga SIEMPRE, cada turno)
  CLAUDE.md / .cursorrules         max ~3,000 tokens

Capa 1 - Sesion (se carga al iniciar sesion)
  WORKING_STATE.md                 max ~2,000 tokens
  AGENT_CONTEXT.md                 max ~2,000 tokens

Capa 2 - Bajo demanda (se carga segun la tarea)
  .product/context/*               Negocio, roadmap, decisiones
  .product/architecture/*          Stack, componentes, riesgos
  .product/operations/*            Deploy, runbook
  .product/security/*              Politicas, amenazas
  .product/contracts/*             Autonomia del agente
  .product/memory/MEMORY.md        Hechos duraderos

Capa 3 - Skills (se carga cuando la tarea lo requiere)
  .claude/skills/*/SKILL.md        Instrucciones especializadas
```

El mapa de que cargar segun la tarea esta en `AGENT_CONTEXT.md`.

### Memoria entre sesiones

El agente no pierde contexto entre conversaciones:

- **`WORKING_STATE.md`** — Estado actual: que esta en progreso, que sigue, que bloquea. Se sobrescribe cada sesion.
- **`.product/memory/MEMORY.md`** — Hechos duraderos: decisiones vigentes, preferencias, lecciones. Se mantiene bajo 3,000 tokens.
- **`.product/memory/YYYY-MM-DD.md`** _(opcional)_ — Log diario: que se hizo, que se decidio. Append-only. Util para equipos que quieren trazabilidad detallada.

**Precedencia de memoria** — cuando dos fuentes dicen cosas distintas:

1. **ADRs aceptadas** en `DECISIONS.md` — maxima autoridad
2. **`MEMORY.md`** — fuente de verdad para hechos duraderos
3. **Logs diarios** (si se usan) — registro temporal, no prevalece sobre MEMORY.md
4. **`WORKING_STATE.md`** — estado operativo, no fuente de verdad historica

### Integracion de conocimiento externo

Si un recurso externo (Confluence, Notion, wiki) se consulta mas de 2 veces, persiste el contenido relevante en `.product/`:

| Tipo de contenido | Donde persistir |
|-------------------|----------------|
| Decisiones de arquitectura | `.product/context/DECISIONS.md` como ADR |
| Contexto de negocio | `.product/context/BUSINESS.md` o `PRODUCT.md` |
| Procedimientos operativos | `.product/operations/RUNBOOK.md` |
| Politicas de seguridad | `.product/security/SECURITY.md` |
| Otro conocimiento duradero | `.product/memory/MEMORY.md` |

**Regla simple:** si copias-y-pegas del mismo doc externo por tercera vez, es momento de traer ese contenido al repositorio.

### Skills

Los skills son instrucciones modulares que el agente carga solo cuando las necesita. Viven en `.claude/skills/[nombre]/SKILL.md`.

El template incluye 8 skills:

| Skill | Tipo | Que hace |
|-------|------|----------|
| `session-start` | Comando | Carga contexto e inicia sesion con reporte de estado |
| `session-end` | Comando | Memory flush y cierre de sesion |
| `update-memory` | Comando | Revisa MEMORY.md y archiva items obsoletos |
| `sync-context` | Comando | Verifica integridad de referencias y sync de bootstrap |
| `import-jira` | Comando | Importa Epic/Stories/Tasks de Jira a archivos AXIS |
| `session-protocol` | Referencia | Protocolo completo de sesion |
| `commit-and-pr` | Referencia | Conventional Commits, branching, estructura de PRs |
| `adr` | Referencia | Formato y proceso para Architecture Decision Records |

Puedes agregar skills propios para tu dominio (patrones de codigo, testing, etc.).

### Niveles de autonomia

El archivo `.product/contracts/AGENT_CONTRACT.md` define 3 niveles:

| Nivel | Cuando | Comportamiento |
|-------|--------|---------------|
| **Explorador** | Arquitectura, decisiones de diseno | Propone opciones, espera aprobacion |
| **Ejecutor** (default) | Features con specs claras | Implementa y reporta |
| **Piloto Automatico** | Tareas rutinarias, bajo riesgo | Implementa y propone PR completo |

### Archivos que actualiza el agente

Estos archivos los actualiza el agente (con tu aprobacion), no tu directamente:

| Archivo | Cuando se actualiza |
|---------|---------------------|
| `WORKING_STATE.md` | Despues de cada tarea completada |
| `.product/memory/YYYY-MM-DD.md` | Durante la sesion — logs diarios, append-only |
| `.product/memory/MEMORY.md` | Cuando hay hechos duraderos nuevos |
| `.product/context/DECISIONS.md` | Cuando se toma una decision arquitectonica |
| `AGENT_CONTEXT.md` | Cuando cambia el mapa de contexto del producto |
| `CHANGELOG.md` | Al preparar un release |

El git hook `pre-commit` sincroniza automaticamente `WORKING_STATE.md` dentro de `CLAUDE.md` y `.cursorrules` en cada commit.

---

## Referencia

### Estructura de archivos

```
proyecto/
├── CLAUDE.md                          # Bootstrap para Claude Code
├── .cursorrules                       # Bootstrap para Cursor/Windsurf
├── AGENT_CONTEXT.md                   # Mapa de progressive disclosure
├── WORKING_STATE.md                   # Estado actual del trabajo
├── CHANGELOG.md                       # Historial de cambios
│
├── .product/                          # Cerebro del producto
│   ├── context/
│   │   ├── PRODUCT.md                 # Que es y para quien
│   │   ├── BUSINESS.md                # Modelo de negocio
│   │   ├── ROADMAP.md                 # Hacia donde va
│   │   └── DECISIONS.md               # ADRs (decisiones arquitectonicas)
│   ├── architecture/
│   │   ├── OVERVIEW.md                # Stack y estructura general
│   │   ├── COMPONENTS.md              # Detalle de componentes
│   │   └── RISKS.md                   # Riesgos y deuda tecnica
│   ├── operations/
│   │   ├── RUNBOOK.md                 # Procedimientos de deploy/rollback
│   │   └── RELEASE_CHECKLIST.md       # Checklist obligatorio pre-release
│   ├── security/
│   │   ├── SECURITY.md                # Politicas de seguridad
│   │   └── THREAT_MODEL.md            # Modelo de amenazas
│   ├── contracts/
│   │   └── AGENT_CONTRACT.md          # Autonomia y protocolos del agente
│   └── memory/
│       ├── MEMORY.md                  # Hechos duraderos del producto
│       └── MEMORY_ARCHIVE.md          # Items archivados de MEMORY.md
│
├── .claude/skills/                    # Skills modulares
│   ├── session-start/SKILL.md         # /session-start
│   ├── session-end/SKILL.md           # /session-end
│   ├── update-memory/SKILL.md         # /update-memory
│   ├── sync-context/SKILL.md          # /sync-context
│   ├── import-jira/SKILL.md           # /import-jira
│   ├── session-protocol/SKILL.md      # Referencia de protocolo
│   ├── commit-and-pr/SKILL.md         # Commits y PRs
│   └── adr/SKILL.md                   # Architecture Decision Records
│
├── scripts/
│   ├── install-axis.sh                # Instala AXIS en proyecto existente
│   ├── install-git-hooks.sh           # Instala git hooks de AXIS
│   ├── sync-working-state.sh          # Sincroniza WORKING_STATE -> CLAUDE.md + .cursorrules
│   ├── validate-axis-tokens.sh        # Valida limites de tokens
│   └── update-axis.sh                 # Actualiza AXIS desde el template
│
└── git-hooks/
    └── pre-commit                     # Auto-sync en cada commit
```

### Scripts incluidos

| Script | Que hace | Cuando usarlo |
|--------|----------|---------------|
| `install-axis.sh` | Instala AXIS en un proyecto existente (un solo comando) | Una vez al adoptar AXIS |
| `install-git-hooks.sh` | Copia los hooks de `git-hooks/` a `.git/hooks/` | Una vez despues de clonar |
| `sync-working-state.sh` | Inyecta el estado de `WORKING_STATE.md` en `CLAUDE.md` y `.cursorrules` | Automatico via pre-commit hook |
| `validate-axis-tokens.sh` | Verifica que ningun archivo exceda su limite de tokens | Manual o en CI |
| `update-axis.sh` | Actualiza archivos framework de AXIS desde el template sin tocar tu proyecto | Cuando hay nueva version de AXIS |

```bash
# Validar que todos los archivos estan dentro de limites
./scripts/validate-axis-tokens.sh --verbose

# Solo verificar (exit code 1 si falla, util para CI)
./scripts/validate-axis-tokens.sh --ci
```

### Compatible con

- **Claude Code** — usa `CLAUDE.md` (se auto-carga)
- **Cursor** — usa `.cursorrules` (se auto-carga)
- **Windsurf** — usa `.cursorrules` (se auto-carga)
- **Cualquier agente** — los archivos `.product/` son markdown estandar
