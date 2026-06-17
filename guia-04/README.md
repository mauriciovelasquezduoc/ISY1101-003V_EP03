# Pasos

## Paso 01

Abrir el directorio guia-04 con visual code y llenar con las variables y los nombres de los repos del servicio que vamos a desplegar

Archivo: secrets.txt

```
aws_access_key_id=
aws_secret_access_key=
aws_session_token=
SONAR_TOKEN=
SNYK_TOKEN=
AWS_REGION=us-east-1
EKS_CLUSTER_NAME=laboratorio-ep03-eks
GITHUB_TOKEN=
GITHUB_DATABASE=
GITHUB_BACKEND=
GITHUB_FRONTEND=
```

**Las variables de repositorios se agregaran posteriormente**

## PASO 02

Se debe ingresar a Docker Desktop y luego entrar ejecutar una imagen de linux especialmente preparada:

```
docker pull ghcr.io/mauriciovelasquezduoc/devops-eks-lab:latest
docker run -it -v ".":/root/work -v ~/.aws:/root/.aws -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/mauriciovelasquezduoc/devops-eks-lab:latest

```

## Paso 03 Aplicación

Se debe seleccionar una aplicacion con tres capas se pueda utilizar para esta implementación, se puede utilizar este mismo codigo, ir a leer y aplicar el paso a paso que esta en

[README.d](bloque00-aplicacion/README.md)

## Paso 04 Infra K8s

Ahora vamos. a crear la infra, que tiene vpc k8s y grupos, el paso a paso esta en

[README.MD](bloque01-infra-k8s/README.md)

## Paso 05 ECR

En el archivo bloque02-ecr/repositorios.yaml se debe poner el nombre del repo que tendra de la imagen, recopmendacion: dejar que comience con ep03- y asi mantener un patron que mas adelante se usara.

[README.md](bloque02-ecr/README.md)

## Paso 06 k8s

Ahora vamos aplicaremos las confiburaciones para todas las aplicaciones

Se debe cambiar los datos de donde estaran las imagens de ECR,  y eso se hace modificando este archivo : bloque03-k8s/values.yaml

[README.md](bloque03-k8s/README.md)

## Paso 07 github secret

Ahora este paso permite crear en forma automatica las variables necesarias para que opere el pipeline, los repositorios deben estar creados en github

[REAME.md](bloque04-github-secret/README.md)

## Paso 08 gihub repos

Ahora, vamos a ir a gihub y vamos a bajar cada proyecto, debe hacerse clone de cada proyecto

[README.md](bloque05-github-repos/README.md)

Para ver la solucion andando:

```
kubectl get svc ep03-frontend \
  -n ep03 \
  -o custom-columns=NAME:.metadata.name,TYPE:.spec.type,CLUSTER-IP:.spec.clusterIP,EXTERNAL-HOST:.status.loadBalancer.ingress[0].hostname,PORT:.spec.ports[0].port
```

## Paso 09 Dashboard

Primero habilitar Container Insights y log group (ejecutar una sola vez):

```bash
cd bloque06-dashboard
bash setup-dashboard.sh
```

Esperar 5-10 minutos para que Container Insights recolecte datos, luego crear el dashboard:

```bash
bash ejecutar.sh
```

Verificar:

```bash
bash verificar.sh
```

## Paso 10 Verificacion Integral

Ahora ejecutaremos las 4 pruebas de validacion de operacion avanzada en un solo paso: HPA, Stress Test, Auto-Healing y Metricas. Se genera un reporte consolidado en `reports/`.

```bash
cd bloque07-verificacion
bash ejecutar.sh
```

Para generar carga real y que las metricas del dashboard se muevan:

```bash
cd bloque07-verificacion
bash stress_test.sh              # frontend, 60s, 50 workers
bash stress_test.sh backend 120  # backend, 120s
```
