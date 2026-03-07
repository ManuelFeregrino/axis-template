---
name: commit-and-pr
description: Convenciones de commits (Conventional Commits), estructura de PRs, y estrategia de branching.
triggers: Al hacer commits, crear PRs, o trabajar con ramas.
dependencies: Ninguna
---

## Contexto
Convenciones de commits y PRs para mantener consistencia en el historial de cambios y facilitar la generacion automatica de CHANGELOG.

## Conventional Commits

Formato: `tipo: descripcion`

| Tipo | Cuando usarlo | Ejemplo |
|------|-------------|---------|
| `feat` | Nueva funcionalidad | `feat: agrega autenticacion con Google` |
| `fix` | Correccion de bug | `fix: corrige error al guardar formulario` |
| `docs` | Cambios en documentacion | `docs: actualiza AGENT_CONTEXT.md con nuevo modulo` |
| `chore` | Mantenimiento, dependencias | `chore: actualiza dependencias de seguridad` |
| `refactor` | Reestructuracion sin cambio funcional | `refactor: extrae logica de validacion a modulo` |
| `test` | Agregar o modificar tests | `test: agrega tests para modulo de pagos` |
| `style` | Formato, espacios (sin cambio funcional) | `style: aplica formateo a modulo auth` |

### Reglas
1. Descripcion en espanol o ingles (consistente dentro del producto)
2. Primera letra minuscula despues del tipo
3. Sin punto al final
4. Linea de asunto maximo 72 caracteres
5. Si es relevante, incluir ID del issue: `feat: agrega OAuth [PROJ-42]`

## Branching

```
main            -> Produccion. Solo recibe merges aprobados.
develop         -> Integracion. Aqui se acumula trabajo antes de main.
feature/[nombre]    -> Sale de develop, regresa a develop.
hotfix/[nombre]     -> Sale de main, regresa a main Y develop.
```

Convencion de nombre de rama:
```
feature/PROJ-42-descripcion-corta
hotfix/PROJ-99-fix-critico
```

## Pull Request — Estructura minima

Todo codigo que va a `main` o `develop` pasa por PR.

```markdown
## Que hace este cambio
[1-3 lineas]

## Por que
[Referencia al issue o ADR]

## Como probarlo
[Pasos para verificar]

## Checklist
- [ ] Codigo sigue las convenciones del producto
- [ ] Tests pasan
- [ ] No hay secrets en el codigo
- [ ] Documentacion AXIS actualizada si aplica
```

## Anti-patrones

### X Commits genericos
```
git commit -m "cambios"
git commit -m "fix"
git commit -m "wip"
```
**Por que no:** No aportan informacion al historial ni al CHANGELOG.

### X Merge directo a main sin PR
**Por que no:** El PR es el momento de revision humana. Sin PR no hay validacion.
