#!/bin/bash
# Quick start script para Prometheus, Grafana, Loki y Restic

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Monitoring & Backup Stack - Quick Start Setup            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${RED}❌ Archivo .env no encontrado${NC}"
    echo -e "${YELLOW}Creando .env desde .env.example...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}⚠️  EDITA .env y cambia las contraseñas antes de continuar:${NC}"
    echo -e "${YELLOW}   - GRAFANA_ADMIN_PASSWORD${NC}"
    echo -e "${YELLOW}   - RESTIC_PASSWORD${NC}"
    exit 1
fi

# Create necessary directories
echo -e "${YELLOW}📁 Creando directorios necesarios...${NC}"
mkdir -p /mnt/backup/restic-repo
mkdir -p /var/log/restic
chmod 700 /mnt/backup/restic-repo
chmod 755 /var/log/restic
echo -e "${GREEN}✅ Directorios creados${NC}"

# Start Prometheus
echo -e "${YELLOW}🚀 Iniciando Prometheus...${NC}"
docker-compose -f prometheus/docker-compose.yml up -d
sleep 5
if docker ps | grep prometheus > /dev/null; then
    echo -e "${GREEN}✅ Prometheus iniciado en http://localhost:9090${NC}"
else
    echo -e "${RED}❌ Error iniciando Prometheus${NC}"
    exit 1
fi

# Start Grafana
echo -e "${YELLOW}🚀 Iniciando Grafana...${NC}"
docker-compose -f grafana/docker-compose.yml up -d
sleep 5
if docker ps | grep grafana > /dev/null; then
    echo -e "${GREEN}✅ Grafana iniciado en http://localhost:3000${NC}"
else
    echo -e "${RED}❌ Error iniciando Grafana${NC}"
    exit 1
fi

# Start Loki
echo -e "${YELLOW}🚀 Iniciando Loki + Promtail...${NC}"
docker-compose -f loki/docker-compose.yml up -d
sleep 5
if docker ps | grep loki > /dev/null; then
    echo -e "${GREEN}✅ Loki iniciado en http://localhost:3100${NC}"
else
    echo -e "${RED}❌ Error iniciando Loki${NC}"
    exit 1
fi

# Initialize Restic repo
echo -e "${YELLOW}🔄 Inicializando repositorio Restic...${NC}"
docker-compose -f restic/docker-compose.yml up -d
sleep 5

if [ -d /mnt/backup/restic-repo ] && [ ! -f /mnt/backup/restic-repo/config ]; then
    echo -e "${YELLOW}   Creando repositorio Restic (primera vez)...${NC}"
    docker exec restic restic init || true
fi
echo -e "${GREEN}✅ Restic listo${NC}"

# Health checks
echo -e "\n${YELLOW}🏥 Verificando salud de servicios...${NC}"
echo -e "${YELLOW}─────────────────────────────────────────${NC}"

check_service() {
    local service=$1
    local port=$2
    local url=$3

    if curl -s "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ ${service}${NC} (http://localhost:${port})"
    else
        echo -e "${RED}❌ ${service}${NC} (http://localhost:${port}) - No responde"
    fi
}

check_service "Prometheus" 9090 "http://localhost:9090/-/healthy"
check_service "Grafana" 3000 "http://localhost:3000/api/health"
check_service "Loki" 3100 "http://localhost:3100/ready"

# Summary
echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✅ Stack de Monitoreo instalado exitosamente           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${YELLOW}📊 Próximos pasos:${NC}"
echo -e "  1. Abre Grafana: ${GREEN}http://localhost:3000${NC}"
echo -e "     Usuario: admin"
echo -e "     Contraseña: (la que configuraste en .env)"
echo -e "\n  2. Cambia la contraseña de admin"
echo -e "\n  3. Importa dashboards:"
echo -e "     Dashboard → Import → ID: 1860 (Node Exporter)"
echo -e "\n  4. Configura Prometheus scrape configs en:"
echo -e "     ${GREEN}prometheus/prometheus.yml${NC}"
echo -e "\n  5. Ejecuta tu primer backup:"
echo -e "     ${GREEN}docker exec restic bash /restic-backup.sh full${NC}"

echo -e "\n${YELLOW}📚 Documentación:${NC}"
echo -e "  Lee: ${GREEN}MONITORING-BACKUP-SETUP.md${NC}"

echo -e "\n${YELLOW}🔗 Enlaces útiles:${NC}"
echo -e "  Prometheus: ${GREEN}http://localhost:9090${NC}"
echo -e "  Grafana:    ${GREEN}http://localhost:3000${NC}"
echo -e "  Loki:       ${GREEN}http://localhost:3100${NC}"
echo -e ""
