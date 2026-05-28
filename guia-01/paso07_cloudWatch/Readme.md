# PASO 7 — Configurar y validar Amazon CloudWatch en EKS

## Objetivo

Validar la integración entre Amazon EKS y Amazon CloudWatch para:

* monitoreo del cluster
* logs Kubernetes
* observabilidad
* troubleshooting
* métricas infraestructura
* eventos EKS

---

# ¿Qué es CloudWatch?

Amazon CloudWatch es el servicio de monitoreo y observabilidad de AWS.

Permite recopilar:

| Tipo       | Ejemplo       |
| ---------- | ------------- |
| Logs       | kube-system   |
| Métricas  | CPU / memoria |
| Eventos    | escalado      |
| Alarmas    | fallos        |
| Dashboards | monitoreo     |

---

# Arquitectura utilizada

En este laboratorio:

```text
Worker Nodes
    ↓
CloudWatch Logs
    ↓
CloudWatch Metrics
    ↓
AWS Console / CLI
```

---

# ¿Por qué es importante?

CloudWatch permite:

* diagnosticar errores Kubernetes
* revisar logs cluster
* monitorear nodos
* revisar eventos EKS
* validar funcionamiento cluster

---

# Requisitos previos

Antes de continuar debe existir:

* Cluster EKS ACTIVE
* NodeGroup ACTIVE
* kubectl funcionando
* Metrics Server funcionando
* VPC Endpoint logs disponible

---

# Validar endpoint CloudWatch

```bash
aws ec2 describe-vpc-endpoints \
  --region us-east-1 \
  --query "VpcEndpoints[*].[ServiceName,State]" \
  --output table
```

---

# Resultado esperado

Debe existir:

```text
com.amazonaws.us-east-1.logs
```

estado:

```text
available
```

---

# Validar logs EKS habilitados

Durante la creación del cluster se habilitaron:

| Log               | Estado |
| ----------------- | ------ |
| api               | ✅     |
| audit             | ✅     |
| authenticator     | ✅     |
| controllerManager | ✅     |
| scheduler         | ✅     |

---

# Verificar logging EKS

```bash
aws eks describe-cluster \
  --name laboratorio-eks \
  --region us-east-1 \
  --query "cluster.logging"
```

---

# Resultado esperado

```text
enabled = true
```

---

# Ver Log Groups CloudWatch

```bash
aws logs describe-log-groups \
  --region us-east-1 \
  --query "logGroups[*].logGroupName" \
  --output table
```

---

# Resultado esperado

Debe existir algo similar a:

```text
/aws/eks/laboratorio-eks/cluster
```

---

# Ver streams logs EKS

```bash
aws logs describe-log-streams \
  --log-group-name /aws/eks/laboratorio-eks/cluster \
  --region us-east-1 \
  --output table
```

---

# Ver eventos recientes CloudWatch

```bash
aws logs tail /aws/eks/laboratorio-eks/cluster \
  --follow \
  --region us-east-1
```

---

# ¿Qué veremos aquí?

Eventos como:

* kube-apiserver
* autenticación IAM
* scheduler
* control plane
* eventos Kubernetes

---

# Validar métricas nodos

```bash
kubectl top nodes
```

---

# Validar métricas pods

```bash
kubectl top pods -A
```

---

# Ver eventos Kubernetes

```bash
kubectl get events -A
```

---

# Validar estado kube-system

```bash
kubectl get pods -n kube-system
```

---

# Pods importantes

| Pod            | Función   |
| -------------- | ---------- |
| aws-node       | networking |
| coredns        | DNS        |
| kube-proxy     | proxy      |
| metrics-server | métricas  |

---

# Beneficios CloudWatch

## Observabilidad

Permite:

* troubleshooting
* análisis cluster
* monitoreo tiempo real

---

## Logs centralizados

Todos los logs:

* EKS
* control plane
* Kubernetes

quedan centralizados.

---

## Diagnóstico

CloudWatch ayuda a diagnosticar:

| Problema      | Ejemplo          |
| ------------- | ---------------- |
| Pods fallando | CrashLoopBackOff |
| networking    | CNI              |
| permisos IAM  | AccessDenied     |
| escalado      | HPA              |
| DNS           | coredns          |

---

# Arquitectura validada

Este paso valida:

* CloudWatch Logs
* integración EKS logging
* métricas cluster
* observabilidad AWS
* troubleshooting Kubernetes

---

# Resultado esperado final

Al finalizar correctamente:

* CloudWatch Logs estará operativo.
* Logs EKS serán visibles.
* Métricas cluster funcionarán.
* Observabilidad Kubernetes quedará habilitada.

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
