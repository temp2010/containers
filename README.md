# Containers — homelab en Raspberry Pi 5

Configuración de Docker Compose de mi servidor casero (Raspberry Pi 5, arm64, Raspberry Pi OS). Cada servicio vive en su propia carpeta y el archivo `docker-compose.yml` principal los une con `extends`.

Repositorio personal y privado. No contiene contraseñas ni claves: esos valores viven en `.env` y en las carpetas de datos, que están excluidas en `.gitignore`.

## Servicios definidos

La lista sale de `docker-compose.yml`. Que un servicio esté definido no significa que esté corriendo: cada uno se levanta a mano.

| Grupo | Servicios |
|---|---|
| Red y DNS | AdGuard Home, DHCP, Nginx (proxy de los subdominios `*.home.arpa`), Cloudflared, Tailscale (acceso remoto) |
| Archivos | File Browser, Samba, Rclone (Google Drive y OneDrive en solo lectura) |
| Impresión | CUPS (imagen local), WSDD |
| Multimedia | Jellyfin, Plex, Stremio, MeTube, Pyload, qBittorrent |
| Automatización | n8n, Home Assistant, Odoo, OpenClaw, Open WebUI + Ollama (IA local) |
| Panel y administración | Homepage, Portainer, Watchtower (solo avisa), Mitmproxy |
| Bases de datos | PostgreSQL, phpMyAdmin, WordPress |
| Monitoreo y respaldo | Prometheus, Grafana, Loki, Promtail, Restic (perfil `backup`) |
| Escritorio remoto | RustDesk |

Obsoletos: WireGuard (reemplazado por Tailscale; no usar).

## Requisitos

- Docker Engine 29 y Docker Compose v2.
- Raspberry Pi 5 o cualquier equipo arm64 (algunas imágenes son solo amd64; compruébalo antes).
- Disco con espacio para las imágenes y las carpetas de datos.

## Puesta en marcha

1. Clona el repositorio y crea tu archivo de variables:

   ```bash
   git clone git@github.com:temp2010/containers.git
   cd containers
   cp .env.example .env
   ```

   Edita `.env` con tus valores. Ojo: `.env.example` está desactualizado; las variables reales son las de tu `.env` actual (zona horaria `TZ`, IPs `*_IP`, DNS `DNS_PRIMARY`/`DNS_SECONDARY`, `PUID`/`PGID`).

2. Crea la red externa que usan los servicios con IP fija:

   ```bash
   docker network create --driver bridge --subnet 192.168.85.0/26 temp2010
   docker network create wordpress
   ```

3. Construye las imágenes locales:

   ```bash
   docker compose build cups ollama
   ```

4. Levanta los servicios **por nombre**. No uses `docker compose up -d` sin nombres: arranca todo lo definido, incluidos servicios que no quieres activos.

   ```bash
   docker compose up -d --no-deps adguardhome nginx homepage jellyfin
   ```

## Estructura

```
.
├── docker-compose.yml   # Compose principal: une los servicios con extends
├── .env                 # Variables reales (NO se versiona)
├── .env.example         # Plantilla de variables
├── <servicio>/
│   ├── docker-compose.yml   # Definición del servicio
│   ├── Dockerfile           # Solo para imágenes locales (cups, ollama)
│   └── config/ o data/      # Datos del servicio (NO se versionan)
└── openclaw/            # Repositorio git anidado: se ignora por completo
```

Las carpetas de datos (`config/`, `data/`, modelos, bases de datos, claves) están en `.gitignore`. Si una app necesita un archivo que contiene secretos, se crea a mano en la Raspberry y nunca se sube.

## Operación

- **Actualizaciones:** Watchtower revisa cada martes a las 09:00 si hay imágenes nuevas y lo anuncia en sus logs (`docker logs watchtower`). No aplica nada solo: tú decides cuándo recrear cada servicio.
- **Recrear un servicio con su nueva imagen:**

  ```bash
  docker compose pull <servicio>
  docker compose up -d --no-deps <servicio>
  ```

- **Ver el estado:** `docker compose ps` o el panel de Homepage.
- **Limpiar espacio:** `docker builder prune` y `docker image prune` son seguros. Evita `docker volume prune` y `docker system prune --volumes` sin revisar antes: pueden borrar datos de contenedores detenidos.

## Seguridad

- `.env`, las carpetas de datos y cualquier archivo con claves permanecen fuera de git.
- Antes de subir cambios, revisa `git status` y `git diff --cached`.
- No expongas puertos a internet sin necesidad: el acceso remoto se hace por Tailscale.

## Notas

- Carpetas sin servicio definido en el compose (no se levantan): Nextcloud, Calibre, MongoDB, MySQL, Redis, Mattermost, Avahi. Las conservo como datos; si alguna se vuelve a usar, se añade al compose.
- `rclone/Dockerfile` ya no se usa: el servicio usa la imagen oficial `rclone/rclone`.
- `wireguard/` queda solo por historial; su configuración con claves se borró del repositorio.
- `openclaw/` es un proyecto aparte con su propio repositorio git.

## Autor

temp2010
