# Release Checklist — [NOMBRE]

> Sin este checklist firmado: NO hay deploy a produccion.

## Fecha de release: YYYY-MM-DD
## Version: X.X.X

### Codigo
- [ ] Todos los tests pasan
- [ ] No hay warnings de seguridad en dependencias
- [ ] Code review completado (PR aprobado)
- [ ] No hay secrets hardcodeados en el codigo

### Documentacion AXIS
- [ ] AGENT_CONTEXT.md refleja el estado actual
- [ ] WORKING_STATE.md actualizado
- [ ] DECISIONS.md con ADRs del release (si aplica)
- [ ] MEMORY.md actualizado con lecciones del ciclo
- [ ] CHANGELOG.md actualizado

### Seguridad
- [ ] SECURITY.md completo y revisado
- [ ] THREAT_MODEL.md completo y revisado
- [ ] Principio de minimo privilegio verificado

### Operaciones
- [ ] RUNBOOK.md con procedimiento de rollback
- [ ] Monitoreo configurado (logs, metricas, alertas)

### Validacion
- [ ] Funcionalidad validada
- [ ] Arquitectura revisada

### Firmas
| Rol | Nombre | Fecha |
|-----|--------|-------|
| Responsable | _________ | _________ |
| Revisor | _________ | _________ |
