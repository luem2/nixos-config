# Plantilla disponible para un servidor NixOS nuevo.
# Copiar a hosts/<nombre>/default.nix para declarar hardware real.
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/profiles/server.nix
  ];
}
