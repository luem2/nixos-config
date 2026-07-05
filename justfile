set shell := ["bash", "-euo", "pipefail", "-c"]

host := env("NIXOS_HOST", "workstation")

default:
    @just --list

check:
    nix flake check

build:
    nix build .#nixosConfigurations.{{ host }}.config.system.build.toplevel --no-link

switch:
    sudo nixos-rebuild switch --flake .#{{ host }}

boot:
    sudo nixos-rebuild boot --flake .#{{ host }}

test:
    sudo nixos-rebuild test --flake .#{{ host }}

update:
    nix flake update

update-input input:
    nix flake update {{ input }}

rollback:
    sudo nixos-rebuild switch --rollback

history:
    nix profile history --profile /nix/var/nix/profiles/system

gc:
    sudo nix store gc

prune-generations keep="5":
    [[ "{{ keep }}" =~ ^[0-9]+$ ]]
    sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +{{ keep }}
    sudo nix store gc
