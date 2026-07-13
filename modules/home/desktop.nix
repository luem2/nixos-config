{
  config,
  hostName,
  pkgs,
  pkgsUnstable,
  repoPath,
  ...
}:

let
  niriConfig = builtins.readFile ../../configs/niri/config.kdl.in;
  niriOutputsPath = ../../hosts + "/${hostName}/niri-outputs.kdl";
in
{
  home.packages = with pkgs; [
    bitwarden-cli
    clock-rs
    ente-auth
    gnome-disk-utility
    ghostty
    nautilus
    file-roller
    inkscape
    krita
    libreoffice
    localsend
    nerd-fonts.hurmit
    nerd-fonts.jetbrains-mono
    obsidian
    pkgsUnstable.bruno
    pkgsUnstable.dbeaver-bin
    seahorse
    thunderbird
  ];

  xdg.configFile = {
    "ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/configs/ghostty/config";
    "niri/config.kdl".text =
      builtins.replaceStrings [ "@niri_outputs_path@" ] [ "${config.xdg.configHome}/niri/outputs.kdl" ]
        niriConfig;
    "niri/outputs.kdl".source = niriOutputsPath;
  };

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      shell = {
        font_family = "JetBrainsMono Nerd Font";
        ui_scale = 0.8;
        telemetry_enabled = false;
        polkit_agent = true;
        niri_overview_type_to_launch_enabled = true;
        launch_apps_as_systemd_services = true;
      };
      lockscreen.enabled = true;
      idle = {
        pre_action_fade_seconds = 2.0;
        behavior = {
          lock = {
            enabled = true;
            timeout = 600;
            action = "lock";
          };
          screen-off = {
            enabled = true;
            timeout = 660;
            action = "screen_off";
          };
          lock-and-suspend = {
            enabled = true;
            timeout = 1800;
            action = "lock_and_suspend";
          };
        };
      };
      battery.warning_threshold = 20;
      theme = {
        mode = "dark";
        source = "wallpaper";
        builtin = "Ayu";
        wallpaper_scheme = "m3-content";
      };
      wallpaper = {
        enabled = true;
        directory = "~/Pictures/wallpapers";
      };
      backdrop = {
        enabled = true;
        blur_intensity = 1.0;
        tint_intensity = 0.0;
      };
      weather = {
        enabled = true;
        refresh_minutes = 30;
        unit = "celsius";
        effects = true;
      };
      location = {
        auto_locate = true;
      };
      keybinds = {
        down = [
          "Down"
          "Ctrl+J"
          "Ctrl+N"
        ];
        up = [
          "Up"
          "Ctrl+K"
          "Ctrl+P"
        ];
      };
      bar.main = {
        position = "top";
        thickness = 36;
        background_opacity = 0.88;
        margin_ends = 8;
        margin_edge = 6;
        padding = 10;
        widget_spacing = 8;
        font_weight = 600;
        radius = 12;
        shadow = true;
        reserve_space = true;
        capsule = true;
        capsule_fill = "surface_variant";
        capsule_opacity = 0.55;
        capsule_radius = 8.0;
        start = [
          "launcher"
          "workspaces"
        ];
        center = [ "clock" ];
        end = [
          "media"
          "tray"
          "notifications"
          "network"
          "bluetooth"
          "volume"
          "battery"
          "control-center"
        ];
      };
      widget = {
        workspaces = {
          type = "workspaces";
          display = "none";
        };
        clock = {
          type = "clock";
          format = "{:%a %d %b  %H:%M}";
          tooltip_format = "{:%A, %d de %B de %Y}";
        };
        media = {
          type = "media";
          hide_when_no_media = true;
          min_length = 80;
          max_length = 180;
          art_size = 18.0;
          title_scroll = "on_hover";
        };
        network = {
          type = "network";
          show_label = false;
        };
        bluetooth = {
          type = "bluetooth";
          show_label = false;
          hide_when_no_connected_device = true;
        };
        volume = {
          type = "volume";
          show_label = false;
        };
        notifications = {
          type = "notifications";
          hide_when_no_unread = true;
        };
      };
      dock = {
        enabled = false;
      };
      plugins = {
        enabled = [ "noctalia/translator" ];
      };
    };
  };
}
