# Reporte de Evidencia: Validación de Metrics Server y CloudWatch

**Fecha:** 2026-06-13 16:36:16
**Etapa:** etapa06-ValidaObservabilidad

---

## Resumen


---

### Paso 1: Metrics Server - Pods en kube-system

**IE Relacionado:** IE3
**Hora ejecución:** 2026-06-13 16:36:16

```
$ kubectl get pods -n kube-system | grep metrics || echo '(metrics-server puede estar integrándose como addon)'

metrics-server-68db5bc85f-bq4vc   1/1     Running   0          14m
metrics-server-68db5bc85f-bwnsx   1/1     Running   0          14m
```

**Estado:** ✅ Completado


---

### Paso 2: Metrics Server - API disponible

**IE Relacionado:** IE3
**Hora ejecución:** 2026-06-13 16:36:18

```
$ kubectl get apiservices | grep metrics || echo '(revisando...)'

v1.metrics.eks.amazonaws.com      kube-system/eks-extension-metrics-api   True        18m
v1beta1.metrics.k8s.io            kube-system/metrics-server              True        14m
```

**Estado:** ✅ Completado


---

### Paso 3: Métricas de nodos (kubectl top)

**IE Relacionado:** IE3
**Hora ejecución:** 2026-06-13 16:36:20

```
$ kubectl top nodes 2>/dev/null || echo '(puede tardar unos segundos en aparecer)'

NAME                          CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
ip-10-0-12-180.ec2.internal   28m          1%       462Mi           6%          
```

**Estado:** ✅ Completado


---

### Paso 4: Métricas de pods (kubectl top)

**IE Relacionado:** IE3
**Hora ejecución:** 2026-06-13 16:36:23

```
$ kubectl top pods -A 2>/dev/null || echo '(puede tardar unos segundos)'

NAMESPACE     NAME                              CPU(cores)   MEMORY(bytes)   
kube-system   aws-node-zxpp9                    3m           54Mi            
kube-system   coredns-55b4f5c59c-6sgcp          2m           11Mi            
kube-system   coredns-55b4f5c59c-vltkz          2m           11Mi            
kube-system   kube-proxy-gjcfw                  1m           12Mi            
kube-system   metrics-server-68db5bc85f-bq4vc   3m           16Mi            
kube-system   metrics-server-68db5bc85f-bwnsx   3m           16Mi            
```

**Estado:** ✅ Completado


---

### Paso 5: VPC Endpoint CloudWatch

**IE Relacionado:** IE6
**Hora ejecución:** 2026-06-13 16:36:25

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
**Hora ejecución:** 2026-06-13 16:36:27

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
**Hora ejecución:** 2026-06-13 16:36:29

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

- **Inicio ejecución:** 2026-06-13 16:36:16
- **Fin ejecución:** 2026-06-13 16:36:31
- **Total pasos ejecutados:** 7

### ⏱️ Línea de tiempo de la etapa

| Evento | Hora |
|---|---|
| **Inicio** | 2026-06-13 16:36:16 |
| **Fin** | 2026-06-13 16:36:31 |
| **Duración total** | 15s |

<!-- ================================================== -->
<!-- Fin del reporte de evidencia                       -->
<!-- ================================================== -->
