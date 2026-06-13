# Reporte de Evidencia: Despliegue de VPC Multi-AZ con CloudFormation

**Fecha:** 2026-06-13 15:46:11
**Etapa:** etapa02-CreaVPC

---

## Resumen


**Stack CloudFormation:** `laboratorio-vpc-completa`  
**Región:** us-east-1  
**Template:** `../../bloque01-infraestructuraBase/paso01_iam-vpc/01-vpc/vpc.yaml`


---

### Paso 1: VPC Creada

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 15:47:54

```
$ aws ec2 describe-vpcs --region us-east-1 --filters 'Name=tag:Name,Values=laboratorio-vpc' --query 'Vpcs[*].[VpcId,CidrBlock,State]' --output table

-------------------------------------------------------
|                    DescribeVpcs                     |
+------------------------+---------------+------------+
|  vpc-040dcd476deec12ed |  10.0.0.0/16  |  available |
+------------------------+---------------+------------+
```

**Estado:** ✅ Completado


---

### Paso 2: Subnets creadas

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 15:47:57

```
$ VPC_ID=$(aws ec2 describe-vpcs --region us-east-1 --filters Name=tag:Name,Values=laboratorio-vpc --query 'Vpcs[0].VpcId' --output text); aws ec2 describe-subnets --region us-east-1 --filters Name=vpc-id,Values=$VPC_ID --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key=="/Name"].Value|[0]]' --output table

--------------------------------------------------------------------
|                          DescribeSubnets                         |
+---------------------------+-------------+---------------+--------+
|  subnet-04990711edfb8419c |  us-east-1b |  10.0.12.0/24 |  None  |
|  subnet-0dbc6460b11a415a4 |  us-east-1a |  10.0.11.0/24 |  None  |
|  subnet-0f86e23b9f3969288 |  us-east-1a |  10.0.1.0/24  |  None  |
|  subnet-04eb10eeb160b730b |  us-east-1a |  10.0.21.0/24 |  None  |
|  subnet-0240dea3a5e912dfb |  us-east-1b |  10.0.2.0/24  |  None  |
|  subnet-0c5bb79e2b81ef2b6 |  us-east-1b |  10.0.22.0/24 |  None  |
+---------------------------+-------------+---------------+--------+
```

**Estado:** ✅ Completado


---

### Paso 3: VPC Endpoints creados

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-13 15:48:04

```
$ aws ec2 describe-vpc-endpoints --region us-east-1 --query 'VpcEndpoints[*].[ServiceName,State]' --output table

---------------------------------------------------------------
|                    DescribeVpcEndpoints                     |
+------------------------------------------------+------------+
|  com.amazonaws.us-east-1.s3                    |  available |
|  com.amazonaws.us-east-1.ec2                   |  available |
|  com.amazonaws.us-east-1.ecr.api               |  available |
|  com.amazonaws.us-east-1.sts                   |  available |
|  com.amazonaws.us-east-1.logs                  |  available |
|  com.amazonaws.us-east-1.ecr.dkr               |  available |
|  com.amazonaws.us-east-1.eks                   |  available |
|  com.amazonaws.us-east-1.elasticloadbalancing  |  available |
+------------------------------------------------+------------+
```

**Estado:** ✅ Completado


---

## Resumen final

- **Inicio ejecución:** 2026-06-13 15:46:11
- **Fin ejecución:** 2026-06-13 15:48:07
- **Total pasos ejecutados:** 3

### ⏱️ Línea de tiempo de la etapa

| Evento | Hora |
|---|---|
| **Inicio** | 2026-06-13 15:46:11 |
| **Fin** | 2026-06-13 15:48:07 |
| **Duración total** | 1m 56s |

<!-- ================================================== -->
<!-- Fin del reporte de evidencia                       -->
<!-- ================================================== -->
