# README-template — Base de Datos PostgreSQL (202601_ep03_db)

> **Instrucciones:** Completa cada sección con las evidencias generadas en los reportes de `bloque06/docs/reports/`.  
> Las capturas de pantalla van en la carpeta `docs/`.

---

## 📝 Descripción

Base de datos PostgreSQL para la Tienda Perritos.  
Se despliega como un Deployment en Kubernetes con almacenamiento efímero  
(los datos se inicializan desde `init.sql` en cada deploy).

**Puerto:** 3306  
**Service:** ClusterIP (solo interno) — nombre DNS: `alumnos-db`  
**Namespace:** `alumnos`

---

## 🚀 Pipeline CI/CD

![Pipeline exitoso](docs/pipeline-success.png)

### Tiempos del pipeline

| Ejecución | Fecha | Versioning | Build & Push | Deploy | Total |
|---|---|---|---|---|---|
| #1 | <!-- fecha --> | <!-- seg --> | <!-- seg --> | <!-- seg --> | <!-- seg --> |
| Promedio | | <!-- seg --> | <!-- seg --> | <!-- seg --> | <!-- seg --> |

---

## 🔧 Manifiestos Kubernetes

| Archivo | Propósito |
|---|---|
| `k8s/postgres-deployment.yaml` | Deployment con 1 réplica, PostgreSQL 16 |
| `k8s/postgres-service.yaml` | Service tipo ClusterIP (puerto 3306) |
| `k8s/postgres-secret.yaml` | Secret con `MYSQL_ROOT_PASSWORD` |

### Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
  namespace: alumnos
type: Opaque
data:
  MYSQL_ROOT_PASSWORD: <base64>
```

---

## ✅ Validación

```
$ kubectl get pods -n alumnos -l app=alumnos-db
NAME                           READY   STATUS    RESTARTS   AGE
alumnos-db-7b98d4fcf-gd44n      1/1     Running   0          34m

$ kubectl logs -n alumnos -l app=alumnos-db --tail=5
...
[Server] /usr/sbin/mysqld: ready for connections. Version: '8.0.33'
```

---

## 📋 Checklist

- [ ] README completo
- [ ] Pipeline ✅ en GitHub Actions
- [ ] Pod PostgreSQL Running
- [ ] Logs visibles

---

*Template para README de la DB — ISY1101 EP3*
