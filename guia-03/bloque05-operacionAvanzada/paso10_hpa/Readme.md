# PASO 10 — Horizontal Pod Autoscaler (HPA)

## Objetivo

Implementar y validar Horizontal Pod Autoscaler (HPA) en Amazon EKS para permitir el escalamiento automático de aplicaciones Kubernetes según carga de trabajo.

En este laboratorio el HPA se aplicará sobre:

* frontend
* backend

permitiendo que Kubernetes:

* aumente pods automáticamente
* reduzca pods automáticamente
* mantenga disponibilidad
* responda a demanda



# El HPA ya estaba configurado

Porque cuando desplegaste:

```
backend-hpa.yaml
frontend-hpa.yaml
```

ya ejecutaste realmente:

```
kubectl apply -f backend-hpa.yaml
kubectl apply -f frontend-hpa.yaml
```


---

# ¿Qué es HPA?

HPA (Horizontal Pod Autoscaler) es un componente Kubernetes encargado de escalar pods dinámicamente según métricas.

Principalmente:

| Métrica         | Uso         |
| ---------------- | ----------- |
| CPU              | más común |
| memoria          | opcional    |
| métricas custom | avanzado    |

---

# ¿Qué significa “Horizontal”?

Horizontal significa:

```text
más pods
```

NO:

* más CPU al pod
* más memoria al pod

Eso sería escalamiento vertical.

---

# Ejemplo

## Situación normal

```text
backend = 2 pods
```

---

## Alta carga CPU

```text
backend = 5 pods
```

---

## Baja carga

```text
backend = 2 pods
```

---

# Arquitectura HPA

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

# ¿Cómo funciona?

El HPA:

1. consulta métricas Kubernetes
2. revisa CPU/memoria
3. compara threshold configurado
4. aumenta o disminuye replicas

---

# Dependencias importantes

HPA requiere:

| Componente     | Estado |
| -------------- | ------ |
| Metrics Server | ✅     |
| kubectl        | ✅     |
| deployments    | ✅     |
| CPU requests   | ✅     |

---

# ¿Por qué Metrics Server era importante?

Porque HPA utiliza:

```text
metrics.k8s.io
```

para obtener:

* CPU pods
* memoria pods

---

# ¿Dónde está configurado?

En este laboratorio:

```text
frontend-hpa.yaml
backend-hpa.yaml
```

---

# Ejemplo conceptual HPA

```yaml
minReplicas: 2
maxReplicas: 5

targetCPUUtilizationPercentage: 70
```

---

# ¿Qué significa?

| Configuración | Significado            |
| -------------- | ---------------------- |
| minReplicas    | mínimo pods           |
| maxReplicas    | máximo pods           |
| 70% CPU        | threshold escalamiento |

---

# Comportamiento esperado

## CPU baja

```text
2 pods
```

---

## CPU alta

```text
3 → 4 → 5 pods
```

---

## CPU baja nuevamente

```text
5 → 4 → 3 → 2
```

---

# ¿Por qué es importante en cloud?

HPA permite:

| Beneficio           | Resultado |
| ------------------- | --------- |
| alta disponibilidad | ✅        |
| elasticidad         | ✅        |
| eficiencia costos   | ✅        |
| resiliencia         | ✅        |

---

# Arquitectura Cloud Native

```text
Internet
   ↓
Frontend
   ↓
Backend
   ↓
HPA
   ↓
Escalamiento automático
```

---

# Validar HPA existente

## Ver HPA

```bash
kubectl get hpa -n alumnos
```

---

# Resultado esperado

```text
frontend-hpa
backend-hpa
```

---

# Ver detalle HPA

```bash
kubectl describe hpa -n alumnos
```

---

# Resultado esperado

Debe mostrar:

* min replicas
* max replicas
* current replicas
* target CPU

---

# Validar métricas nodos

```bash
kubectl top nodes
```

---

# Validar métricas pods

```bash
kubectl top pods -n alumnos
```

---

# ¿Qué valida este paso?

| Validación    | Resultado |
| -------------- | --------- |
| Metrics API    | ✅        |
| CPU metrics    | ✅        |
| HPA controller | ✅        |
| autoscaling    | ✅        |
| resiliencia    | ✅        |

---

# Escenario esperado en el laboratorio

Durante pruebas de carga:

```text
Frontend recibe tráfico
        ↓
Backend aumenta CPU
        ↓
HPA detecta carga
        ↓
Kubernetes crea más pods
```

---

# Relación con CloudWatch

CloudWatch permite:

* observar métricas
* revisar escalamiento
* monitorear comportamiento cluster

---

# Escalamiento automático real

Este laboratorio implementa:

```text
Auto Scaling Kubernetes real
```

similar a producción cloud-native.

---

# Diferencia importante

## HPA escala pods

NO:

* EC2
* worker nodes

---

# ¿Quién escala nodos?

Eso sería:

```text
Cluster Autoscaler
```

que es otra tecnología distinta.

---

# Arquitectura completa final

```text
AWS ELB
    ↓
Frontend Pods
    ↓
Backend Pods
    ↓
PostgreSQL
```

con:

* HPA
* EKS
* ECR
* CloudWatch
* Metrics Server

---

# Resultado esperado final

Al finalizar correctamente:

* HPA estará operativo
* Kubernetes podrá autoescalar pods
* el cluster responderá dinámicamente a carga
* frontend/backend tendrán resiliencia automática

---

# Siguiente paso

Luego continuará:

```text
Pruebas de carga y validación HPA
```

y posteriormente:

* auto-healing
* observabilidad
* monitoreo cluster

---
