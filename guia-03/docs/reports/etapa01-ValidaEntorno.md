# Reporte de Evidencia: Validación de Entorno y Prerrequisitos

**Fecha:** 2026-06-13 15:38:58
**Etapa:** etapa01-ValidaEntorno

---

## Resumen


---

### Paso 1: Validar credenciales AWS

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 15:39:06

```
$ aws sts get-caller-identity

{
    "UserId": "AROAWW7KMHOXNBSPTY2BY:user5150418=_Student_View__Mauricio_Velasquez",
    "Account": "461663648686",
    "Arn": "arn:aws:sts::461663648686:assumed-role/voclabs/user5150418=_Student_View__Mauricio_Velasquez"
}
```

**Estado:** ✅ Completado


---

### Paso 2: Versión de herramientas

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 15:39:08

```
$ echo '--- AWS CLI ---'; aws --version; echo '--- kubectl ---'; kubectl version --client; echo '--- Docker ---'; docker --version

--- AWS CLI ---
aws-cli/2.34.61 Python/3.14.5 Linux/6.12.76-linuxkit exe/x86_64.ubuntu.24
--- kubectl ---
Client Version: v1.33.1
Kustomize Version: v5.6.0
--- Docker ---
Docker version 29.5.3, build d1c06ef
```

**Estado:** ✅ Completado


---

### Paso 3: Validar acceso IAM

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 15:39:10

```
$ aws iam list-roles --max-items 1 >/dev/null 2>&1 && echo 'OK: acceso IAM' || echo 'ERROR: sin permisos IAM'

OK: acceso IAM
```


---

### Paso 4: Buscar roles EKS del laboratorio

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 15:39:12

```
$ echo '--- LabEKSClusterRole ---'; aws iam list-roles --query "Roles[?contains(RoleName, 'LabEksClusterRole')].RoleName" --output table; echo '--- LabEKSNodeRole ---'; aws iam list-roles --query "Roles[?contains(RoleName, 'LabEksNodeRole')].RoleName" --output table

--- LabEKSClusterRole ---
----------------------------------------------------------------------
|                              ListRoles                             |
+--------------------------------------------------------------------+
|  c213284a5393391l15462824t1w461663-LabEksClusterRole-6kkLQWk5dCOf  |
+--------------------------------------------------------------------+
--- LabEKSNodeRole ---
----------------------------------------------------------------------
|                              ListRoles                             |
+--------------------------------------------------------------------+
|  c213284a5393391l15462824t1w461663648-LabEksNodeRole-qer5VPtPBg9Y  |
+--------------------------------------------------------------------+
```

**Estado:** ✅ Completado


---

### Paso 5: Validar acceso EKS

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 15:39:17

```
$ aws eks list-clusters --region us-east-1

{
    "clusters": []
}
```

**Estado:** ✅ Completado


---

## Resumen final

- **Inicio ejecución:** 2026-06-13 15:38:58
- **Fin ejecución:** 2026-06-13 15:39:19
- **Total pasos ejecutados:** 5

### ⏱️ Línea de tiempo de la etapa

| Evento | Hora |
|---|---|
| **Inicio** | 2026-06-13 15:38:58 |
| **Fin** | 2026-06-13 15:39:19 |
| **Duración total** | 21s |

<!-- ================================================== -->
<!-- Fin del reporte de evidencia                       -->
<!-- ================================================== -->
