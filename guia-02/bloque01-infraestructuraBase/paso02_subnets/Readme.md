# PASO 2 — Configurar y validar Subnets para Amazon EKS

## Objetivo

Validar que las subnets de la VPC se encuentren correctamente configuradas y etiquetadas para que Amazon EKS y Kubernetes puedan crear automáticamente:

* Elastic Load Balancers (ELB)
* Network Load Balancers (NLB)
* Services tipo LoadBalancer
* Internal Load Balancers

---


# Ejecutar

```
bash paso02_valida.sh
```

# ¿Por qué es importante este paso?

Kubernetes en AWS necesita identificar automáticamente qué subnets utilizar dependiendo del tipo de servicio desplegado.

Por ejemplo:

| Tipo Service Kubernetes | Subnet utilizada |
| ----------------------- | ---------------- |
| LoadBalancer público   | Public Subnets   |
| Internal LoadBalancer   | Private Subnets  |

AWS detecta esto mediante tags especiales en las subnets.

Si los tags no existen:

* Kubernetes NO podrá crear ELB
* Los Services tipo LoadBalancer fallarán
* El frontend no será accesible
* El Ingress Controller no funcionará

---

# Arquitectura utilizada

La arquitectura implementada utiliza:

| Tipo subnet          | Uso           |
| -------------------- | ------------- |
| Public Subnets       | ELB públicos |
| Private App Subnets  | Worker Nodes  |
| Private Data Subnets | Base de datos |

---

# Tags requeridos por EKS

## Public Subnets

Las subnets públicas deben contener:

```text
kubernetes.io/role/elb = 1
```

Esto indica a Kubernetes:

```text
Esta subnet puede utilizarse para ELB públicos
```

---

## Private Subnets

Las subnets privadas deben contener:

```text
kubernetes.io/role/internal-elb = 1
```

Esto permite:

```text
crear Load Balancers internos
```

---

## Tag del cluster EKS

Todas las subnets deben contener:

```text
kubernetes.io/cluster/laboratorio-eks = shared
```

Esto asocia las subnets al cluster EKS.

---

# ¿Qué significa shared?

```text
shared
```

indica que:

* múltiples recursos Kubernetes pueden utilizar esas subnets
* AWS las considera compartidas para el cluster

---

# Validar subnets existentes

## Mostrar subnets

```bash
aws ec2 describe-subnets \
  --region us-east-1 \
  --query "Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,Tags]" \
  --output table
```

---

# Resultado esperado

Las subnets públicas deben contener:

```text
kubernetes.io/role/elb
```

---

Las privadas:

```text
kubernetes.io/role/internal-elb
```

---

# Validar preparación para LoadBalancer

Gracias a estos tags, Kubernetes podrá crear automáticamente ELB mediante:

```yaml
spec:
  type: LoadBalancer
```

---

# ¿Qué hará Kubernetes automáticamente?

Cuando se despliegue un Service tipo LoadBalancer:

```text
Kubernetes
    ↓
AWS Cloud Controller Manager
    ↓
AWS ELB/NLB
```

AWS detectará automáticamente:

* las subnets públicas
* las AZ disponibles
* el networking correcto

---

# Multi-AZ

Las subnets deben existir en múltiples Availability Zones:

| AZ         |
| ---------- |
| us-east-1a |
| us-east-1b |

Esto permite:

* alta disponibilidad
* tolerancia a fallos
* balanceo multi-zona

---

# Validar VPC Endpoints

Los nodos privados utilizan VPC Endpoints para acceder a servicios AWS sin NAT Gateway.

## Validar endpoints

```bash
aws ec2 describe-vpc-endpoints \
  --region us-east-1 \
  --query "VpcEndpoints[*].[ServiceName,VpcEndpointType,State]" \
  --output table
```

---

# Endpoints esperados

| Endpoint |
| -------- |
| ecr.api  |
| ecr.dkr  |
| s3       |
| sts      |
| logs     |
| eks      |

---

# Resultado esperado final

Al finalizar correctamente:

* Kubernetes podrá crear LoadBalancers automáticamente.
* Las subnets estarán correctamente asociadas al cluster.
* ELB/NLB funcionarán.
* El cluster estará preparado para frontend público.
* Networking EKS quedará completamente operativo.

---

# Conclusión técnica

En esta implementación:

* las subnets fueron configuradas mediante CloudFormation
* los tags fueron automatizados
* el networking quedó integrado con EKS
* la arquitectura soporta Kubernetes privado multi-AZ

---
