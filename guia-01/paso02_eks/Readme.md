# PASO 2 — Crear Cluster Amazon EKS (Control Plane)

## Objetivo

Crear el clúster Amazon EKS que actuará como plano de control (Control Plane) de Kubernetes.

Amazon EKS administrará automáticamente:

* API Server Kubernetes
* Scheduler
* Controller Manager
* etcd
* Alta disponibilidad del plano de control

Este clúster será la base donde posteriormente se desplegarán:

* Node Groups
* Pods
* Services
* Load Balancers
* HPA
* Aplicaciones Kubernetes

---

# ¿Por qué es importante este paso?

El clúster EKS es el núcleo de toda la plataforma Kubernetes en AWS.

Sin este componente:

* kubectl no puede conectarse.
* No existen nodos Kubernetes.
* No pueden desplegarse aplicaciones.
* No funcionan Services ni HPA.

En AWS, EKS abstrae la administración compleja del Control Plane y permite enfocarse en la operación de aplicaciones y contenedores.

---

# Componentes involucrados

| Componente      | Función                         |
| --------------- | -------------------------------- |
| Amazon EKS      | Servicio administrado Kubernetes |
| VPC             | Red privada AWS                  |
| Subnets         | Segmentación red                |
| Security Groups | Firewall                         |
| IAM Role        | Permisos EKS                     |
| CloudWatch      | Logs y monitoreo                 |

---

# Requisitos previos

Antes de continuar debe existir:

* AWS CLI configurado
* Credenciales válidas
* Roles IAM EKS validados
* VPC y subnets creadas
* Paso 1 completado correctamente

---

# Variables necesarias

## Nombre del cluster

```bash
export CLUSTER_NAME=nombre-eks
```

---

## Región AWS

```bash
export AWS_REGION=us-east-1
```

---

## Obtener IAM Role EKS automáticamente

AWS Academy usa nombres dinámicos, por lo tanto se obtiene automáticamente:

```bash
export CLUSTER_ROLE_ARN=$(aws iam list-roles \
  --query "Roles[?contains(RoleName, 'LabEksClusterRole')].Arn" \
  --output text)
```

Validar:

```bash
echo $CLUSTER_ROLE_ARN
```

---

# Obtener VPC y subnets

## Listar VPCs

```bash
aws ec2 describe-vpcs \
  --query "Vpcs[*].[VpcId,CidrBlock]" \
  --output table
```

---

## Listar subnets

```bash
aws ec2 describe-subnets \
  --query "Subnets[*].[SubnetId,VpcId,AvailabilityZone,CidrBlock]" \
  --output table
```

---

# Crear Security Group EKS

## Crear Security Group

```bash
aws ec2 create-security-group \
  --group-name eks-cluster-sg \
  --description "EKS Cluster Security Group" \
  --vpc-id <VPC_ID>
```

Resultado esperado:

```text
sg-xxxxxxxx
```

Guardar el ID:

```bash
export EKS_SG_ID=sg-xxxxxxxx
```

---

# Crear cluster EKS

## Comando principal

```bash
aws eks create-cluster \
  --region $AWS_REGION \
  --name $CLUSTER_NAME \
  --role-arn $CLUSTER_ROLE_ARN \
  --resources-vpc-config subnetIds=<SUBNET_1>,<SUBNET_2>,<SUBNET_3>,securityGroupIds=$EKS_SG_ID,endpointPublicAccess=true,endpointPrivateAccess=true
```

---

# Ejemplo completo

```bash
aws eks create-cluster \
  --region us-east-1 \
  --name nombre-eks \
  --role-arn arn:aws:iam::123456789012:role/xxxx-LabEksClusterRole-xxxx \
  --resources-vpc-config \
  subnetIds=subnet-11111111,subnet-22222222,subnet-33333333,securityGroupIds=sg-12345678,endpointPublicAccess=true,endpointPrivateAccess=true
```

---

# ¿Qué hace este comando?

| Parámetro            | Función                |
| --------------------- | ----------------------- |
| --name                | Nombre cluster          |
| --role-arn            | IAM Role EKS            |
| subnetIds             | Red cluster             |
| securityGroupIds      | Firewall cluster        |
| endpointPublicAccess  | Acceso kubectl internet |
| endpointPrivateAccess | Acceso interno VPC      |

---

# Validar creación del cluster

## Ver estado

```bash
aws eks describe-cluster \
  --name $CLUSTER_NAME \
  --region $AWS_REGION \
  --query "cluster.status"
```

---

# Estado esperado

```text
ACTIVE
```

---

# Tiempo estimado

La creación del cluster puede tardar:

```text
10 a 15 minutos
```

---

# Validar clusters existentes

```bash
aws eks list-clusters \
  --region us-east-1
```

---

# Logs y monitoreo

Posteriormente el cluster generará logs en:

```text
/aws/eks/<cluster-name>/cluster
```

Dentro de CloudWatch Logs.

---

# Script recomendado

Archivo:

```text
scripts/02-create-cluster.sh
```

Este script automatizará:

* Obtención IAM Role
* Obtención subnets
* Creación Security Group
* Creación cluster EKS
* Espera estado ACTIVE

---

# Resultado esperado

Al finalizar correctamente:

* El cluster EKS existirá.
* El Control Plane estará operativo.
* Kubernetes estará listo para recibir Node Groups.
* El endpoint API Kubernetes estará disponible.


# Operación del despliegue EKS

## 1. Verificar archivos

Validar que ambos archivos existan:

```bash
ls -lh
```

Deberías ver:

```text
fase_4_cluster_eks.yaml
crearClusterEks.sh
```

---

# 2. Dar permisos al script

```bash
chmod +x crearClusterEks.sh
```

---

# 3. Validar credenciales AWS

MUY importante en AWS Academy.

```bash
aws sts get-caller-identity
```

Si falla:

* el token expiró
* debes refrescar credenciales Vocareum

---

# 4. Validar stack VPC

El stack VPC debe existir primero.

```bash
aws cloudformation list-stacks \
  --region us-east-1 \
  --query "StackSummaries[*].[StackName,StackStatus]" \
  --output table
```

Debe aparecer:

```text
laboratorio-vpc-completa
```

con estado:

```text
CREATE_COMPLETE
```

---

# 5. Ejecutar despliegue EKS

## Ejecutar script

```bash
./crearClusterEks.sh
```

o:

```bash
bash crearClusterEks.sh
```

---

# ¿Qué hará el script?

El script automáticamente:

| Acción                  | Descripción          |
| ------------------------ | --------------------- |
| Obtiene outputs VPC      | subnets + VPC         |
| Obtiene IAM Roles        | AWS Academy dinámico |
| Despliega CloudFormation | Cluster EKS           |
| Crea NodeGroup           | workers               |
| Configura kubeconfig     | kubectl               |
| Valida nodos             | get nodes             |
| Valida kube-system       | pods                  |

---

# 6. Monitorear CloudFormation

En otra terminal:

```bash
aws cloudformation describe-stacks \
  --stack-name laboratorio-eks \
  --region us-east-1 \
  --query "Stacks[0].StackStatus"
```

---

# Estados posibles

| Estado             | Significado           |
| ------------------ | --------------------- |
| CREATE_IN_PROGRESS | Creando EKS           |
| CREATE_COMPLETE    | Cluster listo         |
| CREATE_FAILED      | Error                 |
| ROLLBACK_COMPLETE  | AWS eliminó recursos |

---

# 7. Ver eventos CloudFormation

Si falla:

```bash
aws cloudformation describe-stack-events \
  --stack-name laboratorio-eks \
  --region us-east-1 \
  --output table
```

---

# 8. Ver cluster EKS

```bash
aws eks list-clusters \
  --region us-east-1
```

---

# 9. Ver estado cluster

```bash
aws eks describe-cluster \
  --name laboratorio-eks \
  --region us-east-1 \
  --query "cluster.status"
```

Resultado esperado:

```text
ACTIVE
```

---

# 10. Configurar kubectl manualmente

Si fuese necesario:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name laboratorio-eks
```

---

# 11. Validar conexión Kubernetes

## Ver nodos

```bash
kubectl get nodes
```

Resultado esperado:

```text
Ready
```

---

# 12. Ver pods sistema

```bash
kubectl get pods -n kube-system
```

---

# 13. Ver addons EKS

```bash
aws eks list-addons \
  --cluster-name laboratorio-eks \
  --region us-east-1
```

---

# 14. Ver Metrics Server

```bash
kubectl get pods -n kube-system | grep metrics
```

---

# 15. Ver NodeGroup

```bash
aws eks list-nodegroups \
  --cluster-name laboratorio-eks \
  --region us-east-1
```

---

# Tiempo estimado

La creación completa puede tardar:

```text
15 a 30 minutos
```

Porque incluye:

* Cluster EKS
* Addons
* NodeGroup
* EC2
* Bootstrap Kubernetes

---

# Resultado esperado final

Al finalizar correctamente tendrás:

* Cluster EKS operativo
* NodeGroup funcionando
* kubectl conectado
* Addons instalados
* Metrics Server activo
* Kubernetes listo para deploys

---

# Limpieza (cleanup)

Eliminar stack EKS:

```bash
aws cloudformation delete-stack \
  --stack-name laboratorio-eks \
  --region us-east-1
```

---

# Siguiente paso

Luego continuará:

```text
Deploy aplicaciones Kubernetes
```

* backend
* frontend
* mysql
* services
* ingress/loadbalancer
* HPA

---

---
