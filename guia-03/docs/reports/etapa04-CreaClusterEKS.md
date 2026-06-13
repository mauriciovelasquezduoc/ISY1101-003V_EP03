# Reporte de Evidencia: Creación de Cluster EKS y conexión kubectl

**Fecha:** 2026-06-13 15:57:00
**Etapa:** etapa04-CreaClusterEKS

---

## Resumen


**Parámetros del clúster:**  
- **Cluster:** `laboratorio-eks`
- **VPC:** `vpc-040dcd476deec12ed`
- **Subnets Públicas:** `subnet-0f86e23b9f3969288`, `subnet-0240dea3a5e912dfb`
- **Subnets Privadas App:** `subnet-0dbc6460b11a415a4`, `subnet-04990711edfb8419c`
- **Cluster Role:** `arn:aws:iam::461663648686:role/c213284a5393391l15462824t1w461663-LabEksClusterRole-6kkLQWk5dCOf`
- **Node Role:** `arn:aws:iam::461663648686:role/c213284a5393391l15462824t1w461663648-LabEksNodeRole-qer5VPtPBg9Y`
- **Región:** `us-east-1`
- **Template:** `../../bloque02-clusterKubernetes/paso03_eks/fase_4_cluster_eks.yaml`


---

### Paso 1: Estado del cluster EKS

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 16:24:01

```
$ aws eks describe-cluster --name laboratorio-eks --region us-east-1 --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint,Role:roleArn}' --output table

-----------------------------------------------------------------------------------------------------------------
|                                                DescribeCluster                                                |
+----------+----------------------------------------------------------------------------------------------------+
|  Endpoint|  https://90138C64322EC9259A6FD67DA1697589.gr7.us-east-1.eks.amazonaws.com                          |
|  Name    |  laboratorio-eks                                                                                   |
|  Role    |  arn:aws:iam::461663648686:role/c213284a5393391l15462824t1w461663-LabEksClusterRole-6kkLQWk5dCOf   |
|  Status  |  ACTIVE                                                                                            |
|  Version |  1.33                                                                                              |
+----------+----------------------------------------------------------------------------------------------------+
```

**Estado:** ✅ Completado


---

### Paso 2: Addons EKS instalados

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 16:24:03

```
$ aws eks list-addons --cluster-name laboratorio-eks --region us-east-1 --output table

----------------------
|     ListAddons     |
+--------------------+
||      addons      ||
|+------------------+|
||  coredns         ||
||  kube-proxy      ||
||  metrics-server  ||
||  vpc-cni         ||
|+------------------+|
```

**Estado:** ✅ Completado


---

### Paso 3: Namespaces de Kubernetes

**IE Relacionado:** IE2
**Hora ejecución:** 2026-06-13 16:24:06

```
$ kubectl get namespaces

NAME              STATUS   AGE
default           Active   6m35s
kube-node-lease   Active   6m35s
kube-public       Active   6m35s
kube-system       Active   6m35s
```


---

### Paso 4: Pods del sistema (kube-system)

**IE Relacionado:** IE2
**Hora ejecución:** 2026-06-13 16:24:09

```
$ kubectl get pods -n kube-system

NAME                              READY   STATUS    RESTARTS   AGE
aws-node-zxpp9                    2/2     Running   0          79s
coredns-55b4f5c59c-6sgcp          1/1     Running   0          4m57s
coredns-55b4f5c59c-vltkz          1/1     Running   0          4m57s
kube-proxy-gjcfw                  1/1     Running   0          79s
metrics-server-68db5bc85f-bq4vc   1/1     Running   0          2m18s
metrics-server-68db5bc85f-bwnsx   1/1     Running   0          2m18s
```


---

## Resumen final

- **Inicio ejecución:** 2026-06-13 15:57:00
- **Fin ejecución:** 2026-06-13 16:24:11
- **Total pasos ejecutados:** 4

### ⏱️ Línea de tiempo de la etapa

| Evento | Hora |
|---|---|
| **Inicio** | 2026-06-13 15:57:00 |
| **Fin** | 2026-06-13 16:24:11 |
| **Duración total** | 27m 11s |

<!-- ================================================== -->
<!-- Fin del reporte de evidencia                       -->
<!-- ================================================== -->
