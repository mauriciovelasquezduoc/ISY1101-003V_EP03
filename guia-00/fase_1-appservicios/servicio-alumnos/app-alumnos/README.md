# App Alumnos - CRUD de Alumnos

API REST con Spring Boot que gestiona un CRUD completo de alumnos, con integración de MySQL, Swagger, SonarQube y Snyk.

## Estructura del Proyecto

```
src/
├── main/
│   ├── java/cl/duocuc/fechaapi/
│   │   ├── domain/              # Capa de dominio (entidades, repositorios, servicios)
│   │   ├── application/         # Capa de aplicación (controladores, servicios de aplicación)
│   │   ├── infrastructure/      # Capa de infraestructura (implementaciones JPA)
│   │   └── config/              # Configuración (Swagger, etc.)
│   └── resources/
│       └── application.yml      # Configuración de Spring Boot
└── test/
    └── java/cl/duocuc/fechaapi/ # Tests unitarios e integración
```

## Arquitectura

Este proyecto sigue la arquitectura limpia (Clean Architecture) con las siguientes capas:

1. **Domain**: Entidades, interfaces de repositorio y servicios de negocio
2. **Application**: Controladores REST y servicios de aplicación
3. **Infrastructure**: Implementaciones de repositorio con JPA y persistencia

## Requisitos

- Java 21
- Maven 3.8+
- Docker y Docker Compose (opcional)

## Configuración

### Variables de Entorno

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `SPRING_DATASOURCE_URL` | URL de conexión a MySQL | `jdbc:mysql://app-db:3306/duoc_db` |
| `SPRING_DATASOURCE_USERNAME` | Usuario de MySQL | `duoc_user` |
| `SPRING_DATASOURCE_PASSWORD` | Contraseña de MySQL | `duoc_pass` |
| `SPRING_JPA_HIBERNATE_DDL_AUTO` | Estrategia de DDL | `update` |
| `SONAR_HOST_URL` | URL de SonarQube | `http://localhost:9000` |

## Desarrollo Local

### Con Docker Compose

```bash
# Iniciar MySQL y la aplicación
cd ../.. && docker-compose up -d

# Ver logs
docker-compose logs -f app-alumnos

# Detener servicios
docker-compose down
```

### Sin Docker

```bash
# Compilar y ejecutar
mvn spring-boot:run
```

## Endpoints de la API

### Alumnos

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/alumnos` | Obtener todos los alumnos |
| GET | `/api/alumnos/{id}` | Obtener alumno por ID |
| GET | `/api/alumnos/rut/{rut}` | Obtener alumno por RUT |
| POST | `/api/alumnos` | Crear nuevo alumno |
| PUT | `/api/alumnos/{id}` | Actualizar alumno |
| DELETE | `/api/alumnos/{id}` | Eliminar alumno |

### Documentación API

- Swagger UI: `http://localhost:8080/swagger-ui.html`
- OpenAPI JSON: `http://localhost:8080/api-docs`
- ReDoc: `http://localhost:8080/redoc`

## Testing

```bash
# Ejecutar tests
mvn test

# Generar reporte de cobertura
mvn clean verify

# Ver reporte JaCoCo
open target/site/jacoco/index.html
```

## Calidad de Código

### SonarQube

```bash
# Analizar con SonarQube
mvn sonar:sonar

# O con profile
mvn sonar:sonar -Dsonar.host.url=http://localhost:9000
```

### Snyk

```bash
# Escanear vulnerabilidades
mvn snyk:test

# Monitorizar
mvn snyk:monitor
```

## Cobertura de Código

El proyecto requiere **100% de cobertura** de código. El reporte JaCoCo se genera automáticamente en:

```
target/site/jacoco/jacoco.xml
```
