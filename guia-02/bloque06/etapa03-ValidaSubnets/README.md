# Etapa 03 — Valida Subnets EKS

## De qué se trata

Kubernetes necesita saber cuales calles son publicas y cuales privadas para crear LoadBalancers automaticamente. Esta etapa revisa que las subnets tengan las "etiquetas" (tags) correctas. Si faltan, los Services tipo LoadBalancer se quedan en estado `<pending>` para siempre.

## Qué hace en detalle

1. Obtiene el ID de la VPC `laboratorio-vpc`
2. Lista todas las subnets con sus tags
3. Verifica que cada subnet tenga los tags EKS requeridos:
   - `kubernetes.io/cluster/laboratorio-eks = shared` (todas)
   - `kubernetes.io/role/elb = 1` (publicas)
   - `kubernetes.io/role/internal-elb = 1` (privadas app)
4. Muestra el estado de los VPC Endpoints

## Diagrama

```mermaid
flowchart TB
    TAG["🏷 TAG COMUN<br/>kubernetes.io/cluster/<br/>laboratorio-eks = shared"]

    PUB["🟠 Subnets publicas<br/>tag: kubernetes.io/role/elb = 1"]
    APP["🔵 Subnets privadas app<br/>tag: kubernetes.io/role/internal-elb = 1"]
    DATA["🔵 Subnets privadas data<br/>solo cluster tag"]

    TAG --> PUB
    TAG --> APP
    TAG --> DATA

    PUB -.->|"sin este tag"| BAD["⚠ LoadBalancer = pending"]

    style TAG fill:#569A31,color:#fff
    style PUB fill:#FF9900,color:#000
    style APP fill:#1A476F,color:#fff
    style DATA fill:#1A476F,color:#ccc
    style BAD fill:#DD344C,color:#fff
```
