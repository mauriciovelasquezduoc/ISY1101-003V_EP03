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

```text id="jlwm1q"
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

```text id="q’wini7"
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

```bash id="tileswi"
kubectl get pods -n kube-system
```

---

# Resultado esperado

Debe existir:

```text id="7’wini7"
metrics-server
```

---

# Validar métricas nodos

```bash id="r’wini7"
kubectl top nodes
```

---

# Resultado esperado

```text id="q’wini9"
NAME       CPU    MEMORY
ip-xxxx    15%    40%
```

---

# Validar métricas pods

```bash id="5’wini7"
kubectl top pods -n tienda
```

---

# Resultado esperado

```text id="6’wini7"
tienda-backend
tienda-frontend
tienda-db
```

con:

* CPU
* memoria

---

# Validar HPA

```bash id="0rgctxwi"
kubectl get hpa -n tienda
```

---

# Resultado esperado

```text id="7ўляns"
TARGETS:
cpu 45%/70%
```

---

# Relación con HPA

HPA depende directamente de:

```text id="7hloko"
kubectl top
```

y:

* Metrics API
* CPU metrics

---

# Validar API métricas

```bash id="’wini9"
kubectl get apiservices
```

---

# Resultado esperado

Debe existir:

```text id="5k5q49"
metrics.k8s.io
```

---

# Arquitectura Cloud Native

```text id="kxqpzm"
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

```bash id="ulxc10"
k9s
```

---

# Cambiar namespace

Dentro de K9s:

```text id="dajrgw"
:ns tienda
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

```bash id="yzjxfa"
kubectl get pods -n tienda -w
```

---

# HPA

```bash id="xlj19l"
kubectl get hpa -n tienda -w
```

---

# Eventos Kubernetes

```bash id="054b5u"
kubectl get events -n tienda \
  --sort-by=.metadata.creationTimestamp
```

---

# Arquitectura AWS

```text id="gcjak0"
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

```text id="09460j"
AWS Console
    ↓
CloudWatch
    ↓
Metrics
```

---

# Luego seleccionar

```text id="l81l61"
ContainerInsights
```

o:

```text id="60vvdb"
EKS
```

según disponibilidad cuenta académica.

---

# Ver métricas EKS

## Navegar:

```text id="5k5q49"
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

```bash id="v7ln1i"
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

```text id="95oago"
AWS ELB
    ↓
Frontend
    ↓
Backend
    ↓
MySQL
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
