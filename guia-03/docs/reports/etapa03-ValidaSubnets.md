# Reporte de Evidencia: Validación de Tags EKS en Subnets

**Fecha:** 2026-06-11 13:30:21
**Etapa:** etapa03-ValidaSubnets

---

## Resumen


---

### Paso 1: Listar subnets de la VPC

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-11 13:30:23

```
$ aws ec2 describe-subnets --region us-east-1 --filters Name=vpc-id,Values=vpc-0e0bde9b896e27970 --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key=="/Name"].Value|[0]]' --output table

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

### Paso 2: Validar tags EKS requeridos

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-11 13:30:25

```
$ echo 'Tags necesarios:'; echo '  - kubernetes.io/cluster/laboratorio-eks = shared'; echo '  - kubernetes.io/role/elb = 1 (subnets publicas)'; echo '  - kubernetes.io/role/internal-elb = 1 (subnets privadas app)'; echo ''; aws ec2 describe-subnets --region us-east-1 --filters Name=vpc-id,Values=vpc-0e0bde9b896e27970 --output json | python3 -c "import json, sys; data = json.load(sys.stdin); print(f'{'Subnet':25s} {'AZ':15s} {'cluster':15s} {'elb':8s} {'internal-elb':12s}'); print('-'*75); [print(f'{s["SubnetId"]:25s} {s["AvailabilityZone"]:15s} { {t["Key"]: t["Value"] for t in s.get("Tags", [])}.get("kubernetes.io/cluster/laboratorio-eks", "FALTA"):15s} { {t["Key"]: t["Value"] for t in s.get("Tags", [])}.get("kubernetes.io/role/elb", "-"):8s} { {t["Key"]: t["Value"] for t in s.get("Tags", [])}.get("kubernetes.io/role/internal-elb", "-"):12s}') for s in data['Subnets']]"

Tags necesarios:
  - kubernetes.io/cluster/laboratorio-eks = shared
  - kubernetes.io/role/elb = 1 (subnets publicas)
  - kubernetes.io/role/internal-elb = 1 (subnets privadas app)

  File "<string>", line 1
    import json, sys; data = json.load(sys.stdin); print(f'{'Subnet':25s} {'AZ':15s} {'cluster':15s} {'elb':8s} {'internal-elb':12s}'); print('-'*75); [print(f'{s[SubnetId]:25s} {s[AvailabilityZone]:15s} { {t[Key]: t[Value] for t in s.get(Tags, [])}.get(kubernetes.io/cluster/laboratorio-eks, FALTA):15s} { {t[Key]: t[Value] for t in s.get(Tags, [])}.get(kubernetes.io/role/elb, -):8s} { {t[Key]: t[Value] for t in s.get(Tags, [])}.get(kubernetes.io/role/internal-elb, -):12s}') for s in data['Subnets']]
                                                                                                                                                                                                                                                                                                                                                                  ^
SyntaxError: f-string: expecting '=', or '!', or ':', or '}'
Exception ignored while flushing sys.stdout:
BrokenPipeError: [Errno 32] Broken pipe
```


---

### Paso 3: VPC Endpoints disponibles

**IE Relacionado:** IE1
**Hora ejecución:** 2026-06-11 13:30:27

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

- **Inicio ejecución:** 2026-06-11 13:30:21
- **Fin ejecución:** 2026-06-11 13:30:29
- **Total pasos ejecutados:** 3

### ⏱️ Línea de tiempo de la etapa

| Evento | Hora |
|---|---|
| **Inicio** | 2026-06-11 13:30:21 |
| **Fin** | 2026-06-11 13:30:29 |
| **Duración total** | 8s |

<!-- ================================================== -->
<!-- Fin del reporte de evidencia                       -->
<!-- ================================================== -->
