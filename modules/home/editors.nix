{
  config,
  pkgs,
  repoPath,
  ...
}:

let
  vscodeSecure = pkgs.vscode.override {
    commandLineArgs = "--password-store=gnome-libsecret";
  };
  nvimPlugins = with pkgs.vimPlugins; [
    gitsigns-nvim
    lualine-nvim
    mini-nvim
    nvim-lspconfig
    nvim-web-devicons
    oil-nvim
    plenary-nvim
    telescope-fzf-native-nvim
    telescope-nvim
    tokyonight-nvim
    which-key-nvim
    (nvim-treesitter.withPlugins (
      parsers: with parsers; [
        bash
        css
        html
        javascript
        json
        lua
        markdown
        markdown_inline
        nix
        python
        regex
        toml
        tsx
        typescript
        vim
        vimdoc
        yaml
      ]
    ))
  ];
  nvimPack = pkgs.neovimUtils.packDir {
    hm = {
      start = nvimPlugins;
      opt = [ ];
    };
  };
in
{
  home.packages = [
    pkgs.zed-editor
  ];

  xdg.configFile = {
    "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/configs/nvim/lua";
    "nvim/stylua.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${repoPath}/configs/nvim/stylua.toml";
    "Code/User/settings.json" = {
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/configs/vscode/settings.json";
    };
    "Code/User/keybindings.json" = {
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/configs/vscode/keybindings.json";
    };
    "Code/User/snippets/python.json" = {
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink "${repoPath}/configs/vscode/snippets/python.json";
    };
    "zed/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${repoPath}/configs/zed/settings.json";
    "zed/keymap.json".source =
      config.lib.file.mkOutOfStoreSymlink "${repoPath}/configs/zed/keymap.json";
  };

  programs.vscode = {
    enable = true;
    package = vscodeSecure;
    mutableExtensionsDir = true;
    argvSettings = {
      enable-crash-reporter = false;
      locale = "en";
    };
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "onedarker";
      editor = {
        line-number = "relative";
        mouse = false;
        bufferline = "multiple";
        cursorline = true;
        true-color = true;
        cursor-shape.insert = "bar";
      };
      keys.normal.esc = [
        "collapse_selection"
        "keep_primary_selection"
      ];
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = false;
    viAlias = true;
    vimAlias = true;
    initLua = ''
      vim.opt.packpath:prepend("${nvimPack}")
      vim.opt.runtimepath:prepend("${nvimPack}")
      vim.opt.runtimepath:prepend("${repoPath}/configs/nvim")
      dofile("${repoPath}/configs/nvim/init.lua")
    '';
    extraPackages = with pkgs; [
      fd
      lua-language-server
      nil
      pyright
      ripgrep
      typescript-language-server
    ];
  };

  # VS Code extensions remain mutable and are handled by VS Code Settings Sync.
  # User JSON files are versioned in this repo and linked out-of-store so VS Code
  # can still update them without hitting Nix store read-only paths.
}
