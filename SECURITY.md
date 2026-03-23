# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

Report security issues via GitHub Issues or contact the owner.

## PL/SQL Security Best Practices

- Use bind variables to prevent SQL injection
- Implement proper grants and privileges
- Enable database auditing
- Use secure authentication methods
- Regular patch management for Oracle database

## APEX Security

- Configure proper session attributes
- Enable CSRF protection
- Use built-in authentication schemes
- Implement authorization schemes
- Sanitize user inputs

## Code Security

- Never hardcode credentials in PL/SQL
- Use DBMS_CREDENTIAL for external credentials
- Implement proper error handling
- Log security-relevant events
- Regular code reviews

---

## ⚠️ CVE-2026-28500 - ONNX Supply Chain Attack

**Fecha:** Marzo 2026 | **Severidad:** HIGH (CVSS 8.6)

### Descripción
Se descubrió una vulnerabilidad crítica en la biblioteca ONNX que permite ataques a la cadena de suministro (supply chain attack).

### Vulnerabilidad
- **Vector:** `onnx.hub.load()` con parámetro `silent=True`
- **Problema:** El parámetro silent=True salta las advertencias de seguridad, permitiendo que cargas maliciosas se ejecuten sin notificación
- **Impacto:** Exfiltración de archivos sensibles (SSH keys, credenciales cloud, tokens)

### Referencias
- NVD: https://nvd.nist.gov/vuln/detail/CVE-2026-28500
- Reddit r/pwnhub: Discusión original

### Acción Recomendada
Si tu proyecto usa ONNX, verifica la versión y considera actualizar cuando hay parche disponible. Evita usar `silent=True` en producción.
