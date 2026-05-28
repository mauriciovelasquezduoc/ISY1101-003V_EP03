# PASO 11 — Stress Test y validación de Auto Scaling

## Objetivo

Generar carga sobre la aplicación desplegada en Amazon EKS para validar el funcionamiento de Horizontal Pod Autoscaler (HPA).

Durante esta etapa se provocará:

* aumento de CPU
* incremento de tráfico HTTP
* crecimiento automático de pods Kubernetes

---

# ¿Qué es un Stress Test?

Un Stress Test consiste en someter una aplicación a carga elevada para observar su comportamiento bajo presión.

En Kubernetes esto permite validar:

| Validación    | Resultado esperado      |
| -------------- | ----------------------- |
| HPA            | escala pods             |
| Metrics Server | entrega métricas       |
| Deployments    | crean replicas          |
| Scheduler      | distribuye carga        |
| EKS            | mantiene disponibilidad |

---

# Arquitectura validada

```text
Usuarios / Requests
        ↓
Frontend
        ↓
Backend
        ↓
HPA detecta CPU alta
        ↓
Kubernetes crea más Pods
```

---

# Objetivo específico del laboratorio

En este laboratorio:

* se generará tráfico HTTP continuo
* se aumentará CPU del backend
* HPA deberá crear nuevas replicas automáticamente

---

# ¿Cómo se realizará?

Se utilizará un script Node.js:

```text
stress-test.js
```

el cual:

* ejecutará múltiples requests HTTP simultáneos
* consumirá continuamente el backend/frontend
* generará carga sostenida

---

# Flujo esperado

## Estado inicial

```text
backend replicas = 2
```

---

## Durante Stress Test

```text
backend replicas = 3 → 4 → 5
```

---

## Después del Stress Test

```text
backend replicas = 2
```

---

# Validaciones importantes

## Ver pods

```bash
kubectl get pods -n tienda -w
```

---

# Ver HPA

```bash
kubectl get hpa -n tienda -w
```

---

# Ver métricas pods

```bash
kubectl top pods -n tienda
```

---

# Ver deployments

```bash
kubectl get deployment -n tienda
```

---

# Requisitos previos

Antes de ejecutar el stress test debe existir:

| Requisito      | Estado |
| -------------- | ------ |
| EKS            | ✅     |
| Frontend       | ✅     |
| Backend        | ✅     |
| MySQL          | ✅     |
| Metrics Server | ✅     |
| HPA            | ✅     |
| LoadBalancer   | ✅     |

---

# Estructura esperada

```text
paso11_stress_test/
├── README.md
└── stress-test.js
```

---

# Navegar a la carpeta

```bash
cd ~/0000000/guia2/paso11_stress_test
```

---

# Validar Node.js

```bash
node --version
```

---

# Ejecutar Stress Test

## Contra Frontend

```bash
node stress-test.js http://LOADBALANCER_URL
```

---

# Ejemplo

```bash
node stress-test.js http://a1b2c3d4.elb.amazonaws.com
```

---

# Resultado esperado

El script comenzará a generar:

* requests concurrentes
* tráfico HTTP continuo
* carga CPU

---

# Monitoreo recomendado

Abrir otra terminal:

## Ver pods

```bash
kubectl get pods -n tienda -w
```

---

# Ver HPA

```bash
kubectl get hpa -n tienda -w
```

---

# Ver métricas CPU

```bash
kubectl top pods -n tienda
```

---

# Resultado esperado HPA

```text
CURRENT CPU:
40% → 60% → 80%
```

---

# Resultado esperado Pods

```text
2 pods → 3 pods → 4 pods
```

---

# ¿Qué valida esta etapa?

| Componente           | Validado |
| -------------------- | -------- |
| HPA                  | ✅       |
| Metrics Server       | ✅       |
| Kubernetes Scheduler | ✅       |
| ReplicaSet           | ✅       |
| Deployments          | ✅       |
| Auto Scaling         | ✅       |
| Elasticidad Cloud    | ✅       |

---

# Arquitectura Cloud Native

```text
Stress Test
      ↓
Frontend
      ↓
Backend
      ↓
HPA
      ↓
Auto Scaling Kubernetes
```

---

# Finalizar prueba

Presionar:

```text
CTRL + C
```

---

# Resultado final esperado

Al finalizar correctamente:

* Kubernetes habrá escalado pods automáticamente
* el cluster habrá respondido a carga
* HPA quedará validado funcionalmente
* EKS demostrará elasticidad automática

---

# Siguiente paso

Luego continuará:

```text
Auto-Healing Kubernetes
```

donde se validará:

* recuperación automática
* recreación pods
* resiliencia Kubernetes

# Parar la prueba

Abrir otra terminal y ejecutar docker

cd paso00_dockerLinux
docker run -it -v "..":/root/work -v ~/.aws:/root/.aws  -v /var/run/docker.sock:/var/run/docker.sock devops-eks-lab


## Vuelve a configurar kubeconfig:

```
aws eks update-kubeconfig \
  --region us-east-1 \
  --name laboratorio-eks
```

# Luego valida:

```
kubectl get nodes
```

# Y recién después:

```
kubectl delete pod hpa-test -n tienda
```




---
