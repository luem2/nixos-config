# Host office

Base para una máquina de trabajo en NixOS sin mezclar sus decisiones con la
notebook personal.

Checklist:

1. Instalar o arrancar una ISO de NixOS.
2. Generar `hardware-configuration.nix` para esta máquina.
3. Decidir si usa LUKS/Disko o particionado existente.
4. Crear `hosts/office/default.nix`.
5. Agregar `nixosConfigurations.office` en `flake.nix`.
6. Mantener configuraciones laborales separadas de secretos personales.

Decisiones del perfil:

- perfil workstation con Niri + Noctalia si el hardware lo permite;
- `hosts/office/niri-outputs.kdl` si necesita monitores propios;
- VPN/SSH/credenciales cifradas con `sops-nix`;
- paquetes laborales sólo si no contaminan el perfil personal.
