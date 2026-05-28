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



# l HPA ya estaba configurado

Porque cuando desplegaste:

<pre class="overflow-visible! px-0!" data-start="122" data-end="168"><div class="relative w-full mt-4 mb-1"><div class=""><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-token-bg-elevated-secondary corner-superellipse/1.1 overflow-clip rounded-3xl lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>backend-hpa.yaml</span><br/><span>frontend-hpa.yaml</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></pre>

ya ejecutaste realmente:

<pre class="overflow-visible! px-0!" data-start="196" data-end="276"><div class="relative w-full mt-4 mb-1"><div class=""><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-token-bg-elevated-secondary corner-superellipse/1.1 overflow-clip rounded-3xl lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>kubectl apply </span><span class="ͼn">-f</span><span> backend-hpa.yaml</span><br/><span>kubectl apply </span><span class="ͼn">-f</span><span> frontend-hpa.yaml</span></code></pre></div></div></div></div></div></div></div></div></div></div></div></div></pre>


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
kubectl get hpa -n tienda
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
kubectl describe hpa -n tienda
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
kubectl top pods -n tienda
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
MySQL
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
