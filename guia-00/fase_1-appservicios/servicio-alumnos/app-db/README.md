# App DB - MySQL Database

Contenedor MySQL con inicialización de base de datos para la aplicación de alumnos.

## Estructura

```
app-db/
├── Dockerfile
├── init.sql
└── README.md
```

## Inicialización

El contenedor ejecuta automáticamente el script `init.sql` al iniciar, creando la tabla `duoc_alumnos` e insertando 5 alumnos iniciales.

## Variables de Entorno

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `MYSQL_ROOT_PASSWORD` | Contraseña del usuario root | `rootpassword` |
| `MYSQL_DATABASE` | Nombre de la base de datos | `duoc_db` |
| `MYSQL_USER` | Usuario de la base de datos | `duoc_user` |
| `MYSQL_PASSWORD` | Contraseña del usuario | `duoc_pass` |

## Estructura de Base de Datos

### Tabla: duoc_alumnos

| Columna | Tipo | Descripción |
|---------|------|-------------|
| id | BIGINT (PK, AUTO) | Identificador único |
| rut | VARCHAR(20) | RUT del alumno (único) |
| nombre | VARCHAR(100) | Nombre del alumno |
| apellido | VARCHAR(100) | Apellido del alumno |

## Scripts

- `init.sql`: Crea la tabla e inserta 5 alumnos iniciales
