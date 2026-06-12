# Bloque 06 — Diseño de la solución

## Vista general

Este laboratorio despliega una aplicación de alumnos online (frontend + backend + base de datos) en Amazon EKS usando infraestructura como código, CI/CD con GitHub Actions y observabilidad completa.

---

## Desglose paso a paso

### Paso 1 — Validar entorno Docker + AWS

| Aspecto | Detalle |
|---------|---------|
| **¿Qué se hace?** | Verifica que Docker, AWS CLI, kubectl y las credenciales AWS estén configuradas. Busca los roles IAM necesarios para EKS. |
| **¿Qué se logra?** | Entorno validado y listo para crear el clúster EKS. |

```mermaid
flowchart LR
    A[Docker] --> B[DevOps EKS Lab<br/>Contenedor]
    C[AWS CLI] --> B
    D[kubectl] --> B
    B --> E{Validación}
    E -->|OK| F[Entorno listo]
    E -->|Error| G[Corregir antes de continuar]
```

---

### Paso 2 — Crear VPC Multi-AZ con CloudFormation

| Aspecto | Detalle |
|---------|---------|
| **¿Qué se hace?** | Despliega una VPC completa con subnets públicas/privadas, NAT Gateway, VPC Endpoints y路由表 mediante CloudFormation. |
| **¿Qué se logra?** | Una VPC multi-AZ lista como base de red para el clúster EKS. |

```mermaid
flowchart LR
    A[Plantilla<br/>CloudFormation] --> B[Stack VPC]
    B --> C[Subnets<br/>públicas]
    B --> D[Subnets<br/>privadas]
    B --> E[VPC Endpoints]
    B --> F[NAT Gateway]
    C & D --> G[VPC multi-AZ<br/>lista]
```

---

### Paso 3 — Validar tags EKS en subnets

| Aspecto | Detalle |
|---------|---------|
| **¿Qué se hace?** | Verifica que las subnets tengan los tags requeridos por EKS: `kubernetes.io/cluster/laboratorio-eks = shared`, `kubernetes.io/role/elb` (públicas) y `kubernetes.io/role/internal-elb` (privadas). Valida los VPC Endpoints. |
| **¿Qué se logra?** | Subnets etiquetadas correctamente para que EKS pueda descubrirlas y los Load Balancers se aprovisionen en las subnets adecuadas. |

```mermaid
flowchart LR
    A[Subnets VPC] --> B{¿Tags EKS<br/>correctos?}
    B -->|Sí| C[EKS descubre subnets]
    B -->|No| D[Corregir tags]
    C --> E[Load Balancers<br/>en subnets correctas]
```

---

### Paso 4 — Crear Cluster EKS + Conectar kubectl

| Aspecto | Detalle |
|---------|---------|
| **¿Qué se hace?** | Despliega el clúster EKS `laboratorio-eks` con CloudFormation, incluyendo addons (vpc-cni, coredns, kube-proxy, metrics-server) y un NodeGroup SPOT. Configura kubectl y valida que el plano de control responda. |
| **¿Qué se logra?** | Clúster EKS completamente operativo con NodeGroup, kubectl conectado. Tiempo estimado: ~15 min. |

```mermaid
flowchart LR
    A[CloudFormation<br/>Cluster EKS] --> B[Plano de control<br/>EKS]
    A --> C[NodeGroup<br/>SPOT t3.large]
    A --> D[Addons<br/>vpc-cni, coredns,<br/>kube-proxy, metrics-server]
    B --> E[kubectl<br/>conectado]
    C --> F[Nodos listos]
    E & F --> G[Clúster EKS<br/>operativo]
```

---

### Paso 5 — Validar / Crear NodeGroup SPOT

| Aspecto | Detalle |
|---------|---------|
| **¿Qué se hace?** | Verifica que el NodeGroup `laboratorio-nodegroup` esté activo. Si ya fue creado en el paso anterior, espera a que termine de iniciar. Si no existe, lo crea con instancias t3.large SPOT en subnets privadas. |
| **¿Qué se logra?** | Workers nodes Ready en el cluster, NodeGroup en estado ACTIVE y pods de sistema (`kube-system`) corriendo sobre los nodos. |

```mermaid
flowchart LR
    A{NodeGroup<br/>¿existe?} -->|Sí| B[Esperar ACTIVE]
    A -->|No| C[Crear NodeGroup<br/>t3.large SPOT]
    B --> D[Nodos Ready]
    C --> D
    D --> E[Pods kube-system<br/>en ejecución]
```

---

### Paso 6 — Validar Metrics Server + CloudWatch

| Aspecto | Detalle |
|---------|---------|
| **¿Qué se hace?** | Verifica que metrics-server exponga CPU/Mem de nodos y pods (`kubectl top`), y que los logs del plano de control se envíen a CloudWatch mediante el VPC Endpoint. |
| **¿Qué se logra?** | Observabilidad completa: `kubectl top` funcionando (crítico para HPA en paso 8) y CloudWatch recibiendo logs del plano de control. |

```mermaid
flowchart LR
    A[Metrics Server] --> B[kubectl top<br/>nodes/pods]
    C[CloudWatch<br/>VPC Endpoint] --> D[Logs plano<br/>de control]
    B & D --> E[Observabilidad<br/>completa]
```

---

### Paso 7 — Crear repositorios en Amazon ECR

| Aspecto | Detalle |
|---------|---------|
| **¿Qué se hace?** | Crear tres repositorios privados en Amazon ECR: `alumnos-db`, `alumnos-backend`, `alumnos-frontend` para almacenar las imágenes Docker. |
| **¿Qué se logra?** | Repositorios ECR listos para recibir imágenes. Tiempo estimado: ~2 min. |

```mermaid
flowchart LR
    A[Amazon ECR] --> B[alumnos-db]
    A --> C[alumnos-backend]
    A --> D[alumnos-frontend]
    B & C & D --> E[3 repositorios<br/>listos para imágenes]
```

---

### Paso 8 — Publicar en GitHub + Desplegar en Kubernetes

| Aspecto | Detalle |
|---------|---------|
| **¿Qué se hace?** | Crea repositorios en GitHub, configura secrets (credenciales AWS), hace push del código fuente para que GitHub Actions construya y publique imágenes en ECR, y despliega los manifiestos Kubernetes en orden: PostgreSQL → Backend API → Frontend Web con LoadBalancer. |
| **¿Qué se logra?** | Los 3 componentes (DB, Backend, Frontend) corriendo como Pods en el namespace `alumnos`, con Services, HPA y Frontend expuesto mediante LoadBalancer. Tiempo estimado: ~15-20 min. |

```mermaid
flowchart LR
    subgraph GitHub
        A[Repositorios<br/>frontend, backend, db] --> B[GitHub Actions<br/>CI/CD]
        B --> C[Construye y<br/>publica imágenes]
    end
    subgraph AWS
        D[Amazon ECR] --> E[kubectl<br/>despliega]
        E --> F[Namespace alumnos]
        F --> G[PostgreSQL Pod]
        F --> H[Backend API Pod]
        F --> I[Frontend Pod<br/>+ LoadBalancer]
    end
    C --> D
    G --> H --> I
```

---

### Paso 9 — Validación final + Operación Avanzada

| Aspecto | Detalle |
|---------|---------|
| **¿Qué se hace?** | Verifica estado del clúster (nodos, pods, services, HPA, métricas), obtiene URL del LoadBalancer, y ejecuta operaciones avanzadas: Auto-Healing (matar un pod y verificar recuperación), HPA (stress test), métricas de observabilidad y stress test externo. |
| **¿Qué se logra?** | Validación completa de la aplicación funcionando + auto-healing, HPA responde a carga, métricas visibles. Tiempo estimado: ~5-10 min. |

```mermaid
flowchart LR
    A[Validación<br/>estado cluster] --> B[Auto-Healing<br/>pod kill & recover]
    A --> C[HPA<br/>Stress test]
    A --> D[Métricas<br/>kubectl top]
    A --> E[Stress test<br/>externo]
    B & C & D & E --> F[App validada<br/>+ capacidades avanzadas]
```

---

### Paso 10 — Conectividad + URL de la aplicación

| Aspecto | Detalle |
|---------|---------|
| **¿Qué se hace?** | Renueva kubeconfig si expiró, verifica conectividad con el clúster y obtiene la URL pública del LoadBalancer del frontend. |
| **¿Qué se logra?** | URL pública de la aplicación lista para abrir en el navegador. |

```mermaid
flowchart LR
    A[Renovar<br/>kubeconfig] --> B[Verificar<br/>conectividad]
    B --> C[Obtener URL<br/>LoadBalancer]
    C --> D[Aplicación<br/>desde Internet]
```

---

### Paso 11 — Auditoría / Reporte completo

| Aspecto | Detalle |
|---------|---------|
| **¿Qué se hace?** | Genera un reporte completo: identidad AWS, VPC, subnets, VPC Endpoints, cluster EKS, NodeGroup, nodos, ECR con imágenes, deployments, services, pods, HPA, eventos de escalamiento y URL de la aplicación. Incluye checklist de evaluación. |
| **¿Qué se logra?** | Archivo `reporte.txt` con toda la evidencia del laboratorio funcionando, listo para entregar. |

```mermaid
flowchart LR
    A[Auditoría] --> B[VPC + subnets]
    A --> C[Cluster EKS + nodos]
    A --> D[ECR + imágenes]
    A --> E[Deployments + pods]
    A --> F[HPA + eventos]
    A --> G[URL app]
    B & C & D & E & F & G --> H[reporte.txt<br/>completo]
```

---

### Paso 12 — Limpieza total

| Aspecto | Detalle |
|---------|---------|
| **¿Qué se hace?** | Elimina todos los recursos en orden inverso: namespace `alumnos`, stack CloudFormation del cluster EKS, stack CloudFormation de la VPC, repositorios ECR, repositorios GitHub, directorios locales clonados, entradas kubeconfig y known_hosts. |
| **¿Qué se logra?** | Laboratorio completamente limpio, listo para empezar desde cero. |

```mermaid
flowchart LR
    A[Limpiar] --> B[Namespace alumnos<br/>pods + ELB]
    B --> C[Stack EKS<br/>cluster + NodeGroup]
    C --> D[Stack VPC<br/>subnets + endpoints]
    D --> E[ECR + GitHub repos]
    E --> F[Archivos locales]
    F --> G[Entorno limpio]
```

---

## Diagrama acumulativo de toda la solución

```mermaid
flowchart TB
    subgraph Paso1[Paso 1: Validación]
        A1[Docker + AWS CLI<br/>+ kubectl] --> A2[Entorno validado]
    end

    subgraph Paso2[Paso 2: Red]
        B1[CloudFormation<br/>VPC Multi-AZ] --> B2[VPC + subnets<br/>+ endpoints]
    end

    subgraph Paso3[Paso 3: Tags]
        C1[Subnets] --> C2[Tags EKS<br/>correctos]
    end

    subgraph Paso4[Paso 4: Cluster]
        D1[CloudFormation<br/>EKS] --> D2[Cluster EKS<br/>+ kubectl]
    end

    subgraph Paso5[Paso 5: Nodos]
        E1[NodeGroup<br/>SPOT t3.large] --> E2[Nodos Ready]
    end

    subgraph Paso6[Paso 6: Monitoreo]
        F1[Metrics Server] --> F2[kubectl top]
        F3[CloudWatch] --> F4[Logs EKS]
    end

    subgraph Paso7[Paso 7: ECR]
        G1[Amazon ECR] --> G2[3 repos<br/>imágenes Docker]
    end

    subgraph Paso8[Paso 8: Deploy]
        H1[GitHub repos<br/>+ Secrets] --> H2[GitHub Actions<br/>CI/CD]
        H2 --> H3[Imágenes en ECR]
        H3 --> H4[kubectl deploy]
        H4 --> H5[PostgreSQL]
        H4 --> H6[Backend API]
        H4 --> H7[Frontend<br/>+ LoadBalancer]
    end

    subgraph Paso9[Paso 9: Operación avanzada]
        I1[Validación] --> I2[Auto-Healing]
        I1 --> I3[HPA Stress]
        I1 --> I4[Métricas]
    end

    subgraph Paso10[Paso 10: Conectividad]
        J1[kubeconfig] --> J2[URL pública]
    end

    subgraph Paso11[Paso 11: Auditoría]
        K1[Recolectar<br/>evidencia] --> K2[reporte.txt]
    end

    subgraph Paso12[Paso 12: Limpieza]
        L1[Eliminar todo<br/>en orden inverso] --> L2[Entorno limpio]
    end

    A2 --> B1
    B2 --> C1
    C2 --> D1
    D2 --> E1
    E2 --> F1
    E2 --> F3
    F2 --> G1
    G2 --> H1
    H5 & H6 & H7 --> I1
    I1 --> J1
    J2 --> K1
    K2 --> L1
```
