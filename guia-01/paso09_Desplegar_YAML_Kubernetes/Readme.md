# PASO 9 — Desplegar YAML Kubernetes y desplegar aplicación multicapa

## Objetivo

Actualizar los archivos YAML Kubernetes para utilizar las imágenes Docker publicadas en Amazon ECR y desplegar las 3 capas de la aplicación en Amazon EKS.

La aplicación está compuesta por:

| Capa     | Función            |
| -------- | ------------------- |
| db       | Base de datos MySQL |
| backend  | API                 |
| frontend | interfaz web        |

---

# ¿Qué se realiza en este paso?

En esta etapa:

* se reemplazan imágenes locales por imágenes ECR
* se aplican los manifiestos Kubernetes
* se crean Deployments
* se crean Services
* se crean HPAs
* se crean Pods
* se despliega la aplicación completa

---

# Arquitectura desplegada

```text
Frontend Pods
      ↓
Backend Pods
      ↓
MySQL Pod
```

---

# Estructura final del proyecto

```text
paso09_YAML_Kubernetes/
├── backend/k8s/
│   ├── backend-deployment.yaml
│   ├── backend-hpa.yaml
│   ├── backend-service.yaml
│   ├── namespace.yaml
│   └── k8s-Backend.sh
│
├── db/k8s/
│   ├── mysql-deployment.yaml
│   ├── mysql-secret.yaml
│   ├── mysql-service.yaml
│   ├── namespace.yaml
│   └── k8s-Db.sh
│
└── frontend/k8s/
    ├── frontend-deployment.yaml
    ├── frontend-hpa.yaml
    ├── frontend-service.yaml
    ├── namespace.yaml
    └── k8s-Frontend.sh
```

---

# ¿Qué hace cada script?

Cada script:

| Acción                | Descripción    |
| ---------------------- | --------------- |
| obtiene ACCOUNT_ID AWS | automatización |
| reemplaza image ECR    | sed             |
| aplica YAML            | kubectl apply   |
| crea Deployments       | Kubernetes      |
| crea Services          | networking      |
| crea HPA               | autoscaling     |
| valida pods            | troubleshooting |
| valida logs            | observabilidad  |

---

# Importancia del reemplazo ECR

Los archivos:

```yaml
deployment.yaml
```

deben apuntar a imágenes ECR reales:

Ejemplo:

```yaml
image: 919889862541.dkr.ecr.us-east-1.amazonaws.com/tienda-backend:eks-v1
```

---

# ¿Por qué es importante?

Porque EKS:

* NO despliega código fuente
* despliega imágenes Docker
* descarga imágenes desde ECR

---

# Flujo Kubernetes real

```text
ECR
   ↓
Deployment
   ↓
ReplicaSet
   ↓
Pods
```

---

# ORDEN CORRECTO DE DESPLIEGUE

## MUY IMPORTANTE

Debe respetarse el siguiente orden:

| Orden | Componente |
| ----- | ---------- |
| 1     | Database   |
| 2     | Backend    |
| 3     | Frontend   |

---

# ¿Por qué?

Porque:

```text
Frontend depende del Backend
Backend depende de MySQL
```

---

# PARTE 1 — Desplegar Database

---

# Navegar carpeta DB

```bash
cd ~/0000000/guia2/paso09_YAML_Kubernetes/db/k8s
```

---

# Validar archivos

```bash
ls -lh
```

---

# Dar permisos ejecución

```bash
chmod +x k8s-Db.sh
```

---

# Ejecutar despliegue DB

```bash
bash k8s-Db.sh
```

---

# Resultado esperado

Se crearán:

* namespace
* mysql deployment
* mysql service
* mysql pod

---

# Validar pods DB

```bash
kubectl get pods -n tienda
```

---

# Resultado esperado

```text
tienda-db-xxxxx   Running
```

---

# PARTE 2 — Desplegar Backend

---

# Navegar carpeta Backend

```bash
cd ~/0000000/guia2/paso09_YAML_Kubernetes/backend/k8s
```

---

# Validar archivos

```bash
ls -lh
```

---

# Dar permisos ejecución

```bash
chmod +x k8s-Backend.sh
```

---

# Ejecutar despliegue Backend

```bash
bash k8s-Backend.sh
```

---

# Resultado esperado

Se crearán:

* backend deployment
* backend service
* backend replicas
* backend HPA

---

# Validar pods Backend

```bash
kubectl get pods -n tienda
```

---

# Resultado esperado

```text
tienda-backend-xxxxx   Running
```

---

# Validar deployments

```bash
kubectl get deployment -n tienda
```

---

# Resultado esperado

```text
tienda-backend
tienda-db
```

---

# PARTE 3 — Desplegar Frontend

---

# Navegar carpeta Frontend

```bash
cd ~/0000000/guia2/paso09_YAML_Kubernetes/frontend/k8s
```

---

# Validar archivos

```bash
ls -lh
```

---

# Dar permisos ejecución

```bash
chmod +x k8s-Frontend.sh
```

---

# Ejecutar despliegue Frontend

```bash
bash k8s-Frontend.sh
```

---

# Resultado esperado

Se crearán:

* frontend deployment
* frontend service
* frontend replicas
* frontend HPA
* LoadBalancer

---

# Validar pods Frontend

```bash
kubectl get pods -n tienda
```

---

# Resultado esperado

```text
tienda-frontend-xxxxx   Running
```

---

# Validar TODOS los pods

```bash
kubectl get pods -n tienda
```

---

# Resultado esperado final

```text
tienda-db-xxxxx
tienda-backend-xxxxx
tienda-frontend-xxxxx
```

todos en estado:

```text
Running
```

---

# Validar deployments

```bash
kubectl get deployment -n tienda
```

---

# Validar services

```bash
kubectl get svc -n tienda
```

---

# Validar HPA

```bash
kubectl get hpa -n tienda
```

---

# Validar endpoints

```bash
kubectl get endpoints -n tienda
```

---

# Validar arquitectura completa

```text
Frontend
    ↓
Backend
    ↓
MySQL
```

---

# Validar eventos Kubernetes

```bash
kubectl get events -n tienda \
  --sort-by=.metadata.creationTimestamp
```

---

# Validar logs pods

```bash
kubectl logs -n tienda POD_NAME
```

---

# Arquitectura validada

Este paso valida:

| Componente     | Estado |
| -------------- | ------ |
| ECR Pull       | ✅     |
| Deployments    | ✅     |
| Services       | ✅     |
| HPA            | ✅     |
| ReplicaSets    | ✅     |
| Pod Networking | ✅     |
| Kubernetes DNS | ✅     |
| Runtime        | ✅     |
| Multi-tier app | ✅     |

---

# Resultado final esperado

Al finalizar correctamente:

* la aplicación multicapa estará desplegada
* frontend/backend/db estarán operativos
* Kubernetes manejará replicas
* HPA estará habilitado
* EKS ejecutará toda la solución

---

# Siguiente paso

Luego continuará:

```text
Exponer Frontend mediante LoadBalancer AWS
```

y posteriormente:

* pruebas acceso web
* autoscaling
* stress testing
* auto-healing

---
