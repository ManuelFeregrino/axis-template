# Contexto del Producto — Mapa de Progressive Disclosure

> Este archivo es un INDICE, no un monolito. Apunta a los documentos correctos
> segun el tipo de tarea. Maximo 2,000 tokens.

## TL;DR
[NOMBRE DEL PRODUCTO]: [1 frase — que hace exactamente, para quien].

## Mapa de Contexto — Que cargar segun la tarea

### Codigo nuevo / feature
```
.product/architecture/OVERVIEW.md    -> Entender la estructura
.product/architecture/COMPONENTS.md  -> Saber donde va el codigo
Skill relevante del dominio          -> Patrones y convenciones
```

### Debugging / hotfix
```
.product/architecture/COMPONENTS.md  -> Entender el modulo afectado
.product/context/DECISIONS.md        -> Verificar si hay restricciones relevantes
```

### Diseno de arquitectura
```
.product/architecture/OVERVIEW.md    -> Estado actual de la arquitectura
.product/context/DECISIONS.md        -> Decisiones previas y su contexto
.product/architecture/RISKS.md       -> Riesgos tecnicos conocidos
.product/memory/MEMORY.md            -> Lecciones aprendidas relevantes
```

### Testing
```
Skill de testing                     -> Frameworks, cobertura, patrones
.product/architecture/COMPONENTS.md  -> Entender que testear
```

### Deploy / Release
```
.product/operations/RELEASE_CHECKLIST.md  -> Checklist obligatorio
.product/operations/RUNBOOK.md            -> Procedimientos de rollback
.product/security/SECURITY.md             -> Validacion de seguridad
```

### Contexto de negocio
```
.product/context/PRODUCT.md          -> Que es el producto y para quien
.product/context/BUSINESS.md         -> Modelo de negocio, cliente
.product/context/ROADMAP.md          -> Hacia donde va
```

## Estado Actual
- **Fase:** [Construccion / Validacion / Produccion]
- **WORKING_STATE.md** tiene el estado detallado del dia a dia
- **MEMORY.md** tiene los hechos duraderos del producto
