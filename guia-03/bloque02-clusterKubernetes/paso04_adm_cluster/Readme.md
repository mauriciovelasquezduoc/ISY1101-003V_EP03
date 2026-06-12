# PASO 4 — Conectar kubectl a Amazon EKS

## Objetivo

Configurar `kubectl` para conectarse al cluster Amazon EKS y administrar Kubernetes desde línea de comandos.

Esto permitirá:

* desplegar aplicaciones
* administrar pods
* crear deployments
* crear services
* revisar logs
* escalar aplicaciones
* administrar namespaces
* utilizar HPA



## Ejecutar

```
bash configurar-validar.sh 
```


---

# ¿Qué es kubectl?

`kubectl` es la herramienta oficial de administración de Kubernetes.

Con ella es posible:

| Acción              | Ejemplo           |
| -------------------- | ----------------- |
| Ver nodos            | kubectl get nodes |
| Ver pods             | kubectl get pods  |
| Crear deployments    | kubectl apply -f  |
| Ver logs             | kubectl logs      |
| Escalar aplicaciones | kubectl scale     |
| Eliminar recursos    | kubectl delete    |

---

# ¿Qué hace este paso?

Este paso conecta:

```text
kubectl
    ↓
AWS CLI
    ↓
Amazon EKS API
    ↓
Kubernetes API Server
```

---

# Requisitos previos

Antes de continuar debe existir:

* AWS CLI configurado
* kubectl instalado
* Cluster EKS ACTIVE
* NodeGroup ACTIVE
* Credenciales AWS válidas

---

# Validar credenciales AWS

```bash
aws sts get-caller-identity
```

---

# Resultado esperado

Debe mostrar:

* Account
* Arn
* UserId

---

# Validar cluster EKS

```bash
aws eks list-clusters \
  --region us-east-1
```

---

# Resultado esperado

```text
laboratorio-eks
```

---

# Configurar kubeconfig

## Comando principal

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name laboratorio-eks
```

---

# ¿Qué hace este comando?

AWS CLI:

* obtiene endpoint Kubernetes
* obtiene certificado cluster
* genera kubeconfig
* configura autenticación IAM
* conecta kubectl al cluster

---

# Resultado esperado

```text
Updated context arn:aws:eks:...
```

---

# Archivo kubeconfig

La configuración se almacena en:

```text
/root/.kube/config
```

o:

```text
~/.kube/config
```

---

# Ver contextos Kubernetes

```bash
kubectl config get-contexts
```

---

# Resultado esperado

Debe aparecer:

```text
laboratorio-eks
```

---

# Ver contexto actual

```bash
kubectl config current-context
```

---

# Validar conexión Kubernetes

## Ver nodos

```bash
kubectl get nodes -o wide
```

---

# Resultado esperado

```text
STATUS = Ready
```

---

# Ver namespaces

```bash
kubectl get namespaces
```

---

# Ver pods sistema

```bash
kubectl get pods -n kube-system
```

---

# Pods importantes esperados

| Pod            | Función       |
| -------------- | -------------- |
| aws-node       | Networking CNI |
| coredns        | DNS Kubernetes |
| kube-proxy     | Networking     |
| metrics-server | Métricas HPA  |

---

# Validar métricas

```bash
kubectl top nodes
```

---

# Resultado esperado

Uso CPU y memoria de nodos.

---

# Probar comunicación Kubernetes

## Crear namespace prueba

```bash
kubectl create namespace laboratorio
```

---

# Ver namespace

```bash
kubectl get namespaces
```

---

# Eliminar namespace prueba

```bash
kubectl delete namespace laboratorio
```

---

# Resultado esperado final

Al finalizar correctamente:

* kubectl quedará conectado al cluster.
* Kubernetes responderá correctamente.
* Los nodos estarán visibles.
* kube-system estará operativo.
* El cluster estará listo para despliegues.

---

# Seguridad importante

La autenticación se realiza mediante:

```text
AWS IAM + kubeconfig
```

NO mediante usuario/password Kubernetes.

---

# Arquitectura validada

Este paso valida correctamente:

* API Server EKS
* IAM Authentication
* Networking cluster
* Worker Nodes
* DNS Kubernetes
* kubectl connectivity

---

# Siguiente paso

Luego continuará:

```text
Paso 05 — Crear NodeGroup
```

* worker nodes EC2
* NodeGroup SPOT
* validar nodos Ready
* preparar cluster para aplicaciones

---
