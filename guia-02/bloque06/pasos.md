# Bloque 06 — Pasos


## Requisito previo

```bash
docker build -t devops-eks-lab .
```

Debes estar dentro del contenedor Docker `devops-eks-lab` con las credenciales de AWS Academy configuradas:

# Desde Windows PowerShell / CMD (fuera del contenedor):
docker run -it -v "..":/root/work -v ~/.aws:/root/.aws -v /var/run/docker.sock:/var/run/docker.sock devops-eks-lab

# Ya dentro del contenedor, configurar AWS:
aws configure



## Paso 1 — Validar entorno Docker + AWS

**¿Qué se hará?**
Verificar que Docker, AWS CLI, kubectl y las credenciales AWS estén correctamente configuradas antes de comenzar el laboratorio. También se buscan los roles IAM necesarios para EKS.

**Comando a ejecutar:**

```bash
cd bloque06/etapa01-ValidaEntorno
bash ejecutar.sh
```

**¿Qué se logra?**
Un entorno validado y listo para crear el clúster EKS. Si todos los checks pasan, se puede continuar con la etapa 02.

## Paso 2 — Crear VPC Multi-AZ con CloudFormation

**¿Qué se hará?**
Desplegar una VPC completa (subnets públicas/privadas, endpoints) usando CloudFormation desde la plantilla definida en el bloque 01 de infraestructura base.

**Comando a ejecutar:**

```bash
cd ../etapa02-CreaVPC
bash ejecutar.sh
```

**¿Qué se logra?**
Una VPC multi-AZ lista con subnets, endpoints y el stack de CloudFormation creado. Base de red para el clúster EKS.

## Paso 3 — Validar tags EKS en subnets

**¿Qué se hará?**
Verificar que las subnets de la VPC tengan los tags que EKS necesita para funcionar: `kubernetes.io/cluster/laboratorio-eks = shared`, `kubernetes.io/role/elb` (públicas) y `kubernetes.io/role/internal-elb` (privadas). También se validan los VPC Endpoints.

**Comando a ejecutar:**

```bash
cd ../etapa03-ValidaSubnets
bash ejecutar.sh
```

**¿Qué se logra?**
Subnets etiquetadas correctamente para que EKS pueda descubrirlas y los Load Balancers se aprovisionen en las subnets adecuadas.

## Paso 4 — Crear Cluster EKS + Conectar kubectl

**¿Qué se hará?**
Desplegar el cluster EKS `laboratorio-eks` usando CloudFormation, con addons (vpc-cni, coredns, kube-proxy, metrics-server) y un NodeGroup SPOT. Luego se configura kubectl para conectarse al cluster y se valida que el plano de control responda.

**Comando a ejecutar:**

```bash
cd ../etapa04-CreaClusterEKS
bash ejecutar.sh
```

**¿Qué se logra?**
Un cluster EKS completamente operativo con su NodeGroup, kubectl conectado y el plano de control respondiendo. Tiempo estimado: ~15 minutos.

## Paso 5 — Validar / Crear NodeGroup SPOT

**¿Qué se hará?**
Verificar que el NodeGroup `laboratorio-nodegroup` esté activo. Si ya fue creado por CloudFormation en la etapa anterior, se espera a que termine de iniciar. Si no existe, se crea desde cero con instancias t3.large SPOT en las subnets privadas de aplicación.

**Comando a ejecutar:**

```bash
cd ../etapa05-CreaNodeGroup
bash ejecutar.sh
```

**¿Qué se logra?**
Workers nodes Ready en el cluster, con el NodeGroup en estado ACTIVE y los pods de sistema (`kube-system`) corriendo correctamente sobre los nodos.

## Paso 6 — Validar Metrics Server + CloudWatch

**¿Qué se hará?**
Verificar que el monitoreo del cluster funcione: metrics-server exponiendo CPU/Mem de nodos y pods (`kubectl top`), y los logs del plano de control enviándose a CloudWatch a través del VPC Endpoint.

**Comando a ejecutar:**

```bash
cd ../etapa06-ValidaObservabilidad
bash ejecutar.sh
```

**¿Qué se logra?**
Observabilidad completa del cluster: `kubectl top nodes/pods` funcionando (crítico para HPA en etapa08) y CloudWatch recibiendo logs del plano de control EKS.

## Paso 7 — Crear repositorios en Amazon ECR

**¿Qué se hará?**
Crear tres repositorios privados en Amazon ECR (`tienda-db`, `tienda-backend`, `tienda-frontend`) donde se almacenarán las imágenes de los contenedores. Las imágenes se publicarán después mediante GitHub Actions (CI/CD). Esta etapa no depende del cluster EKS.

**Comando a ejecutar:**

```bash
cd ../etapa07-PublicaECR
bash ejecutar.sh
```

**¿Qué se logra?**
Tres repositorios ECR listos para recibir imágenes Docker. Tiempo estimado: ~2 minutos.
