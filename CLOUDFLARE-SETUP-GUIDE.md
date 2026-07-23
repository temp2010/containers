# 🌐 Guía de Configuración - Cloudflare + Cloudflared

## 📊 Estado Actual

Tu Cloudflared está **corriendo** ✅ y conectado al túnel de Cloudflare.

**Rutas actualmente configuradas:**
1. ✅ `intranet.temp2010.win` → 127.0.0.1:8083 (WordPress)
2. ✅ `ssh.temp2010.win` → 127.0.0.1:22 (SSH)
3. ✅ `mac.temp2010.win` → 192.168.83.23:5900 (Mac Mini RDP)
4. ✅ `app.temp2010.win` → 192.168.83.22:3000 (App)

---

## 🔧 Rutas Recomendadas para Agregar

### Para Media Servers (Plex, Jellyfin)

```
Nombre: plex.temp2010.win
Servicio: HTTP
Destino: 192.168.83.22:32400
Tipo: Aplicación web pública

Nombre: jellyfin.temp2010.win
Servicio: HTTP
Destino: 192.168.83.22:8096
Tipo: Aplicación web pública
```

### Para Monitoreo (Grafana, Prometheus)

```
Nombre: grafana.temp2010.win
Servicio: HTTP
Destino: 192.168.85.51:3000
Tipo: Aplicación web privada
Requiere: Autenticación

Nombre: prometheus.temp2010.win
Servicio: HTTP
Destino: 192.168.85.50:9090
Tipo: Aplicación web privada
Requiere: Autenticación
```

### Acceso Total a Red Local (Opcional)

```
Nombre: network.temp2010.win
Servicio: TCP
Destino: 192.168.83.0/24 (CIDR)
Tipo: Acceso general
```

---

## 📱 Cómo Agregar Nuevas Rutas en Cloudflare

### Paso 1: Ir al Dashboard
```
1. Abre: https://dash.cloudflare.com
2. Selecciona tu dominio: temp2010
3. En el menú izquierdo: Redes / Conectores / Cloudflared
4. Encuentra tu túnel "Raspberry"
5. Haz clic en "Configurar"
```

### Paso 2: Agregar Nueva Ruta
```
1. Click en "+ Agregar aplicación pública" (o "+ Ruta de aplicación publicada")
2. Rellena:
   - Nombre de subdominio: plex (se convierte a plex.temp2010.win)
   - Tipo: HTTP
   - URL: 192.168.83.22:32400
3. Click en "Guardar ruta"
4. Repetir para cada servicio
```

### Paso 3: Verificar Conectividad
```bash
# Desde tu Mac o cualquier lugar:
curl https://plex.temp2010.win
curl https://grafana.temp2010.win
```

---

## 🔐 Consideraciones de Seguridad

### Servicios que SÍ deberías exponer públicamente:
- ✅ **Plex** - Necesita acceso remoto
- ✅ **Jellyfin** - Necesita acceso remoto
- ✅ **Intranet** - Web app

### Servicios que deberías proteger:
- ⚠️ **Grafana** - Agregar autenticación básica
- ⚠️ **Prometheus** - Solo acceso local/VPN
- ⚠️ **Prometheus** - Considerar no exponer públicamente

### Cómo agregar autenticación en Cloudflare:

**Para Grafana:**
1. En la ruta de Grafana, abre "Configuración avanzada"
2. Agrega "Access Rules" o "Autenticación"
3. Requiere email de Cloudflare para acceso

**Para Prometheus:**
- Opción 1: No exponerlo públicamente
- Opción 2: Agregarlo con autenticación
- Recomendación: Acceso solo vía VPN (WireGuard)

---

## 🧪 Pruebas de Conectividad

### Desde Internet (fuera de red local):
```bash
# Probar acceso público
curl -I https://plex.temp2010.win
curl -I https://grafana.temp2010.win

# Resultado esperado: 200 OK o 302 (redirect a login)
```

### Desde red local (192.168.83.x):
```bash
# En tu Mac Mini o Raspberry:
curl http://192.168.83.22:32400
curl http://192.168.85.51:3000
```

### Desde VPN (WireGuard):
```bash
# Conectado a WireGuard:
curl http://192.168.83.22:32400    # Directo a IP local
curl https://plex.temp2010.win     # Via Cloudflare
```

---

## 📋 Tabla de Rutas Recomendadas

| Subdominio | Destino | Puerto | Público | Autenticación |
|-----------|---------|--------|---------|---------------|
| **plex** | 192.168.83.22 | 32400 | ✅ Sí | ❌ No |
| **jellyfin** | 192.168.83.22 | 8096 | ✅ Sí | ❌ No |
| **grafana** | 192.168.85.51 | 3000 | ⚠️ Sí | ✅ Sí |
| **prometheus** | 192.168.85.50 | 9090 | ❌ No | ✅ VPN only |
| **wireguard** | 192.168.83.22 | 51820 | ❌ No | ✅ VPN only |
| **mac** | 192.168.83.23 | 5900 | ⚠️ Sí | ✅ SSH key |

---

## 🚨 Solución de Problemas

### "La ruta no funciona"
1. Verifica que Cloudflared esté corriendo:
   ```bash
   docker ps | grep cloudflared
   ```

2. Revisa logs:
   ```bash
   docker logs cloudflared --tail 50
   ```

3. Verifica conectividad desde Raspberry a destino:
   ```bash
   ping 192.168.83.22
   curl http://192.168.83.22:32400
   ```

4. En Cloudflare dashboard:
   - Verifica que el túnel esté "Connected"
   - Verifica que la ruta esté en la lista

### "Errores de timeout en logs"
- Normal si hay mucha latencia
- Monitorea: `docker stats cloudflared`
- Si hay problema persistente, reinicia:
  ```bash
  docker restart cloudflared
  ```

### "No puedo acceder desde WireGuard"
- VPN no debería ir por Cloudflare
- Usa IP local directo: `192.168.83.22:32400`
- Cloudflare es para acceso público desde internet

---

## 🔗 URLs Finales (una vez configuradas)

```
Plex (público):        https://plex.temp2010.win
Jellyfin (público):    https://jellyfin.temp2010.win
Grafana (protegido):   https://grafana.temp2010.win
Prometheus (VPN):      http://192.168.85.50:9090 (via WireGuard)
Mac Mini (SSH/RDP):    ssh://ssh.temp2010.win o rdp://mac.temp2010.win
```

---

## 📞 Referencia de Cloudflare

**Dashboard:** https://dash.cloudflare.com  
**Documentación Cloudflared:** https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/  
**Configuración local:** `/home/jopena/containers/cloudflared/`

---

**Estado:** ✅ Cloudflared operativo  
**Última actualización:** 2026-07-23  
**Dominio:** temp2010 en Cloudflare
