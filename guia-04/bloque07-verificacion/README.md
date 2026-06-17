# Verificacion Integral — Operacion Avanzada EP03

## Descripcion

Este bloque ejecuta las 4 pruebas de validacion del cluster Kubernetes y genera un reporte consolidado.

## Archivos

| Archivo | Descripcion |
|---------|-------------|
| `ejecutar.sh` | Verificacion integral (HPA, Healing, Metricas) |
| `stress_test.sh` | Stress test real que genera carga HTTP y publica metricas a CloudWatch |
| `README.md` | Esta documentacion |

## Stress Test (para mover metricas del dashboard)

El stress test genera carga real contra los servicios y publica metricas a CloudWatch para que el dashboard muestre datos.

```bash
# Frontend via LoadBalancer (default: 60s, 50 workers)
bash stress_test.sh

# Backend via port-forward (120s, 100 workers)
bash stress_test.sh backend 120 100

# Database via port-forward (30s, 20 workers)
bash stress_test.sh database 30 20
```

### Metricas publicadas

- `Custom/DeployDuration` — Duracion del stress test
- `Custom/RequestsPerSecond` — Requests por segundo
- `Custom/SuccessRate` — Porcentaje de exito
- `Custom/TotalRequests` — Total de requests realizados

## Verificacion Integral

Ejecuta las 4 pruebas en secuencia:

```bash
bash ejecutar.sh
```

## Estructura

```
bloque07-verificacion/
├── ejecutar.sh          # Script principal unificado
├── README.md            # Esta documentacion
└── reports/             # Reportes generados (gitignore)
    └── verificacion-YYYYMMDD-HHMMSS.md
```
