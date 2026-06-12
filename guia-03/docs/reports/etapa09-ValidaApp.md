# Reporte de Evidencia: Validación final y operación avanzada (HPA, Healing, Métricas)

**Fecha:** 2026-06-11 23:46:54
**Etapa:** etapa09-ValidaApp

---

## Resumen


---

### Paso 1: Nodos del cluster

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-11 23:46:58

```
$ kubectl get nodes -o wide

NAME                            STATUS   ROLES    AGE     VERSION               INTERNAL-IP     EXTERNAL-IP      OS-IMAGE                        KERNEL-VERSION                    CONTAINER-RUNTIME
ip-172-31-37-22.ec2.internal    Ready    <none>   3h27m   v1.35.5-eks-3385e9b   172.31.37.22    18.212.109.159   Amazon Linux 2023.11.20260526   6.12.88-119.157.amzn2023.x86_64   containerd://2.2.3+unknown
ip-172-31-89-144.ec2.internal   Ready    <none>   3h25m   v1.35.5-eks-3385e9b   172.31.89.144   100.58.179.189   Amazon Linux 2023.11.20260526   6.12.88-119.157.amzn2023.x86_64   containerd://2.2.3+unknown
```

**Estado:** ✅ Completado


---

### Paso 2: Pods en namespace alumnos

**IE Relacionado:** IE2 + IE7
**Hora ejecución:** 2026-06-11 23:47:00

```
$ kubectl get pods -n alumnos -o wide

NAME                               READY   STATUS    RESTARTS        AGE     IP              NODE                            NOMINATED NODE   READINESS GATES
alumnos-backend-77d766d598-8gcs5   1/1     Running   0               6m14s   172.31.91.136   ip-172-31-89-144.ec2.internal   <none>           <none>
alumnos-db-c946c688d-lnl2p         1/1     Running   0               7m45s   172.31.93.108   ip-172-31-89-144.ec2.internal   <none>           <none>
alumnos-frontend-b868c47cf-9cdsc   1/1     Running   2 (6m46s ago)   6m47s   172.31.45.247   ip-172-31-37-22.ec2.internal    <none>           <none>
alumnos-frontend-b868c47cf-mzvgc   1/1     Running   2 (6m45s ago)   6m47s   172.31.88.111   ip-172-31-89-144.ec2.internal   <none>           <none>
```

**Estado:** ✅ Completado


---

### Paso 3: Services en alumnos

**IE Relacionado:** IE2
**Hora ejecución:** 2026-06-11 23:47:02

```
$ kubectl get svc -n alumnos

NAME               TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)        AGE
alumnos-backend    ClusterIP      10.100.121.232   <none>                                                                    8080/TCP       6m46s
alumnos-db         ClusterIP      10.100.149.12    <none>                                                                    5432/TCP       7m48s
alumnos-frontend   LoadBalancer   10.100.102.222   ae40432f35fb5417aa2141c7392bdd81-1478249194.us-east-1.elb.amazonaws.com   80:30187/TCP   6m52s
```

**Estado:** ✅ Completado


---

### Paso 4: HPA en alumnos

**IE Relacionado:** IE3
**Hora ejecución:** 2026-06-11 23:47:04

```
$ kubectl get hpa -n alumnos

NAME                   REFERENCE                     TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
alumnos-backend-hpa    Deployment/alumnos-backend    cpu: <unknown>/70%   1         10        1          6m42s
alumnos-frontend-hpa   Deployment/alumnos-frontend   cpu: <unknown>/60%   2         6         2          6m51s
```

**Estado:** ✅ Completado


---

### Paso 5: Deployments en alumnos

**IE Relacionado:** IE2
**Hora ejecución:** 2026-06-11 23:47:05

```
$ kubectl get deployment -n alumnos

NAME               READY   UP-TO-DATE   AVAILABLE   AGE
alumnos-backend    1/1     1            1           6m46s
alumnos-db         1/1     1            1           7m52s
alumnos-frontend   2/2     2            2           6m56s
```

**Estado:** ✅ Completado


---

### Paso 6: Endpoints

**IE Relacionado:** IE7
**Hora ejecución:** 2026-06-11 23:47:07

```
$ kubectl get endpoints -n alumnos

Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME               ENDPOINTS                           AGE
alumnos-backend    172.31.91.136:8080                  6m51s
alumnos-db         172.31.93.108:5432                  7m53s
alumnos-frontend   172.31.45.247:80,172.31.88.111:80   6m57s
```

**Estado:** ✅ Completado


---

### Paso 7: Pods del sistema (kube-system)

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-11 23:47:09

```
$ kubectl get pods -n kube-system

NAME                       READY   STATUS    RESTARTS   AGE
aws-node-n7l5h             2/2     Running   0          3h27m
aws-node-q4wgw             2/2     Running   0          3h25m
coredns-7fc5967d79-wrjkt   1/1     Running   0          3h29m
coredns-7fc5967d79-x4zqn   1/1     Running   0          3h29m
kube-proxy-mnlw2           1/1     Running   0          3h27m
kube-proxy-zz5dw           1/1     Running   0          3h25m
```

**Estado:** ✅ Completado


---

### Paso 8: Métricas de nodos

**IE Relacionado:** IE3
**Hora ejecución:** 2026-06-11 23:47:11

```
$ kubectl top nodes 2>/dev/null || echo '(metrics-server puede tardar)'

(metrics-server puede tardar)
```

**Estado:** ✅ Completado


---

### Paso 9: Métricas de pods

**IE Relacionado:** IE3
**Hora ejecución:** 2026-06-11 23:47:12

```
$ kubectl top pods -n alumnos 2>/dev/null || echo '(metrics-server puede tardar)'

(metrics-server puede tardar)
```

**Estado:** ✅ Completado


### URL pública de la aplicación

```
http://ae40432f35fb5417aa2141c7392bdd81-1478249194.us-east-1.elb.amazonaws.com
```


### Auto-Healing (paso12)

El script elimina un Pod y verifica que Kubernetes lo recrea automáticamente.
Esto demuestra la capacidad de **self-healing** del clúster.


=====================================================
 KUBERNETES AUTO-HEALING TEST
=====================================================


=====================================================
 VALIDANDO PODS ACTUALES
=====================================================

NAME                               READY   STATUS    RESTARTS       AGE
alumnos-backend-77d766d598-8gcs5   1/1     Running   0              6m30s
alumnos-db-c946c688d-lnl2p         1/1     Running   0              8m1s
alumnos-frontend-b868c47cf-9cdsc   1/1     Running   2 (7m2s ago)   7m3s
alumnos-frontend-b868c47cf-mzvgc   1/1     Running   2 (7m1s ago)   7m3s

=====================================================
 VALIDANDO DEPLOYMENTS
=====================================================

NAME               READY   UP-TO-DATE   AVAILABLE   AGE
alumnos-backend    1/1     1            1           6m59s
alumnos-db         1/1     1            1           8m5s
alumnos-frontend   2/2     2            2           7m9s

=====================================================
 VALIDANDO REPLICASETS
=====================================================

NAME                         DESIRED   CURRENT   READY   AGE
alumnos-backend-77d766d598   1         1         1       7m1s
alumnos-db-c946c688d         1         1         1       8m7s
alumnos-frontend-b868c47cf   2         2         2       7m11s

=====================================================
 SELECCIONANDO POD BACKEND
=====================================================

POD SELECCIONADO:
alumnos-backend-77d766d598-8gcs5

=====================================================
 IMPORTANTE
=====================================================

Abrir otra terminal y ejecutar:

kubectl get pods -n alumnos -w

para observar recreacion automatica.

=====================================================
 ELIMINANDO POD BACKEND
=====================================================

pod "alumnos-backend-77d766d598-8gcs5" deleted

=====================================================
 ESPERANDO RECREACION
=====================================================


=====================================================
 VALIDANDO NUEVOS PODS
=====================================================

NAME                               READY   STATUS    RESTARTS        AGE
alumnos-backend-77d766d598-2gh8x   0/1     Running   0               17s
alumnos-db-c946c688d-lnl2p         1/1     Running   0               8m30s
alumnos-frontend-b868c47cf-9cdsc   1/1     Running   2 (7m31s ago)   7m32s
alumnos-frontend-b868c47cf-mzvgc   1/1     Running   2 (7m30s ago)   7m32s

=====================================================
 VALIDANDO DEPLOYMENTS
=====================================================

NAME               READY   UP-TO-DATE   AVAILABLE   AGE
alumnos-backend    0/1     1            0           7m28s
alumnos-db         1/1     1            1           8m34s
alumnos-frontend   2/2     2            2           7m38s

=====================================================
 VALIDANDO REPLICASETS
=====================================================

NAME                         DESIRED   CURRENT   READY   AGE
alumnos-backend-77d766d598   1         1         0       7m30s
alumnos-db-c946c688d         1         1         1       8m36s
alumnos-frontend-b868c47cf   2         2         2       7m40s

=====================================================
 VALIDANDO EVENTOS
=====================================================

LAST SEEN   TYPE      REASON                         OBJECT                                         MESSAGE
8m38s       Normal    ScalingReplicaSet              deployment/alumnos-db                          Scaled up replica set alumnos-db-c946c688d from 0 to 1
8m38s       Normal    Scheduled                      pod/alumnos-db-c946c688d-kcdrw                 Successfully assigned alumnos/alumnos-db-c946c688d-kcdrw to ip-172-31-89-144.ec2.internal
8m38s       Normal    SuccessfulCreate               replicaset/alumnos-db-c946c688d                Created pod: alumnos-db-c946c688d-kcdrw
8m37s       Normal    Pulling                        pod/alumnos-db-c946c688d-kcdrw                 Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-db:latest"
8m36s       Normal    Scheduled                      pod/alumnos-db-c946c688d-lnl2p                 Successfully assigned alumnos/alumnos-db-c946c688d-lnl2p to ip-172-31-89-144.ec2.internal
8m36s       Normal    SuccessfulCreate               replicaset/alumnos-db-c946c688d                Created pod: alumnos-db-c946c688d-lnl2p
8m36s       Normal    Pulled                         pod/alumnos-db-c946c688d-kcdrw                 Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-db:latest" in 702ms (702ms including waiting). Image size: 110028092 bytes.
8m36s       Normal    Created                        pod/alumnos-db-c946c688d-kcdrw                 Container created
8m36s       Normal    Started                        pod/alumnos-db-c946c688d-kcdrw                 Container started
8m35s       Normal    Killing                        pod/alumnos-db-c946c688d-kcdrw                 Stopping container postgres
8m35s       Normal    Pulling                        pod/alumnos-db-c946c688d-lnl2p                 Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-db:latest"
8m35s       Normal    Pulled                         pod/alumnos-db-c946c688d-lnl2p                 Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-db:latest" in 257ms (257ms including waiting). Image size: 110028092 bytes.
8m35s       Normal    Created                        pod/alumnos-db-c946c688d-lnl2p                 Container created
8m35s       Normal    Started                        pod/alumnos-db-c946c688d-lnl2p                 Container started
7m42s       Normal    Scheduled                      pod/alumnos-frontend-b868c47cf-d6rcz           Successfully assigned alumnos/alumnos-frontend-b868c47cf-d6rcz to ip-172-31-37-22.ec2.internal
7m40s       Normal    Pulling                        pod/alumnos-frontend-b868c47cf-xngls           Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest"
7m42s       Normal    Scheduled                      pod/alumnos-frontend-b868c47cf-xngls           Successfully assigned alumnos/alumnos-frontend-b868c47cf-xngls to ip-172-31-89-144.ec2.internal
7m40s       Normal    Pulling                        pod/alumnos-frontend-b868c47cf-d6rcz           Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest"
7m42s       Normal    SuccessfulCreate               replicaset/alumnos-frontend-b868c47cf          Created pod: alumnos-frontend-b868c47cf-xngls
7m42s       Normal    SuccessfulCreate               replicaset/alumnos-frontend-b868c47cf          Created pod: alumnos-frontend-b868c47cf-d6rcz
7m42s       Normal    ScalingReplicaSet              deployment/alumnos-frontend                    Scaled up replica set alumnos-frontend-b868c47cf from 0 to 2
7m40s       Normal    Started                        pod/alumnos-frontend-b868c47cf-xngls           Container started
7m40s       Normal    Created                        pod/alumnos-frontend-b868c47cf-d6rcz           Container created
7m40s       Normal    Started                        pod/alumnos-frontend-b868c47cf-d6rcz           Container started
7m41s       Normal    Pulled                         pod/alumnos-frontend-b868c47cf-d6rcz           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest" in 789ms (789ms including waiting). Image size: 22199110 bytes.
7m41s       Normal    EnsuringLoadBalancer           service/alumnos-frontend                       Ensuring load balancer
7m41s       Normal    Pulled                         pod/alumnos-frontend-b868c47cf-xngls           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest" in 859ms (859ms including waiting). Image size: 22199110 bytes.
7m40s       Normal    Created                        pod/alumnos-frontend-b868c47cf-xngls           Container created
7m40s       Normal    Pulled                         pod/alumnos-frontend-b868c47cf-xngls           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest" in 144ms (144ms including waiting). Image size: 22199110 bytes.
7m40s       Normal    Pulled                         pod/alumnos-frontend-b868c47cf-d6rcz           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest" in 143ms (143ms including waiting). Image size: 22199110 bytes.
7m38s       Warning   BackOff                        pod/alumnos-frontend-b868c47cf-d6rcz           Back-off restarting failed container frontend in pod alumnos-frontend-b868c47cf-d6rcz_alumnos(bf3eed60-a78e-424c-b82f-6ab778d82e0f)
7m38s       Warning   BackOff                        pod/alumnos-frontend-b868c47cf-xngls           Back-off restarting failed container frontend in pod alumnos-frontend-b868c47cf-xngls_alumnos(7ab7e2d2-6216-4ec2-87f5-3839e716a0d3)
7m38s       Normal    Scheduled                      pod/alumnos-frontend-b868c47cf-mzvgc           Successfully assigned alumnos/alumnos-frontend-b868c47cf-mzvgc to ip-172-31-89-144.ec2.internal
7m38s       Normal    Pulled                         pod/alumnos-frontend-b868c47cf-mzvgc           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest" in 138ms (138ms including waiting). Image size: 22199110 bytes.
7m38s       Normal    SuccessfulCreate               replicaset/alumnos-frontend-b868c47cf          Created pod: alumnos-frontend-b868c47cf-9cdsc
7m38s       Normal    SuccessfulCreate               replicaset/alumnos-frontend-b868c47cf          Created pod: alumnos-frontend-b868c47cf-mzvgc
7m25s       Normal    Pulling                        pod/alumnos-frontend-b868c47cf-mzvgc           Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest"
7m38s       Normal    EnsuredLoadBalancer            service/alumnos-frontend                       Ensured load balancer
7m38s       Normal    Scheduled                      pod/alumnos-frontend-b868c47cf-9cdsc           Successfully assigned alumnos/alumnos-frontend-b868c47cf-9cdsc to ip-172-31-37-22.ec2.internal
7m26s       Normal    Pulling                        pod/alumnos-frontend-b868c47cf-9cdsc           Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest"
7m38s       Normal    Pulled                         pod/alumnos-frontend-b868c47cf-9cdsc           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest" in 174ms (174ms including waiting). Image size: 22199110 bytes.
7m26s       Normal    Created                        pod/alumnos-frontend-b868c47cf-9cdsc           Container created
7m25s       Normal    Started                        pod/alumnos-frontend-b868c47cf-mzvgc           Container started
7m37s       Normal    Pulled                         pod/alumnos-frontend-b868c47cf-9cdsc           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest" in 152ms (152ms including waiting). Image size: 22199110 bytes.
7m26s       Normal    Started                        pod/alumnos-frontend-b868c47cf-9cdsc           Container started
7m25s       Normal    Created                        pod/alumnos-frontend-b868c47cf-mzvgc           Container created
7m28s       Warning   BackOff                        pod/alumnos-frontend-b868c47cf-9cdsc           Back-off restarting failed container frontend in pod alumnos-frontend-b868c47cf-9cdsc_alumnos(ddc3825d-cdfb-44b2-9e1f-b7ee50ffc2d6)
7m36s       Normal    Pulled                         pod/alumnos-frontend-b868c47cf-mzvgc           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest" in 141ms (141ms including waiting). Image size: 22199110 bytes.
7m28s       Warning   BackOff                        pod/alumnos-frontend-b868c47cf-mzvgc           Back-off restarting failed container frontend in pod alumnos-frontend-b868c47cf-mzvgc_alumnos(ff9ad895-9a54-461e-a632-dc5d8da6d576)
7m32s       Normal    ScalingReplicaSet              deployment/alumnos-backend                     Scaled up replica set alumnos-backend-77d766d598 from 0 to 1
7m32s       Normal    SuccessfulCreate               replicaset/alumnos-backend-77d766d598          Created pod: alumnos-backend-77d766d598-ws8qf
7m32s       Normal    Scheduled                      pod/alumnos-backend-77d766d598-ws8qf           Successfully assigned alumnos/alumnos-backend-77d766d598-ws8qf to ip-172-31-89-144.ec2.internal
7m32s       Normal    Pulling                        pod/alumnos-backend-77d766d598-ws8qf           Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest"
7m27s       Normal    Started                        pod/alumnos-backend-77d766d598-ws8qf           Container started
7m27s       Normal    Created                        pod/alumnos-backend-77d766d598-ws8qf           Container created
7m27s       Normal    Pulled                         pod/alumnos-backend-77d766d598-ws8qf           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest" in 4.117s (4.117s including waiting). Image size: 216398104 bytes.
7m26s       Normal    Pulled                         pod/alumnos-frontend-b868c47cf-9cdsc           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest" in 135ms (135ms including waiting). Image size: 22199110 bytes.
7m25s       Normal    Pulled                         pod/alumnos-frontend-b868c47cf-mzvgc           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest" in 116ms (116ms including waiting). Image size: 22199110 bytes.
4m39s       Warning   FailedComputeMetricsReplicas   horizontalpodautoscaler/alumnos-frontend-hpa   invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: unable to get metrics for resource cpu: unable to fetch metrics from resource metrics API: the server could not find the requested resource (get pods.metrics.k8s.io)
2m24s       Warning   FailedGetResourceMetric        horizontalpodautoscaler/alumnos-frontend-hpa   failed to get cpu utilization: unable to get metrics for resource cpu: unable to fetch metrics from resource metrics API: the server could not find the requested resource (get pods.metrics.k8s.io)
2m14s       Warning   FailedGetResourceMetric        horizontalpodautoscaler/alumnos-backend-hpa    failed to get cpu utilization: unable to get metrics for resource cpu: unable to fetch metrics from resource metrics API: the server could not find the requested resource (get pods.metrics.k8s.io)
4m30s       Warning   FailedComputeMetricsReplicas   horizontalpodautoscaler/alumnos-backend-hpa    invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: unable to get metrics for resource cpu: unable to fetch metrics from resource metrics API: the server could not find the requested resource (get pods.metrics.k8s.io)
7m5s        Normal    SuccessfulCreate               replicaset/alumnos-backend-77d766d598          Created pod: alumnos-backend-77d766d598-8gcs5
7m5s        Normal    Scheduled                      pod/alumnos-backend-77d766d598-8gcs5           Successfully assigned alumnos/alumnos-backend-77d766d598-8gcs5 to ip-172-31-89-144.ec2.internal
7m5s        Normal    Killing                        pod/alumnos-backend-77d766d598-ws8qf           Stopping container backend
7m4s        Normal    Started                        pod/alumnos-backend-77d766d598-8gcs5           Container started
7m4s        Normal    Created                        pod/alumnos-backend-77d766d598-8gcs5           Container created
7m4s        Normal    Pulled                         pod/alumnos-backend-77d766d598-8gcs5           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest" in 118ms (118ms including waiting). Image size: 216398104 bytes.
7m4s        Normal    Pulling                        pod/alumnos-backend-77d766d598-8gcs5           Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest"
6m10s       Warning   Unhealthy                      pod/alumnos-backend-77d766d598-8gcs5           Readiness probe failed: Get "http://172.31.91.136:8080/actuator/health/readiness": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
23s         Normal    Scheduled                      pod/alumnos-backend-77d766d598-2gh8x           Successfully assigned alumnos/alumnos-backend-77d766d598-2gh8x to ip-172-31-89-144.ec2.internal
23s         Normal    Killing                        pod/alumnos-backend-77d766d598-8gcs5           Stopping container backend
23s         Normal    SuccessfulCreate               replicaset/alumnos-backend-77d766d598          Created pod: alumnos-backend-77d766d598-2gh8x
22s         Normal    Started                        pod/alumnos-backend-77d766d598-2gh8x           Container started
22s         Normal    Created                        pod/alumnos-backend-77d766d598-2gh8x           Container created
22s         Normal    Pulled                         pod/alumnos-backend-77d766d598-2gh8x           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest" in 113ms (113ms including waiting). Image size: 216398104 bytes.
22s         Normal    Pulling                        pod/alumnos-backend-77d766d598-2gh8x           Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest"

=====================================================
 VALIDANDO PODS RUNNING
=====================================================

alumnos-backend-77d766d598-2gh8x   0/1     Running   0               25s
alumnos-db-c946c688d-lnl2p         1/1     Running   0               8m38s
alumnos-frontend-b868c47cf-9cdsc   1/1     Running   2 (7m39s ago)   7m40s
alumnos-frontend-b868c47cf-mzvgc   1/1     Running   2 (7m38s ago)   7m40s

=====================================================
 RESULTADO ESPERADO
=====================================================

Pod eliminado -> nuevo pod creado automaticamente

=====================================================
 AUTO-HEALING VALIDADO
=====================================================

Kubernetes resiliencia automatica operativa

=====================================================
 PROCESO FINALIZADO
=====================================================


### HPA y Stress Test (paso10 + paso11)

Se valida que el HPA responde a carga y se ejecuta un stress test
contra el backend para ver el escalado en tiempo real.


=====================================================
 VALIDANDO HPA KUBERNETES
=====================================================


=====================================================
 [1/8] VALIDANDO METRICS SERVER
=====================================================

v1.metrics.eks.amazonaws.com      kube-system/eks-extension-metrics-api   True        2d18h

=====================================================
 [2/8] VALIDANDO METRICAS NODOS
=====================================================

error: Metrics API not available

=====================================================
 [3/8] VALIDANDO METRICAS PODS
=====================================================

error: Metrics API not available

=====================================================
 [4/8] VALIDANDO HPA EXISTENTES
=====================================================

NAME                   REFERENCE                     TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
alumnos-backend-hpa    Deployment/alumnos-backend    cpu: <unknown>/70%   1         10        1          7m39s
alumnos-frontend-hpa   Deployment/alumnos-frontend   cpu: <unknown>/60%   2         6         2          7m48s

  Verificando que los HPA esten configurados...
  ✔ 2 HPA encontrados.

=====================================================
 [5/8] VALIDANDO PODS BACKEND RUNNING
=====================================================

  Esperando pods de alumnos-backend esten Ready...
pod/alumnos-backend-77d766d598-2gh8x condition met
  ✔ Backend pods Ready.

  Verificando replicas iniciales...
  Replicas iniciales: 1

=====================================================
 [6/8] INICIANDO PRUEBA DE CARGA BACKEND
=====================================================

  Eliminando pod stress anterior (si existe)...

  Creando pod de estres para generar carga HTTP...
  Target: http://alumnos-backend:3001
  Usando imagen del backend (ya en ECR)

  Imagen: 461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest
pod/hpa-test created

  Esperando que el pod stress este Running...
pod/hpa-test condition met
  ✔ Pod stress creado y generando trafico.

=====================================================
 [7/8] ESPERANDO ESCALAMIENTO AUTOMATICO (HPA)
=====================================================

  Monitoreando replicas de alumnos-backend (max 300 seg)...

    elapsed:   0s | replicas: 1 | hpa-current: 1    elapsed:  10s | replicas: 1 | hpa-current: 1    elapsed:  20s | replicas: 1 | hpa-current: 1    elapsed:  30s | replicas: 1 | hpa-current: 1    elapsed:  40s | replicas: 1 | hpa-current: 1    elapsed:  50s | replicas: 1 | hpa-current: 1    elapsed:  60s | replicas: 1 | hpa-current: 1    elapsed:  70s | replicas: 1 | hpa-current: 1