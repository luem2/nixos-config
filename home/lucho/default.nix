{ userName, ... }:

{
  imports = [
    ../../modules/home
  ];

  home = {
    username = userName;
    homeDirectory = "/home/${userName}";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
