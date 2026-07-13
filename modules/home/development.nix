{ pkgs, pkgsUnstable, ... }:

{
  home.packages = with pkgs; [
    direnv
    just-lsp
    nil
    nixd
    just
    nix-direnv
    nixfmt
    shellcheck
    pkgsUnstable.codex
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
