# VPC para EKS Privado con VPC Endpoints

Este diseño mantiene tu arquitectura 3-tier:

* Public Subnets → ELB / ALB
* Private App Subnets → EKS Worker Nodes
* Private Data Subnets → MySQL
* Sin NAT Gateway
* Acceso AWS mediante VPC Endpoints

---

# Objetivos del diseño

## Mantener:

* Arquitectura Multi-AZ
* Segmentación 3 capas
* Seguridad East-West
* Compatibilidad EKS
* Compatibilidad LoadBalancer
* CloudFormation
* Infraestructura como código

---

## Agregar:

* Endpoints ECR
* Endpoint S3
* Endpoint STS
* Endpoint CloudWatch Logs
* Endpoint EKS
* Endpoint EC2
* Endpoint ELB

---

# Endpoints requeridos

| Endpoint             | Tipo      | Uso                   |
| -------------------- | --------- | --------------------- |
| ecr.api              | Interface | API ECR               |
| ecr.dkr              | Interface | Pull imágenes Docker |
| s3                   | Gateway   | Layers imágenes      |
| sts                  | Interface | Tokens IAM            |
| logs                 | Interface | CloudWatch Logs       |
| ec2                  | Interface | ENI EKS               |
| eks                  | Interface | API EKS               |
| elasticloadbalancing | Interface | Load Balancer         |

---

# Security Group para Endpoints

Agregar este recurso:

```yaml
EndpointSecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupDescription: Security Group for VPC Endpoints
    VpcId: !Ref VPC

    SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 443
        ToPort: 443
        CidrIp: 10.0.0.0/16

    Tags:
      - Key: Name
        Value: eks-endpoints-sg
```

---

# Endpoint S3 (Gateway Endpoint)

```yaml
S3Endpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcId: !Ref VPC
    ServiceName: !Sub com.amazonaws.${AWS::Region}.s3
    VpcEndpointType: Gateway

    RouteTableIds:
      - !Ref PublicRouteTable
      - !Ref AppPrivateRouteTable
      - !Ref DataPrivateRouteTable
```

---

# Endpoint ECR API

```yaml
EcrApiEndpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcId: !Ref VPC
    ServiceName: !Sub com.amazonaws.${AWS::Region}.ecr.api
    VpcEndpointType: Interface

    PrivateDnsEnabled: true

    SecurityGroupIds:
      - !Ref EndpointSecurityGroup

    SubnetIds:
      - !Ref PrivateAppSubnetA
      - !Ref PrivateAppSubnetB
```

---

# Endpoint ECR Docker

```yaml
EcrDkrEndpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcId: !Ref VPC
    ServiceName: !Sub com.amazonaws.${AWS::Region}.ecr.dkr
    VpcEndpointType: Interface

    PrivateDnsEnabled: true

    SecurityGroupIds:
      - !Ref EndpointSecurityGroup

    SubnetIds:
      - !Ref PrivateAppSubnetA
      - !Ref PrivateAppSubnetB
```

---

# Endpoint STS

```yaml
StsEndpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcId: !Ref VPC
    ServiceName: !Sub com.amazonaws.${AWS::Region}.sts
    VpcEndpointType: Interface

    PrivateDnsEnabled: true

    SecurityGroupIds:
      - !Ref EndpointSecurityGroup

    SubnetIds:
      - !Ref PrivateAppSubnetA
      - !Ref PrivateAppSubnetB
```

---

# Endpoint CloudWatch Logs

```yaml
LogsEndpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcId: !Ref VPC
    ServiceName: !Sub com.amazonaws.${AWS::Region}.logs
    VpcEndpointType: Interface

    PrivateDnsEnabled: true

    SecurityGroupIds:
      - !Ref EndpointSecurityGroup

    SubnetIds:
      - !Ref PrivateAppSubnetA
      - !Ref PrivateAppSubnetB
```

---

# Endpoint EC2

```yaml
Ec2Endpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcId: !Ref VPC
    ServiceName: !Sub com.amazonaws.${AWS::Region}.ec2
    VpcEndpointType: Interface

    PrivateDnsEnabled: true

    SecurityGroupIds:
      - !Ref EndpointSecurityGroup

    SubnetIds:
      - !Ref PrivateAppSubnetA
      - !Ref PrivateAppSubnetB
```

---

# Endpoint EKS

```yaml
EksEndpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcId: !Ref VPC
    ServiceName: !Sub com.amazonaws.${AWS::Region}.eks
    VpcEndpointType: Interface

    PrivateDnsEnabled: true

    SecurityGroupIds:
      - !Ref EndpointSecurityGroup

    SubnetIds:
      - !Ref PrivateAppSubnetA
      - !Ref PrivateAppSubnetB
```

---

# Endpoint Elastic Load Balancing

```yaml
ElbEndpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcId: !Ref VPC
    ServiceName: !Sub com.amazonaws.${AWS::Region}.elasticloadbalancing
    VpcEndpointType: Interface

    PrivateDnsEnabled: true

    SecurityGroupIds:
      - !Ref EndpointSecurityGroup

    SubnetIds:
      - !Ref PrivateAppSubnetA
      - !Ref PrivateAppSubnetB
```

---

# Tags importantes para EKS

Tus subnets públicas deben conservar:

```yaml
Tags:
  - Key: kubernetes.io/role/elb
    Value: "1"

  - Key: kubernetes.io/cluster/nombre-eks
    Value: shared
```

---

# Tags para subnets privadas

Agregar:

```yaml
Tags:
  - Key: kubernetes.io/role/internal-elb
    Value: "1"

  - Key: kubernetes.io/cluster/nombre-eks
    Value: shared
```

---

# Resultado esperado

Con esta mejora:

* Los worker nodes privados podrán descargar imágenes desde ECR.
* CloudWatch funcionará sin NAT.
* Kubernetes podrá crear ELB automáticamente.
* EKS funcionará completamente privado.
* La arquitectura seguirá Multi-AZ.
* Se mantiene segmentación Front/App/Data.

---

# Arquitectura final

```text
Internet
   ↓
ALB / ELB
   ↓
Public Subnets
   ↓
Private App Subnets
(EKS Nodes + Pods)
   ↓
Private Data Subnets
(MySQL)

AWS Services
   ↑
VPC Endpoints
```

---

# Nivel arquitectónico alcanzado

La arquitectura queda alineada con:

* Amazon EKS privado
* Buenas prácticas AWS
* Seguridad cloud enterprise
* Networking Kubernetes real
* Infraestructura como código
* Arquitectura Multi-AZ
* Segmentación por capas
* Cloud Native Networking



# Crear infraestructura VPC con CloudFormation

## 1. Crear el stack

Ejecutar:

```bash
aws cloudformation create-stack \
  --stack-name laboratorio-vpc-completa \
  --template-body file://vpc.yaml \
  --region us-east-1
```

---

# Resultado esperado

CloudFormation comenzará a crear:

* VPC
* Subnets
* Route Tables
* Internet Gateway
* Security Groups
* VPC Endpoints

---

# 2. Monitorear creación del stack

## Ver estado general

Ejecutar cada 20–30 segundos:

```bash
aws cloudformation describe-stacks \
  --stack-name laboratorio-vpc-completa \
  --region us-east-1 \
  --query "Stacks[0].StackStatus" \
  --output text
```

---

# Estados posibles

| Estado             | Significado                    |
| ------------------ | ------------------------------ |
| CREATE_IN_PROGRESS | Creando recursos               |
| CREATE_COMPLETE    | Stack listo                    |
| CREATE_FAILED      | Error                          |
| ROLLBACK_COMPLETE  | Falló y AWS eliminó recursos |

---

# 3. Ver errores si falla

## Mostrar recursos que fallaron

```bash
aws cloudformation describe-stack-events \
  --stack-name laboratorio-vpc-completa \
  --region us-east-1 \
  --query "StackEvents[?ResourceStatus=='CREATE_FAILED'].[LogicalResourceId,ResourceStatusReason]" \
  --output table
```

---

# 4. Ver recursos creados

## Ver VPCs

```bash
aws ec2 describe-vpcs \
  --region us-east-1 \
  --query "Vpcs[*].[VpcId,CidrBlock]" \
  --output table
```

---

## Ver subnets

```bash
aws ec2 describe-subnets \
  --region us-east-1 \
  --query "Subnets[*].[SubnetId,CidrBlock,AvailabilityZone]" \
  --output table
```

---

## Ver route tables

```bash
aws ec2 describe-route-tables \
  --region us-east-1 \
  --query "RouteTables[*].[RouteTableId,VpcId]" \
  --output table
```

---

## Ver Internet Gateway

```bash
aws ec2 describe-internet-gateways \
  --region us-east-1 \
  --query "InternetGateways[*].[InternetGatewayId]" \
  --output table
```

---

## Ver Security Groups

```bash
aws ec2 describe-security-groups \
  --region us-east-1 \
  --query "SecurityGroups[*].[GroupName,GroupId]" \
  --output table
```

---

# 5. Ver VPC Endpoints

## Listar endpoints creados

```bash
aws ec2 describe-vpc-endpoints \
  --region us-east-1 \
  --query "VpcEndpoints[*].[VpcEndpointId,ServiceName,VpcEndpointType,State]" \
  --output table
```

---

# Resultado esperado

Deberías ver endpoints como:

| Service | Tipo      |
| ------- | --------- |
| ecr.api | Interface |
| ecr.dkr | Interface |
| s3      | Gateway   |
| sts     | Interface |
| logs    | Interface |
| eks     | Interface |

---

# 6. Ver outputs del stack

```bash
aws cloudformation describe-stacks \
  --stack-name laboratorio-vpc-completa \
  --region us-east-1 \
  --query "Stacks[0].Outputs" \
  --output table
```

---

# 7. Validar tags EKS en subnets

```bash
aws ec2 describe-subnets \
  --region us-east-1 \
  --query "Subnets[*].[SubnetId,Tags]" \
  --output table
```

Buscar:

```text
kubernetes.io/role/elb
kubernetes.io/role/internal-elb
kubernetes.io/cluster/nombre-eks
```

---

# 8. Validar DNS VPC

Muy importante para endpoints privados:

```bash
aws ec2 describe-vpcs \
  --region us-east-1 \
  --query "Vpcs[*].[VpcId,EnableDnsSupport,EnableDnsHostnames]" \
  --output table
```

Debe estar:

```text
true
true
```

---

# 9. Tiempo esperado

La creación completa puede tardar:

```text
5 a 15 minutos
```

Los VPC Endpoints Interface suelen ser lo más lento.

---

# 10. Eliminar stack (cleanup)

Cuando termines:

```bash
aws cloudformation delete-stack \
  --stack-name laboratorio-vpc-completa \
  --region us-east-1
```

---

# Resultado esperado final

Al finalizar correctamente tendrás:

* VPC Multi-AZ
* Subnets públicas
* Subnets privadas APP
* Subnets privadas DATA
* Route Tables
* Internet Gateway
* Security Groups
* VPC Endpoints privados
* Base lista para EKS privado

---
