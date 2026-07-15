# Host office

Base para una máquina de trabajo en NixOS sin mezclar sus decisiones con la
notebook personal.

## Decisiones

- instalación limpia en un disco separado del disco de Windows;
- Windows queda intacto en su propio disco;
- NixOS usa LUKS + Btrfs mediante `hosts/office/disko.nix`;
- perfil workstation con Niri + Noctalia;
- `hosts/office/niri-outputs.kdl` guarda monitores propios;
- VPN/SSH/credenciales laborales deben quedar fuera del repo o ir a `sops-nix`
  cuando haya secretos declarativos reales.

## Antes de instalar

En Windows:

1. Confirmar que el disco de Windows no se va a tocar.
2. Guardar BitLocker recovery key si BitLocker está activo.
3. Hacer backup de archivos laborales importantes.
4. Desactivar Windows Fast Startup si Windows comparte hardware con Linux.
   Esto evita que Windows deje dispositivos o particiones en estado híbrido.
   Ruta orientativa: Control Panel -> Power Options -> Choose what the power
   buttons do -> Change settings that are currently unavailable -> desmarcar
   "Turn on fast startup". En Windows también se puede revisar con:

   ```powershell
   powercfg /a
   ```

   Si hibernación/fast startup molestan, desactivar hibernación elimina Fast
   Startup:

   ```powershell
   powercfg /h off
   ```

5. Entrar al firmware/UEFI y decidir el orden de arranque:
   Linux/NixOS como primera entrada, Windows sólo desde boot menu manual.

En la ISO de NixOS:

```bash
sudo -i
export NIX_CONFIG='experimental-features = nix-command flakes'

lsblk -o NAME,SIZE,MODEL,SERIAL,TYPE,FSTYPE,MOUNTPOINTS,PARTLABEL
lspci -nn
efibootmgr -v
```

No seguir hasta identificar con certeza el disco nuevo de Linux. El valor de
`diskDevice` debe apuntar a ese disco, no al disco de Windows.

## Preparar el host desde la ISO

```bash
nix-shell -p git vim pciutils
cd /tmp
git clone <URL-DE-ESTE-REPO> nixos-config
cd nixos-config
```

Generar el hardware real de esta PC:

```bash
mkdir -p hosts/office
nixos-generate-config --show-hardware-config > hosts/office/hardware-configuration.nix
```

## Habilitar `office` en `flake.nix`

Este repo deja `hosts/office` preparado, pero el host no debe agregarse al
flake hasta estar frente a la PC y conocer el disco real. Falta editar
`flake.nix` y agregar `office` dentro de `nixosConfigurations`, al lado de
`workstation`:

```nix
office = mkNixos {
  hostName = "office";
  diskDevice = "/dev/<DISCO-LINUX>";
  modules = [
    ./hosts/office
    inputs.disko.nixosModules.disko
    ./modules/nixos/virtualization.nix
  ];
};
```

Checklist antes de guardar ese bloque:

1. `hostName` debe quedar como `"office"`.
2. `diskDevice` debe apuntar al disco nuevo de Linux completo, no a una
   partición y no al disco de Windows.
3. `modules` debe incluir `./hosts/office`.
4. `inputs.disko.nixosModules.disko` debe estar incluido porque el host usa
   `hosts/office/disko.nix`.
5. `./modules/nixos/virtualization.nix` es opcional, pero conviene mantenerlo si
   querés Podman/virtualización como en la notebook personal.

Ejemplo: si `lsblk` muestra que el disco nuevo es `/dev/nvme1n1`, usar:

```nix
diskDevice = "/dev/nvme1n1";
```

No usar valores por costumbre. En algunas PCs el disco de Windows puede ser
`/dev/nvme0n1` y el disco Linux `/dev/nvme1n1`; en otras puede ser al revés.
Confirmar por tamaño, modelo y serial:

```bash
lsblk -o NAME,SIZE,MODEL,SERIAL,TYPE,FSTYPE,MOUNTPOINTS,PARTLABEL
```

## Instalar

Este paso destruye sólo el disco indicado por `diskDevice`:

```bash
nix run github:nix-community/disko -- \
  --mode destroy,format,mount \
  --flake .#office

nixos-install --flake .#office
nixos-enter --root /mnt -c 'passwd lucho'
reboot
```

## Primer arranque

```bash
lsblk -f
findmnt / /home /nix /boot
systemctl --failed
just build
```

Si el monitor queda con escala/resolución incómoda, ajustar:

```text
hosts/office/niri-outputs.kdl
```

## VPN

La configuración compartida instala NetworkManager con plugins para:

- OpenVPN;
- OpenConnect, común para Cisco/GlobalProtect compatibles;
- Fortinet SSL VPN;
- L2TP/IPsec;
- vpnc;
- WireGuard por CLI.

Para importar o editar perfiles visualmente:

```bash
nm-connection-editor
```

Si Noctalia muestra tray, `nm-applet` puede dar un icono visual. Para un flujo
de teclado o diagnóstico, usar:

```bash
nmcli connection show
nmcli connection up <perfil>
nmcli connection down <perfil>
journalctl -b -u NetworkManager.service
```

## Cifrado

Recomendación para daily driver laboral: TPM2 + PIN después de confirmar que el
primer arranque funciona. La passphrase larga de LUKS queda como recuperación.

Enrolar el PIN ajustando la partición real de LUKS:

```bash
sudo systemd-cryptenroll \
  --wipe-slot=tpm2 \
  --tpm2-device=auto \
  --tpm2-with-pin=yes \
  /dev/<PARTICION-LUKS>
```

Si el disco Linux es `/dev/nvme1n1`, normalmente la partición LUKS será
`/dev/nvme1n1p2`, pero confirmar siempre con `lsblk -f`.

## Pendiente por máquina

- generar `hosts/office/hardware-configuration.nix`;
- agregar `office` a `flake.nix` con el `diskDevice` real;
- ajustar `hosts/office/niri-outputs.kdl`;
- decidir si alguna herramienta laboral debe vivir sólo en este host.
