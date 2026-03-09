---
name: import-dfc
description: Importa un DFC (Documento Fundacional del Chamaco) desde Confluence y llena los archivos AXIS con el contexto del producto.
triggers: /import-dfc, "importar DFC", "cargar el DFC", inicializar AXIS desde DFC.
dependencies: CLAUDE.md, .cursorrules, .product/context/PRODUCT.md, .product/context/BUSINESS.md, .product/context/ROADMAP.md, .product/architecture/OVERVIEW.md, .product/architecture/RISKS.md, .product/memory/MEMORY.md
---

## Prerequisito

Este skill requiere MCP de Atlassian configurado para leer desde Confluence. Si no esta disponible, el usuario puede pegar el contenido del DFC como Markdown.

## Cobertura DFC → AXIS

| Archivo AXIS | Secciones DFC | Cobertura |
|---|---|---|
| `CLAUDE.md` + `.cursorrules` | §1 TL;DR + §9 Stack + §4 Alcance | **Alta** |
| `.product/context/PRODUCT.md` | §1 + §3 + §4 + §5 | **Completa** |
| `.product/context/BUSINESS.md` | §2 Origen + §12 Gate 0 | **Completa** |
| `.product/context/ROADMAP.md` | §5 Metricas 30/60/90 + §4 scope_out | **Alta** |
| `.product/architecture/OVERVIEW.md` | §9 Stack | **Parcial** (solo stack) |
| `.product/architecture/RISKS.md` | §7 Riesgos + §9 decisiones pendientes | **Alta** |
| `.product/security/SECURITY.md` | §8 AEGIS | **Baja** (solo nombre) |
| `.product/operations/RELEASE_CHECKLIST.md` | §8 AEGIS | **Baja** (solo nombre + compromisos) |
| `COMPONENTS.md`, `THREAT_MODEL.md`, `RUNBOOK.md` | — | **Sin cobertura** |
| `AGENT_CONTRACT.md` | — | **No aplica** (ya completo) |

## Que hacer

### Paso 1 — Obtener el DFC

Preguntar al usuario:
- **Page ID o URL de Confluence** del DFC llenado — obligatorio
- **Cloud ID** del site de Atlassian — obligatorio la primera vez, reutilizar de MEMORY.md si existe (puede venir de import-jira)

Usar `getConfluencePage` para obtener el contenido completo del DFC.

**Fallback sin MCP:** Pedir al usuario que pegue el DFC completo como Markdown y continuar con el mismo flujo.

### Paso 2 — Parsear las 13 secciones

Extraer datos estructurados de cada heading del DFC. Campos clave por seccion:

- **§1 TL;DR:** nombre, que_es, para_quien, por_que_ahora, hipotesis
- **§2 Origen:** cliente_sponsor, padrino, problema, evidencia, dependencias_internas
- **§3 Outcomes:** outcomes medibles
- **§4 Alcance:** scope_in, scope_out, criterios_aceptacion, entrega_minima
- **§5 Metricas:** dia_30, dia_60, dia_90
- **§7 Riesgos:** riesgos_mercado, riesgos_tecnicos, riesgos_operativos
- **§8 AEGIS:** nombre_aegis, severidad, compromisos
- **§9 Stack:** stack_preliminar, restricciones, decisiones_pendientes
- **§12 Gate 0:** decision, condiciones

### Paso 3 — Validar cobertura minima

Requiere al menos **§1 + §4 + §9** presentes. Si alguna de estas tres falta:
- Avisar cuales secciones faltan
- Preguntar si continuar con lo que hay o si el usuario quiere completar primero

Si faltan secciones opcionales (§2, §3, §5, §7, §8, §12), continuar y dejar placeholders en los archivos correspondientes.

### Paso 4 — Generar contenido

Para cada archivo AXIS, reemplazar placeholders con datos del DFC. Mapeo detallado:

**CLAUDE.md / .cursorrules:**
- `[NOMBRE DEL PRODUCTO]` ← §1 nombre
- Identidad ← "{que_es}, para {para_quien}. Stack: {tech}"
- Fase ← "Construccion"
- Foco actual ← "Construir MVP: {entrega_minima}"
- Ultimo cambio ← "{fecha_hoy} — DFC importado"
- Proximo objetivo ← §5 dia_30 primer item
- Reglas Inquebrantables ← §9 restricciones (top 3)

**PRODUCT.md:**
- Que es ← §1 que_es
- Para quien ← §1 para_quien + §2 cliente
- Por que existe ← §1 por_que_ahora + §2 problema
- Hipotesis ← §1 hipotesis
- Funcionalidades ← §4 scope_in como `- [ ]`
- Metricas ← §5 dia_30 + dia_60 metricas

**BUSINESS.md:**
- Cliente/Sponsor ← §2 cliente_sponsor
- Evidencia ← §12 Gate 0 decision + §2 evidencia
- Monetizacion ← dejar placeholder (DFC no cubre)
- Dependencias ← §2 dependencias_internas

**ROADMAP.md:**
- Dia 30 ← §5 dia_30 como `- [ ]`
- Dia 60 ← §5 dia_60 como `- [ ]`
- Dia 90 ← §5 dia_90 como `- [ ]`
- Post-MVP ← §4 scope_out

**OVERVIEW.md:**
- Stack table ← §9 stack_preliminar
- Diagrama, capas, patrones ← dejar placeholder

**RISKS.md:**
- Riesgos de mercado ← §7 riesgos_mercado con IDs RM-1, RM-2, ...
- Riesgos tecnicos ← §7 riesgos_tecnicos con IDs RT-1, RT-2, ...
- Riesgos operativos ← §7 riesgos_operativos con IDs RO-1, RO-2, ...
- Deuda tecnica conocida ← §9 decisiones_pendientes

**SECURITY.md / RELEASE_CHECKLIST.md:** Solo reemplazar `[NOMBRE]` con nombre del producto + compromisos AEGIS de §8 si los hay. No inventar contenido.

### Paso 5 — Presentar resumen

Mostrar al usuario antes de escribir:

```
## Import DFC: [nombre del producto]

### Fuente
DFC: [page ID o "pegado manualmente"] — [fecha]

### Archivos a llenar
| Archivo | Cobertura | Vista previa |
|---------|-----------|--------------|
| CLAUDE.md | Alta | "{nombre} — {que_es}, para {para_quien}" |
| .cursorrules | Alta | (espejo de CLAUDE.md) |
| PRODUCT.md | Completa | {N} funcionalidades, {M} metricas |
| BUSINESS.md | Completa | Sponsor: {padrino}, Cliente: {cliente} |
| ROADMAP.md | Alta | Dia 30: {N} items, Dia 60: {M} items, Dia 90: {P} items |
| OVERVIEW.md | Parcial | Stack: {tech} |
| RISKS.md | Alta | {X} riesgos, {Y} decisiones pendientes |
| SECURITY.md | Baja | Solo nombre + AEGIS |
| RELEASE_CHECKLIST.md | Baja | Solo nombre + AEGIS |

### Datos DFC no mapeados
- §10: [seccion] — no tiene archivo AXIS destino
- §11: [seccion] — no tiene archivo AXIS destino
- §13: [seccion] — no tiene archivo AXIS destino

¿Apruebas? Puedes pedir "ver detalle de [archivo]" antes de confirmar.
```

### Paso 6 — Persistir

Con aprobacion del usuario, escribir archivos en este orden:
1. `.product/context/PRODUCT.md`
2. `.product/context/BUSINESS.md`
3. `.product/context/ROADMAP.md`
4. `.product/architecture/OVERVIEW.md`
5. `.product/architecture/RISKS.md`
6. `.product/security/SECURITY.md`
7. `.product/operations/RELEASE_CHECKLIST.md`
8. `CLAUDE.md`
9. `.cursorrules`

### Paso 7 — Registrar en MEMORY.md

Agregar a `.product/memory/MEMORY.md`:
```markdown
## Fuente DFC
- DFC importado: [nombre] — [page ID o "pegado"] — [fecha]
- Padrino: [padrino]
- APA: [cliente/sponsor]
- AEGIS: [severidad si hay]
- Cloud ID Atlassian: [cloud_id] (reutilizable por import-jira y sync-jira)
```

### Paso 8 — Reporte final

```
## Import DFC completado

### Archivos llenados
- CLAUDE.md ✓
- .cursorrules ✓
- PRODUCT.md ✓
- BUSINESS.md ✓
- ROADMAP.md ✓
- OVERVIEW.md (parcial — solo stack)
- RISKS.md ✓
- SECURITY.md (solo nombre + AEGIS)
- RELEASE_CHECKLIST.md (solo nombre + AEGIS)

### Pendientes manuales
- [ ] OVERVIEW.md: diagrama de arquitectura, capas, patrones
- [ ] COMPONENTS.md: detalle de componentes (sin cobertura DFC)
- [ ] THREAT_MODEL.md: modelo de amenazas (sin cobertura DFC)
- [ ] RUNBOOK.md: procedimientos operativos (sin cobertura DFC)
- [ ] BUSINESS.md: modelo de monetizacion (DFC no cubre)
- [ ] Revisar Reglas Inquebrantables en CLAUDE.md

### Datos DFC no mapeados
- §10: [titulo] — disponible en DFC si se necesita
- §11: [titulo] — disponible en DFC si se necesita
- §13: [titulo] — disponible en DFC si se necesita

Proximo: revisar los archivos generados y hacer commit.
```

## Reglas

1. **Nunca escribir sin aprobacion** — siempre mostrar resumen y esperar confirmacion
2. **Si archivo ya tiene contenido real**, preguntar: reemplazar / mergear / saltar
3. **Archivos con cobertura Baja/Nula:** solo reemplazar `[NOMBRE]`, no inventar contenido
4. **Continuar con secciones faltantes** — excepto si faltan §1 + §4 + §9 simultaneamente
5. **Guardar fuente DFC en MEMORY.md** — reutilizar Cloud ID de import-jira si existe
6. **Fallback sin MCP:** pedir paste del DFC como Markdown, seguir el mismo flujo
7. **Respetar estructura Markdown exacta** de cada template AXIS — no cambiar headings ni formato
8. **Copiar del DFC textualmente** — no parafrasear ni embellecer el contenido
9. **Datos no mapeados** (§10, §11, §13) — mencionarlos en reporte final para que el usuario sepa
10. **Permitir "ver detalle"** de cualquier archivo antes de aprobar la escritura
