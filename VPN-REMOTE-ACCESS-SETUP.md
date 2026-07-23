# 🔐 Acceso Remoto VPN - Guía Completa

## 🎯 Lo que Conseguirás

Desde **fuera de casa** (oficina, café, viaje):
```
✅ Conectarte a VPN (Puerto 51820 UDP - único expuesto)
✅ Todo tu tráfico pasa por casa (seguro + DNS AdGuard)
✅ Acceso a escritorio remoto del Mac Mini
✅ SSH a Raspberry Pi y otros dispositivos
✅ Acceso a servicios internos (Plex, Jellyfin, Prometheus)
✅ Salir por internet de tu casa
✅ Bloqueo de publicidad (AdGuard activo)
```

---

## 📋 Requisitos Previos

### En la Raspberry Pi ✅ (YA HECHO)
- [x] WireGuard corriendo
- [x] Cliente Xiaomi 12 configurado
- [x] Tráfico completo por VPN (0.0.0.0/0)
- [x] DNS: 192.168.83.22 (AdGuard Home)

### En tu Router ⚠️ (FALTA HACER)
- [ ] Port Forwarding: 51820 UDP → 192.168.83.22
- [ ] IP Pública dinámica (DDNS: temp2010.ddns.net)
- [ ] Firewall: Permitir puerto 51820

### En tu Celular/Laptop ⚠️ (FALTA HACER)
- [ ] WireGuard app instalada
- [ ] Configuración descargada
- [ ] Conectado a VPN

---

## 🔧 PASO 1: Configurar Router

### A) Port Forwarding (CRÍTICO)

Tu router necesita redirigir el puerto 51820 UDP a la Raspberry Pi.

**Pasos genéricos:**
```
1. Abre: 192.168.1.1 o 192.168.0.1 (dirección del router)
2. Usuario/Contraseña: admin/admin (o tu contraseña)
3. Busca: "Port Forwarding" o "Redirección de puertos"
4. Agrega nueva regla:
   - Protocolo: UDP
   - Puerto externo: 51820
   - Puerto interno: 51820
   - IP destino: 192.168.83.22 (tu Raspberry Pi)
5. Guarda y reinicia router (opcional)
```

**Marcas específicas:**
- **TP-Link:** Advanced → NAT Forwarding → Port Forwarding
- **D-Link:** Advanced → Port Forwarding
- **Cisco/Linksys:** Advanced → Port Range Forwarding
- **Huawei/ZTE:** Port Mapping

### B) Verificar IP Pública Dinámica

Tu router probablemente tiene IP pública dinámica (cambia). Por eso usas DDNS.

**Verifica que DDNS esté configurado:**
```
Tu dominio: temp2010.ddns.net
Cliente: Probablemente noip.com o similar
Estado: Debe estar "Connected"
```

**Verificar IP pública actual:**
```bash
# Desde Raspberry:
curl ifconfig.me
# O en navegador:
https://www.cualesmiip.com/
```

---

## 📱 PASO 2: Descargar Configuración de Cliente

### Opción A: Desde Web UI de WireGuard (Recomendado)

```
1. Abre: http://temp2010.ddns.net:8020
   (Desde DENTRO de casa)
   
2. O desde fuera: Necesitas estar en VPN primero
   O usar IP pública + contraseña
   
3. Busca cliente "Xiaomi 12"

4. Click en ⬇️ (Descargar) → Guarda archivo .conf
```

### Opción B: Desde Raspberry Pi Directamente

```bash
# En terminal de Raspberry:
cat ~/containers/wireguard/config/wg0.json | grep -A 20 '"Xiaomi 12"'

# Luego creas archivo: xiaomi12.conf
```

---

## 📲 PASO 3: Conectar Desde Celular/Laptop

### iOS/Android

```
1. Descarga "WireGuard" desde App Store / Google Play
2. Abre WireGuard
3. + (agregar)
4. "Importar desde archivo"
5. Selecciona: xiaomi12.conf
6. "Importar" y "Activar"
```

### macOS/Windows

```
1. Descarga WireGuard: wireguard.com/install
2. Instala y abre
3. + (agregar túnel)
4. "Importar desde archivo"
5. Selecciona: xiaomi12.conf
6. Activa
```

### Linux

```bash
sudo apt install wireguard wireguard-tools
sudo cp xiaomi12.conf /etc/wireguard/wg0.conf
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
sudo wg show
```

---

## 🧪 PASO 4: Verificar Conexión

### Desde tu Celular/Laptop (FUERA de casa):

```bash
# 1. Conectar a WireGuard
# (click en app para activar)

# 2. Esperar 3-5 segundos

# 3. Verificar que está conectado:
#    - App muestra "Connected" 
#    - Ves IP: 10.8.0.2

# 4. Probar conectividad:
#    - Ping a 192.168.83.22 (Raspberry)
#    - Visita cualesmiip.com (debe mostrar tu IP de casa)
```

### Pruebas de Funcionalidad

```bash
# Conectado a VPN:

1. Escritorio Remoto (Mac Mini):
   IP: 192.168.83.23:5900
   Usuario: (tu usuario)

2. SSH a Raspberry:
   ssh usuario@192.168.83.22

3. SSH a Mac Mini:
   ssh usuario@192.168.83.23

4. Acceso a Plex/Jellyfin:
   http://192.168.83.22:32400
   http://192.168.83.22:8096

5. Verificar DNS:
   nslookup google.com (debería usar AdGuard)
   
6. Salida por internet de casa:
   curl ifconfig.me (debe mostrar IP de tu casa)
```

---

## 🚨 Problemas Comunes

### "No puedo conectarme a la VPN"

**Causa 1: Puerto 51820 no está abierto**
```bash
# Desde fuera, prueba:
nc -u -zv temp2010.ddns.net 51820

# Si dice "failed": El puerto NO está abierto
# Solución: Configura Port Forwarding en router
```

**Causa 2: DDNS no funciona**
```bash
# Desde Raspberry:
nslookup temp2010.ddns.net
# Debe mostrar tu IP pública

# Si no funciona:
- Verifica cliente DDNS en router
- Reinicia router
- Crea nuevo cliente DDNS si falta
```

**Causa 3: WireGuard no está corriendo**
```bash
docker ps | grep wireguard
# Si no aparece:
docker start wireguard
# O reinicia:
docker restart wireguard
```

### "Conectado a VPN pero no tengo internet"

```bash
# Problema: DNS no funciona

# Soluciones:
1. Verifica DNS en cliente .conf:
   DNS = 192.168.83.22 (AdGuard)

2. Verifica AdGuard está corriendo:
   ping 192.168.83.22

3. Si sigue sin funcionar:
   - Recarga configuración
   - Reinicia WireGuard
   - Genera nueva configuración de cliente
```

### "Internet lento desde VPN"

```
Normal si:
- Tienes conexión lenta en casa
- Hay mucho tráfico
- Red WiFi débil

Soluciones:
- Usa Ethernet en Raspberry Pi
- Reduce MTU a 1420 en cliente
- Cerca la app de WireGuard en background
```

---

## 🔐 Seguridad - Solo Puerto 51820

**Lo que está BLOQUEADO para internet:**
- ❌ SSH directo (puerto 22)
- ❌ Servicios web sin VPN
- ❌ Base de datos
- ❌ Cualquier otro puerto

**Lo único abierto es:**
- ✅ Puerto 51820 UDP (WireGuard VPN)

**Beneficios:**
- Conexión encriptada (WireGuard)
- Sin exponer servicios individuales
- Solo autorizado quienes tienen clave VPN
- Todo el tráfico controlado

---

## 📊 Flujo de Tráfico

```
┌─────────────────────────────────────────────────┐
│ TU CELULAR EN OFICINA                           │
│ (conect VPN)                                     │
└────────────────────┬────────────────────────────┘
                     │
        INTERNET PÚBLICA (seguro)
                     │ Puerto 51820 UDP
                     │ (Encriptado con WireGuard)
                     ▼
┌─────────────────────────────────────────────────┐
│ TU ROUTER (Port Forward 51820 → 192.168.83.22) │
└────────────────────┬────────────────────────────┘
                     │
              RED LOCAL (192.168.83.x)
                     │
                     ▼
        ┌────────────────────────────┐
        │ RASPBERRY PI (WireGuard)   │
        │ 192.168.83.22              │
        └────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
    MAC MINI              Otros dispositivos
   192.168.83.23          (Servicios, etc)
   (SSH, RDP)
```

---

## 📞 Checklist Final

### Antes de viajar:
- [ ] WireGuard instalado en tu dispositivo
- [ ] Archivo .conf descargado
- [ ] Probaste VPN en casa (funciona)
- [ ] Configuraste Port Forwarding en router
- [ ] Probaste conexión desde fuera (café, etc)
- [ ] Verificaste que DNS/Internet funcionan

### En la oficina:
- [ ] Abrir WireGuard app
- [ ] Click en cliente "Xiaomi 12"
- [ ] Esperar "Connected"
- [ ] Ya tienes acceso a todo

---

## 🎯 URLs de Acceso (Conectado a VPN)

```
SSH:           ssh usuario@192.168.83.22 (Raspberry)
SSH:           ssh usuario@192.168.83.23 (Mac Mini)
RDP:           192.168.83.23:5900 (Escritorio Mac)
Plex:          http://192.168.83.22:32400
Jellyfin:      http://192.168.83.22:8096
Grafana:       http://192.168.85.51:3000
Prometheus:    http://192.168.85.50:9090
AdGuard:       http://192.168.83.22:3000
```

---

## 📚 Documentación Adicional

- **WireGuard:** https://www.wireguard.com
- **DDNS:** Revisa configuración en tu router
- **Port Forwarding:** Búsca tu modelo de router en Google

---

**Estado:** ✅ Listo para usar  
**Última actualización:** 2026-07-23  
**VPN:** WireGuard + 0.0.0.0/0 (Todo el tráfico)
