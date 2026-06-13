# Reporte de Evidencia: Validación final y operación avanzada (HPA, Healing, Métricas)

**Fecha:** 2026-06-13 17:28:29
**Etapa:** etapa09-ValidaApp

---

## Resumen


---

### Paso 1: Nodos del cluster

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 17:28:33

```
$ kubectl get nodes -o wide

NAME                          STATUS   ROLES    AGE   VERSION                INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                    CONTAINER-RUNTIME
ip-10-0-12-180.ec2.internal   Ready    <none>   65m   v1.33.11-eks-3385e9b   10.0.12.180   <none>        Amazon Linux 2023.11.20260526   6.12.88-119.157.amzn2023.x86_64   containerd://2.2.3+unknown
```

**Estado:** ✅ Completado


---

### Paso 2: Pods en namespace alumnos

**IE Relacionado:** IE2 + IE7
**Hora ejecución:** 2026-06-13 17:28:35

```
$ kubectl get pods -n alumnos -o wide

NAME                                READY   STATUS    RESTARTS   AGE     IP            NODE                          NOMINATED NODE   READINESS GATES
alumnos-backend-6c6566dd55-z4np5    1/1     Running   0          4m5s    10.0.12.147   ip-10-0-12-180.ec2.internal   <none>           <none>
alumnos-db-dfd59ccdf-bcbvv          1/1     Running   0          5m28s   10.0.12.13    ip-10-0-12-180.ec2.internal   <none>           <none>
alumnos-frontend-68c9467575-j2bkz   1/1     Running   0          116s    10.0.12.157   ip-10-0-12-180.ec2.internal   <none>           <none>
alumnos-frontend-68c9467575-kkntn   1/1     Running   0          116s    10.0.12.43    ip-10-0-12-180.ec2.internal   <none>           <none>
```

**Estado:** ✅ Completado


---

### Paso 3: Services en alumnos

**IE Relacionado:** IE2
**Hora ejecución:** 2026-06-13 17:28:37

```
$ kubectl get svc -n alumnos

NAME               TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)        AGE
alumnos-backend    ClusterIP      172.20.68.114    <none>                                                                   8080/TCP       4m9s
alumnos-db         ClusterIP      172.20.13.102    <none>                                                                   5432/TCP       5m31s
alumnos-frontend   LoadBalancer   172.20.228.213   a9e4b2153d2df4f1eb03e40f1032ce71-223483394.us-east-1.elb.amazonaws.com   80:30174/TCP   2m
```

**Estado:** ✅ Completado


---

### Paso 4: HPA en alumnos

**IE Relacionado:** IE3
**Hora ejecución:** 2026-06-13 17:28:38

```
$ kubectl get hpa -n alumnos

NAME                   REFERENCE                     TARGETS        MINPODS   MAXPODS   REPLICAS   AGE
alumnos-backend-hpa    Deployment/alumnos-backend    cpu: 14%/70%   1         10        1          4m9s
alumnos-frontend-hpa   Deployment/alumnos-frontend   cpu: 2%/60%    2         6         2          2m
```

**Estado:** ✅ Completado


---

### Paso 5: Deployments en alumnos

**IE Relacionado:** IE2
**Hora ejecución:** 2026-06-13 17:28:40

```
$ kubectl get deployment -n alumnos

NAME               READY   UP-TO-DATE   AVAILABLE   AGE
alumnos-backend    1/1     1            1           4m13s
alumnos-db         1/1     1            1           5m36s
alumnos-frontend   2/2     2            2           2m4s
```

**Estado:** ✅ Completado


---

### Paso 6: Endpoints

**IE Relacionado:** IE7
**Hora ejecución:** 2026-06-13 17:28:42

```
$ kubectl get endpoints -n alumnos

Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME               ENDPOINTS                      AGE
alumnos-backend    10.0.12.147:8080               4m14s
alumnos-db         10.0.12.13:5432                5m36s
alumnos-frontend   10.0.12.157:80,10.0.12.43:80   2m5s
```

**Estado:** ✅ Completado


---

### Paso 7: Pods del sistema (kube-system)

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 17:28:44

```
$ kubectl get pods -n kube-system

NAME                              READY   STATUS    RESTARTS   AGE
aws-node-zxpp9                    2/2     Running   0          65m
coredns-55b4f5c59c-6sgcp          1/1     Running   0          69m
coredns-55b4f5c59c-vltkz          1/1     Running   0          69m
kube-proxy-gjcfw                  1/1     Running   0          65m
metrics-server-68db5bc85f-bq4vc   1/1     Running   0          66m
metrics-server-68db5bc85f-bwnsx   1/1     Running   0          66m
```

**Estado:** ✅ Completado


---

### Paso 8: Métricas de nodos

**IE Relacionado:** IE3
**Hora ejecución:** 2026-06-13 17:28:46

```
$ kubectl top nodes 2>/dev/null || echo '(metrics-server puede tardar)'

NAME                          CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
ip-10-0-12-180.ec2.internal   42m          2%       912Mi           12%         
```

**Estado:** ✅ Completado


---

### Paso 9: Métricas de pods

**IE Relacionado:** IE3
**Hora ejecución:** 2026-06-13 17:28:48

```
$ kubectl top pods -n alumnos 2>/dev/null || echo '(metrics-server puede tardar)'

NAME                                CPU(cores)   MEMORY(bytes)   
alumnos-backend-6c6566dd55-z4np5    4m           232Mi           
alumnos-db-dfd59ccdf-bcbvv          2m           49Mi            
alumnos-frontend-68c9467575-j2bkz   1m           2Mi             
alumnos-frontend-68c9467575-kkntn   1m           2Mi             
```

**Estado:** ✅ Completado


### URL pública de la aplicación

```
http://a9e4b2153d2df4f1eb03e40f1032ce71-223483394.us-east-1.elb.amazonaws.com
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

NAME                                READY   STATUS    RESTARTS   AGE
alumnos-backend-6c6566dd55-z4np5    1/1     Running   0          4m22s
alumnos-db-dfd59ccdf-bcbvv          1/1     Running   0          5m45s
alumnos-frontend-68c9467575-j2bkz   1/1     Running   0          2m13s
alumnos-frontend-68c9467575-kkntn   1/1     Running   0          2m13s

=====================================================
 VALIDANDO DEPLOYMENTS
=====================================================

NAME               READY   UP-TO-DATE   AVAILABLE   AGE
alumnos-backend    1/1     1            1           4m27s
alumnos-db         1/1     1            1           5m50s
alumnos-frontend   2/2     2            2           2m18s

=====================================================
 VALIDANDO REPLICASETS
=====================================================

NAME                          DESIRED   CURRENT   READY   AGE
alumnos-backend-6c6566dd55    1         1         1       4m29s
alumnos-db-dfd59ccdf          1         1         1       5m52s
alumnos-frontend-68c9467575   2         2         2       2m20s

=====================================================
 SELECCIONANDO POD BACKEND
=====================================================

POD SELECCIONADO:
alumnos-backend-6c6566dd55-z4np5

=====================================================
 IMPORTANTE
=====================================================

Abrir otra terminal y ejecutar:

kubectl get pods -n alumnos -w

para observar recreacion automatica.

=====================================================
 ELIMINANDO POD BACKEND
=====================================================

pod "alumnos-backend-6c6566dd55-z4np5" deleted

=====================================================
 ESPERANDO RECREACION
=====================================================


=====================================================
 VALIDANDO NUEVOS PODS
=====================================================

NAME                                READY   STATUS    RESTARTS   AGE
alumnos-backend-6c6566dd55-wlm8c    0/1     Running   0          17s
alumnos-db-dfd59ccdf-bcbvv          1/1     Running   0          6m15s
alumnos-frontend-68c9467575-j2bkz   1/1     Running   0          2m43s
alumnos-frontend-68c9467575-kkntn   1/1     Running   0          2m43s

=====================================================
 VALIDANDO DEPLOYMENTS
=====================================================

NAME               READY   UP-TO-DATE   AVAILABLE   AGE
alumnos-backend    0/1     1            0           4m57s
alumnos-db         1/1     1            1           6m20s
alumnos-frontend   2/2     2            2           2m48s

=====================================================
 VALIDANDO REPLICASETS
=====================================================

NAME                          DESIRED   CURRENT   READY   AGE
alumnos-backend-6c6566dd55    1         1         0       4m59s
alumnos-db-dfd59ccdf          1         1         1       6m22s
alumnos-frontend-68c9467575   2         2         2       2m50s

=====================================================
 VALIDANDO EVENTOS
=====================================================

LAST SEEN   TYPE      REASON                         OBJECT                                         MESSAGE
6m24s       Normal    ScalingReplicaSet              deployment/alumnos-db                          Scaled up replica set alumnos-db-dfd59ccdf from 0 to 1
6m23s       Normal    Created                        pod/alumnos-db-dfd59ccdf-tgcb4                 Created container: postgres
6m23s       Normal    Pulling                        pod/alumnos-db-dfd59ccdf-tgcb4                 Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-db:latest"
6m23s       Normal    SuccessfulCreate               replicaset/alumnos-db-dfd59ccdf                Created pod: alumnos-db-dfd59ccdf-tgcb4
6m23s       Normal    Pulled                         pod/alumnos-db-dfd59ccdf-tgcb4                 Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-db:latest" in 253ms (253ms including waiting). Image size: 110028092 bytes.
6m23s       Normal    Scheduled                      pod/alumnos-db-dfd59ccdf-tgcb4                 Successfully assigned alumnos/alumnos-db-dfd59ccdf-tgcb4 to ip-10-0-12-180.ec2.internal
6m22s       Normal    Started                        pod/alumnos-db-dfd59ccdf-tgcb4                 Started container postgres
6m21s       Normal    Scheduled                      pod/alumnos-db-dfd59ccdf-bcbvv                 Successfully assigned alumnos/alumnos-db-dfd59ccdf-bcbvv to ip-10-0-12-180.ec2.internal
6m21s       Normal    Pulling                        pod/alumnos-db-dfd59ccdf-bcbvv                 Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-db:latest"
6m21s       Normal    Pulled                         pod/alumnos-db-dfd59ccdf-bcbvv                 Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-db:latest" in 138ms (138ms including waiting). Image size: 110028092 bytes.
6m21s       Normal    SuccessfulCreate               replicaset/alumnos-db-dfd59ccdf                Created pod: alumnos-db-dfd59ccdf-bcbvv
6m21s       Normal    Created                        pod/alumnos-db-dfd59ccdf-bcbvv                 Created container: postgres
6m20s       Normal    Started                        pod/alumnos-db-dfd59ccdf-bcbvv                 Started container postgres
6m20s       Normal    Killing                        pod/alumnos-db-dfd59ccdf-tgcb4                 Stopping container postgres
5m1s        Normal    ScalingReplicaSet              deployment/alumnos-backend                     Scaled up replica set alumnos-backend-6c6566dd55 from 0 to 1
5m1s        Normal    Pulling                        pod/alumnos-backend-6c6566dd55-d7b6f           Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest"
5m1s        Normal    SuccessfulCreate               replicaset/alumnos-backend-6c6566dd55          Created pod: alumnos-backend-6c6566dd55-d7b6f
5m1s        Normal    Scheduled                      pod/alumnos-backend-6c6566dd55-d7b6f           Successfully assigned alumnos/alumnos-backend-6c6566dd55-d7b6f to ip-10-0-12-180.ec2.internal
5m          Normal    Pulled                         pod/alumnos-backend-6c6566dd55-d7b6f           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest" in 241ms (241ms including waiting). Image size: 216398104 bytes.
5m          Normal    Started                        pod/alumnos-backend-6c6566dd55-d7b6f           Started container backend
5m          Normal    Created                        pod/alumnos-backend-6c6566dd55-d7b6f           Created container: backend
4m58s       Normal    SuccessfulCreate               replicaset/alumnos-backend-6c6566dd55          Created pod: alumnos-backend-6c6566dd55-z4np5
4m58s       Normal    Pulled                         pod/alumnos-backend-6c6566dd55-z4np5           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest" in 164ms (164ms including waiting). Image size: 216398104 bytes.
4m58s       Normal    Scheduled                      pod/alumnos-backend-6c6566dd55-z4np5           Successfully assigned alumnos/alumnos-backend-6c6566dd55-z4np5 to ip-10-0-12-180.ec2.internal
4m58s       Normal    Pulling                        pod/alumnos-backend-6c6566dd55-z4np5           Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest"
4m58s       Normal    Created                        pod/alumnos-backend-6c6566dd55-z4np5           Created container: backend
4m57s       Normal    Killing                        pod/alumnos-backend-6c6566dd55-d7b6f           Stopping container backend
4m57s       Normal    Started                        pod/alumnos-backend-6c6566dd55-z4np5           Started container backend
3m44s       Warning   FailedGetResourceMetric        horizontalpodautoscaler/alumnos-backend-hpa    failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
3m44s       Warning   FailedComputeMetricsReplicas   horizontalpodautoscaler/alumnos-backend-hpa    invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
4m5s        Warning   Unhealthy                      pod/alumnos-backend-6c6566dd55-z4np5           Readiness probe failed: Get "http://10.0.12.147:8080/actuator/health/readiness": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
2m52s       Normal    SuccessfulCreate               replicaset/alumnos-frontend-68c9467575         Created pod: alumnos-frontend-68c9467575-d4mvf
2m52s       Normal    Scheduled                      pod/alumnos-frontend-68c9467575-wpw4h          Successfully assigned alumnos/alumnos-frontend-68c9467575-wpw4h to ip-10-0-12-180.ec2.internal
2m52s       Normal    ScalingReplicaSet              deployment/alumnos-frontend                    Scaled up replica set alumnos-frontend-68c9467575 from 0 to 2
2m52s       Normal    Scheduled                      pod/alumnos-frontend-68c9467575-d4mvf          Successfully assigned alumnos/alumnos-frontend-68c9467575-d4mvf to ip-10-0-12-180.ec2.internal
2m52s       Normal    SuccessfulCreate               replicaset/alumnos-frontend-68c9467575         Created pod: alumnos-frontend-68c9467575-wpw4h
2m51s       Normal    Created                        pod/alumnos-frontend-68c9467575-wpw4h          Created container: frontend
2m51s       Normal    Pulling                        pod/alumnos-frontend-68c9467575-wpw4h          Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest"
2m51s       Normal    Pulled                         pod/alumnos-frontend-68c9467575-wpw4h          Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest" in 292ms (292ms including waiting). Image size: 22199110 bytes.
2m51s       Normal    EnsuringLoadBalancer           service/alumnos-frontend                       Ensuring load balancer
2m51s       Normal    Started                        pod/alumnos-frontend-68c9467575-wpw4h          Started container frontend
2m51s       Normal    Pulling                        pod/alumnos-frontend-68c9467575-d4mvf          Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest"
2m51s       Normal    Pulled                         pod/alumnos-frontend-68c9467575-d4mvf          Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest" in 168ms (168ms including waiting). Image size: 22199110 bytes.
2m51s       Normal    Created                        pod/alumnos-frontend-68c9467575-d4mvf          Created container: frontend
2m51s       Normal    Started                        pod/alumnos-frontend-68c9467575-d4mvf          Started container frontend
2m49s       Normal    Pulling                        pod/alumnos-frontend-68c9467575-j2bkz          Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest"
2m49s       Normal    SuccessfulCreate               replicaset/alumnos-frontend-68c9467575         Created pod: alumnos-frontend-68c9467575-j2bkz
2m49s       Normal    SuccessfulCreate               replicaset/alumnos-frontend-68c9467575         Created pod: alumnos-frontend-68c9467575-kkntn
2m49s       Normal    Scheduled                      pod/alumnos-frontend-68c9467575-j2bkz          Successfully assigned alumnos/alumnos-frontend-68c9467575-j2bkz to ip-10-0-12-180.ec2.internal
2m49s       Normal    Pulling                        pod/alumnos-frontend-68c9467575-kkntn          Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest"
2m49s       Normal    Scheduled                      pod/alumnos-frontend-68c9467575-kkntn          Successfully assigned alumnos/alumnos-frontend-68c9467575-kkntn to ip-10-0-12-180.ec2.internal
2m48s       Normal    Killing                        pod/alumnos-frontend-68c9467575-wpw4h          Stopping container frontend
2m48s       Normal    Created                        pod/alumnos-frontend-68c9467575-j2bkz          Created container: frontend
2m48s       Normal    Pulled                         pod/alumnos-frontend-68c9467575-kkntn          Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest" in 170ms (170ms including waiting). Image size: 22199110 bytes.
2m48s       Normal    Created                        pod/alumnos-frontend-68c9467575-kkntn          Created container: frontend
2m48s       Normal    Started                        pod/alumnos-frontend-68c9467575-kkntn          Started container frontend
2m48s       Normal    EnsuredLoadBalancer            service/alumnos-frontend                       Ensured load balancer
2m48s       Normal    Started                        pod/alumnos-frontend-68c9467575-j2bkz          Started container frontend
2m48s       Normal    Killing                        pod/alumnos-frontend-68c9467575-d4mvf          Stopping container frontend
2m48s       Normal    Pulled                         pod/alumnos-frontend-68c9467575-j2bkz          Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-frontend:latest" in 176ms (176ms including waiting). Image size: 22199110 bytes.
2m35s       Warning   FailedGetResourceMetric        horizontalpodautoscaler/alumnos-frontend-hpa   failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
2m35s       Warning   FailedComputeMetricsReplicas   horizontalpodautoscaler/alumnos-frontend-hpa   invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
2m20s       Warning   FailedGetResourceMetric        horizontalpodautoscaler/alumnos-frontend-hpa   failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
2m20s       Warning   FailedComputeMetricsReplicas   horizontalpodautoscaler/alumnos-frontend-hpa   invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
23s         Normal    Killing                        pod/alumnos-backend-6c6566dd55-z4np5           Stopping container backend
23s         Normal    SuccessfulCreate               replicaset/alumnos-backend-6c6566dd55          Created pod: alumnos-backend-6c6566dd55-wlm8c
23s         Normal    Scheduled                      pod/alumnos-backend-6c6566dd55-wlm8c           Successfully assigned alumnos/alumnos-backend-6c6566dd55-wlm8c to ip-10-0-12-180.ec2.internal
22s         Normal    Started                        pod/alumnos-backend-6c6566dd55-wlm8c           Started container backend
22s         Normal    Created                        pod/alumnos-backend-6c6566dd55-wlm8c           Created container: backend
22s         Normal    Pulled                         pod/alumnos-backend-6c6566dd55-wlm8c           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest" in 127ms (127ms including waiting). Image size: 216398104 bytes.
22s         Normal    Pulling                        pod/alumnos-backend-6c6566dd55-wlm8c           Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest"
14s         Warning   FailedComputeMetricsReplicas   horizontalpodautoscaler/alumnos-backend-hpa    invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
14s         Warning   FailedGetResourceMetric        horizontalpodautoscaler/alumnos-backend-hpa    failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API

=====================================================
 VALIDANDO PODS RUNNING
=====================================================

alumnos-backend-6c6566dd55-wlm8c    0/1     Running   0          26s
alumnos-db-dfd59ccdf-bcbvv          1/1     Running   0          6m24s
alumnos-frontend-68c9467575-j2bkz   1/1     Running   0          2m52s
alumnos-frontend-68c9467575-kkntn   1/1     Running   0          2m52s

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

v1.metrics.eks.amazonaws.com      kube-system/eks-extension-metrics-api   True        71m
v1beta1.metrics.k8s.io            kube-system/metrics-server              True        67m

=====================================================
 [2/8] VALIDANDO METRICAS NODOS
=====================================================

NAME                          CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
ip-10-0-12-180.ec2.internal   576m         29%      773Mi           10%         

=====================================================
 [3/8] VALIDANDO METRICAS PODS
=====================================================

NAME                                CPU(cores)   MEMORY(bytes)   
alumnos-backend-6c6566dd55-wlm8c    502m         98Mi            
alumnos-db-dfd59ccdf-bcbvv          4m           33Mi            
alumnos-frontend-68c9467575-j2bkz   1m           2Mi             
alumnos-frontend-68c9467575-kkntn   1m           2Mi             

=====================================================
 [4/8] VALIDANDO HPA EXISTENTES
=====================================================

NAME                   REFERENCE                     TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
alumnos-backend-hpa    Deployment/alumnos-backend    cpu: <unknown>/70%   1         10        1          5m11s
alumnos-frontend-hpa   Deployment/alumnos-frontend   cpu: 2%/60%          2         6         2          3m2s

  Verificando que los HPA esten configurados...
  ✔ 2 HPA encontrados.

=====================================================
 [5/8] VALIDANDO PODS BACKEND RUNNING
=====================================================

  Esperando pods de alumnos-backend esten Ready...
pod/alumnos-backend-6c6566dd55-wlm8c condition met
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

    elapsed:   0s | replicas: 1 | hpa-current: 1    elapsed:  10s | replicas: 1 | hpa-current: 1    elapsed:  20s | replicas: 1 | hpa-current: 1    elapsed:  30s | replicas: 1 | hpa-current: 1    elapsed:  40s | replicas: 1 | hpa-current: 1    elapsed:  50s | replicas: 1 | hpa-current: 1    elapsed:  60s | replicas: 1 | hpa-current: 1    elapsed:  70s | replicas: 1 | hpa-current: 1    elapsed:  80s | replicas: 1 | hpa-current: 1    elapsed:  90s | replicas: 1 | hpa-current: 1    elapsed: 100s | replicas: 1 | hpa-current: 1    elapsed: 110s | replicas: 1 | hpa-current: 1    elapsed: 120s | replicas: 1 | hpa-current: 1    elapsed: 130s | replicas: 1 | hpa-current: 1    elapsed: 140s | replicas: 1 | hpa-current: 1    elapsed: 150s | replicas: 1 | hpa-current: 1    elapsed: 160s | replicas: 1 | hpa-current: 1    elapsed: 170s | replicas: 1 | hpa-current: 1    elapsed: 180s | replicas: 1 | hpa-current: 1    elapsed: 190s | replicas: 1 | hpa-current: 1    elapsed: 200s | replicas: 1 | hpa-current: 1    elapsed: 210s | replicas: 1 | hpa-current: 1    elapsed: 220s | replicas: 1 | hpa-current: 1    elapsed: 230s | replicas: 1 | hpa-current: 1    elapsed: 240s | replicas: 1 | hpa-current: 1    elapsed: 250s | replicas: 1 | hpa-current: 1    elapsed: 260s | replicas: 1 | hpa-current: 1    elapsed: 270s | replicas: 1 | hpa-current: 1    elapsed: 280s | replicas: 1 | hpa-current: 1    elapsed: 290s | replicas: 1 | hpa-current: 1
  ⚠ No se detecto escalamiento en 300 segundos.
  Posibles causas:
    - Metrics Server aun recolectando datos (esperar 1-2 min extra)
    - La carga no es suficiente para superar el threshold CPU
    - El HPA no esta correctamente vinculado al deployment

  Estado actual del HPA:
Reference:                                             Deployment/alumnos-backend
Metrics:                                               ( current / target )
Min replicas:                                          1
Max replicas:                                          10

=====================================================
 [8/8] RESUMEN FINAL
=====================================================

--- HPA ---
NAME                   REFERENCE                     TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
alumnos-backend-hpa    Deployment/alumnos-backend    cpu: 4%/70%   1         10        1          12m
alumnos-frontend-hpa   Deployment/alumnos-frontend   cpu: 2%/60%   2         6         2          10m

--- PODS ---
NAME                                READY   STATUS    RESTARTS   AGE
alumnos-backend-6c6566dd55-wlm8c    1/1     Running   0          8m10s
alumnos-db-dfd59ccdf-bcbvv          1/1     Running   0          14m
alumnos-frontend-68c9467575-j2bkz   1/1     Running   0          10m
alumnos-frontend-68c9467575-kkntn   1/1     Running   0          10m
hpa-test                            0/1     Error     0          7m

--- DEPLOYMENTS ---
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
alumnos-backend    1/1     1            1           12m
alumnos-db         1/1     1            1           14m
alumnos-frontend   2/2     2            2           10m

--- EVENTOS RECIENTES ---
10m         Normal    Killing                        pod/alumnos-frontend-68c9467575-wpw4h          Stopping container frontend
10m         Warning   FailedGetResourceMetric        horizontalpodautoscaler/alumnos-frontend-hpa   failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
10m         Warning   FailedComputeMetricsReplicas   horizontalpodautoscaler/alumnos-frontend-hpa   invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
10m         Warning   FailedComputeMetricsReplicas   horizontalpodautoscaler/alumnos-frontend-hpa   invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
10m         Warning   FailedGetResourceMetric        horizontalpodautoscaler/alumnos-frontend-hpa   failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
8m14s       Normal    Scheduled                      pod/alumnos-backend-6c6566dd55-wlm8c           Successfully assigned alumnos/alumnos-backend-6c6566dd55-wlm8c to ip-10-0-12-180.ec2.internal
8m14s       Normal    Killing                        pod/alumnos-backend-6c6566dd55-z4np5           Stopping container backend
8m14s       Normal    SuccessfulCreate               replicaset/alumnos-backend-6c6566dd55          Created pod: alumnos-backend-6c6566dd55-wlm8c
8m13s       Normal    Pulling                        pod/alumnos-backend-6c6566dd55-wlm8c           Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest"
8m13s       Normal    Started                        pod/alumnos-backend-6c6566dd55-wlm8c           Started container backend
8m13s       Normal    Created                        pod/alumnos-backend-6c6566dd55-wlm8c           Created container: backend
8m13s       Normal    Pulled                         pod/alumnos-backend-6c6566dd55-wlm8c           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest" in 127ms (127ms including waiting). Image size: 216398104 bytes.
8m5s        Warning   FailedComputeMetricsReplicas   horizontalpodautoscaler/alumnos-backend-hpa    invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
8m5s        Warning   FailedGetResourceMetric        horizontalpodautoscaler/alumnos-backend-hpa    failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
7m21s       Warning   Unhealthy                      pod/alumnos-backend-6c6566dd55-wlm8c           Readiness probe failed: Get "http://10.0.12.204:8080/actuator/health/readiness": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
7m4s        Normal    Scheduled                      pod/hpa-test                                   Successfully assigned alumnos/hpa-test to ip-10-0-12-180.ec2.internal
7m3s        Normal    Pulling                        pod/hpa-test                                   Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest"
7m3s        Normal    Pulled                         pod/hpa-test                                   Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest" in 149ms (149ms including waiting). Image size: 216398104 bytes.
7m3s        Normal    Created                        pod/hpa-test                                   Created container: hpa-test
7m3s        Normal    Started                        pod/hpa-test                                   Started container hpa-test

=====================================================
 NOTA: Para detener la prueba de carga ejecuta:
   kubectl delete pod hpa-test -n alumnos
=====================================================

  Los pods extras se reduciran automaticamente
  cuando el CPU baje (aprox 5 min).

=====================================================
 PROCESO FINALIZADO
=====================================================


### Métricas y Observabilidad (paso13)

Se consolidan las métricas del clúster: kubectl top, CloudWatch y estado general.


=====================================================
 KUBERNETES METRICS VALIDATION
=====================================================


=====================================================
 [1/9] VALIDANDO METRICS SERVER
=====================================================

metrics-server-68db5bc85f-bq4vc   1/1     Running   0          76m
metrics-server-68db5bc85f-bwnsx   1/1     Running   0          76m

  Esperando que Metrics Server este Ready...
pod/metrics-server-68db5bc85f-bq4vc condition met
pod/metrics-server-68db5bc85f-bwnsx condition met

=====================================================
 [2/9] VALIDANDO API METRICS
=====================================================

  Esperando que la API metrics.k8s.io este disponible...
  ✔ API metrics.k8s.io disponible (intento 1)

v1.metrics.eks.amazonaws.com      kube-system/eks-extension-metrics-api   True        80m
v1beta1.metrics.k8s.io            kube-system/metrics-server              True        76m

=====================================================
 [3/9] VALIDANDO NODOS
=====================================================

NAME                          STATUS   ROLES    AGE   VERSION
ip-10-0-12-180.ec2.internal   Ready    <none>   75m   v1.33.11-eks-3385e9b

=====================================================
 [4/9] METRICAS NODOS
=====================================================

  Recolectando metricas de nodos...
NAME                          CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
ip-10-0-12-180.ec2.internal   71m          3%       911Mi           12%         


=====================================================
 [5/9] METRICAS PODS
=====================================================

  Recolectando metricas de pods...
NAME                                CPU(cores)   MEMORY(bytes)   
alumnos-backend-6c6566dd55-wlm8c    4m           231Mi           
alumnos-db-dfd59ccdf-bcbvv          1m           49Mi            
alumnos-frontend-68c9467575-j2bkz   6m           3Mi             
alumnos-frontend-68c9467575-kkntn   8m           2Mi             


=====================================================
 [6/9] VALIDANDO HPA
=====================================================

NAME                   REFERENCE                     TARGETS        MINPODS   MAXPODS   REPLICAS   AGE
alumnos-backend-hpa    Deployment/alumnos-backend    cpu: 4%/70%    1         10        1          13m
alumnos-frontend-hpa   Deployment/alumnos-frontend   cpu: 14%/60%   2         6         2          11m

  Detalle de HPA:
Name:                                                  alumnos-backend-hpa
Namespace:                                             alumnos
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Sat, 13 Jun 2026 17:24:31 +0000
Reference:                                             Deployment/alumnos-backend
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  4% (4m) / 70%
Min replicas:                                          1
Max replicas:                                          10
Deployment pods:                                       1 current / 1 desired
Conditions:
  Type            Status  Reason              Message
  ----            ------  ------              -------
  AbleToScale     True    ReadyForNewScale    recommended size matches current size
  ScalingActive   True    ValidMetricFound    the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  False   DesiredWithinRange  the desired count is within the acceptable range
Events:
  Type     Reason                        Age                  From                       Message
  ----     ------                        ----                 ----                       -------
  Warning  FailedGetResourceMetric       8m57s                horizontal-pod-autoscaler  failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
  Warning  FailedComputeMetricsReplicas  8m57s                horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
  Warning  FailedGetResourceMetric       7m56s (x9 over 13m)  horizontal-pod-autoscaler  failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
  Warning  FailedComputeMetricsReplicas  7m56s (x9 over 13m)  horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)


Name:                                                  alumnos-frontend-hpa
Namespace:                                             alumnos
Labels:                                                <none>
Annotations:                                           <none>

=====================================================
 [7/9] ESTADO DEL CLUSTER
=====================================================

--- DEPLOYMENTS ---
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
alumnos-backend    1/1     1            1           13m
alumnos-db         1/1     1            1           15m
alumnos-frontend   2/2     2            2           11m

--- SERVICES ---
NAME               TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)        AGE
alumnos-backend    ClusterIP      172.20.68.114    <none>                                                                   8080/TCP       13m
alumnos-db         ClusterIP      172.20.13.102    <none>                                                                   5432/TCP       15m
alumnos-frontend   LoadBalancer   172.20.228.213   a9e4b2153d2df4f1eb03e40f1032ce71-223483394.us-east-1.elb.amazonaws.com   80:30174/TCP   11m

--- PODS ---
NAME                                READY   STATUS    RESTARTS   AGE
alumnos-backend-6c6566dd55-wlm8c    1/1     Running   0          9m13s
alumnos-db-dfd59ccdf-bcbvv          1/1     Running   0          15m
alumnos-frontend-68c9467575-j2bkz   1/1     Running   0          11m
alumnos-frontend-68c9467575-kkntn   1/1     Running   0          11m
hpa-test                            0/1     Error     0          8m3s

=====================================================
 [8/9] EVENTOS RECIENTES
=====================================================

11m         Normal    Killing                        pod/alumnos-frontend-68c9467575-wpw4h          Stopping container frontend
11m         Warning   FailedGetResourceMetric        horizontalpodautoscaler/alumnos-frontend-hpa   failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
11m         Warning   FailedComputeMetricsReplicas   horizontalpodautoscaler/alumnos-frontend-hpa   invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
11m         Warning   FailedComputeMetricsReplicas   horizontalpodautoscaler/alumnos-frontend-hpa   invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
11m         Warning   FailedGetResourceMetric        horizontalpodautoscaler/alumnos-frontend-hpa   failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
9m15s       Normal    Scheduled                      pod/alumnos-backend-6c6566dd55-wlm8c           Successfully assigned alumnos/alumnos-backend-6c6566dd55-wlm8c to ip-10-0-12-180.ec2.internal
9m15s       Normal    Killing                        pod/alumnos-backend-6c6566dd55-z4np5           Stopping container backend
9m15s       Normal    SuccessfulCreate               replicaset/alumnos-backend-6c6566dd55          Created pod: alumnos-backend-6c6566dd55-wlm8c
9m14s       Normal    Pulling                        pod/alumnos-backend-6c6566dd55-wlm8c           Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest"
9m14s       Normal    Started                        pod/alumnos-backend-6c6566dd55-wlm8c           Started container backend
9m14s       Normal    Created                        pod/alumnos-backend-6c6566dd55-wlm8c           Created container: backend
9m14s       Normal    Pulled                         pod/alumnos-backend-6c6566dd55-wlm8c           Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest" in 127ms (127ms including waiting). Image size: 216398104 bytes.
9m6s        Warning   FailedComputeMetricsReplicas   horizontalpodautoscaler/alumnos-backend-hpa    invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
9m6s        Warning   FailedGetResourceMetric        horizontalpodautoscaler/alumnos-backend-hpa    failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
8m22s       Warning   Unhealthy                      pod/alumnos-backend-6c6566dd55-wlm8c           Readiness probe failed: Get "http://10.0.12.204:8080/actuator/health/readiness": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
8m5s        Normal    Scheduled                      pod/hpa-test                                   Successfully assigned alumnos/hpa-test to ip-10-0-12-180.ec2.internal
8m4s        Normal    Pulling                        pod/hpa-test                                   Pulling image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest"
8m4s        Normal    Pulled                         pod/hpa-test                                   Successfully pulled image "461663648686.dkr.ecr.us-east-1.amazonaws.com/alumnos-backend:latest" in 149ms (149ms including waiting). Image size: 216398104 bytes.
8m4s        Normal    Created                        pod/hpa-test                                   Created container: hpa-test
8m4s        Normal    Started                        pod/hpa-test                                   Started container hpa-test

=====================================================
 [9/9] VALIDANDO CLOUDWATCH
=====================================================

--- LOG GROUPS ---
-------------------------------------------
|            DescribeLogGroups            |
+-----------------------------------------+
|  /aws/eks/laboratorio-eks/cluster       |
|  /aws/lambda/RedshiftEventSubscription  |
|  /aws/lambda/RedshiftOverwatch          |
|  /aws/lambda/RoleCreationFunction       |
+-----------------------------------------+

--- EKS LOGGING CONFIG ---
---------------------------
|     DescribeCluster     |
+-------------------------+
||    clusterLogging     ||
|+-----------------------+|
||        enabled        ||
|+-----------------------+|
||  True                 ||
|+-----------------------+|
|||        types        |||
||+---------------------+||
|||  api                |||
|||  audit              |||
|||  authenticator      |||
|||  controllerManager  |||
|||  scheduler          |||
||+---------------------+||

=====================================================
 RESUMEN DE OBSERVABILIDAD
=====================================================

  Metrics Server:     Running
Running
  HPA configurados:   2
  Pods totales:       5
  Nodes disponibles:  1

=====================================================
 OBSERVABILIDAD VALIDADA
=====================================================

  Metrics Server operativo
  HPA monitoreando CPU

=====================================================
 PROCESO FINALIZADO
=====================================================


---

## Resumen final

- **Inicio ejecución:** 2026-06-13 17:28:29
- **Fin ejecución:** 2026-06-13 17:38:35
- **Total pasos ejecutados:** 9

### ⏱️ Línea de tiempo de la etapa

| Evento | Hora |
|---|---|
| **Inicio** | 2026-06-13 17:28:29 |
| **Fin** | 2026-06-13 17:38:35 |
| **Duración total** | 10m 6s |

<!-- ================================================== -->
<!-- Fin del reporte de evidencia                       -->
<!-- ================================================== -->
