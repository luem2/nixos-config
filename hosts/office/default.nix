# Host-specific entrypoint for the office machine.
# Generate hardware-configuration.nix from the NixOS ISO before enabling this
# host in flake.nix.
{ ... }:

{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../../modules/nixos/encryption.nix
    ../../modules/nixos/profiles/workstation.nix
  ];
}
