# Bloque 6 — Ejecucion rapida paso a paso (Fast Track)

> **Objetivo:** Ejecutar secuencialmente todos los comandos necesarios para llegar del paso00 al paso09 de forma automatizada. Cada etapa tiene su propio README con explicacion coloquial y diagrama.

---

## Requisito previo

```bash
docker build -t devops-eks-lab .
```

Debes estar dentro del contenedor Docker `devops-eks-lab` con las credenciales de AWS Academy configuradas:

```bash
# Desde Windows PowerShell / CMD (fuera del contenedor):
docker run -it -v "..":/root/work -v ~/.aws:/root/.aws -v /var/run/docker.sock:/var/run/docker.sock devops-eks-lab

# Ya dentro del contenedor, configurar AWS:
aws configure
```

---

## Como usar este bloque

Cada etapa es autocontenida. Entra al directorio y ejecuta el script:

```bash
cd bloque06/etapa01-ValidaEntorno
bash ejecutar.sh
```

Cuando termine, sube un nivel y continua con la siguiente:

```bash
cd ../etapa02-CreaVPC
bash ejecutar.sh
```

...y asi sucesivamente.

---

## Si hay error de formato Windows (CRLF)

```bash
fix-crlf
# o
fixwin
```

---

## Etapas

| Etapa | Duracion | Carpeta | Que hace |
|-------|----------|---------|----------|
| **01** | ~1 min | `etapa01-ValidaEntorno` | Valida herramientas (aws, kubectl, docker), credenciales AWS, roles IAM |
| **02** | ~3 min | `etapa02-CreaVPC` | Despliega VPC con CloudFormation (6 subnets, VPC Endpoints, IGW) |
| **03** | ~1 min | `etapa03-ValidaSubnets` | Verifica tags EKS en subnets para LoadBalancer |
| **04** | ~15 min | `etapa04-CreaClusterEKS` | Crea cluster EKS + addons + conecta kubectl |
| **05** | ~10 min | `etapa05-CreaNodeGroup` | Valida/crea NodeGroup SPOT (t3.large) |
| **06** | ~2 min | `etapa06-ValidaObservabilidad` | Metrics Server (`kubectl top`) + CloudWatch Logs |
| **07** | ~10 min | `etapa07-PublicaECR` | Crea 3 repos ECR, build y push (db, backend, frontend) |
| **08** | ~5 min | `etapa08-DespliegaK8s` | Despliega app 3-capas: MySQL → Backend → Frontend + HPA |
| **09** | ~1 min | `etapa09-ValidaApp` | Validacion final de todos los recursos + URL |
| **10** | ~1 min | `etapa10-ConectividadURL` | Conectividad, renueva kubeconfig, URL publica |
| **11** | ~1 min | `etapa11-Auditoria` | Reporte completo + checklist de evaluacion |
| **12** | ~20 min | `etapa12-LimpiezaTotal` | Borra todo (EKS, VPC, ECR, namespace) |

---

## ⚡ Modo paralelo (recomendado — ahorra ~15 min)

La **etapa07 (ECR)** no depende del cluster EKS. Solo necesita la VPC de la etapa02.
Ejecutala en una **segunda terminal** mientras la etapa04 crea el cluster.

```
                    TERMINAL 1                                          TERMINAL 2
                    ─────────                                          ─────────
min  0  ┌───────   etapa01-ValidaEntorno
min  1  │          etapa02-CreaVPC
min  4  │          etapa03-ValidaSubnets
min  5  │          etapa04-CreaClusterEKS (~15 min) ────────────────  etapa07-PublicaECR (~10 min)
        │          ████████████████████████████████                   ██████████
min 15  │          ████████████████████████████████                   ✅ listo
min 20  │          etapa05-CreaNodeGroup
min 30  │          etapa06-ValidaObservabilidad
min 32  │          etapa08-DespliegaK8s ◄───────────────────────────  (imagenes listas)
min 37  │          etapa09-ValidaApp
min 38  │          etapa10-ConectividadURL
min 39  └───────   etapa11-Auditoria
```

### Comandos — modo paralelo

```bash
# ========== TERMINAL 1 ==========

fix-crlf
cd /root/work/bloque06/etapa01-ValidaEntorno && bash ejecutar.sh
cd /root/work/bloque06/etapa02-CreaVPC && bash ejecutar.sh
cd /root/work/bloque06/etapa03-ValidaSubnets && bash ejecutar.sh

# ⚡ LANZAR EN PARALELO AHORA ⚡
# Terminal 1:
cd /root/work/bloque06/etapa04-CreaClusterEKS && bash ejecutar.sh

# Terminal 2 (abre otra ventana del contenedor):
cd /root/work/bloque06/etapa07-PublicaECR && bash ejecutar.sh

# Cuando TERMINAL 1 termine etapa04, seguir:
cd /root/work/bloque06/etapa05-CreaNodeGroup && bash ejecutar.sh
cd /root/work/bloque06/etapa06-ValidaObservabilidad && bash ejecutar.sh
cd /root/work/bloque06/etapa08-DespliegaK8s && bash ejecutar.sh
cd /root/work/bloque06/etapa09-ValidaApp && bash ejecutar.sh
cd /root/work/bloque06/etapa10-ConectividadURL && bash ejecutar.sh
cd /root/work/bloque06/etapa11-Auditoria && bash ejecutar.sh
```

### Para abrir una segunda terminal dentro del mismo contenedor

```bash
# Desde Windows PowerShell / CMD (fuera del contenedor):
docker exec -it $(docker ps -q --filter ancestor=devops-eks-lab) bash
```

---

## 🐢 Modo secuencial (si solo tienes una terminal)

```bash
fix-crlf
cd /root/work/bloque06/etapa01-ValidaEntorno && bash ejecutar.sh
cd /root/work/bloque06/etapa02-CreaVPC && bash ejecutar.sh
cd /root/work/bloque06/etapa03-ValidaSubnets && bash ejecutar.sh
cd /root/work/bloque06/etapa04-CreaClusterEKS && bash ejecutar.sh
cd /root/work/bloque06/etapa05-CreaNodeGroup && bash ejecutar.sh
cd /root/work/bloque06/etapa06-ValidaObservabilidad && bash ejecutar.sh
cd /root/work/bloque06/etapa07-PublicaECR && bash ejecutar.sh
cd /root/work/bloque06/etapa08-DespliegaK8s && bash ejecutar.sh
cd /root/work/bloque06/etapa09-ValidaApp && bash ejecutar.sh
cd /root/work/bloque06/etapa10-ConectividadURL && bash ejecutar.sh
cd /root/work/bloque06/etapa11-Auditoria && bash ejecutar.sh
```

---

## Tiempo total estimado

| Modo       | Tiempo     |
| ---------- | ---------- |
| Paralelo   | **~39 min** |
| Secuencial | ~49 min    |

---

## Estructura de directorios

```
bloque06/
├── README.md
├── etapa01-ValidaEntorno/
│   ├── README.md          ← explicacion + diagrama
│   └── ejecutar.sh
├── etapa02-CreaVPC/
│   ├── README.md
│   └── ejecutar.sh
├── etapa03-ValidaSubnets/
│   ├── README.md
│   └── ejecutar.sh
├── etapa04-CreaClusterEKS/
│   ├── README.md
│   └── ejecutar.sh
├── etapa05-CreaNodeGroup/
│   ├── README.md
│   └── ejecutar.sh
├── etapa06-ValidaObservabilidad/
│   ├── README.md
│   └── ejecutar.sh
├── etapa07-PublicaECR/
│   ├── README.md
│   └── ejecutar.sh
├── etapa08-DespliegaK8s/
│   ├── README.md
│   └── ejecutar.sh
├── etapa09-ValidaApp/
│   ├── README.md
│   └── ejecutar.sh
├── etapa10-ConectividadURL/
│   ├── README.md
│   └── ejecutar.sh
├── etapa11-Auditoria/
│   ├── README.md
│   └── ejecutar.sh
└── etapa12-LimpiezaTotal/
    ├── README.md
    └── ejecutar.sh
```
