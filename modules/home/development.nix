{ pkgs, pkgsUnstable, ... }:

{
  home.packages = with pkgs; [
    direnv
    go
    just-lsp
    nil
    nixd
    just
    nix-direnv
    nixfmt
    python3
    rust-analyzer
    rustc
    cargo
    shellcheck
    sqlfluff
    uv
    pkgsUnstable.codex
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
