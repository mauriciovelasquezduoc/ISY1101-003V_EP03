# PASO 1 — Validar permisos IAM y entorno AWS/EKS

## Objetivo

Antes de crear un clúster Amazon EKS es necesario validar que el entorno local y las credenciales AWS estén correctamente configuradas.

Este paso permite verificar:

* Acceso válido a AWS mediante AWS CLI.
* Existencia de los roles IAM requeridos para EKS.
* Disponibilidad de herramientas necesarias como `kubectl` y `docker`.
* Correcta autenticación contra la cuenta AWS utilizada en el laboratorio.

---

# ¿Por qué es importante este paso?

Amazon EKS requiere permisos IAM específicos para:

* Crear el Control Plane del clúster.
* Administrar Node Groups.
* Permitir que los nodos EC2 se unan al clúster.
* Gestionar networking, Load Balancers y métricas.

Si los roles IAM o credenciales son incorrectos:

* El clúster EKS no podrá crearse.
* Los Node Groups fallarán.
* Kubernetes no podrá desplegar pods correctamente.
* Los servicios tipo LoadBalancer no funcionarán.

Por esta razón, validar el entorno antes de continuar evita errores posteriores difíciles de diagnosticar.

---

# Roles IAM requeridos

El laboratorio requiere validar la existencia de los siguientes roles:

| Role              | Uso                              |
| ----------------- | -------------------------------- |
| LabEKSClusterRole | Permisos del Control Plane EKS   |
| LabEKSNodeRole    | Permisos de los nodos EC2 worker |

---

# Herramientas requeridas

| Herramienta | Uso                        |
| ----------- | -------------------------- |
| AWS CLI     | Administración AWS        |
| kubectl     | Administración Kubernetes |
| Docker      | Construcción de imágenes |
| jq          | Procesamiento JSON         |

---

# Validaciones a realizar

## 1. Validar AWS CLI

```bash
aws --version
```

Resultado esperado:

```text
aws-cli/2.x.x
```

---

## 2. Validar kubectl

```bash
kubectl version --client
```

Resultado esperado:

```text
Client Version: v1.xx.x
```

---

## 3. Validar credenciales AWS

```bash
aws sts get-caller-identity
```

Resultado esperado:

```json
{
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/lab-user",
  "UserId": "XXXXXXXX"
}
```

Esta validación confirma:

* Credenciales válidas.
* Acceso correcto a AWS.
* Región y sesión configuradas correctamente.

---

## 4. Validar Role IAM del clúster

```bash
aws iam list-roles \
  --query "Roles[?contains(RoleName, 'LabEksClusterRole')].Arn" \
  --output text
```

Resultado esperado:

```text
RoleName: LabEKSClusterRole
```

---

## 5. Validar Role IAM de nodos

```bash
aws iam list-roles \
  --query "Roles[?contains(RoleName, 'LabEks')].[RoleName,Arn]" \
  --output table
```

Resultado esperado:

```text
RoleName: LabEKSNodeRole
```

---

# Script de validación automatizada

Archivo:

```text
01-validate-prereqs.sh
```

Dar permisos:

```bash
chmod +x 01-validate-prereqs.sh
```

Ejecutar:

```bash
./01-validate-prereqs.sh
```

---

# Resultado esperado

Si todas las validaciones son correctas, el entorno estará listo para continuar con:

* Creación del clúster EKS.
* Creación de Node Groups.
* Conexión mediante kubectl.
* Despliegue de aplicaciones Kubernetes.

---
