{ pkgs, userName, ... }:

{
  programs.noctalia-greeter = {
    enable = true;
    greeter-args = "--session niri --user ${userName}";
    settings.cursor = {
      theme = "Adwaita";
      size = 24;
      package = pkgs.adwaita-icon-theme;
    };
  };

  security.pam.services.greetd.enableGnomeKeyring = true;
}
