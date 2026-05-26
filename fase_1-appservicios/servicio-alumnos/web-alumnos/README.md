# Web Alumnos - Gestión de Estudiantes

Frontend profesional desarrollado con React, Vite y Tailwind CSS para la gestión de alumnos.

## Características

- ✅ Listado de alumnos con búsqueda
- ✅ Formulario para crear nuevos alumnos
- ✅ Edición de alumnos existentes
- ✅ Visualización de detalles por alumno
- ✅ Eliminación de alumnos
- ✅ Diseño responsivo y moderno
- ✅ Validación de formularios
- ✅ Manejo de errores
- ✅ Interfaz de usuario intuitiva

## Tecnologías

- **React 18** - Framework de JavaScript
- **Vite** - Herramienta de construcción rápida
- **Tailwind CSS** - Framework de CSS utility-first
- **React Router** - Navegación del lado del cliente
- **Axios** - Cliente HTTP para consumir la API
- **Nginx** - Servidor web y reverse proxy

## Requisitos

- Node.js 20 o superior
- Docker y Docker Compose (opcional)

## Instalación Local

```bash
# Clonar el repositorio
cd web-alumnos

# Instalar dependencias
npm install

# Iniciar el servidor de desarrollo
npm run dev
```

El frontend estará disponible en `http://localhost:5173`

## Uso con Docker

### Construir y ejecutar con Docker Compose

```bash
# Desde el directorio raíz del servicio
cd ../

# Construir y ejecutar todos los servicios
docker-compose up --build

# O ejecutar en modo detached
docker-compose up -d --build
```

### Comandos útiles

```bash
# Ver logs
docker-compose logs -f

# Detener servicios
docker-compose down

# Detener y eliminar volúmenes
docker-compose down -v
```

## Estructura del Proyecto

```
web-alumnos/
├── src/
│   ├── components/       # Componentes React
│   │   ├── AlumnoList.jsx
│   │   ├── AlumnoForm.jsx
│   │   ├── AlumnoDetail.jsx
│   │   └── Navbar.jsx
│   ├── services/         # Servicios de API
│   │   └── alumnoService.js
│   ├── App.jsx           # Componente principal
│   ├── main.jsx          # Punto de entrada
│   └── index.css         # Estilos globales
├── public/               # Archivos públicos
├── Dockerfile            # Configuración Docker
├── nginx.conf           # Configuración Nginx
├── package.json         # Dependencias
└── vite.config.js       # Configuración Vite
```

## Endpoints de la API

El frontend consume los siguientes endpoints del backend:

- `GET /api/alumnos` - Obtener todos los alumnos
- `GET /api/alumnos/:id` - Obtener alumno por ID
- `GET /api/alumnos/rut/:rut` - Obtener alumno por RUT
- `POST /api/alumnos` - Crear nuevo alumno
- `PUT /api/alumnos/:id` - Actualizar alumno
- `DELETE /api/alumnos/:id` - Eliminar alumno

## Configuración del Proxy

Durante el desarrollo, las peticiones a `/api` se proxyan automáticamente al backend en `http://localhost:8080`.

Para producción, el frontend se sirve directamente desde Nginx y se comunica con el backend a través de la red Docker.

## Personalización

### Cambiar colores

Edita el archivo `tailwind.config.js` para personalizar los colores de la aplicación.

### Modificar estilos

Los estilos globales se encuentran en `src/index.css` y los estilos específicos de componentes están integrados usando clases de Tailwind CSS.

## Licencia

Este proyecto es de código cerrado y confidencial.
