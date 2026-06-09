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

## Paso 8 — Publicar en GitHub + Desplegar en Kubernetes

**¿Qué se hará?**
Crear los repositorios en GitHub con sus secrets (SSH key, AWS credenciales), hacer push del código fuente (DB, Backend, Frontend) para que GitHub Actions construya y publique las imágenes en ECR, esperar a que las imágenes estén disponibles y finalmente desplegar los manifiestos Kubernetes en el clúster EKS en orden: MySQL Database → Backend API → Frontend Web con LoadBalancer.

**Comando a ejecutar:**

```bash
cd ../etapa08-DespliegaK8s
bash ejecutar.sh
```

**¿Qué se logra?**
Los tres componentes (DB, Backend, Frontend) corriendo como Pods en el namespace `tienda` del clúster EKS, con sus Services, HPA y el Frontend expuesto mediante un LoadBalancer de AWS. Tiempo estimado: ~15-20 minutos (depende de GitHub Actions).

## Paso 9 — Validación final + Operación Avanzada (HPA, Healing, Métricas)

**¿Qué se hará?**
Verificar el estado completo del clúster y la aplicación (nodos, pods, services, HPA, métricas con `kubectl top`), obtener la URL del LoadBalancer del frontend, y ejecutar los scripts de operación avanzada del bloque 05: Auto-Healing (matar un pod y verificar que se recupera), HPA (validación y stress test), métricas de observabilidad y un stress test externo contra el LoadBalancer.

**Comando a ejecutar:**

```bash
cd ../etapa09-ValidaApp
bash ejecutar.sh
```

**¿Qué se logra?**
Validación completa de que la aplicación funciona correctamente en EKS, más la demostración de capacidades avanzadas: auto-healing (pods se recuperan automáticamente), escalado horizontal (HPA responde a carga), y métricas de CPU/memoria visibles. Tiempo estimado: ~5-10 minutos.

## Paso 10 — Conectividad + URL de la aplicación

**¿Qué se hará?**
Renovar el kubeconfig por si expiró, verificar la conectividad con el clúster y obtener la URL pública del LoadBalancer del frontend para acceder a la aplicación desde el navegador.

**Comando a ejecutar:**

```bash
cd ../etapa10-ConectividadURL
bash ejecutar.sh
```

**¿Qué se logra?**
La URL pública de la aplicación lista para abrir en el navegador y verificar que la tienda online funciona correctamente desde Internet.

## Paso 11 — Auditoría / Reporte completo del laboratorio

**¿Qué se hará?**
Generar un reporte completo del laboratorio que incluye: identidad AWS, estado de la VPC, subnets, VPC Endpoints, cluster EKS, NodeGroup, nodos Kubernetes, repositorios ECR con sus imágenes, deployments, services, pods, HPA, eventos de escalamiento y la URL de la aplicación. El reporte incluye un checklist de evaluación.

**Comando a ejecutar:**

```bash
cd ../etapa11-Auditoria
bash ejecutar.sh
```

**¿Qué se logra?**
Un archivo `reporte.txt` en `etapa11/` con toda la evidencia del laboratorio funcionando, listo para entregar o revisar. Cada componente se marca como `[X]` (funcionando) o `[ ]` (pendiente).

## Paso 12 — Limpieza total del laboratorio

**¿Qué se hará?**
Eliminar todos los recursos creados durante el laboratorio en orden inverso: namespace `tienda` (pods, services, ELB), stack CloudFormation del cluster EKS (incluye NodeGroup), stack CloudFormation de la VPC (VPC, subnets, endpoints), repositorios ECR, repositorios en GitHub, directorios locales clonados, entradas del kubeconfig y el `known_hosts` de github.com.

**Comando a ejecutar:**

```bash
cd ../etapa12-LimpiezaTotal
bash ejecutar.sh
```

**¿Qué se logra?**
Laboratorio completamente limpio: sin clusters EKS, sin VPC, sin repositorios ECR ni GitHub, sin rastros locales. El entorno queda listo para empezar desde cero en la etapa 01.
