# Reporte de Evidencia: Validación de Metrics Server y CloudWatch

**Fecha:** 2026-06-11 13:32:04
**Etapa:** etapa06-ValidaObservabilidad

---

## Resumen


---

### Paso 1: Metrics Server - Pods en kube-system

**IE Relacionado:** IE3
**Hora ejecución:** 2026-06-11 13:32:04

```
$ kubectl get pods -n kube-system | grep metrics || echo '(metrics-server puede estar integrándose como addon)'

metrics-server-68db5bc85f-bc9j6   1/1     Running   0          30h
metrics-server-68db5bc85f-ttx5m   1/1     Running   0          30h
```

**Estado:** ✅ Completado


---

### Paso 2: Metrics Server - API disponible

**IE Relacionado:** IE3
**Hora ejecución:** 2026-06-11 13:32:06

```
$ kubectl get apiservices | grep metrics || echo '(revisando...)'

v1.metrics.eks.amazonaws.com      kube-system/eks-extension-metrics-api   True        37h
v1beta1.metrics.k8s.io            kube-system/metrics-server              True        37h
```

**Estado:** ✅ Completado


---

### Paso 3: Métricas de nodos (kubectl top)

**IE Relacionado:** IE3
**Hora ejecución:** 2026-06-11 13:32:08

```
$ kubectl top nodes 2>/dev/null || echo '(puede tardar unos segundos en aparecer)'

NAME                         CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
ip-10-0-12-36.ec2.internal   40m          2%       543Mi           7%          
```

**Estado:** ✅ Completado


---

### Paso 4: Métricas de pods (kubectl top)

**IE Relacionado:** IE3
**Hora ejecución:** 2026-06-11 13:32:10

```
$ kubectl top pods -A 2>/dev/null || echo '(puede tardar unos segundos)'

NAMESPACE     NAME                              CPU(cores)   MEMORY(bytes)   
kube-system   aws-node-nqw7c                    2m           56Mi            
kube-system   coredns-55b4f5c59c-47kj2          2m           12Mi            
kube-system   coredns-55b4f5c59c-9rkwt          2m           12Mi            
kube-system   kube-proxy-gp4hf                  1m           12Mi            
kube-system   metrics-server-68db5bc85f-bc9j6   3m           18Mi            
kube-system   metrics-server-68db5bc85f-ttx5m   4m           18Mi            
```

**Estado:** ✅ Completado


---

### Paso 5: VPC Endpoint CloudWatch

**IE Relacionado:** IE6
**Hora ejecución:** 2026-06-11 13:32:12

```
$ aws ec2 describe-vpc-endpoints --region us-east-1 --query 'VpcEndpoints[?contains(ServiceName, `logs`)].{Service:ServiceName,State:State}' --output table

-----------------------------------------------
|            DescribeVpcEndpoints             |
+-------------------------------+-------------+
|            Service            |    State    |
+-------------------------------+-------------+
|  com.amazonaws.us-east-1.logs |  available  |
+-------------------------------+-------------+
```

**Estado:** ✅ Completado


---

### Paso 6: Logging del cluster EKS habilitado

**IE Relacionado:** IE6
**Hora ejecución:** 2026-06-11 13:32:14

```
$ aws eks describe-cluster --name laboratorio-eks --region us-east-1 --query 'cluster.logging' --output json

{
    "clusterLogging": [
        {
            "types": [
                "api",
                "audit",
                "authenticator",
                "controllerManager",
                "scheduler"
            ],
            "enabled": true
        }
    ]
}
```

**Estado:** ✅ Completado


---

### Paso 7: Log Groups en CloudWatch

**IE Relacionado:** IE6
**Hora ejecución:** 2026-06-11 13:32:16

```
$ aws logs describe-log-groups --region us-east-1 --query 'logGroups[?contains(logGroupName, `eks`)].logGroupName' --output table 2>/dev/null || echo '(puede tardar en aparecer)'

--------------------------------------
|          DescribeLogGroups         |
+------------------------------------+
|  /aws/eks/laboratorio-eks/cluster  |
+------------------------------------+
```

**Estado:** ✅ Completado


---

## Resumen final

- **Inicio ejecución:** 2026-06-11 13:32:04
- **Fin ejecución:** 2026-06-11 13:32:18
- **Total pasos ejecutados:** 7

### ⏱️ Línea de tiempo de la etapa

| Evento | Hora |
|---|---|
| **Inicio** | 2026-06-11 13:32:04 |
| **Fin** | 2026-06-11 13:32:18 |
| **Duración total** | 14s |

<!-- ================================================== -->
<!-- Fin del reporte de evidencia                       -->
<!-- ================================================== -->
