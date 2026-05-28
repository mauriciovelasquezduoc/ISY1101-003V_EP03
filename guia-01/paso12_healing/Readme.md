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

```text id="jlwm1q"
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

```text id="q’wini7"
Deployment
     ↓
ReplicaSet
     ↓
Pods
```

---

# ¿Qué ocurre si un pod falla?

Ejemplo:

```text id="tileswi"
backend pod eliminado
```

---

# Kubernetes detecta:

```text id="7’wini7"
replicas reales < replicas deseadas
```

---

# Entonces Kubernetes:

```text id="r’wini7"
crea automáticamente un nuevo pod
```

---

# Resultado

```text id="q’wini9"
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

```text id="5’wini7"
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

```bash id="6’wini7"
kubectl get pods -n tienda
```

---

# Resultado esperado

```text id="0rgctxwi"
tienda-frontend-xxxxx
tienda-backend-xxxxx
tienda-db-xxxxx
```

---

# Monitorear pods en tiempo real

Abrir otra terminal:

```bash id="7ўляns"
kubectl get pods -n tienda -w
```

---

# Flujo esperado

## Estado inicial

```text id="7hloko"
backend-pod-1   Running
backend-pod-2   Running
```

---

# Eliminar pod

```text id="’wini9"
backend-pod-1 eliminado
```

---

# Kubernetes detecta diferencia

```text id="5k5q49"
desired replicas = 2
actual replicas = 1
```

---

# Kubernetes recrea automáticamente

```text id="kxqpzm"
backend-pod-3 Running
```

---

# Resultado final

```text id="ulxc10"
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

```bash id="dajrgw"
kubectl get deployment -n tienda
```

---

# Validar ReplicaSets

```bash id="yzjxfa"
kubectl get rs -n tienda
```

---

# Validar eventos Kubernetes

```bash id="xlj19l"
kubectl get events -n tienda \
  --sort-by=.metadata.creationTimestamp
```

---

# Validar logs pods

```bash id="054b5u"
kubectl logs -n tienda POD_NAME
```

---

# Arquitectura resiliente

```text id="gcjak0"
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

```text id="09460j"
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

```text id="l81l61"
Validaciones finales y observabilidad
```

incluyendo:

* K9s
* CloudWatch
* monitoreo
* métricas

---
