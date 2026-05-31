# Etapa 02 — Crea VPC

## De qué se trata

Imagina que necesitas un terreno privado con calles, portones y servicios basicos antes de construir. Esta etapa crea ese "terreno" en AWS: una VPC (red privada virtual) con subnets publicas y privadas en dos zonas de disponibilidad, mas todos los "portones" (VPC Endpoints) para que los servicios AWS se comuniquen sin salir a internet.

## Qué hace en detalle

1. Toma el template CloudFormation `vpc.yaml` (del Bloque 1)
2. Lo despliega como stack `laboratorio-vpc-completa`
3. Espera a que todos los recursos esten creados
4. Muestra la VPC, las 6 subnets y los 8 VPC Endpoints creados

**Recursos creados:** VPC 10.0.0.0/16 · Internet Gateway · 2 subnets publicas · 2 subnets privadas app · 2 subnets privadas data · 8 VPC Endpoints (S3, ECR, STS, CloudWatch, EC2, EKS, ELB)

## Diagrama

```mermaid
flowchart TB
    CF["📦 CloudFormation<br/>Stack: laboratorio-vpc-completa"]

    subgraph VPC["🌐 VPC 10.0.0.0/16"]
        subgraph AZA["AZ us-east-1a"]
            PA["public-subnet-a<br/>10.0.1.0/24"]
            AA["private-app-a<br/>10.0.11.0/24"]
            DA["private-data-a<br/>10.0.21.0/24"]
        end
        subgraph AZB["AZ us-east-1b"]
            PB["public-subnet-b<br/>10.0.2.0/24"]
            AB["private-app-b<br/>10.0.12.0/24"]
            DB["private-data-b<br/>10.0.22.0/24"]
        end
    end

    EP["🔌 VPC Endpoints<br/>ECR · STS · CloudWatch<br/>EC2 · EKS · ELB · S3"]

    CF --> VPC
    VPC --> EP

    style CF fill:#FF9900,color:#000
    style VPC fill:#1A476F,color:#fff
    style PA fill:#FF9900,color:#000
    style PB fill:#FF9900,color:#000
    style AA fill:#1A476F,color:#fff
    style AB fill:#1A476F,color:#fff
    style DA fill:#1A476F,color:#ccc
    style DB fill:#1A476F,color:#ccc
    style EP fill:#569A31,color:#fff
```
