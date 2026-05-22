# 🐳 Docker Containers - Stack Infrastructure as Code

Complete Docker infrastructure configuration for a multi-service homelab/infrastructure setup. This repository contains all necessary configurations to replicate the entire service architecture.

## 📋 Servicios Incluidos (44+)

**Base Infrastructure:**
- AdGuard Home - DNS filtering and ad blocking
- DHCP Server - DHCP management
- Nginx - Reverse proxy and load balancer
- Samba - File sharing (NAS)
- Wireguard - VPN
- CloudFlared - Cloudflare tunnel for remote access

**Databases & Storage:**
- PostgreSQL - Relational database
- MongoDB - NoSQL document database
- MySQL - Relational database
- Redis - In-memory cache
- RClone - Cloud storage sync with custom build
- File Browser - Web file manager

**Media & Entertainment:**
- Jellyfin - Media server
- Plex - Media streaming service
- MeTube - YouTube downloader
- Stremio - Media streaming aggregator
- Calibre - E-book library

**Automation & Integration:**
- N8N - Workflow automation
- Portainer - Docker management UI
- Watchtower - Auto-update Docker images
- Mattermost - Team collaboration

**Developer Tools:**
- PHPMyAdmin - MySQL management
- Sonarqube - Code quality analysis
- OpenClaw - AI-powered development assistant

**Downloaders & Tools:**
- qBittorrent - Torrent client
- Prowlarr - Indexer aggregator
- Radarr - Movie library manager
- Readarr - E-book library manager
- Sonarr - Series library manager
- PyLoad - Download manager

**System & Networking:**
- CUPS - Print server with custom build
- Ollama - Local LLM with custom build
- Mitmproxy - HTTP proxy analysis
- Noip - Dynamic DNS with custom build
- DuckDNS - Dynamic DNS
- RustDesk - Remote desktop
- HomeAssistant - Home automation
- Avahi - mDNS service discovery
- WSDD - Windows network discovery

## 🚀 Inicio Rápido

### Requisitos
- Docker Engine 20.10+
- Docker Compose 2.0+ (recomendado)
- 50GB+ espacio libre (depende de servicios activos)
- Raspberry Pi 4+ o similar (for ARM64 support)
- Git for cloning repository

### Instalación Rápida

1. **Clone the repository:**
```bash
git clone https://github.com/temp2010/containers.git
cd containers
```

2. **Configure environment:**
```bash
cp .env.example .env
nano .env  # Edit with your settings
```

3. **Build custom images (if needed):**
```bash
# Services with custom Dockerfiles require building:
docker-compose build rclone cups ollama noip
```

4. **Start all services:**
```bash
docker-compose up -d
```

5. **Verify status:**
```bash
docker-compose ps
```

## 📁 Repository Structure

```
.
├── docker-compose.yml       # Main orchestration file
├── .env.example             # Environment variables template
├── .gitignore              # Git exclusions (volumes, data, secrets)
├── README.md               # This file
├── [service-folders]/      # Individual service configurations
│   ├── docker-compose.yml  # Service-specific compose file
│   ├── Dockerfile          # Custom image build (if applicable)
│   ├── entrypoint.sh       # Startup script (if applicable)
│   ├── install.sh          # Build helper script (if applicable)
│   └── .dockerignore       # Docker build context exclusions
└── volumes/               # Data directory (created at runtime, NOT in git)
    └── [service-volumes]/ # Persistent data for each service
```

## 🛠️ Services with Custom Builds

The following services use custom Dockerfiles and must be built locally:

| Service | Dockerfile | Custom Scripts | Purpose |
|---------|-----------|----------------|---------|
| rclone | ✓ | entrypoint.sh, install.sh | Cloud storage sync client |
| cups | ✓ | entrypoint.sh | Print server |
| ollama | ✓ | - | Local LLM runtime |
| noip | ✓ | - | Dynamic DNS client |

Build all custom images:
```bash
docker-compose build rclone cups ollama noip
```

Or build specific service:
```bash
docker-compose build rclone
```

## 🔧 Configuration

### Environment Variables

Copy `.env.example` to `.env` and customize:

```bash
# Core settings
TIMEZONE=America/Bogota
DOMAIN=example.com

# Database passwords (CHANGE THESE!)
POSTGRES_PASSWORD=your-secure-password
MYSQL_PASSWORD=your-secure-password
MONGO_INITDB_ROOT_PASSWORD=your-secure-password

# Service-specific ports
PLEX_PORT=32400
JELLYFIN_PORT=8096
PORTAINER_PORT=9000

# Advanced settings
ENABLE_IPVLAN=true
IPV4_SUBNET=172.18.0.0/24
```

### Per-Service Configuration

Each service may have additional `.env.example` files in its folder:

```bash
# OpenClaw configuration
openclaw/.env.example

# N8N configuration
n8n/docker-compose.yml
```

Customize service-specific settings by editing `.env` and referencing variables in service docker-compose files.

### Volume Management

Persistent data is stored in `volumes/` directory (excluded from git):

```bash
# Create volume directories (optional - docker creates automatically)
mkdir -p volumes/{postgres,mongodb,jellyfin,nextcloud}

# Backup volumes
tar -czf backup-volumes.tar.gz volumes/

# Restore volumes
tar -xzf backup-volumes.tar.gz
```

## 🚀 Operation

### Start/Stop Services

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart specific service
docker-compose restart jellyfin

# View all containers
docker-compose ps

# View service logs
docker-compose logs -f nginx

# View last 100 lines of logs
docker-compose logs --tail=100 postgres
```

### Update Services

```bash
# Pull latest images (without building)
docker-compose pull

# Rebuild custom images
docker-compose build --no-cache

# Update and restart
docker-compose pull && docker-compose up -d
```

## 📊 Monitoring & Maintenance

### Check Resource Usage
```bash
docker stats

# View container details
docker inspect [container-id]
```

### Health Checks
```bash
# Services with healthchecks
docker-compose ps

# Manual health test
curl http://localhost:9000/api/system/status
```

### Clean Up Resources
```bash
# Remove unused images
docker image prune -a

# Remove stopped containers
docker container prune

# Clean volumes (⚠️ deletes data)
docker volume prune

# Full system cleanup (⚠️ careful!)
docker system prune -a --volumes
```

## 🔐 Security Best Practices

1. **Change Default Passwords:**
   - Edit `.env` with strong passwords
   - Change default credentials for each service
   - Store .env securely (never commit to git)

2. **Network Security:**
   - Use firewall to restrict service access
   - Enable CloudFlared tunnel for remote access only
   - Use Wireguard VPN for secure connections
   - Restrict ports to trusted IPs only

3. **Regular Updates:**
   ```bash
   # Update all images to latest versions
   docker-compose pull
   docker image prune -a
   docker-compose down && docker-compose up -d
   ```

4. **Backup Important Data:**
   ```bash
   # Backup database volumes
   docker-compose exec postgres pg_dump -U user database > backup.sql
   
   # Backup file volumes
   tar -czf backup-config.tar.gz volumes/nextcloud volumes/mattermost
   ```

5. **Secrets Management:**
   - Keep `.env` out of version control
   - Use strong random passwords
   - Rotate credentials periodically
   - Never commit actual credentials

## 🆘 Troubleshooting

### Common Issues

**Service fails to start:**
```bash
# Check logs
docker-compose logs [service]

# Check resource availability
docker stats

# Verify configuration
docker-compose config
```

**Port already in use:**
```bash
# Find process using port
lsof -i :[PORT]

# Kill process or change port in .env
```

**Database connection errors:**
```bash
# Verify database is running
docker-compose ps postgres

# Check database logs
docker-compose logs postgres

# Test connection
docker-compose exec postgres psql -U user -d database
```

**Out of disk space:**
```bash
# Check disk usage
du -sh volumes/

# Clean docker
docker system prune -a

# Remove old backups
rm -rf old-backups/
```

### Reset Service

```bash
# Stop and remove container (keeps volumes)
docker-compose rm -f [service]
docker-compose up -d [service]

# Full reset (deletes volumes ⚠️)
docker-compose down -v
docker volume prune -f
docker-compose up -d
```

## 📝 Important Notes

### What's NOT in This Repository

The following are intentionally excluded (via `.gitignore`):

- **volumes/** - Service data and persistent storage
- **data/** - Application-generated data  
- **.env** - Sensitive environment variables
- **logs/** - Service logs
- **.git/config** - Repository metadata
- **node_modules/**, **build/**, **dist/** - Build artifacts
- **Configuration files** containing passwords

### What IS in This Repository

- `docker-compose.yml` - Service orchestration (updated to latest versions)
- `[service]/docker-compose.yml` - Individual service configurations
- `Dockerfile` files - Custom image definitions for specialized services
- `.env.example` - Configuration template
- Build scripts - `entrypoint.sh`, `install.sh` for custom builds
- README files - Documentation and setup guides

### Replicating This Setup

To replicate this infrastructure on another machine:

1. Clone this repository
2. Create `.env` from `.env.example` with your settings
3. Build custom images: `docker-compose build`
4. Start services: `docker-compose up -d`
5. Configure each service through their web UIs
6. Restore data from backups if available

Services using official images will pull from Docker Hub. Services with Dockerfiles will build locally.

## 📚 Service Documentation

For service-specific configuration and documentation, refer to:

- Official service documentation (search online for service name)
- Environment variables in `.env.example`
- Service docker-compose.yml files
- Admin panels (usually accessible at `http://localhost:[PORT]`)

## 🔗 Related Projects

- **OpenClaw** - AI development assistant (subproject)
- **AdGuard Home** - DNS & Ad-blocking
- **Portainer** - Docker container management

## 📝 Licencia

Privado / Private

## 👤 Autor

temp2010

---

**Last Updated:** 2026-05-22  
**Docker Compose Version:** 2.0+  
**Services:** 44+  
**Total Config Files:** 47  
**Repository:** https://github.com/temp2010/containers.git
