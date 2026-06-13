# Reporte de Evidencia: Publicación en GitHub y Despliegue en Kubernetes

**Fecha:** 2026-06-13 17:21:42
**Etapa:** etapa08-DespliegaK8s

---

## Resumen


**AWS Account ID:** `461663648686`  
**Región:** `us-east-1`  
**Namespace Kubernetes:** `alumnos`


---

### Paso 1: Imágenes disponibles en ECR

**IE Relacionado:** IE2
**Hora ejecución:** 2026-06-13 17:26:30

```
$ for repo in alumnos-db alumnos-backend alumnos-frontend; do echo '---'; echo $repo; aws ecr describe-images --repository-name $repo --region us-east-1 --query 'imageDetails[*].imageTags' --output table 2>/dev/null; done

---
alumnos-db
----------------------
|   DescribeImages   |
+---------+----------+
|  v1.3.0 |  latest  |
+---------+----------+
---
alumnos-backend
----------------------
|   DescribeImages   |
+---------+----------+
|  v1.3.0 |  latest  |
+---------+----------+
---
alumnos-frontend
----------------------
|   DescribeImages   |
+---------+----------+
|  v1.3.0 |  latest  |
+---------+----------+
```

**Estado:** ✅ Completado


---

### Paso 2: Pods desplegados en namespace alumnos

**IE Relacionado:** IE2
**Hora ejecución:** 2026-06-13 17:27:38

```
$ kubectl get pods -n alumnos -o wide

NAME                                READY   STATUS    RESTARTS   AGE     IP            NODE                          NOMINATED NODE   READINESS GATES
alumnos-backend-6c6566dd55-z4np5    1/1     Running   0          3m9s    10.0.12.147   ip-10-0-12-180.ec2.internal   <none>           <none>
alumnos-db-dfd59ccdf-bcbvv          1/1     Running   0          4m32s   10.0.12.13    ip-10-0-12-180.ec2.internal   <none>           <none>
alumnos-frontend-68c9467575-j2bkz   1/1     Running   0          60s     10.0.12.157   ip-10-0-12-180.ec2.internal   <none>           <none>
alumnos-frontend-68c9467575-kkntn   1/1     Running   0          60s     10.0.12.43    ip-10-0-12-180.ec2.internal   <none>           <none>
```

**Estado:** ✅ Completado


---

### Paso 3: Services en namespace alumnos

**IE Relacionado:** IE2
**Hora ejecución:** 2026-06-13 17:27:40

```
$ kubectl get svc -n alumnos

NAME               TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)        AGE
alumnos-backend    ClusterIP      172.20.68.114    <none>                                                                   8080/TCP       3m12s
alumnos-db         ClusterIP      172.20.13.102    <none>                                                                   5432/TCP       4m34s
alumnos-frontend   LoadBalancer   172.20.228.213   a9e4b2153d2df4f1eb03e40f1032ce71-223483394.us-east-1.elb.amazonaws.com   80:30174/TCP   63s
```

**Estado:** ✅ Completado


---

### Paso 4: HPA configurados

**IE Relacionado:** IE3
**Hora ejecución:** 2026-06-13 17:27:42

```
$ kubectl get hpa -n alumnos 2>/dev/null || echo '(sin HPAs configurados)'

NAME                   REFERENCE                     TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
alumnos-backend-hpa    Deployment/alumnos-backend    cpu: 5%/70%   1         10        1          3m13s
alumnos-frontend-hpa   Deployment/alumnos-frontend   cpu: 2%/60%   2         6         2          64s
```

**Estado:** ✅ Completado


---

### Paso 5: Deployments activos

**IE Relacionado:** IE2
**Hora ejecución:** 2026-06-13 17:27:44

```
$ kubectl get deployment -n alumnos

NAME               READY   UP-TO-DATE   AVAILABLE   AGE
alumnos-backend    1/1     1            1           3m17s
alumnos-db         1/1     1            1           4m40s
alumnos-frontend   2/2     2            2           68s
```

**Estado:** ✅ Completado


---

## Resumen final

- **Inicio ejecución:** 2026-06-13 17:21:42
- **Fin ejecución:** 2026-06-13 17:27:46
- **Total pasos ejecutados:** 5

### ⏱️ Línea de tiempo de la etapa

| Evento | Hora |
|---|---|
| **Inicio** | 2026-06-13 17:21:42 |
| **Fin** | 2026-06-13 17:27:46 |
| **Duración total** | 6m 4s |

<!-- ================================================== -->
<!-- Fin del reporte de evidencia                       -->
<!-- ================================================== -->
