# Dashboard de Observabilidad — CloudWatch EP03

## Descripcion

Este bloque crea un **dashboard personalizado en Amazon CloudWatch** que visualiza las metricas clave de los tres servicios desplegados: **backend**, **database** y **frontend**.

## Prerequisito — Ejecutar antes del dashboard

El dashboard necesita **Container Insights** habilitado para mostrar metricas de CPU, memoria y red. Ejecutar una sola vez:

```bash
bash setup-dashboard.sh
```

Este script:
1. Instala el addon `amazon-cloudwatch` en el cluster EKS
2. Crea el log group `/aws/eks/laboratorio-ep03-eks/application`
3. Habilita EKS logging a CloudWatch
4. Verifica Metrics Server
5. Publica metricas custom iniciales

**Esperar 5-10 minutos** despues de ejecutar para que Container Insights empiece a reportar datos.

## Metricas del Dashboard

| Metrica | Fuente | Descripcion |
|---------|--------|-------------|
| **Tiempo de Despliegue** | Custom/DeployDuration | Duracion de cada despliegue en segundos |
| **Cobertura de Pruebas** | Custom/TestCoverage | Porcentaje de codigo cubierto por tests |
| **Uso de CPU** | ContainerInsights | CPU por pod (Backend, Frontend, Database) |
| **Uso de Memoria** | ContainerInsights | Memoria por pod |
| **Trafico de Red** | ContainerInsights | Bytes recibidos/enviados |
| **Errores en Logs** | AWS/Logs | Volumen de logs con errores |
| **Estado de Pods** | ContainerInsights | Pods Running/Pending/Failed |
| **Alarmas Activas** | AWS/CloudWatch | Estado de alarmas configuradas |
| **Numero de Despliegues** | Custom/DeployCount | Conteo de deploys por servicio |

## Archivos

| Archivo | Descripcion |
|---------|-------------|
| `ejecutar.sh` | Crea el dashboard en CloudWatch |
| `dashboard.json` | Definicion estatica del dashboard (plantilla) |
| `publicar-metricas.sh` | Publica metricas custom desde el pipeline |
| `verificar.sh` | Verifica que el dashboard funciona |
| `README.md` | Esta documentacion |

## Uso

### 1. Crear el dashboard

```bash
cd bloque06-dashboard
bash ejecutar.sh
```

### 2. Publicar metricas despues de cada deploy

```bash
# Desde el pipeline CI/CD o manualmente
bash publicar-metricas.sh backend $DEPLOY_START $DEPLOY_END $TEST_COVERAGE success
bash publicar-metricas.sh frontend $DEPLOY_START $DEPLOY_END $TEST_COVERAGE success
bash publicar-metricas.sh database $DEPLOY_START $DEPLOY_END $TEST_COVERAGE success
```

### 3. Verificar que funciona

```bash
bash verificar.sh
```

## Integracion con Pipeline CI/CD

### En GitHub Actions

Agregar estos pasos despues del deploy en cada workflow:

```yaml
- name: Publicar metricas de despliegue
  env:
    AWS_REGION: ${{ secrets.AWS_REGION }}
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    AWS_SESSION_TOKEN: ${{ secrets.AWS_SESSION_TOKEN }}
  run: |
    DEPLOY_START=${{ steps.deploy.outputs.start_time }}
    DEPLOY_END=$(date +%s)
    TEST_COVERAGE=${{ steps.test.outputs.coverage }}
    bash publicar-metricas.sh backend "$DEPLOY_START" "$DEPLOY_END" "$TEST_COVERAGE" success
```

## Acceso al Dashboard

1. Ir a **AWS Console** -> **CloudWatch**
2. Seleccionar **Dashboards** en el menu lateral
3. Buscar `laboratorio-ep03-eks-observability`
4. O acceder directamente:
   ```
   https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=laboratorio-ep03-eks-observability
   ```

## Widgets del Dashboard

### Fila 1: Metricas de Recursos
- **CPU por Pod**: Backend, Frontend, Database
- **Memoria por Pod**: Backend, Frontend, Database
- **Trafico de Red**: Bytes RX/TX totales

### Fila 2: Metricas de CI/CD
- **Tiempo de Despliegue**: Duracion de cada deploy con objetivo de <5 min
- **Cobertura de Pruebas**: Porcentaje con objetivo de >80%
- **Errores en Logs**: Volumen de logs de error

### Fila 3: Estado del Sistema
- **Estado de Pods**: Running, Pending, Failed
- **Alarmas Activas**: Estado de alarmas de CloudWatch
- **Numero de Despliegues**: Conteo acumulado por servicio

### Fila 4: Logs
- **Ultimos Errores**: Tabla con los 20 errores mas recientes

## Costos Estimados

- **Dashboard**: Gratis (hasta 3 dashboards por cuenta)
- **Metricas Custom**: $0.30/metric/mes
- **Container Insights**: $0.30/pod/mes

**Total estimado**: ~$2-4 USD/mes
