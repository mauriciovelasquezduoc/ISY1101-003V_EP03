FROM postgres:16-alpine

# Variables de entorno para PostgreSQL
ENV POSTGRES_DB=alumnos
ENV POSTGRES_USER=alumnos_user
ENV POSTGRES_PASSWORD=alumnos_pass

# Script de inicialización — se ejecuta automáticamente al primer arranque
COPY init.sql /docker-entrypoint-initdb.d/01-init.sql

EXPOSE 5432
