#!/usr/bin/env bash
set -euo pipefail

ADMIN_USER="${CUPS_USER:-${ADMIN_USER:-admin}}"
ADMIN_PASSWORD="${CUPS_PASSWORD:-${ADMIN_PASSWORD:-admin}}"

# Si /etc/cups está vacío (porque viene de volumen), inicializar con defaults del paquete.
if [ -z "$(ls -A /etc/cups 2>/dev/null || true)" ]; then
  mkdir -p /etc/cups
  cp -a /usr/share/cups-default/etc-cups/. /etc/cups/
fi

# Asegura grupo de administración
if ! getent group lpadmin >/dev/null; then
  groupadd -r lpadmin
fi

# Crea/actualiza usuario admin de CUPS
if ! id -u "$ADMIN_USER" >/dev/null 2>&1; then
  useradd -m -s /usr/sbin/nologin -G lpadmin "$ADMIN_USER"
else
  usermod -aG lpadmin "$ADMIN_USER" || true
fi
echo "${ADMIN_USER}:${ADMIN_PASSWORD}" | chpasswd

# Habilitar acceso web admin desde LAN (sin TLS) y permitir administración remota
if [ -f /etc/cups/cupsd.conf ]; then
  # Escuchar en todas las interfaces
  if ! grep -qE '^[[:space:]]*Port[[:space:]]+631' /etc/cups/cupsd.conf; then
    echo "Port 631" >> /etc/cups/cupsd.conf
  fi
  if ! grep -qE '^[[:space:]]*Listen[[:space:]]+0\.0\.0\.0:631' /etc/cups/cupsd.conf; then
    echo "Listen 0.0.0.0:631" >> /etc/cups/cupsd.conf
  fi

  # ServerAlias por defecto
  if ! grep -qE '^[[:space:]]*ServerAlias' /etc/cups/cupsd.conf; then
    echo "ServerAlias *" >> /etc/cups/cupsd.conf
  fi

  # Asegurar que el web admin esté disponible
  if ! grep -qE '^[[:space:]]*WebInterface[[:space:]]+Yes' /etc/cups/cupsd.conf; then
    echo "WebInterface Yes" >> /etc/cups/cupsd.conf
  fi

  # Política de acceso mínima: permitir LAN; autenticación para admin
  if ! grep -qE '^<Location /admin>' /etc/cups/cupsd.conf; then
    cat >> /etc/cups/cupsd.conf <<'EOF'

<Location />
  Order allow,deny
  Allow all
</Location>

<Location /admin>
  AuthType Default
  Require user @SYSTEM
  Order allow,deny
  Allow all
</Location>

<Location /admin/conf>
  AuthType Default
  Require user @SYSTEM
  Order allow,deny
  Allow all
</Location>
EOF
  fi
fi

# Arrancar dbus y avahi (para discovery), si se puede
mkdir -p /run/dbus
dbus-daemon --system --fork || true
avahi-daemon -D || true

# Ajustes de permisos típicos de spool
mkdir -p /var/spool/cups /var/log/cups
chown -R lp:lp /var/spool/cups /var/log/cups || true

exec /usr/sbin/cupsd -f

