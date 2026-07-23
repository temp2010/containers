# 🔐 Guía de WireGuard VPN - Acceso Remoto a Red Local

## 📋 Resumen

WireGuard es tu servidor VPN para acceder remotamente a:
- **Red Local:** 192.168.83.0/24 (Raspberry Pi, Mac Mini, IoT devices)
- **Servicios Docker:** 192.168.85.0/26 (Plex, Jellyfin, Prometheus, etc.)

---

## 🚀 Acceso a WireGuard Web UI

**URL:** `http://temp2010.ddns.net:8020`  
**Usuario:** admin  
**Contraseña:** (la configurada en docker-compose)

### Desde la interfaz web puedes:
- ✅ Ver clientes conectados
- ✅ Generar nuevas configuraciones de cliente
- ✅ Descargar archivos `.conf`
- ✅ Ver estadísticas de conexión

---

## 📱 Conectar Dispositivo a WireGuard

### Opción 1: Desde la Web UI (Recomendado)

1. Accede a `temp2010.ddns.net:8020`
2. Haz clic en **"Add Client"** (o usa cliente existente "Xiaomi 12")
3. Haz clic en **"Download"** para obtener el archivo `.conf`
4. En tu dispositivo VPN:
   - Instala la app de WireGuard (disponible en App Store, Google Play, etc.)
   - Importa el archivo `.conf` descargado
   - Activa la conexión

### Opción 2: Manual - Editar Configuración

Si necesitas cambiar rutas o configuraciones:

1. Edita `wireguard/config/wg0.conf`
2. Modifica las líneas `AllowedIPs` para el cliente:
   ```
   [Peer]
   PublicKey = ...
   AllowedIPs = 10.8.0.x/32, 192.168.83.0/24, 192.168.85.0/26
   ```
3. Recarga la configuración:
   ```bash
   docker exec wireguard sh -c 'wg syncconf wg0 <(wg-quick strip wg0)'
   ```

---

## 🔗 Acceso a Dispositivos Desde VPN

### Raspberry Pi (Host)
```
IP: 192.168.83.22
- SSH: ssh usuario@192.168.83.22
- Consola remota
```

### Mac Mini (Escritorio Remoto)
```
IP: 192.168.83.23
- SSH: ssh usuario@192.168.83.23
- RDP: Conexión a escritorio remoto (puerto 3389)
- Apple Remote Desktop: 192.168.83.23
```

### Otros Dispositivos en Red Local
- Cámara IP, impresora, etc. están disponibles en 192.168.83.x

---

## 🐳 Acceso a Servicios Docker

Desde VPN puedes acceder a cualquier servicio en 192.168.85.0/26:

| Servicio | IP | Puerto | URL |
|----------|----|----|-----|
| **Plex** | 192.168.85.x | host mode | http://192.168.83.22:32400 |
| **Jellyfin** | 192.168.85.x | host mode | http://192.168.83.22:8096 |
| **Grafana** | 192.168.85.51 | 3000 | http://192.168.85.51:3000 |
| **Prometheus** | 192.168.85.50 | 9090 | http://192.168.85.50:9090 |
| **Nginx** | 192.168.85.13 | 80/443 | http://192.168.85.13 |

---

## ⚙️ Configuración Actual de WireGuard

### Servidor WireGuard
- **Dirección VPN:** 10.8.0.1
- **Puerto:** 51820 (UDP)
- **Rango de clientes:** 10.8.0.0/24

### Cliente: Xiaomi 12
- **Dirección VPN:** 10.8.0.2
- **Redes accesibles:**
  - 10.8.0.2/32 (su IP VPN)
  - 192.168.83.0/24 (Red local - ACTUALIZADO ✅)
  - Pronto: 192.168.85.0/26 (Red Docker)

### Rutas y Routing
```
PostUp Rules:
- NAT: 10.8.0.0/24 → eth0 (MASQUERADE)
- Forwarding: Permitir tráfico bidireccional
- INPUT: Aceptar puerto 51820
```

---

## 🔍 Troubleshooting

### "No puedo conectarme a la VPN"

1. Verifica que el puerto 51820/UDP esté abierto en router
2. Comprueba el servidor DDNS: `ping temp2010.ddns.net`
3. Verifica logs: `docker logs wireguard`
4. Reinicia WireGuard: `docker restart wireguard`

### "Conectado a VPN pero no puedo acceder a red local"

1. Verifica AllowedIPs incluyan 192.168.83.0/24
2. Verifica rutas de firewall: `sudo iptables -L -n -v`
3. Comprueba conectividad: `ping 192.168.83.22` desde cliente VPN
4. Revisa logs: `docker logs wireguard`

### "Conexión muy lenta"

1. Verifica MTU: Intenta cambiar a MTU 1420 en cliente
2. Verifica latencia: `ping 10.8.0.1`
3. Revisa si hay congestionamiento: `docker stats wireguard`
4. Comprueba conexión internet: `ping 8.8.8.8`

### "Se desconecta frecuentemente"

1. Habilita PersistentKeepalive en cliente:
   ```
   PersistentKeepalive = 25
   ```
2. Reinicia el contenedor: `docker restart wireguard`
3. Reinstala configuración de cliente

---

## 🛡️ Seguridad

### ✅ Buenas Prácticas Implementadas:
- ✅ Contraseña fuerte en web UI
- ✅ WireGuard corre como contenedor aislado
- ✅ Firewall rules aplicadas (ver `REGLAS-VPN-BLOQUEO.txt`)
- ✅ Clave privada protegida en volumen

### ⚠️ Recomendaciones Adicionales:
1. Cambia la contraseña del web UI regularmente
2. Genera nuevas claves cada 90 días
3. Desactiva clientes no usados
4. Monitorea logs para conexiones sospechosas
5. Usa VPN únicamente desde redes confiables

---

## 📊 Monitoreo de Conexiones

### Ver clientes conectados:
```bash
docker exec wireguard wg show wg0
```

### Ver logs del servidor:
```bash
docker logs wireguard -f
```

### Ver estadísticas:
```bash
docker stats wireguard
```

---

## 🔧 Comandos Útiles

### Reiniciar WireGuard:
```bash
docker restart wireguard
```

### Ver configuración actual:
```bash
docker exec wireguard wg show
```

### Recarga ligera (sin reiniciar):
```bash
docker exec wireguard sh -c 'wg syncconf wg0 <(wg-quick strip wg0)'
```

### Ver archivos de configuración:
```bash
ls -lah ~/containers/wireguard/config/
```

---

## 📞 Soporte y Más Información

**Documentación WireGuard:** https://www.wireguard.com/  
**WG-Easy GitHub:** https://github.com/wg-easy/wg-easy  
**Configuración local:** `/home/jopena/containers/wireguard/`

---

**Última actualización:** 2026-07-23  
**Estado:** ✅ Operativo  
**Versión:** wg-easy latest
