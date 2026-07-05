{ pkgs, repoPath, ... }:

let
  updateCheck = pkgs.writeShellApplication {
    name = "nixos-update-check";
    runtimeInputs = with pkgs; [
      coreutils
      diffutils
      libnotify
      nix
    ];
    text = ''
      repo="${repoPath}"

      if [[ ! -f "$repo/flake.nix" || ! -f "$repo/flake.lock" ]]; then
        notify-send "NixOS" "No se encontró el flake en $repo"
        exit 0
      fi

      tmp="$(mktemp -d)"
      trap 'rm -rf "$tmp"' EXIT
      cp "$repo/flake.nix" "$repo/flake.lock" "$tmp/"

      if ! nix flake update --flake "$tmp" >/dev/null; then
        notify-send "NixOS" "No se pudo comprobar si hay actualizaciones"
        exit 0
      fi

      if cmp -s "$repo/flake.lock" "$tmp/flake.lock"; then
        notify-send "NixOS" "El flake está actualizado"
      else
        notify-send -u normal "NixOS" "Hay actualizaciones disponibles. Ejecutá: just update"
      fi
    '';
  };
in
{
  home.packages = [ updateCheck ];

  systemd.user.services.nixos-update-check = {
    Unit = {
      Description = "Comprobar actualizaciones del flake de NixOS";
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${updateCheck}/bin/nixos-update-check";
    };
  };

  systemd.user.timers.nixos-update-check = {
    Unit.Description = "Comprobación semanal de actualizaciones de NixOS";
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "2h";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
