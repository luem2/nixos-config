{ inputs, ... }:

{
  imports = [
    inputs.noctalia-greeter.nixosModules.default
    ../core.nix
    ../desktop.nix
    ../greeter.nix
    ../hardware
    ../maintenance.nix
    ../networking.nix
    ../packages.nix
  ];
}
