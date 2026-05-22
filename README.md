# 🐳 Containers - Stack Docker Completo

Repositorio de configuración de servicios Docker para replicas infraestructura.

## 📋 Servicios Incluidos

- **AdGuard Home** - Filtrado DNS y Ad blocking
- **Jellyfin** - Servidor de streaming multimedia
- **Plex** - Media server
- **Portainer** - Gestión visual de Docker
- **PostgreSQL** - Base de datos
- **Nginx** - Reverse proxy
- **Samba** - Compartir archivos NAS
- **N8N** - Automatización de workflows
- **MeTube** - Descargador de vídeos
- **FileBrowser** - Explorador de archivos web
- **CloudFlared** - Túnel remoto Cloudflare

## 🚀 Inicio Rápido

### Requisitos
- Docker Engine 20.10+
- Docker Compose 1.29+
- 10GB espacio libre mínimo
- Usuarios en grupos apropiados

### Instalación

1. Clonar repositorio:
```bash
git clone https://github.com/temp2010/containers.git
cd containers
```

2. Crear archivo de configuración:
```bash
cp .env.example .env
nano .env  # Editar con valores reales
```

3. Crear directorios de datos:
```bash
mkdir -p volumes/{adguardhome,jellyfin,postgres,portainer}
```

4. Iniciar servicios:
```bash
docker-compose up -d
```

5. Verificar estado:
```bash
docker-compose ps
```

## 📁 Estructura

```
.
├── docker-compose.yml      # Configuración principal
├── .env.example            # Variables de ejemplo
├── .gitignore             # Git ignore rules
├── README.md              # Este archivo
└── [subcarpetas]/
    ├── adguardhome/       # Configuración AdGuard
    ├── jellyfin/          # Config Jellyfin
    ├── portainer/         # Config Portainer
    └── ... (otras carpetas de config)
```

## 🔧 Configuración

### Variables de Entorno
Copiar `.env.example` a `.env` y configurar:
- Contraseñas
- Puertos (si necesario cambiar)
- Directorios de datos
- Timezone

### Volúmenes
Los volúmenes se crean automáticamente en Docker. Para persistencia en disco:
```bash
mkdir -p /mnt/data/{adguardhome,jellyfin,postgres}
```

## 📊 Monitoreo

Ver estado:
```bash
docker-compose ps
```

Ver logs:
```bash
docker-compose logs -f [servicio]
```

## 🔐 Seguridad

- Cambiar todas las contraseñas por defecto
- Usar `.env` para datos sensibles (NO incluir en Git)
- Usar firewall para limitar acceso
- Actualizar imágenes regularmente: `docker-compose pull`

## 🆘 Troubleshooting

### Puerto en uso
```bash
lsof -i :PUERTO
```

### Reiniciar un servicio
```bash
docker-compose restart [servicio]
```

### Limpiar espacio
```bash
docker system prune -a
```

## 📝 Licencia

Privado

## 👤 Autor

temp2010
