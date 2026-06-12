# Reporte de Evidencia: Despliegue de VPC Multi-AZ con CloudFormation

**Fecha:** 2026-06-11 13:29:22
**Etapa:** etapa02-CreaVPC

---

## Resumen


**Stack CloudFormation:** `laboratorio-vpc-completa`  
**Región:** us-east-1  
**Template:** `../../bloque01-infraestructuraBase/paso01_iam-vpc/01-vpc/vpc.yaml`


---

### Paso 1: VPC Creada

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-11 13:29:26

```
$ aws ec2 describe-vpcs --region us-east-1 --filters 'Name=tag:Name,Values=laboratorio-vpc' --query 'Vpcs[*].[VpcId,CidrBlock,State]' --output table

-------------------------------------------------------
|                    DescribeVpcs                     |
+------------------------+---------------+------------+
|  vpc-0e0bde9b896e27970 |  10.0.0.0/16  |  available |
+------------------------+---------------+------------+
```

**Estado:** ✅ Completado


---

### Paso 2: Subnets creadas

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-11 13:29:28

```
$ VPC_ID=$(aws ec2 describe-vpcs --region us-east-1 --filters Name=tag:Name,Values=laboratorio-vpc --query 'Vpcs[0].VpcId' --output text); aws ec2 describe-subnets --region us-east-1 --filters Name=vpc-id,Values=$VPC_ID --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key=="/Name"].Value|[0]]' --output table

--------------------------------------------------------------------
|                          DescribeSubnets                         |
+---------------------------+-------------+---------------+--------+
|  subnet-0147393032c98a5d5 |  us-east-1a |  10.0.21.0/24 |  None  |
|  subnet-03ed152fa05c8b4da |  us-east-1a |  10.0.1.0/24  |  None  |
|  subnet-030a9353d09c7967e |  us-east-1b |  10.0.22.0/24 |  None  |
|  subnet-0ad54fb089b0b1d8f |  us-east-1b |  10.0.12.0/24 |  None  |
|  subnet-031653e7200b5ffad |  us-east-1a |  10.0.11.0/24 |  None  |
|  subnet-025b1820365ef31e5 |  us-east-1b |  10.0.2.0/24  |  None  |
+---------------------------+-------------+---------------+--------+
```

**Estado:** ✅ Completado


---

### Paso 3: VPC Endpoints creados

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-11 13:29:32

```
$ aws ec2 describe-vpc-endpoints --region us-east-1 --query 'VpcEndpoints[*].[ServiceName,State]' --output table

---------------------------------------------------------------
|                    DescribeVpcEndpoints                     |
+------------------------------------------------+------------+
|  com.amazonaws.us-east-1.s3                    |  available |
|  com.amazonaws.us-east-1.eks                   |  available |
|  com.amazonaws.us-east-1.ecr.api               |  available |
|  com.amazonaws.us-east-1.sts                   |  available |
|  com.amazonaws.us-east-1.elasticloadbalancing  |  available |
|  com.amazonaws.us-east-1.logs                  |  available |
|  com.amazonaws.us-east-1.ecr.dkr               |  available |
|  com.amazonaws.us-east-1.ec2                   |  available |
+------------------------------------------------+------------+
```

**Estado:** ✅ Completado


---

## Resumen final

- **Inicio ejecución:** 2026-06-11 13:29:22
- **Fin ejecución:** 2026-06-11 13:29:34
- **Total pasos ejecutados:** 3

### ⏱️ Línea de tiempo de la etapa

| Evento | Hora |
|---|---|
| **Inicio** | 2026-06-11 13:29:22 |
| **Fin** | 2026-06-11 13:29:34 |
| **Duración total** | 12s |

<!-- ================================================== -->
<!-- Fin del reporte de evidencia                       -->
<!-- ================================================== -->
