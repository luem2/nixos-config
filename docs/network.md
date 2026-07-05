# NetworkManager y VPN

Notas migradas desde el repo anterior. Son procedimientos de diagnóstico para
problemas reales de Wi‑Fi y perfiles VPN importados en NetworkManager.

## Wi‑Fi: autoconnect, prioridad y perfiles guardados

NetworkManager no elige “la red más cercana” de forma literal. Decide en base a
perfiles guardados, `autoconnect`, prioridad del perfil y resultados previos de
conexión.

Cuando se conecta una red una vez desde la UI o con `nmcli`, el perfil queda
guardado localmente en `/etc/NetworkManager/system-connections/` y se vuelve a
usar automáticamente. Esos perfiles pueden contener contraseñas, por eso no se
versionan en este repo.

## Wi‑Fi: Intel BE201 e inestabilidad

Síntoma observado en esta máquina:

- cortes y reconexiones frecuentes;
- `NetworkManager` registra `link timed out` y `Activation failed`;
- el kernel registra repetidamente `iwlwifi ... missed beacons exceeds
  threshold` y `Connection to AP ... lost`.

Mitigación declarada:

- desactivar powersave de Wi‑Fi en NetworkManager;
- cargar `iwlwifi` con `power_save=0`;
- desactivar temporalmente Wi‑Fi 7/EHT con `disable_11be=1`.

Esto fuerza al adaptador Intel BE201 a usar modos más maduros como Wi‑Fi 6/5.
Si la conexión queda estable durante varios días, el problema probablemente está
en la combinación BE201 + firmware/driver + router usando Wi‑Fi 7. Más adelante
se puede volver a habilitar `11be` para probar.

Inspeccionar perfiles:

```bash
nmcli connection show
```

Ver nombre, tipo, autoconnect y prioridad:

```bash
nmcli -f NAME,TYPE,AUTOCONNECT,AUTOCONNECT-PRIORITY connection show
```

Subir la prioridad de un perfil:

```bash
nmcli connection modify "<wifi>" connection.autoconnect-priority 200
```

Bajar la prioridad de otro perfil:

```bash
nmcli connection modify "<wifi>" connection.autoconnect-priority 50
```

Desactivar autoconnect sin borrar el perfil:

```bash
nmcli connection modify "<wifi>" connection.autoconnect no
```

Borrar un perfil guardado:

```bash
nmcli connection delete "<wifi>"
```

Ver la conexión activa:

```bash
nmcli -f NAME,TYPE,DEVICE,STATE connection show --active
```

Logs del arranque actual:

```bash
journalctl -b -u NetworkManager.service
```

Filtrar eventos Wi‑Fi/auth:

```bash
journalctl -b -u NetworkManager.service | rg "wifi|wpa|auth|ssid|wrong_key|need-auth"
```

## VPN importada en NetworkManager

Síntomas conocidos:

- la GUI entra en bucle pidiendo el secreto;
- al conectar, se pierde Internet;
- hosts internos no resuelven por DNS aunque el túnel levante.

Diagnóstico rápido:

```bash
nmcli connection show "<vpn>"
nmcli --show-secrets connection show "<vpn>"
nmcli device show tun0
resolvectl status
ip route
```

Si el perfil usa una clave privada cifrada, normalmente el secreto relevante es
`cert-pass`.

Guardar la passphrase del certificado de forma persistente:

```bash
sudo nvim /etc/NetworkManager/system-connections/<vpn>.nmconnection
```

En `[vpn]`:

```ini
cert-pass-flags=0
```

Agregar:

```ini
[vpn-secrets]
cert-pass=<passphrase>
```

Aplicar:

```bash
sudo chmod 600 /etc/NetworkManager/system-connections/<vpn>.nmconnection
sudo nmcli connection reload
```

Si al conectar se pierde Internet, dejar el perfil en split tunnel:

```bash
nmcli connection modify "<vpn>" ipv4.never-default yes ipv6.never-default yes
```

Si los hosts internos no resuelven, asociar el dominio interno al DNS del túnel:

```bash
nmcli connection modify "<vpn>" ipv4.dns-search "dominio.interno"
```

Reconectar:

```bash
nmcli connection down "<vpn>"
nmcli connection up "<vpn>"
```

Verificar:

```bash
resolvectl query host.interno.dominio.interno
nc -vz host.interno.dominio.interno 1433
```

Los perfiles importados viven en
`/etc/NetworkManager/system-connections/<vpn>.nmconnection`. Editar el `.ovpn`
original no actualiza automáticamente el perfil ya importado.
