{ inputs, ... }:

{
  imports = [
    inputs.noctalia-greeter.nixosModules.default
    inputs.stylix.nixosModules.stylix
    ../core.nix
    ../desktop.nix
    ../greeter.nix
    ../hardware
    ../maintenance.nix
    ../networking.nix
    ../packages.nix
    ../stylix.nix
  ];
}
