---
name: update-memory
description: Revisa y actualiza MEMORY.md. Archiva items obsoletos a MEMORY_ARCHIVE.md.
triggers: Cuando el usuario dice /update-memory o pide revisar la memoria del proyecto.
dependencies: .product/memory/MEMORY.md, .product/memory/MEMORY_ARCHIVE.md
---

## Que hacer

### Paso 1 — Leer estado actual
1. Leer `.product/memory/MEMORY.md` completo
2. Leer `.product/memory/MEMORY_ARCHIVE.md` si existe
3. Estimar tokens de MEMORY.md (cada ~3.5 caracteres = 1 token)

### Paso 2 — Evaluar contenido
Para cada item en MEMORY.md, clasificar:
- **Vigente** — sigue siendo relevante para decisiones actuales
- **Obsoleto** — ya no aplica (tecnologia cambiada, problema resuelto, decision reemplazada)
- **Candidato a archivar** — correcto pero no necesario en el dia a dia

### Paso 3 — Proponer cambios
Presentar al usuario:

```
## Revision de MEMORY.md (~X tokens)

### Mantener
- [items vigentes]

### Propuesta: archivar a MEMORY_ARCHIVE.md
- [items obsoletos o no necesarios en dia a dia]
  Razon: [por que ya no necesita estar en MEMORY.md]

### Propuesta: agregar
- [hechos nuevos de la sesion actual, si los hay]

### Resultado estimado: ~Y tokens (limite: 3,000)
```

### Paso 4 — Ejecutar con aprobacion
Solo aplicar cambios cuando el usuario apruebe:
1. Mover items archivados a `MEMORY_ARCHIVE.md` con fecha y razon
2. Agregar items nuevos a `MEMORY.md` en la seccion correspondiente
3. Verificar que MEMORY.md quede bajo 3,000 tokens

## Reglas

1. NUNCA borrar informacion — lo que sale de MEMORY.md va a MEMORY_ARCHIVE.md
2. No modificar sin aprobacion del usuario
3. Mantener MEMORY.md bajo 3,000 tokens
4. Al archivar, incluir fecha y razon: `## [Fecha] — [Tema] / Razon: [por que se archivo]`
5. Si MEMORY.md ya esta bajo 3,000 tokens y todo es vigente, decir "memoria saludable, sin cambios necesarios"
