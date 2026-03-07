# Politicas de Seguridad — [NOMBRE]

## Principios
1. **Seguridad por diseno** — no como afterthought
2. **Minimo privilegio** — cada componente solo accede a lo que necesita
3. **Defense in depth** — multiples capas de proteccion

## Datos sensibles
| Tipo de dato | Clasificacion | Tratamiento |
|-------------|--------------|-------------|
| [Tipo] | [PII / Financiero / Confidencial] | [Como se protege] |

## Accesos y permisos
| Recurso | Quien accede | Tipo de acceso |
|---------|-------------|---------------|
| [recurso] | [quien] | [lectura/escritura/admin] |

## Politicas de codigo
- No commitear secrets (API keys, passwords, tokens)
- Usar variables de entorno para configuracion sensible
- [Politica especifica del producto]

---
_Requerido para firmar RELEASE_CHECKLIST._
