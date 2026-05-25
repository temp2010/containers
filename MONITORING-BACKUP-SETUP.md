# 📊 Configuración de Monitoreo y Backups

Esta guía configura Prometheus, Grafana, Loki y Restic para monitoreo completo y backups automáticos de tu infraestructura Docker.

## 🏗️ Componentes

### 1. **Prometheus** (puerto 9090)
- Servidor de métricas en tiempo real
- Almacenamiento de series temporales
- Scraping de múltiples fuentes
- **Ubicación**: `http://localhost:9090`

### 2. **Grafana** (puerto 3000)
- Dashboards visuales
- Alertas basadas en métricas
- Integración con Prometheus y Loki
- **Ubicación**: `http://localhost:3000`
- **Usuario por defecto**: admin / changeme_strong_password

### 3. **Loki** (puerto 3100)
- Agregación centralizada de logs
- **Promtail**: Agente para recolectar logs de contenedores
- Bajo uso de recursos (optimizado para Raspberry Pi)
- **Ubicación**: Accesible desde Grafana

### 4. **Restic**
- Backups incrementales y deduplicados
- Soporte para múltiples destinos (local, S3, B2, etc.)
- Automatización con cron
- Rotación automática de backups

---

## 🚀 Inicio Rápido

### 1. Configurar variables de entorno

```bash
# Copiar y editar .env
cp .env.example .env
nano .env

# Variables críticas a cambiar:
GRAFANA_ADMIN_PASSWORD=tu_password_fuerte
RESTIC_PASSWORD=otro_password_fuerte
PROMETHEUS_RETENTION_DAYS=30
```

### 2. Crear directorios necesarios

```bash
# Crear directorios de backups y datos
mkdir -p /mnt/backup/restic-repo
mkdir -p /var/log/restic

# Permisos
chmod 700 /mnt/backup/restic-repo
chmod 755 /var/log/restic
```

### 3. Iniciar servicios

```bash
# Prometheus
docker-compose -f prometheus/docker-compose.yml up -d

# Grafana
docker-compose -f grafana/docker-compose.yml up -d

# Loki + Promtail
docker-compose -f loki/docker-compose.yml up -d

# Restic (opcional, para backups)
docker-compose -f restic/docker-compose.yml up -d
```

### 4. Verificar estado

```bash
docker-compose ps | grep -E "prometheus|grafana|loki|restic"
```

---

## 📊 Configurar Prometheus

### Agregar scrape configs para tus servicios

**Editar `prometheus/prometheus.yml`** y descomentar lo que necesites:

```yaml
scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']  # Node Exporter

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']
```

### Iniciar exporters (si necesitas)

```bash
# Node Exporter - métricas del host
docker run -d \
  --name=node-exporter \
  --net=host \
  prom/node-exporter:latest

# PostgreSQL Exporter
docker run -d \
  --name=postgres-exporter \
  --net=host \
  -e DATA_SOURCE_NAME="postgresql://user:password@postgres:5432/postgres?sslmode=disable" \
  prometheuscommunity/postgres-exporter:latest
```

---

## 📈 Configurar Grafana

### Acceder a Grafana

1. Abre `http://localhost:3000`
2. Login: `admin` / `changeme_strong_password`
3. **IMPORTANTE**: Cambiar contraseña (Admin → Change Password)

### Agregar Datasources

Grafana ya tiene Prometheus y Loki configurados automáticamente gracias a `provisioning/datasources/prometheus.yml`

**Para verificar:**
- Ir a: Configuration → Data Sources
- Deberías ver: "Prometheus" y "Loki"

### Crear Dashboards

**Importar dashboards prehechos:**

1. Grafana → Dashboards → Import
2. Usar IDs de Grafana:
   - **1860**: Node Exporter Full
   - **3662**: Prometheus Stats
   - **14891**: Loki
   - **8919**: Prometheus 2.0 Stats

**O crear custom dashboards:**
- Grafana → Dashboards → New
- Agregar paneles con queries de Prometheus/Loki

---

## 📝 Configurar Loki y Promtail

### Verificar que Promtail está recolectando logs

```bash
# Ver logs de Promtail
docker logs promtail

# Ver métricas de Loki
curl http://localhost:3100/metrics
```

### Explorar logs en Grafana

1. Grafana → Explore
2. Seleccionar datasource: "Loki"
3. Seleccionar label: `container` o `service`
4. Ver logs en tiempo real

---

## 🔄 Configurar Restic Backups

### Inicializar repositorio

```bash
# Inicializar repo (primera vez)
cd restic
docker exec restic restic init

# Verificar repositorio
docker exec restic restic snapshots
```

### Ejecutar backup manual

```bash
# Backup completo
docker exec restic bash /restic-backup.sh full

# Solo volúmenes
docker exec restic bash /restic-backup.sh files

# Solo bases de datos
docker exec restic bash /restic-backup.sh db
```

### Automatizar backups con cron

```bash
# Ver el archivo docker-compose de restic
# Está configurado con ofelia para ejecutar en cron

# El horario está en .env: BACKUP_SCHEDULE=0 2 * * *
# Esto ejecuta backup diariamente a las 2 AM
```

### Restaurar desde backup

```bash
# Listar snapshots disponibles
docker exec restic bash /restic-restore.sh list

# Restaurar último snapshot
docker exec restic bash /restic-restore.sh latest /mnt/restore

# Restaurar snapshot específico
docker exec restic bash /restic-restore.sh abc123def /mnt/restore
```

### Backups a AWS S3

```bash
# En .env:
RESTIC_REPOSITORY=s3:s3.amazonaws.com/bucket-name/restic-backup
AWS_ACCESS_KEY_ID=tu_access_key
AWS_SECRET_ACCESS_KEY=tu_secret_key

# Restic se conectará a S3 automáticamente
```

---

## 🚨 Alertas en Prometheus

Las alertas están definidas en `prometheus/alert-rules.yml`

**Alertas configuradas:**
- ✅ Prometheus not scraping
- ✅ High disk usage (>80%)
- ✅ High memory usage (>85%)
- ✅ High CPU usage (>80%)
- ✅ Container down
- ✅ Container restarting frequently

**Para habilitar notificaciones:**
1. Descomentar en `prometheus/prometheus.yml`:
```yaml
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager:9093
```

2. Configurar AlertManager (en otra guía)

---

## 🔍 Troubleshooting

### Prometheus no scrapeando

```bash
# Ver logs
docker logs prometheus

# Verificar que endpoints están accesibles
curl http://localhost:9090/api/v1/targets

# Chequear prometheus.yml
docker exec prometheus promtool check config /etc/prometheus/prometheus.yml
```

### Grafana no conecta a Prometheus

```bash
# Verificar conectividad desde Grafana
docker exec grafana curl http://prometheus:9090

# Verificar logs de Grafana
docker logs grafana
```

### Loki/Promtail no recolecta logs

```bash
# Ver logs de Promtail
docker logs promtail

# Verificar conexión a Loki
docker exec promtail curl http://loki:3100/ready

# Ver labels disponibles
curl "http://localhost:3100/loki/api/v1/labels"
```

### Restic - repositorio inválido

```bash
# Reinicializar repositorio
rm -rf /mnt/backup/restic-repo/*
docker exec restic restic init

# Verificar integridad
docker exec restic restic check
```

---

## 📊 Comandos Útiles

### Prometheus

```bash
# Validar configuración
docker exec prometheus promtool check config /etc/prometheus/prometheus.yml

# Ver targets
curl http://localhost:9090/api/v1/targets | jq

# Ver series disponibles
curl 'http://localhost:9090/api/v1/label/__name__/values' | jq
```

### Grafana

```bash
# Ver estado de datasources
curl -u admin:password http://localhost:3000/api/datasources

# Crear datasource vía API
curl -X POST -H "Content-Type: application/json" \
  -d '{"name":"MyDataSource",...}' \
  http://localhost:3000/api/datasources
```

### Loki

```bash
# Ver logs de un contenedor
curl "http://localhost:3100/loki/api/v1/query_range?query={container=\"nginx\"}&start=0&end=now" | jq

# Ver espacios de etiquetas
curl http://localhost:3100/loki/api/v1/labels
```

### Restic

```bash
# Listar archivos en snapshot
docker exec restic restic ls latest

# Verificar integridad de backups
docker exec restic restic check --read-data

# Ver estadísticas de compresión
docker exec restic restic stats
```

---

## 🔐 Seguridad

### Proteger Grafana

1. Cambiar contraseña admin (después del primer login)
2. Crear usuarios adicionales con permisos limitados
3. Usar proxy (Nginx/Traefik) con SSL
4. En production: deshabilitar sign-up en .env

### Proteger Prometheus

- **NO exponer a Internet** (sin autenticación)
- Usar Nginx reverse proxy con básica auth:
```nginx
location /prometheus {
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://prometheus:9090;
}
```

### Restic password

- ✅ **Cambiar** RESTIC_PASSWORD en .env
- ✅ Guardar en lugar seguro (password manager)
- ✅ NO commitar .env a Git

---

## 📚 Referencias

- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/grafana/)
- [Loki Docs](https://grafana.com/docs/loki/)
- [Restic Docs](https://restic.readthedocs.io/)
- [Promtail Docs](https://grafana.com/docs/loki/latest/promtail/)

---

**Última actualización**: 2026-05-22  
**Versiones**: Prometheus latest, Grafana latest, Loki latest, Restic latest
