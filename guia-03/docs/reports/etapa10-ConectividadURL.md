# Reporte de Evidencia: Conectividad y URL de la aplicación

**Fecha:** 2026-06-13 17:38:47
**Etapa:** etapa10-ConectividadURL

---

## Resumen


---

### Paso 1: Conectividad con el clúster

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 17:38:49

```
$ kubectl get nodes -o wide

NAME                          STATUS   ROLES    AGE   VERSION                INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                    CONTAINER-RUNTIME
ip-10-0-12-180.ec2.internal   Ready    <none>   75m   v1.33.11-eks-3385e9b   10.0.12.180   <none>        Amazon Linux 2023.11.20260526   6.12.88-119.157.amzn2023.x86_64   containerd://2.2.3+unknown
```

**Estado:** ✅ Completado


---

### Paso 2: Servicios en namespace alumnos

**IE Relacionado:** IE2
**Hora ejecución:** 2026-06-13 17:38:51

```
$ kubectl get svc -n alumnos

NAME               TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)        AGE
alumnos-backend    ClusterIP      172.20.68.114    <none>                                                                   8080/TCP       14m
alumnos-db         ClusterIP      172.20.13.102    <none>                                                                   5432/TCP       15m
alumnos-frontend   LoadBalancer   172.20.228.213   a9e4b2153d2df4f1eb03e40f1032ce71-223483394.us-east-1.elb.amazonaws.com   80:30174/TCP   12m
```

**Estado:** ✅ Completado


### URL Pública

La aplicación está disponible en:

```
http://a9e4b2153d2df4f1eb03e40f1032ce71-223483394.us-east-1.elb.amazonaws.com
```

> Esta URL debe funcionar en el navegador. Si no carga, espera 2-3 min
> adicionales para que el LoadBalancer de AWS se aprovisione completamente.


---

### Paso 3: Logs del backend (últimas líneas)

**IE Relacionado:** IE6 + IE7
**Hora ejecución:** 2026-06-13 17:38:54

```
$ kubectl logs -n alumnos -l app=alumnos-backend --tail=10 2>/dev/null || echo '(logs no disponibles)'


2026-06-13T17:29:46.149Z  INFO 1 --- [           main] r$InitializeUserDetailsManagerConfigurer : Global AuthenticationManager configured with UserDetailsService bean with name inMemoryUserDetailsManager
2026-06-13T17:29:51.068Z  INFO 1 --- [           main] o.s.b.a.e.web.EndpointLinksResolver      : Exposing 2 endpoints beneath base path '/actuator'
2026-06-13T17:29:51.761Z  INFO 1 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port 8080 (http) with context path '/'
2026-06-13T17:29:51.941Z  INFO 1 --- [           main] cl.duocuc.alumnos.DemoApplication        : Started DemoApplication in 39.887 seconds (process running for 43.517)
2026-06-13T17:29:52.560Z  WARN 1 --- [           main] o.s.core.events.SpringDocAppInitializer  : SpringDoc /v3/api-docs endpoint is enabled by default. To disable it in production, set the property 'springdoc.api-docs.enabled=false'
2026-06-13T17:29:52.561Z  WARN 1 --- [           main] o.s.core.events.SpringDocAppInitializer  : SpringDoc /swagger-ui.html endpoint is enabled by default. To disable it in production, set the property 'springdoc.swagger-ui.enabled=false'
2026-06-13T17:30:00.149Z  INFO 1 --- [nio-8080-exec-1] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring DispatcherServlet 'dispatcherServlet'
2026-06-13T17:30:00.150Z  INFO 1 --- [nio-8080-exec-1] o.s.web.servlet.DispatcherServlet        : Initializing Servlet 'dispatcherServlet'
2026-06-13T17:30:00.153Z  INFO 1 --- [nio-8080-exec-1] o.s.web.servlet.DispatcherServlet        : Completed initialization in 2 ms
```

**Estado:** ✅ Completado


---

### Paso 4: Logs del frontend (últimas líneas)

**IE Relacionado:** IE6 + IE7
**Hora ejecución:** 2026-06-13 17:38:56

```
$ kubectl logs -n alumnos -l app=alumnos-frontend --tail=10 2>/dev/null || echo '(logs no disponibles)'

10.0.12.180 - - [13/Jun/2026:17:38:03 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:11 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:13 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:23 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:26 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:33 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:41 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:43 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:53 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:56 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:03 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:11 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:13 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:23 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:26 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:33 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:41 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:43 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:53 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
10.0.12.180 - - [13/Jun/2026:17:38:56 +0000] "GET / HTTP/1.1" 200 469 "-" "kube-probe/1.33" "-"
```

**Estado:** ✅ Completado


---

## Resumen final

- **Inicio ejecución:** 2026-06-13 17:38:47
- **Fin ejecución:** 2026-06-13 17:38:59
- **Total pasos ejecutados:** 4

### ⏱️ Línea de tiempo de la etapa

| Evento | Hora |
|---|---|
| **Inicio** | 2026-06-13 17:38:47 |
| **Fin** | 2026-06-13 17:38:59 |
| **Duración total** | 12s |

<!-- ================================================== -->
<!-- Fin del reporte de evidencia                       -->
<!-- ================================================== -->
