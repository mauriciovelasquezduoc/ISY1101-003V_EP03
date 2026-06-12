# Reporte de Evidencia: Creación de repositorios en Amazon ECR

**Fecha:** 2026-06-11 13:32:24
**Etapa:** etapa07-PublicaECR

---

## Resumen


**Account ID:** `461663648686`  
**ECR Base URL:** `461663648686.dkr.ecr.us-east-1.amazonaws.com`


---

### Paso 1: Repositorios ECR creados

**IE Relacionado:** IE2
**Hora ejecución:** 2026-06-11 13:32:37

```
$ for repo in alumnos-db alumnos-app alumnos-web; do echo '---'; echo $repo; aws ecr describe-repositories --repository-names $repo --region us-east-1 --query 'repositories[0].repositoryUri' --output text; aws ecr list-images --repository-name $repo --region us-east-1 --query 'imageIds[*].imageTag' --output table 2>/dev/null || echo '(sin imágenes aún)'; done

---
alumnos-db
461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-db
---
alumnos-app
461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-app
---
alumnos-web
461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-web
```

**Estado:** ✅ Completado


**Comandos para login y push manual:**  

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 461663648686.dkr.ecr.us-east-1.amazonaws.com

docker build -t alumnos-app .
docker tag alumnos-app:latest 461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-app:latest
docker push 461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-app:latest
```

> Las imágenes se publicarán automáticamente mediante GitHub Actions
> al hacer push a `main` en cada repositorio.


---

## Resumen final

- **Inicio ejecución:** 2026-06-11 13:32:24
- **Fin ejecución:** 2026-06-11 13:32:47
- **Total pasos ejecutados:** 1

### ⏱️ Línea de tiempo de la etapa

| Evento | Hora |
|---|---|
| **Inicio** | 2026-06-11 13:32:24 |
| **Fin** | 2026-06-11 13:32:47 |
| **Duración total** | 23s |

<!-- ================================================== -->
<!-- Fin del reporte de evidencia                       -->
<!-- ================================================== -->
