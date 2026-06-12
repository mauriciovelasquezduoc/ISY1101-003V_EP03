# Reporte de Evidencia: Creación de Cluster EKS y conexión kubectl

**Fecha:** 2026-06-11 13:30:42
**Etapa:** etapa04-CreaClusterEKS

---

## Resumen


**Parámetros del clúster:**  
- **Cluster:** `laboratorio-eks`
- **VPC:** `vpc-0e0bde9b896e27970`
- **Subnets Públicas:** `subnet-03ed152fa05c8b4da`, `subnet-025b1820365ef31e5`
- **Subnets Privadas App:** `subnet-031653e7200b5ffad`, `subnet-0ad54fb089b0b1d8f`
- **Cluster Role:** `arn:aws:iam::461663648686:role/c213284a5393391l15462824t1w461663-LabEksClusterRole-6kkLQWk5dCOf`
- **Node Role:** `arn:aws:iam::461663648686:role/c213284a5393391l15462824t1w461663648-LabEksNodeRole-qer5VPtPBg9Y`
- **Región:** `us-east-1`
- **Template:** `../../bloque02-clusterKubernetes/paso03_eks/fase_4_cluster_eks.yaml`


---

### Paso 1: Estado del cluster EKS

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-11 13:30:59

```
$ aws eks describe-cluster --name laboratorio-eks --region us-east-1 --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint,Role:roleArn}' --output table

-----------------------------------------------------------------------------------------------------------------
|                                                DescribeCluster                                                |
+----------+----------------------------------------------------------------------------------------------------+
|  Endpoint|  https://7C20BC5BD4377B9655DFED85B3CE99F3.gr7.us-east-1.eks.amazonaws.com                          |
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
**Hora ejecución:** 2026-06-11 13:31:01

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
**Hora ejecución:** 2026-06-11 13:31:03

```
$ kubectl get namespaces

NAME              STATUS   AGE
default           Active   37h
kube-node-lease   Active   37h
kube-public       Active   37h
kube-system       Active   37h
```


---

### Paso 4: Pods del sistema (kube-system)

**IE Relacionado:** IE2
**Hora ejecución:** 2026-06-11 13:31:05

```
$ kubectl get pods -n kube-system

NAME                              READY   STATUS    RESTARTS   AGE
aws-node-nqw7c                    2/2     Running   0          30h
coredns-55b4f5c59c-47kj2          1/1     Running   0          30h
coredns-55b4f5c59c-9rkwt          1/1     Running   0          30h
kube-proxy-gp4hf                  1/1     Running   0          30h
metrics-server-68db5bc85f-bc9j6   1/1     Running   0          30h
metrics-server-68db5bc85f-ttx5m   1/1     Running   0          30h
```


---

## Resumen final

- **Inicio ejecución:** 2026-06-11 13:30:42
- **Fin ejecución:** 2026-06-11 13:31:07
- **Total pasos ejecutados:** 4

### ⏱️ Línea de tiempo de la etapa

| Evento | Hora |
|---|---|
| **Inicio** | 2026-06-11 13:30:42 |
| **Fin** | 2026-06-11 13:31:07 |
| **Duración total** | 25s |

<!-- ================================================== -->
<!-- Fin del reporte de evidencia                       -->
<!-- ================================================== -->
