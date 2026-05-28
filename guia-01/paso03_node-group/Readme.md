# Crear Node Group Amazon EKS

## Objetivo

Crear el Node Group administrado (Managed Node Group) que proporcionará los worker nodes EC2 donde se ejecutarán los pods Kubernetes.

Los Node Groups permiten:

* Ejecutar aplicaciones Kubernetes
* Escalar pods
* Ejecutar Deployments
* Ejecutar Services
* Soportar HPA
* Ejecutar contenedores Docker

---

# ¿Qué es un Node Group?

Un Node Group es un conjunto de instancias EC2 administradas por Amazon EKS.

AWS se encargará automáticamente de:

* Crear instancias EC2
* Unir nodos al cluster
* Bootstrap Kubernetes
* Actualizaciones rolling
* Auto Scaling
* Reemplazo de nodos fallidos

---

# Arquitectura utilizada

Los worker nodes serán desplegados en:

| Subnet            | Uso          |
| ----------------- | ------------ |
| PrivateAppSubnetA | Worker Nodes |
| PrivateAppSubnetB | Worker Nodes |

---

# ¿Por qué usar subnets privadas?

Los worker nodes:

* NO necesitan IP pública
* NO deben exponerse directamente a internet
* Consumirán servicios AWS mediante VPC Endpoints
* Mejoran la seguridad del cluster

---

# Comunicación AWS privada

Gracias a los VPC Endpoints previamente creados:

* ECR
* STS
* CloudWatch
* EKS API

los nodos podrán operar completamente privados sin NAT Gateway.

---

# Requisitos previos

Antes de continuar debe existir:

* Cluster EKS operativo
* VPC creada
* Private App Subnets
* IAM Roles EKS
* VPC Endpoints
* kubectl configurado

---

# Obtener cluster existente

```
aws eks list-clusters \
  --region us-east-1
```

---

# Validar estado cluster

```
aws eks describe-cluster \
  --name laboratorio-eks \
  --region us-east-1 \
  --query "cluster.status"
```

Resultado esperado:

```
ACTIVE
```

---

# Obtener Node Role automáticamente

AWS Academy utiliza nombres dinámicos.

```
export NODE_ROLE_ARN=$(aws iam list-roles \
  --query "Roles[?contains(RoleName, 'LabEksNodeRole')].Arn" \
  --output text)
```

---

# Validar Node Role

```
echo $NODE_ROLE_ARN
```

---

# Obtener subnets privadas APP

```
aws ec2 describe-subnets \
  --region us-east-1 \
  --query "Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,Tags]" \
  --output table
```

Identificar:

* private-app-a
* private-app-b

---

# Crear Node Group EKS

## Comando principal

```
aws eks create-nodegroup \
  --region us-east-1 \
  --cluster-name laboratorio-eks \
  --nodegroup-name laboratorio-nodegroup \
  --node-role $NODE_ROLE_ARN \
  --subnets subnet-aaaa subnet-bbbb \
  --instance-types t3.large \
  --capacity-type SPOT \
  --scaling-config minSize=1,maxSize=3,desiredSize=1 \
  --disk-size 20
```

---

# ¿Qué hace este comando?

| Parámetro           | Función         |
| -------------------- | ---------------- |
| --cluster-name       | Cluster EKS      |
| --nodegroup-name     | Nombre nodegroup |
| --node-role          | IAM Role EC2     |
| --subnets            | Subnets privadas |
| --instance-types     | Tipo EC2         |
| --capacity-type SPOT | Instancias spot  |
| scaling-config       | Escalado         |
| disk-size            | Disco EBS        |

---

# Tipo de instancia utilizada

## t3.large

| Recurso | Valor |
| ------- | ----- |
| vCPU    | 2     |
| RAM     | 8 GB  |

Adecuado para:

* laboratorios
* Kubernetes básico
* HPA
* frontend/backend/mysql

---

# ¿Por qué SPOT?

Las instancias SPOT:

* son más económicas
* reducen consumo AWS Academy
* son suficientes para laboratorios

---

# Validar creación Node Group

## Ver estado

```
aws eks describe-nodegroup \
  --cluster-name laboratorio-eks \
  --nodegroup-name laboratorio-nodegroup \
  --region us-east-1 \
  --query "nodegroup.status"
```

---

# Estado esperado

```
ACTIVE
```

---

# Tiempo estimado

La creación puede tardar:

```
5 a 15 minutos
```

---

# Configurar kubectl

```
aws eks update-kubeconfig \
  --region us-east-1 \
  --name laboratorio-eks
```

---

# Validar nodos Kubernetes

```
kubectl get nodes
```

Resultado esperado:

```
Ready
```

---

# Validar kube-system

```
kubectl get pods -n kube-system
```

---

# Validar addons EKS

```
aws eks list-addons \
  --cluster-name laboratorio-eks \
  --region us-east-1
```

---

# Validar métricas

```
kubectl top nodes
```

---

# Resultado esperado final

Al finalizar correctamente:

* Worker nodes EC2 estarán activos.
* Kubernetes tendrá capacidad de ejecución.
* Los nodos aparecerán Ready.
* Los pods podrán desplegarse.
* El cluster estará listo para aplicaciones.

---

# Siguiente paso

El siguiente paso será:

```
Deploy aplicaciones Kubernetes
```

* frontend
* backend
* mysql
* services
* loadbalancer
* HPA


# Ejecutar PASO 3 — Node Group EKS

## 1. Verificar archivos

```bash
ls -lh
```

Deberías ver:

```text
03-create-nodegroup.sh
03-validate-nodegroup.sh
```

---

# 2. Dar permisos ejecución

```bash
chmod +x 03-create-nodegroup.sh
chmod +x 03-validate-nodegroup.sh
```

---

# 3. Validar credenciales AWS

MUY importante en AWS Academy.

```bash
aws sts get-caller-identity
```

---

# 4. Validar cluster EKS

El cluster debe existir y estar ACTIVE.

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

# 5. Ejecutar creación NodeGroup

## Ejecutar script

```bash
bash 03-create-nodegroup.sh
```

o:

```bash
./03-create-nodegroup.sh
```

---

# ¿Qué hace el script?

El script automáticamente:

| Acción                  | Descripción          |
| ------------------------ | --------------------- |
| Obtiene IAM Role         | AWS Academy dinámico |
| Obtiene subnets privadas | private-app-a/b       |
| Crea NodeGroup           | EC2 workers           |
| Configura escalado       | min/max/desired       |
| Configura SPOT           | ahorro costos         |

---

# 6. Monitorear creación

## Ver estado NodeGroup

Ejecutar cada 20–30 segundos:

```bash
aws eks describe-nodegroup \
  --cluster-name laboratorio-eks \
  --nodegroup-name laboratorio-nodegroup \
  --region us-east-1 \
  --query "nodegroup.status"
```

---

# Estados posibles

| Estado        | Significado      |
| ------------- | ---------------- |
| CREATING      | Creando EC2      |
| ACTIVE        | NodeGroup listo  |
| CREATE_FAILED | Error            |
| DEGRADED      | Problema parcial |

---

# 7. Validar NodeGroup

Cuando el estado sea ACTIVE:

```bash
bash 03-validate-nodegroup.sh
```

---

# ¿Qué valida este script?

| Validación       | Descripción      |
| ----------------- | ----------------- |
| kubeconfig        | conexión cluster |
| kubectl get nodes | nodos Ready       |
| kube-system       | pods sistema      |
| networking        | conectividad EKS  |

---

# 8. Validar nodos manualmente

```bash
kubectl get nodes -o wide
```

Resultado esperado:

```text
STATUS = Ready
```

---

# 9. Validar pods sistema

```bash
kubectl get pods -n kube-system
```

---

# 10. Validar addons EKS

```bash
aws eks list-addons \
  --cluster-name laboratorio-eks \
  --region us-east-1
```

---

# 11. Validar métricas

```bash
kubectl top nodes
```

---

# Tiempo estimado

La creación puede tardar:

```text
5 a 15 minutos
```

porque AWS debe:

* crear EC2
* instalar kubelet
* unir nodos
* bootstrap Kubernetes
* registrar nodes

---

# Resultado esperado final

Al finalizar correctamente tendrás:

* Worker nodes EC2 activos
* Nodos Ready
* Kubernetes operativo
* kube-system saludable
* Cluster listo para aplicaciones

---

# Limpieza (cleanup)

Eliminar NodeGroup:

```bash
aws eks delete-nodegroup \
  --cluster-name laboratorio-eks \
  --nodegroup-name laboratorio-nodegroup \
  --region us-east-1
```

---

# Siguiente paso

Luego continuará:

```text
Deploy aplicaciones Kubernetes
```

* frontend
* backend
* mysql
* services
* loadbalancer
* HPA

---
