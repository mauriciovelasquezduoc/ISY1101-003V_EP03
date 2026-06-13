# Reporte de Evidencia: Validación/Creación de NodeGroup SPOT

**Fecha:** 2026-06-13 16:36:01
**Etapa:** etapa05-CreaNodeGroup

---

## Resumen


---

### Paso 1: Detalle del NodeGroup

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 16:36:05

```
$ aws eks describe-nodegroup --cluster-name laboratorio-eks --nodegroup-name laboratorio-nodegroup --region us-east-1 --query 'nodegroup.{Name:nodegroupName,Status:status,InstanceType:instanceTypes[0],Capacity:capacityType,ScalingMin:scalingConfig.minSize,ScalingMax:scalingConfig.maxSize,ScalingDesired:scalingConfig.desiredSize,Subnets:subnets[0]}' --output table

------------------------------------------------
|               DescribeNodegroup              |
+-----------------+----------------------------+
|  Capacity       |  SPOT                      |
|  InstanceType   |  t3.large                  |
|  Name           |  laboratorio-nodegroup     |
|  ScalingDesired |  1                         |
|  ScalingMax     |  3                         |
|  ScalingMin     |  1                         |
|  Status         |  ACTIVE                    |
|  Subnets        |  subnet-0dbc6460b11a415a4  |
+-----------------+----------------------------+
```

**Estado:** ✅ Completado


---

### Paso 2: Nodos Kubernetes Ready

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 16:36:07

```
$ kubectl get nodes -o wide

NAME                          STATUS   ROLES    AGE   VERSION                INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                    CONTAINER-RUNTIME
ip-10-0-12-180.ec2.internal   Ready    <none>   13m   v1.33.11-eks-3385e9b   10.0.12.180   <none>        Amazon Linux 2023.11.20260526   6.12.88-119.157.amzn2023.x86_64   containerd://2.2.3+unknown
```

**Estado:** ✅ Completado


---

### Paso 3: Pods del sistema saludables

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 16:36:09

```
$ kubectl get pods -n kube-system -o wide

NAME                              READY   STATUS    RESTARTS   AGE   IP            NODE                          NOMINATED NODE   READINESS GATES
aws-node-zxpp9                    2/2     Running   0          13m   10.0.12.180   ip-10-0-12-180.ec2.internal   <none>           <none>
coredns-55b4f5c59c-6sgcp          1/1     Running   0          16m   10.0.12.199   ip-10-0-12-180.ec2.internal   <none>           <none>
coredns-55b4f5c59c-vltkz          1/1     Running   0          16m   10.0.12.253   ip-10-0-12-180.ec2.internal   <none>           <none>
kube-proxy-gjcfw                  1/1     Running   0          13m   10.0.12.180   ip-10-0-12-180.ec2.internal   <none>           <none>
metrics-server-68db5bc85f-bq4vc   1/1     Running   0          14m   10.0.12.42    ip-10-0-12-180.ec2.internal   <none>           <none>
metrics-server-68db5bc85f-bwnsx   1/1     Running   0          14m   10.0.12.184   ip-10-0-12-180.ec2.internal   <none>           <none>
```

**Estado:** ✅ Completado


---

## Resumen final

- **Inicio ejecución:** 2026-06-13 16:36:01
- **Fin ejecución:** 2026-06-13 16:36:11
- **Total pasos ejecutados:** 3

### ⏱️ Línea de tiempo de la etapa

| Evento | Hora |
|---|---|
| **Inicio** | 2026-06-13 16:36:01 |
| **Fin** | 2026-06-13 16:36:11 |
| **Duración total** | 10s |

<!-- ================================================== -->
<!-- Fin del reporte de evidencia                       -->
<!-- ================================================== -->
