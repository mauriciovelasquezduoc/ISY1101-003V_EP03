# PASO 12 — Auto-Healing Kubernetes

## Objetivo

Validar la capacidad de recuperación automática (Auto-Healing) de Kubernetes eliminando pods manualmente y observando cómo Amazon EKS reconstruye automáticamente los componentes afectados.

Este laboratorio demostrará:

* tolerancia a fallos
* recuperación automática
* alta disponibilidad
* resiliencia Kubernetes

---

# ¿Qué es Auto-Healing?

Auto-Healing es la capacidad de Kubernetes para:

```text
detectar fallos y recuperarse automáticamente
```

sin intervención manual.

---

# ¿Cómo funciona?

Kubernetes constantemente monitorea:

| Recurso     | Supervisión    |
| ----------- | -------------- |
| Pods        | estado         |
| Containers  | salud          |
| Nodes       | disponibilidad |
| Deployments | replicas       |

---

# Arquitectura Kubernetes

```text
Deployment
     ↓
ReplicaSet
     ↓
Pods
```

---

# ¿Qué ocurre si un pod falla?

Ejemplo:

```text
backend pod eliminado
```

---

# Kubernetes detecta:

```text
replicas reales < replicas deseadas
```

---

# Entonces Kubernetes:

```text
crea automáticamente un nuevo pod
```

---

# Resultado

```text
alta disponibilidad automática
```

---

# ¿Qué se validará?

Durante esta etapa:

| Validación            | Resultado esperado |
| --------------------- | ------------------ |
| eliminar pod          | Kubernetes detecta |
| recreación automática | nuevo pod          |
| deployment            | mantiene replicas  |
| scheduler             | reasigna pod       |
| EKS                   | mantiene servicio  |

---

# Conceptos Cloud Native

Este laboratorio valida:

| Concepto            | Estado |
| ------------------- | ------ |
| resiliencia         | ✅      |
| self-healing        | ✅      |
| alta disponibilidad | ✅      |
| orchestration       | ✅      |
| automation          | ✅      |

---

# Arquitectura validada

```text
Usuario
   ↓
Frontend
   ↓
Backend
   ↓
Pod falla
   ↓
Kubernetes recrea pod
```

---

# Recursos que se probarán

Se realizarán pruebas sobre:

* frontend pods
* backend pods

---

# ¿Por qué NO MySQL?

Porque:

* base de datos requiere persistencia
* podría existir pérdida temporal
* normalmente se usa StatefulSet

---

# Validar pods actuales

```bash
kubectl get pods -n tienda
```

---

# Resultado esperado

```text
tienda-frontend-xxxxx
tienda-backend-xxxxx
tienda-db-xxxxx
```

---

# Monitorear pods en tiempo real

Abrir otra terminal:

```bash
kubectl get pods -n tienda -w
```

---

# Flujo esperado

## Estado inicial

```text
backend-pod-1   Running
backend-pod-2   Running
```

---

# Eliminar pod

```text
backend-pod-1 eliminado
```

---

# Kubernetes detecta diferencia

```text
desired replicas = 2
actual replicas = 1
```

---

# Kubernetes recrea automáticamente

```text
backend-pod-3 Running
```

---

# Resultado final

```text
replicas restauradas automáticamente
```

---

# ¿Qué componente hace esto?

Principalmente:

| Componente | Función           |
| ---------- | ----------------- |
| Deployment | replicas deseadas |
| ReplicaSet | mantener replicas |
| Scheduler  | asignar node      |
| Kubelet    | ejecutar pod      |

---

# Validar deployments

```bash
kubectl get deployment -n tienda
```

---

# Validar ReplicaSets

```bash
kubectl get rs -n tienda
```

---

# Validar eventos Kubernetes

```bash
kubectl get events -n tienda \
  --sort-by=.metadata.creationTimestamp
```

---

# Validar logs pods

```bash
kubectl logs -n tienda POD_NAME
```

---

# Arquitectura resiliente

```text
Pod falla
    ↓
Kubernetes detecta
    ↓
ReplicaSet actúa
    ↓
Nuevo pod creado
```

---

# Diferencia importante

## Kubernetes NO reinicia manualmente

Kubernetes:

* detecta diferencia estado deseado
* corrige automáticamente

---

# Resultado esperado final

Al finalizar correctamente:

* Kubernetes recreará pods automáticamente
* la aplicación seguirá operativa
* EKS demostrará resiliencia automática
* auto-healing quedará validado

---

# Arquitectura Cloud Native final

```text
AWS ELB
    ↓
Frontend Pods
    ↓
Backend Pods
    ↓
Auto-Healing Kubernetes
```

---

# Siguiente paso

Luego continuará:

```text
Validaciones finales y observabilidad
```

incluyendo:

* K9s
* CloudWatch
* monitoreo
* métricas

---
