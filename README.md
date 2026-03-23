# 🗄️ Oracle APEX Advanced Solution

[![Oracle APEX](https://img.shields.io/badge/Oracle%20APEX-23.x-orange.svg)](https://apex.oracle.com)
[![PL/SQL](https://img.shields.io/badge/PL/SQL-Advanced-green.svg)](https://www.oracle.com/database/technologies/appdev/plsql.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://docker.com)

## 📋 Descripción

Colección avanzada de scripts PL/SQL para Oracle APEX, incluyendo procedimientos almacenados, triggers, funciones y patrones de optimización para aplicaciones empresariales.

## ✨ Características

- 📦 **Procedimientos Almacenados**: PL/SQL optimizado para alto rendimiento
- 🔄 **Triggers**: Automatización de lógica de negocio
- 📊 **Funciones**: Funciones personalizadas para reportes
- 🎯 **Patrones Avanzados**: Mejores prácticas Oracle
- 🛡️ **Seguridad**: Stored procedures con validación de entrada
- 📈 **Optimización**: Índices, particiones y caching
- 🐳 **Docker Ready**: Contenedorizable con docker-compose

## 🚀 Uso

### Prerequisites

- Oracle Database 19c o superior
- Oracle APEX 23.x
- SQL*Plus o SQLcl

### Docker Compose

```bash
# Iniciar Oracle
docker-compose up -d

# Ver estado
docker-compose ps
```

### Ejecutar Scripts Manualmente

```bash
# Conectar a Oracle
sqlplus usuario/password@//localhost:1521/XEPDB1

# Ejecutar scripts en orden
@plsql_procedures.sql
@advanced_plsql.sql
```

### Usar Procedimientos

```sql
-- Verificar procedimientos disponibles
SELECT object_name, object_type 
FROM user_objects 
WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE');

-- Ejecutar procedimiento
EXEC nombre_procedimiento(parametros);
```

## 📁 Estructura

```
oracle-apex-solution-20260321/
├── advanced_plsql.sql        # PL/SQL avanzado
├── plsql_procedures.sql      # Procedimientos base
├── setup.sh                  # Script de configuración
├── health_check.py           # Health check
├── docker-compose.yml        # Orquestación Docker
├── README.md                 # Este archivo
├── SECURITY.md               # Políticas de seguridad
├── CODE_OF_CONDUCT.md        # Código de conducta
├── CONTRIBUTING.md           # Guía de contribución
├── CODEOWNERS                # Owners del código
├── LICENSE
└── .gitignore
```

## ⚙️ Configuración

### Variables de Entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| `ORACLE_USER` | Usuario de conexión | apexuser |
| `ORACLE_PASS` | Password de conexión | password |
| `ORACLE_HOST` | Host de Oracle | localhost |
| `ORACLE_PORT` | Puerto de Oracle | 1521 |
| `ORACLE_SERVICE` | Service name | XEPDB1 |

### Conexión SQL*Plus

```bash
# Conexión básica
sqlplus user/pass@host:port/service

# Como SYSDBA
sqlplus / as sysdba

# Con archivo de conexión
sqlplus user/pass@connect_string
```

## 📄 Scripts Disponibles

### plsql_procedures.sql

Contiene procedimientos fundamentales:

| Procedimiento | Descripción |
|---------------|-------------|
| `create_audit_trigger` | Trigger de auditoría |
| `log_operations` | Logging de operaciones |
| `validate_input` | Validación de entrada |

### advanced_plsql.sql

Contiene procedimientos avanzados:

| Procedimiento | Descripción |
|---------------|-------------|
| `bulk_operations` | Operaciones en bulk |
| `dynamic_sql_handler` | SQL dinámico seguro |
| `pagination_helper` | Paginación optimizada |
| `cache_manager` | Gestión de cache |

## 🔐 Seguridad

### Principios de Seguridad

1. **Principio de mínimo privilegio**: Usuarios solo tienen permisos necesarios
2. **Validación de entrada**: Todos los inputs son sanitizados
3. **SQL dinámico seguro**: Usar bind variables para prevenir SQL injection
4. **Auditoría**: Logging de todas las operaciones sensibles

### Validación de Entrada

```sql
CREATE OR REPLACE PROCEDURE safe_update (
    p_id IN NUMBER,
    p_value IN VARCHAR2
) AS
BEGIN
    -- Validar que p_id es un número válido
    IF NOT validate_input(p_id, 'NUMBER') THEN
        RAISE_APPLICATION_ERROR(-20001, 'ID inválido');
    END IF;
    
    -- Validar longitud de p_value
    IF LENGTH(p_value) > 1000 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Valor demasiado largo');
    END IF;
    
    -- Proceder con update
    UPDATE table SET value = p_value WHERE id = p_id;
END;
```

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:
1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Add nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

Ver [CONTRIBUTING.md](CONTRIBUTING.md) para más detalles.

## 🧪 Testing

```bash
# Ejecutar setup
./setup.sh

# Health check
python3 health_check.py
```

## 📝 Licencia

MIT - ver [LICENSE](LICENSE) para detalles.

## 🌐 Referencias

- [Oracle PL/SQL Documentation](https://docs.oracle.com/en/database/oracle/plsql/)
- [Oracle APEX Documentation](https://docs.oracle.com/en/database/oracle/apex/)
- [Oracle Database Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/)
- [Oracle SQL*Plus User's Guide](https://docs.oracle.com/en/database/oracle/sqlplus/19/)

## 👤 Autor

**Alex** - [@alexkore12](https://github.com/alexkore12)