{
  pkgs,
  pkgsUnstable,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    google-chrome
    podman-compose
    pkgsUnstable.opencode
  ];

  programs = {
    firefox.enable = true;
  };
}
