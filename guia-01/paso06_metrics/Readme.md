6. Metrics Server

# PASO 6 — Instalar y validar Metrics Server en Amazon EKS

## Objetivo

Instalar y validar `Metrics Server`, el componente Kubernetes encargado de recopilar métricas de:

* CPU
* memoria
* uso de nodos
* uso de pods

Estas métricas son fundamentales para:

* HPA (Horizontal Pod Autoscaler)
* monitoreo Kubernetes
* escalamiento automático
* observabilidad básica

## Ejecutar

```
bash configurar-validar.sh
```

---

# ¿Qué es Metrics Server?

Metrics Server es un agregador de métricas liviano para Kubernetes.

Recopila información desde:

```text
kubelet
    ↓
Metrics Server
    ↓
Kubernetes Metrics API
```

---

# ¿Por qué es importante?

Sin Metrics Server:

* `kubectl top` NO funciona
* HPA NO funciona
* Kubernetes no puede autoescalar pods
* no hay métricas CPU/memoria

---

# Arquitectura utilizada

En este laboratorio:

```text
Worker Nodes privados
    ↓
kubelet
    ↓
Metrics Server
    ↓
Kubernetes API
```

---

# Requisitos previos

Antes de continuar debe existir:

* Cluster EKS ACTIVE
* NodeGroup ACTIVE
* kubectl conectado
* kube-system funcionando

---

# Validar cluster

```bash
kubectl get nodes
```

---

# Resultado esperado

```text
Ready
```

---

# Validar kube-system

```bash
kubectl get pods -n kube-system
```

---

# Verificar si Metrics Server ya existe

```bash
kubectl get deployment metrics-server -n kube-system
```

---

# Resultado esperado

Si existe:

```text
metrics-server
```

---

# En esta arquitectura

Metrics Server ya fue desplegado automáticamente mediante:

```text
EKS Addons
```

durante la creación del cluster EKS.

---

# Validar pods Metrics Server

```bash
kubectl get pods -n kube-system | grep metrics
```

---

# Resultado esperado

```text
metrics-server
STATUS = Running
```

---

# Validar Metrics API

```bash
kubectl top nodes
```

---

# Resultado esperado

Debe mostrar:

| NODE | CPU | MEMORY |
| ---- | --- | ------ |

---

# Validar métricas pods

```bash
kubectl top pods -A
```

---

# ¿Qué valida este paso?

| Validación       | Resultado |
| ----------------- | --------- |
| kubelet accesible | ✅        |
| Metrics API       | ✅        |
| HPA readiness     | ✅        |
| métricas cluster | ✅        |

---

# ¿Por qué es crítico para HPA?

El HPA utiliza:

```text
CPU %
MEMORY %
```

para decidir:

* escalar pods
* reducir pods
* mantener disponibilidad

---

# Flujo HPA

```text
Aplicación
   ↓
CPU alta
   ↓
Metrics Server
   ↓
HPA
   ↓
Más replicas
```

---

# Validar API metrics Kubernetes

```bash
kubectl get apiservices | grep metrics
```

---

# Resultado esperado

```text
metrics.k8s.io
True
```

---

# Ver deployment Metrics Server

```bash
kubectl describe deployment metrics-server -n kube-system
```

---

# Ver logs Metrics Server

```bash
kubectl logs -n kube-system deployment/metrics-server
```

---

# Problemas comunes

| Problema                | Causa                   |
| ----------------------- | ----------------------- |
| kubectl top no funciona | metrics-server no listo |
| metrics.k8s.io False    | API no registrada       |
| HPA no escala           | métricas ausentes      |
| pods CrashLoopBackOff   | networking              |

---

# Validación final esperada

Al finalizar correctamente:

* Metrics Server estará Running.
* `kubectl top` funcionará.
* Kubernetes Metrics API estará operativa.
* HPA podrá utilizar métricas CPU/memoria.

---

# Arquitectura validada

Este paso valida:

* kubelet metrics
* Kubernetes Metrics API
* observabilidad básica
* auto scaling readiness
* monitoreo cluster

---

# Siguiente paso

Luego continuará:

```text
Deploy aplicaciones Kubernetes
```

y posteriormente:

```text
Horizontal Pod Autoscaler (HPA)
```

---
