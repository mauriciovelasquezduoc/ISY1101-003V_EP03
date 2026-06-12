# Etapa 10 — Conectividad y URL

## De qué se trata

Si paso tiempo desde que empezaste, el token de AWS Academy probablemente expiro. Esta etapa renueva la conexion, verifica que todo siga funcionando y te muestra la URL de la aplicacion lista para copiar y pegar en el navegador. Es la etapa que ejecutas cada vez que vuelves al laboratorio.

## Qué hace en detalle

1. Te recuerda renovar `aws configure` si el token expiro
2. Refresca el kubeconfig (`aws eks update-kubeconfig`)
3. Verifica conectividad con el cluster (`kubectl get nodes`)
4. Muestra los servicios en el namespace alumnos
5. **Extrae y muestra la URL publica** en formato `http://...`

## Diagrama

```mermaid
flowchart LR
    CFG["🔑 aws configure<br/>renueva token"]
    KUBE["🔗 aws eks update-kubeconfig<br/>renueva conexion"]
    NODES["🖥 kubectl get nodes<br/>conectividad OK"]
    SVC["📋 kubectl get svc -n alumnos<br/>servicios"]
    URL["🌐 URL PUBLICA<br/>http://...elb.amazonaws.com"]

    CFG --> KUBE --> NODES --> SVC --> URL

    style CFG fill:#DD344C,color:#fff
    style KUBE fill:#2496ED,color:#fff
    style NODES fill:#569A31,color:#fff
    style SVC fill:#FF9900,color:#000
    style URL fill:#FF9900,color:#000
```
