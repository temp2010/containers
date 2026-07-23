# 🎯 TAILSCALE VPN Setup - Guía Completa

## ¿Qué es Tailscale?

**Tailscale** es una VPN mesh de cero configuración que conecta tus dispositivos de forma segura:
- ✅ **Sin abrir puertos** en router
- ✅ **Sin DDNS** necesario
- ✅ **Funciona en cualquier red** (empresa, hotel, 4G)
- ✅ **Automático NAT traversal**
- ✅ **Gratis para 3 usuarios**

---

## 🚀 PASO 1: Iniciar Tailscale en Raspberry

```bash
cd ~/containers
docker compose up -d tailscale
```

**Verificar que funciona:**
```bash
docker logs tailscale --tail 20
# Debería mostrar: "Tailscale started"
```

---

## 🔐 PASO 2: Autenticar Tailscale

### Conectar a tu cuenta Tailscale:

```bash
# Abrir sesión interactiva:
docker exec -it tailscale tailscale login

# Esto mostrará una URL como:
# https://login.tailscale.com/a/xxxxxxxxxxxxx
```

### En tu navegador:

1. Copia la URL del terminal
2. Abre en navegador
3. Login con Google/GitHub/Microsoft
4. **Autoriza la Raspberry Pi**
5. El terminal mostrará: `Success`

---

## 📱 PASO 3: Conectar Celular/Laptop

### iOS (iPhone/iPad)

```
1. App Store → Busca "Tailscale"
2. Descarga app oficial
3. Abre app → "Sign in"
4. Login con la MISMA cuenta (Google/GitHub)
5. Click en "Connect"
6. ¡Listo! ✅
```

### Android

```
1. Google Play → Busca "Tailscale"
2. Descarga app oficial
3. Abre app → "Sign in"
4. Login con la MISMA cuenta
5. Click en "Connect"
6. ¡Listo! ✅
```

### macOS/Windows/Linux

```
1. Descarga desde: https://tailscale.com/download
2. Instala
3. Abre Tailscale
4. Click "Sign in"
5. Login con tu cuenta
6. ¡Listo! ✅
```

---

## 🧪 PASO 4: Verificar Conexión

### Desde tu Raspberry (terminal local):

```bash
# Ver estado de Tailscale:
docker exec tailscale tailscale status

# Debería mostrar:
# - Tu Raspberry Pi (como exit node o simplemente como dispositivo)
# - Tus otros dispositivos conectados (iPhone, Laptop, etc)
```

### Desde tu Celular/Laptop (VPN activada):

```
1. Abre app Tailscale
2. Debería mostrar "Connected"
3. Debería ver tu Raspberry Pi en la lista
4. Click en Raspberry → Ver opciones de conexión
```

---

## 🔗 ACCESO A TUS SERVICIOS

Una vez conectado a Tailscale, accede a todo:

### IPs de tu red (conectado a Tailscale):

```
Raspberry Pi:      192.168.83.22
Mac Mini:          192.168.83.23
Plex:              192.168.83.22:32400
Jellyfin:          192.168.83.22:8096
Grafana:           192.168.85.51:3000
Prometheus:        192.168.85.50:9090
AdGuard Home:      192.168.83.22:3000
```

### SSH desde celular/laptop:

```bash
# En Terminal/PowerShell (VPN activada):
ssh usuario@192.168.83.22      # Raspberry Pi
ssh usuario@192.168.83.23      # Mac Mini
```

### RDP a Mac Mini:

```
Mac Mini IP: 192.168.83.23
Puerto RDP: 5900 (estándar)

En tu Mac:
- Remote Desktop App
- Conectar a: 192.168.83.23:5900
```

### Navegador (servicios web):

```
Grafana: http://192.168.85.51:3000
Prometheus: http://192.168.85.50:9090
AdGuard: http://192.168.83.22:3000
Plex: http://192.168.83.22:32400
Jellyfin: http://192.168.83.22:8096
```

---

## ⚙️ FUNCIONALIDADES AVANZADAS

### Exit Node (Opcional)

Si quieres que TODO el tráfico pase por tu casa (como VPN tradicional):

```bash
# Habilitar exit node en Raspberry:
docker exec tailscale tailscale set --advertise-exit-node

# En app de cliente (iPhone/Mac):
# Tailscale → Configuración → VPN → 
# Selecciona "Route all traffic"
```

### Split DNS (Opcional)

Para usar DNS de casa en todos los servicios:

```bash
# En Tailscale web console:
# https://login.tailscale.com/admin/dns

# Agregar:
# DNS Nameserver: 192.168.83.22 (AdGuard Home)
# Search domain: local.
```

### ACL - Control de Acceso

Por defecto, todos en tu Tailnet pueden acceder a todo.

Para restricciones:
```bash
# Ir a: https://login.tailscale.com/admin/acls
# Crear reglas de acceso más restrictivas si lo necesitas
```

---

## 🔐 Seguridad

### ✅ Lo que funciona automáticamente:

- ✅ **Encriptación end-to-end** (WireGuard under the hood)
- ✅ **Autenticación automática** (OAuth)
- ✅ **No expones puertos** públicos
- ✅ **Firewall traversal automático**
- ✅ **Criptografía moderna** (Chacha20-Poly1305)

### ⚠️ Consideraciones:

- Tailscale (empresa) puede ver metadatos de conexión
- Pero NO puede ver contenido encriptado
- Data center en EU disponible si preocupa privacidad

---

## 🆘 Troubleshooting

### "No puedo conectar a Tailscale"

```bash
# 1. Verificar que contenedor está corriendo:
docker ps | grep tailscale

# 2. Ver logs:
docker logs tailscale

# 3. Reiniciar:
docker restart tailscale

# 4. Verificar autenticación:
docker exec tailscale tailscale status
# Debería mostrar "Logged in as..."
```

### "El celular se conecta pero no tiene internet"

```bash
# 1. No es problema de Tailscale, es que no tienes exit node
# Esto es NORMAL - Tailscale VPN solo accede a tu red local

# 2. Para tener internet a través de VPN:
docker exec tailscale tailscale set --advertise-exit-node

# 3. En app del celular:
# Settings → Route all traffic → Enable
```

### "Celular conectado pero no veo Raspberry Pi"

```bash
# 1. Verificar que ambos ven el mismo Tailnet:
#    - App celular debe mostrar Raspberry Pi
#    
# 2. Ir a https://login.tailscale.com/admin/machines
#    Ambos dispositivos deberían estar en la lista

# 3. Si no aparece:
docker restart tailscale
# Espera 10 segundos y recarga página web
```

---

## 📊 Estado y Monitoreo

### Ver estado de Tailscale:

```bash
# Estado general:
docker exec tailscale tailscale status

# Ver IPs asignadas:
docker exec tailscale tailscale ip -4

# Ver todos los dispositivos en red:
docker logs tailscale | grep "Available"
```

### Admin Console Web:

```
URL: https://login.tailscale.com/admin/machines
Aquí ves:
- Todos tus dispositivos conectados
- IP de Tailscale asignada a cada uno
- Estado (online/offline)
- Última actividad
```

---

## 🔄 Actualizaciones

Tailscale se actualiza automáticamente en el contenedor:

```bash
# Para forzar actualización:
docker pull tailscale/tailscale:latest
docker restart tailscale
```

---

## ✨ Diferencias vs WireGuard

| Característica | Tailscale | WireGuard |
|---|---|---|
| Puerto abierto | ❌ NO | ✅ 51820 |
| Setup | ⏱️ 5 min | ⏱️ 1 hora |
| DDNS | ❌ NO | ✅ Necesario |
| Mantenimiento | ✅ Automático | ⏱️ Manual |
| Confiabilidad | ✅ 99.9% | ⏱️ Tu Raspberry |
| Control | ⏱️ Cloud | ✅ Local |

---

## 📞 Referencia

**Documentación oficial:** https://tailscale.com/kb/1019/install-ubuntu

**Tailscale Admin:** https://login.tailscale.com/admin/

**Verificar dispositivos conectados:** https://login.tailscale.com/admin/machines

---

**Estado:** ✅ Listo para usar  
**Última actualización:** 2026-07-23  
**Sustitución de:** WireGuard  
**Ventaja:** Sin puertos abiertos, auto-management
