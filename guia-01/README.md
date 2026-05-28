# Guía práctica: Despliegue y operación de aplicaciones en AWS EKS (paso00 → paso13)

Este repositorio contiene una secuencia educativa paso a paso (paso00 a paso13) diseñada para enseñar a estudiantes cómo diseñar, desplegar, escalar y monitorear aplicaciones en Kubernetes sobre AWS EKS. Cada paso incluye objetivos, diagramas con Mermaid, comandos clave, actividades prácticas y comprobaciones de aprendizaje.

---

## Tabla de contenido

- Tabla de pasos y objetivos
- Requisitos previos
- Flujo general (diagrama)
- Guía por paso (00 → 13)
- Buenas prácticas y evaluación
- Referencias y recursos

---

## Tabla de pasos y objetivos

| Paso   | Carpeta                           |                                                         Objetivo principal |
| ------ | --------------------------------- | -------------------------------------------------------------------------: |
| paso00 | paso00_dockerLinux/               |              Preparar entorno local: Docker y Linux herramientas básicas. |
| paso01 | paso01_iam-vpc/                   |                           Configurar IAM y VPC: roles, políticas y redes. |
| paso02 | paso02_eks/                       |                                                 Crear cluster EKS básico. |
| paso03 | paso03_node-group/                |             Añadir NodeGroups (Grupos de nodos) y gestionar worker nodes. |
| paso04 | paso04_subnets/                   |                           Configurar subnets y topología de red para EKS. |
| paso05 | paso05_adm_cluster/               |                           Configurar accesos administrativos y kubeconfig. |
| paso06 | paso06_metrics/                   | Instalar métricas y stack de observabilidad (metrics-server, Prometheus). |
| paso07 | paso07_cloudWatch/                |                       Integrar CloudWatch para logs y métricas centrales. |
| paso08 | paso08_ecr/                       |                              Construir y publicar imágenes en Amazon ECR. |
| paso09 | paso09_Desplegar_YAML_Kubernetes/ |                               Desplegar aplicaciones usando manifest YAML. |
| paso10 | paso10_hpa/                       |                               Implementar Horizontal Pod Autoscaler (HPA). |
| paso11 | paso11_stress_test/               |               Ejecutar pruebas de carga/estrés y observar comportamiento. |
| paso12 | paso12_healing/                   |                 Practicar auto-healing: fallos y recuperación (Pod/Node). |
| paso13 | paso13_metricas/                  |                             Analizar métricas y crear dashboards/alertas. |

---

## Requisitos previos

- Cuenta AWS con permisos suficientes (IAM). No usar credenciales compartidas en código.
- AWS CLI configurado y kubectl instalado.
- Docker instalado localmente.
- kubectl, eksctl (opcional), y herramientas como helm.
- Conocimientos básicos de Linux, contenedores y redes.

---

## Flujo general (diagrama MerMaid)

```mermaid
flowchart LR
  A[paso00: Entorno] --> B[paso01: IAM & VPC]
  B --> C[paso02: EKS Cluster]
  C --> D[paso03: NodeGroups]
  D --> E[paso04: Subnets]
  E --> F[paso05: Admin & kubeconfig]
  F --> G[paso08: ECR & CI]
  F --> H[paso09: Deploy YAML]
  H --> I[paso10: HPA]
  I --> J[paso11: Stress тест]
  J --> K[paso12: Healing]
  G --> H
  F --> L[paso06: Metrics]
  L --> M[paso07: CloudWatch]
  M --> N[paso13: Dashboards & Alerts]
```

---

# Guía por paso (instrucciones educativas, diagramas y ejercicios)

Las secciones siguientes están pensadas como módulos de clase. Cada módulo contiene:

- Objetivo de aprendizaje
- Diagrama explicativo (Mermaid)
- Comandos clave y checklist
- Ejercicio práctico
- Preguntas de comprobación

## Paso 00 — Entorno: Docker y Linux básicos

Objetivo: Asegurar que el estudiante entiende y configura Docker, CLI y utilidades Linux.

Diagrama:

```mermaid
flowchart TB
  subgraph Local
    A[Docker] --> B[Imagenes]
    B --> C[Contenedores]
    C --> D[Volúmenes]
  end
```

Comandos clave (ejemplos):

- docker --version
- docker build -t myapp:local ./app
- docker run --rm -p 8080:8080 myapp:local

Ejercicio práctico: Construir y ejecutar una imagen simple que exponga /health.

Checkpoints:

- docker ps muestra el contenedor en ejecución
- curl localhost:8080/health devuelve 200

Preguntas:

- ¿Qué diferencia hay entre imagen y contenedor?

---

## Paso 01 — IAM y VPC

Objetivo: Crear rol IAM con permisos mínimos necesarios y diseñar VPC segura.

Diagrama:

```mermaid
flowchart LR
  IAM[Role IAM] -->|assumeRole| EKS[EKS Service]
  VPC --> Subnet1
  VPC --> Subnet2
  Subnet1 --> EKS
  Subnet2 --> EKS
```

Comandos clave:

- aws iam create-role ...
- aws ec2 create-vpc ...
- Revisar políticas de least privilege

Ejercicio práctico: Crear un rol para EKS control plane y anexar política de acceso a ECR.

Checkpoints:

- Role existe y tiene trust relationship para EKS
- Subnets públicas/privadas creadas y etiquetadas

Preguntas:

- ¿Por qué separar subnets públicas y privadas?

---

## Paso 02 — Crear cluster EKS

Objetivo: Provisionar cluster EKS mínimo funcional y validar acceso.

Diagrama:

```mermaid
flowchart LR
  AWS[Cuenta AWS] --> EKS[Cluster EKS]
  EKS --> Kubeconfig[Usuario admin]
  Kubeconfig --> kubectl
```

Comandos (ejemplos):

- eksctl create cluster --name aula-eks --region us-east-1 --nodes 2
- aws eks update-kubeconfig --name aula-eks
- kubectl get nodes

Ejercicio: Crear cluster con eksctl y listar nodos.

Checkpoints:

- kubectl get nodes muestra nodos Ready

---

## Paso 03 — NodeGroups

Objetivo: Añadir y gestionar NodeGroups, entender tipos de instancias.

Diagrama:

```mermaid
flowchart LR
  Cluster --> NG1[NodeGroup - on-demand]
  Cluster --> NG2[NodeGroup - spot]
```

Comandos:

- eksctl create nodegroup --cluster aula-eks --name ng-workers --node-type t3.medium
- kubectl top nodes

Ejercicio: Crear un nodegroup Spot y uno On-demand; desplazar pods entre grupos.

Checkpoints:

- pods circulan correctamente al drenar nodos

---

## Paso 04 — Subnets y Networking

Objetivo: Configurar subnets, routing y security groups.

Diagrama:

```mermaid
flowchart LR
  VPC --> PrivateSubnet
  VPC --> PublicSubnet
  PrivateSubnet --> EKS
  PublicSubnet --> NAT
```

Comandos: crear tablas de rutas, NAT Gateway, revisar SG.

Ejercicio: Bloquear acceso directo a pods desde Internet y exponer servicio vía LoadBalancer.

Checkpoints:

- Servicio LoadBalancer accesible y pods no expuestos directamente

---

## Paso 05 — Administración del cluster

Objetivo: Gestionar kubeconfig, RBAC y accesos administrativos.

Diagrama:

```mermaid
flowchart LR
  AdminUser --> Kubeconfig --> RBAC --> KubernetesAPI
```

Comandos: kubectl config, kubectl create clusterrolebinding, aws-auth configmap edit.

Ejercicio: Crear usuario con role limitado y validar permisos.

Checkpoints:

- Usuario limitado no puede eliminar recursos críticos

---

## Paso 06 — Métricas: metrics-server y Prometheus

Objetivo: Instalar herramientas de telemetría para uso con HPA.

Diagrama:

```mermaid
flowchart LR
  Cluster --> MetricsServer
  Cluster --> Prometheus
  Prometheus --> Grafana
```

Comandos: helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install ...

Ejercicio: Exponer métricas del pod y consultar con kubectl top.

Checkpoints:

- kubectl top pods muestra uso de CPU/mem

---

## Paso 07 — CloudWatch

Objetivo: Centralizar logs y métricas en CloudWatch.

Diagrama:

```mermaid
flowchart LR
  Cluster --> CloudWatchAgent --> CloudWatch
  ECR --> CloudWatchLogs
```

Comandos: Configurar agent y fluentd/fluent-bit.

Ejercicio: Crear regla para exportar logs de pods a CloudWatch y verificar en consola AWS.

Checkpoints:

- Logs de la aplicación visibles en CloudWatch Logs

---

## Paso 08 — ECR: construir y publicar imágenes

Objetivo: Enseñar pipeline básico: build, tag, push a ECR.

Diagrama:

```mermaid
flowchart LR
  Dockerfile --> ImagenLocal --> Tag --> ECR
  CI --> Build --> ECR
```

Comandos:

- aws ecr create-repository --repository-name myapp
- $(aws ecr get-login --no-include-email --region ...)
- docker build -t myapp:1.0 .
- docker tag myapp:1.0 `<account>`.dkr.ecr.region.amazonaws.com/myapp:1.0
- docker push ...

Ejercicio: Publicar una imagen y desplegarla desde ECR en el cluster.

Checkpoints:

- Imagen aparecer en ECR console

---

## Paso 09 — Desplegar YAML de Kubernetes

Objetivo: Comprender manifiestos (Deployments, Services, ConfigMaps, Secrets).

Diagrama:

```mermaid
flowchart TB
  Deployment --> ReplicaSet --> Pods
  Service --> Pods
  ConfigMap --> Pod
```

Comandos clave: kubectl apply -f deployment.yaml

Ejercicio: Crear Deployment con 3 réplicas y Service tipo ClusterIP y LoadBalancer.

Checkpoints:

- kubectl get deploys muestra desired=available

---

## Paso 10 — HPA: escalado automático

Objetivo: Configurar HPA basado en CPU y/o custom metrics.

Diagrama:

```mermaid
flowchart LR
  HPA --> MetricsServer
  HPA --> Deployment
```

Comandos:

- kubectl autoscale deployment myapp --cpu-percent=50 --min=2 --max=10

Ejercicio: Generar carga y observar incremento de réplicas.

Checkpoints:

- kubectl get hpa muestra métricas y replicas actuales

---

## Paso 11 — Stress tests

Objetivo: Generar carga controlada y observar comportamiento del sistema.

Diagrama:

```mermaid
flowchart LR
  Artillery/JMeter --> Service --> Pods
```

Comandos de ejemplo: hey -z 30s -q 10 -c 50 http://LB-ENDPOINT/

Ejercicio: Ejecutar pruebas y registrar métricas en Prometheus/CloudWatch.

Checkpoints:

- HPA responde escalandose
- Latencia y errores dentro de límites aceptables

---

## Paso 12 — Healing y recuperación

Objetivo: Simular fallos de pod y nodo; verificar auto-recovery.

Diagrama:

```mermaid
flowchart LR
  NodeFailure --> KubeController --> ReschedulePod
  PodCrashLoop --> LivenessProbe --> Restart
```

Ejercicios: drenar nodo, eliminar pods, provocar CrashLoopBackOff y validar probes.

Checkpoints:

- Pods rescheduled a otros nodos
- Liveness/readiness probes funcionan

---

## Paso 13 — Métricas, Dashboards y Alertas

Objetivo: Construir dashboards y alertas (Grafana/CloudWatch) para SLOs.

Diagrama:

```mermaid
flowchart LR
  Prometheus --> Grafana
  Alerts --> SNS/Email
```

Ejercicio: Crear un alerta que dispare si la latencia media supera 500ms por 5 minutos.

Checkpoints:

- Notificación recibida por canal configurado

---

# Buenas prácticas y evaluación

- Mantener principios de least privilege en IAM.
- Versionar manifiestos y pipelines en Git.
- No incluir credenciales en repositorio.
- Evaluación sugerida: crear un reto final que combine crear cluster, desplegar app y configurar HPA + alerta.

# Recursos y referencias

- Documentación oficial EKS: https://docs.aws.amazon.com/eks
- Kubernetes docs: https://kubernetes.io
- Helm charts: https://helm.sh
