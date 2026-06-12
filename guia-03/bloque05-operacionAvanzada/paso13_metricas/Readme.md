# PASO 13 — Métricas y Observabilidad Kubernetes

## Objetivo

Validar el monitoreo y observabilidad del cluster Amazon EKS utilizando:

* Metrics Server
* kubectl top
* CloudWatch
* métricas Kubernetes
* métricas nodos
* métricas pods

Este laboratorio permitirá observar:

* consumo CPU
* consumo memoria
* estado pods
* métricas cluster
* comportamiento HPA

---

# ¿Qué es Observabilidad?

Observabilidad permite comprender:

```text
qué está ocurriendo dentro del cluster Kubernetes
```

---

# ¿Qué se monitoreará?

| Recurso     | Métrica   |
| ----------- | --------- |
| Nodes       | CPU / RAM |
| Pods        | CPU / RAM |
| Deployments | replicas  |
| HPA         | scaling   |
| Containers  | estado    |
| Cluster     | salud     |

---

# Componentes utilizados

| Componente     | Función             |
| -------------- | ------------------- |
| Metrics Server | métricas Kubernetes |
| kubectl top    | visualizar métricas |
| CloudWatch     | monitoreo AWS       |
| EKS            | métricas cluster    |

---

# Arquitectura monitoreo

```text
Pods
   ↓
Metrics Server
   ↓
kubectl top
   ↓
HPA / Observabilidad
```

---

# ¿Qué es Metrics Server?

Metrics Server es un componente Kubernetes encargado de:

* recolectar CPU
* recolectar memoria
* entregar métricas al cluster

---

# ¿Quién utiliza Metrics Server?

Principalmente:

| Componente  | Uso          |
| ----------- | ------------ |
| HPA         | auto scaling |
| kubectl top | métricas     |
| dashboards  | monitoreo    |

---

# Validar Metrics Server

```bash
kubectl get pods -n kube-system
```

---

# Resultado esperado

Debe existir:

```text
metrics-server
```

---

# Validar métricas nodos

```bash
kubectl top nodes
```

---

# Resultado esperado

```text
NAME       CPU    MEMORY
ip-xxxx    15%    40%
```

---

# Validar métricas pods

```bash
kubectl top pods -n alumnos
```

---

# Resultado esperado

```text
alumnos-backend
alumnos-frontend
alumnos-db
```

con:

* CPU
* memoria

---

# Validar HPA

```bash
kubectl get hpa -n alumnos
```

---

# Resultado esperado

```text
TARGETS:
cpu 45%/70%
```

---

# Relación con HPA

HPA depende directamente de:

```text
kubectl top
```

y:

* Metrics API
* CPU metrics

---

# Validar API métricas

```bash
kubectl get apiservices
```

---

# Resultado esperado

Debe existir:

```text
metrics.k8s.io
```

---

# Arquitectura Cloud Native

```text
Aplicación
    ↓
Métricas
    ↓
Metrics Server
    ↓
HPA
    ↓
Escalamiento automático
```

---

# Observabilidad con K9s

K9s permite:

* ver CPU
* ver memoria
* ver pods
* ver logs
* monitoreo live

---

# Abrir K9s

```bash
k9s
```

---

# Cambiar namespace

Dentro de K9s:

```text
:ns alumnos
```

---

# Ver métricas pods

K9s mostrará:

* CPU
* MEM
* restarts
* status

---

# Monitoreo en tiempo real

## Pods

```bash
kubectl get pods -n alumnos -w
```

---

# HPA

```bash
kubectl get hpa -n alumnos -w
```

---

# Eventos Kubernetes

```bash
kubectl get events -n alumnos \
  --sort-by=.metadata.creationTimestamp
```

---

# Arquitectura AWS

```text
Kubernetes
    ↓
Metrics Server
    ↓
CloudWatch
    ↓
Observabilidad AWS
```

---

# Visualizar métricas en AWS Web Console

## Navegar:

```text
AWS Console
    ↓
CloudWatch
    ↓
Metrics
```

---

# Luego seleccionar

```text
ContainerInsights
```

o:

```text
EKS
```

según disponibilidad cuenta académica.

---

# Ver métricas EKS

## Navegar:

```text
AWS Console
    ↓
EKS
    ↓
laboratorio-eks
    ↓
Monitoring
```

---

# Métricas típicas

| Métrica      | Observación   |
| ------------ | ------------- |
| CPU nodes    | carga cluster |
| memory nodes | uso memoria   |
| pod count    | replicas      |
| network      | tráfico       |
| containers   | estado        |

---

# Limitaciones posibles cuenta académica

Algunas cuentas académicas:

* limitan Container Insights
* limitan dashboards avanzados
* limitan métricas detalladas

---

# Validación mínima requerida

Con:

```bash
kubectl top
```

ya queda validado:

* Metrics Server
* métricas Kubernetes
* observabilidad básica

---

# Resultado esperado final

Al finalizar correctamente:

* Metrics Server operativo
* métricas Kubernetes visibles
* HPA monitoreando CPU
* observabilidad cluster validada
* monitoreo EKS funcional

---

# Conceptos Cloud Native validados

| Concepto       | Estado |
| -------------- | ------ |
| observabilidad | ✅      |
| monitoreo      | ✅      |
| métricas       | ✅      |
| autoscaling    | ✅      |
| resiliencia    | ✅      |

---

# Arquitectura final completa

```text
AWS ELB
    ↓
Frontend
    ↓
Backend
    ↓
PostgreSQL
    ↓
Metrics Server
    ↓
HPA
    ↓
CloudWatch
```

---

# Resultado final del laboratorio

La solución implementa:

* Kubernetes
* Amazon EKS
* Amazon ECR
* HPA
* Metrics Server
* CloudWatch
* Auto-Healing
* Observabilidad
* Arquitectura Multi-Tier

---
