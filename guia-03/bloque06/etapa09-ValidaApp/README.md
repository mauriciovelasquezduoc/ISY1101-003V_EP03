# Etapa 09 — Valida la Aplicacion

## De qué se trata

La app ya esta desplegada. Esta etapa hace un chequeo completo para confirmar que todo funciona: nodos del cluster, Pods de la aplicacion, servicios de red, HPAs configurados, y obtiene la URL publica para acceder a la aplicacion desde el navegador.

## Qué hace en detalle

1. Muestra los nodos del cluster (`kubectl get nodes`)
2. Lista todos los Pods en el namespace `alumnos`
3. Muestra los Services (incluyendo el LoadBalancer)
4. Verifica los HPAs configurados
5. Muestra los Deployments y Endpoints
6. Ejecuta `kubectl top` para ver uso de CPU/Memoria
7. **Extrae la URL publica del LoadBalancer**

## Diagrama

```mermaid
flowchart LR
    N1["📋 kubectl get nodes"]
    N2["📋 kubectl get pods<br/>-n alumnos"]
    N3["📋 kubectl get svc<br/>-n alumnos"]
    N4["📋 kubectl get hpa<br/>-n alumnos"]
    N5["📋 kubectl top pods<br/>-n alumnos"]
    URL["🌐 URL PUBLICA<br/>http://*.elb.amazonaws.com"]

    N1 --> N2 --> N3 --> N4 --> N5 --> URL

    style N1 fill:#569A31,color:#fff
    style N2 fill:#569A31,color:#fff
    style N3 fill:#569A31,color:#fff
    style N4 fill:#569A31,color:#fff
    style N5 fill:#569A31,color:#fff
    style URL fill:#FF9900,color:#000
```
