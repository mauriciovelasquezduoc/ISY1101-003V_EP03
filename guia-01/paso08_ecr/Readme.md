# PASO 8 — Amazon ECR: publicación de imágenes Docker para EKS

## Objetivo

Construir y publicar las imágenes Docker del proyecto en Amazon ECR para que posteriormente puedan ser desplegadas en Amazon EKS.

En este laboratorio se trabajará con una arquitectura multicapa compuesta por:

| Capa     | Función              |
| -------- | --------------------- |
| Frontend | Interfaz web          |
| Backend  | API / lógica negocio |
| Database | MySQL                 |

---

# ¿Qué es Amazon ECR?

Amazon ECR (Elastic Container Registry) es el registro Docker administrado por AWS.

Funciona como:

```text
Docker Hub privado en AWS
```

Permite almacenar:

* imágenes Docker
* versiones
* tags
* artefactos containerizados

---

# Arquitectura del flujo ECR

```text
Código fuente
    ↓
Docker Build
    ↓
Imagen local Docker
    ↓
Amazon ECR
    ↓
Amazon EKS
    ↓
Pods Kubernetes
```

---

# ¿Por qué es importante este paso?

Kubernetes NO despliega código fuente directamente.

EKS necesita:

* imágenes Docker
* disponibles en un registry
* accesibles por los worker nodes

En este laboratorio:

* EKS descargará imágenes desde ECR
* los pods se construirán desde esas imágenes

---

# Arquitectura multicapa del proyecto

El proyecto contempla 3 imágenes Docker:

| Imagen          | Uso                 |
| --------------- | ------------------- |
| tienda-frontend | Aplicación web     |
| tienda-backend  | API                 |
| tienda-db       | Base de datos MySQL |

---

# Flujo completo que se implementará

## FRONTEND

```text
frontend/
   ↓
docker build
   ↓
tienda-frontend:eks-v1
   ↓
Amazon ECR
```

---

## BACKEND

```text
backend/
   ↓
docker build
   ↓
tienda-backend:eks-v1
   ↓
Amazon ECR
```

---

## DATABASE

```text
db/
   ↓
docker build
   ↓
tienda-db:eks-v1
   ↓
Amazon ECR
```

---

# ¿Qué haremos exactamente?

El proceso se repetirá para las 3 capas:

| Paso | Acción               |
| ---- | --------------------- |
| 1    | Login ECR             |
| 2    | Crear repositorio ECR |
| 3    | Docker build          |
| 4    | Docker tag            |
| 5    | Docker push           |
| 6    | Validar imagen en ECR |

---

# Requisitos previos

Antes de continuar debe existir:

* Docker funcionando
* AWS CLI configurado
* EKS operativo
* permisos ECR
* proyecto descargado
* Dockerfiles existentes

---

# Validar Docker

```bash
docker --version
```

---

# Validar sesión AWS

```bash
aws sts get-caller-identity
```

---

# Validar ECR API privada

La arquitectura implementada utiliza:

```text
VPC Endpoint ECR
```

permitiendo:

* pulls privados
* nodes sin internet
* arquitectura sin NAT Gateway

---

# ¿Qué es el Login ECR?

Docker necesita autenticarse contra AWS ECR.

Esto se realiza mediante:

```bash
aws ecr get-login-password
```

que genera un token temporal.

---

# Versionamiento de imágenes

En este laboratorio se utilizará:

```text
eks-v1
```

como tag inicial.

Ejemplo:

```text
tienda-backend:eks-v1
```

---

# ¿Por qué usar tags?

Permiten:

* versionar aplicaciones
* hacer rollback
* controlar despliegues
* identificar releases

---

# Flujo Docker → ECR

## Build

Construye imagen local:

```text
docker build
```

---

## Tag

Asocia imagen al repo ECR:

```text
docker tag
```

---

## Push

Publica imagen en AWS:

```text
docker push
```

---

# Resultado esperado

Al finalizar correctamente:

* Existirán 3 repositorios ECR
* Las imágenes estarán publicadas
* EKS podrá descargarlas
* Kubernetes podrá desplegar pods

---

# Validaciones esperadas

| Validación    | Resultado       |
| -------------- | --------------- |
| Login ECR      | Login Succeeded |
| Build Docker   | imagen creada   |
| Push ECR       | imagen subida   |
| ECR repository | visible en AWS  |
| Tags           | eks-v1          |

---

# Arquitectura final esperada

```text
Frontend Image
        ↓
Backend Image
        ↓
Database Image
        ↓
Amazon ECR
        ↓
Amazon EKS
        ↓
Pods Kubernetes
```

---

# Importante

En el siguiente paso:

```text
Deploy Kubernetes
```

los YAML deberán actualizarse para apuntar a:

```text
ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
```

---

# Resultado final del paso 8

Al finalizar correctamente:

* Las imágenes Docker estarán publicadas en ECR.
* Kubernetes podrá descargarlas.
* El cluster estará listo para desplegar la aplicación multicapa.

---

# Siguiente paso

Luego continuará:

```text
Deploy de la aplicación en EKS
```

utilizando:

* Deployments
* Services
* LoadBalancer
* HPA
* Auto-healing


# PASO 8 — Publicar imágenes Docker en Amazon ECR

## Objetivo

Construir y publicar las imágenes Docker del proyecto multicapa en Amazon ECR para posteriormente desplegarlas en Amazon EKS.

La aplicación está compuesta por:

| Capa     | Función     |
| -------- | ------------ |
| frontend | interfaz web |
| backend  | API          |
| db       | MySQL        |

---

# Estructura del proyecto

La estructura final del laboratorio quedó organizada de la siguiente forma:

```
paso08_ecr/
└── app/
    ├── backend/
    │   ├── Dockerfile
    │   ├── package.json
    │   ├── server.js
    │   └── publicarECR-Backend.sh
    │
    ├── db/
    │   ├── Dockerfile
    │   ├── init.sql
    │   └── publicarECR-DB.sh
    │
    └── frontend/
        ├── Dockerfile
        ├── app.js
        ├── index.html
        ├── default.conf
        └── publicarECR-Frontend.sh
```

---

# ¿Qué hace cada script?

Cada script realiza automáticamente:

| Acción               | Descripción           |
| --------------------- | ---------------------- |
| Validar AWS           | verifica sesión       |
| Obtener ACCOUNT_ID    | cuenta AWS             |
| Login ECR             | autenticación Docker  |
| Crear repositorio ECR | si no existe           |
| Docker Build          | construir imagen       |
| Docker Tag            | etiquetar imagen       |
| Docker Push           | publicar imagen        |
| Validar ECR           | verificar publicación |

---

# Requisitos previos

Antes de continuar debe existir:

* Docker funcionando
* AWS CLI configurado
* credenciales AWS válidas
* EKS operativo
* permisos ECR
* Dockerfiles configurados

---

# Validar sesión AWS

```
aws sts get-caller-identity
```

---

# Validar Docker

```
docker --version
```

---

# Flujo general

El proceso se repetirá para:

1. Database
2. Backend
3. Frontend

---

# PARTE 1 — Publicar Database en ECR

---

# Navegar carpeta DB

```
cd ~/0000000/guia2/paso08_ecr/app/db
```

---

# Validar archivos

```
ls -lh
```

Debe existir:

```
Dockerfile
init.sql
publicarECR-DB.sh
```

---

# Dar permisos ejecución

```
chmod +x publicarECR-DB.sh
```

---

# Ejecutar publicación ECR DB

```
bash publicarECR-DB.sh
```

---

# Resultado esperado

El script:

* creará repo ECR `<span>tienda-db</span>`
* construirá imagen Docker
* publicará imagen
* mostrará URI final

---

# URI esperada

```
ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/tienda-db:eks-v1
```

---

# PARTE 2 — Publicar Backend en ECR

---

# Navegar carpeta Backend

```
cd ~/0000000/guia2/paso08_ecr/app/backend
```

---

# Validar archivos

```
ls -lh
```

Debe existir:

```
Dockerfile
package.json
server.js
publicarECR-Backend.sh
```

---

# Dar permisos ejecución

```
chmod +x publicarECR-Backend.sh
```

---

# Ejecutar publicación ECR Backend

```
bash publicarECR-Backend.sh
```

---

# Resultado esperado

El script:

* creará repo ECR `<span>tienda-backend</span>`
* construirá imagen Docker
* publicará imagen
* mostrará URI final

---

# URI esperada

```
ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/tienda-backend:eks-v1
```

---

# PARTE 3 — Publicar Frontend en ECR

---

# Navegar carpeta Frontend

```
cd ~/0000000/guia2/paso08_ecr/app/frontend
```

---

# Validar archivos

```
ls -lh
```

Debe existir:

```
Dockerfile
app.js
index.html
default.conf
publicarECR-Frontend.sh
```

---

# Dar permisos ejecución

```
chmod +x publicarECR-Frontend.sh
```

---

# Ejecutar publicación ECR Frontend

```
bash publicarECR-Frontend.sh
```

---

# Resultado esperado

El script:

* creará repo ECR `<span>tienda-frontend</span>`
* construirá imagen Docker
* publicará imagen
* mostrará URI final

---

# URI esperada

```
ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/tienda-frontend:eks-v1
```

---

# Validar repositorios ECR creados

```
aws ecr describe-repositories \
  --region us-east-1
```

---

# Resultado esperado

Repositorios:

```
tienda-db
tienda-backend
tienda-frontend
```

---

# Validar imágenes ECR

```
aws ecr list-images \
  --repository-name tienda-db \
  --region us-east-1
```

---

# Repetir para:

```
tienda-backend
tienda-frontend
```

---

# Arquitectura final

```
Frontend Image
        ↓
Backend Image
        ↓
Database Image
        ↓
Amazon ECR
        ↓
Amazon EKS
```

---

# Resultado esperado final

Al finalizar correctamente:

* las 3 imágenes estarán publicadas en ECR
* Kubernetes podrá descargarlas
* EKS quedará listo para despliegues
* los worker nodes privados podrán hacer pull desde ECR

---

# Importante

En el siguiente paso:

```
Deploy Kubernetes
```

los archivos YAML deberán actualizarse para utilizar las imágenes ECR publicadas.

Ejemplo:

```
image: ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/tienda-backend:eks-v1
```

---

# Siguiente paso

Luego continuará:

```
Actualizar manifests Kubernetes y desplegar la aplicación
```

utilizando:

* Deployments
* Services
* Namespace
* LoadBalancer
* HPA

---
