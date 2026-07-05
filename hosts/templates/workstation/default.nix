# Plantilla disponible para una workstation nueva.
# Copiar a hosts/<nombre>/default.nix para declarar hardware real.
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/profiles/workstation.nix
  ];
}
