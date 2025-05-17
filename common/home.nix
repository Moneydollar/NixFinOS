{
  lib,
  pkgs,
  username,
  host,
  inputs,

  ...
}:
let
  inherit (import ../hosts/${host}/variables.nix) gitUsername gitEmail;
  nvimPlugins = import ../config/neovim/plugins.nix;
  nvimConfig = import ../config/neovim/extraConfig.nix;
in
{
  # Home Manager Settings

  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.sessionPath = [
    "$HOME/.local/bin"
    "~/.local/share/"
  ];
  home.stateVersion = "24.11";

  home.sessionVariables = {
    TERMINAL = "kitty";
  };

  # Import Program Configurations
  imports = [
    ../modules/apps/firefox.nix
    ../config/fastfetch
    inputs.nix4nvchad.homeManagerModule
  ];

  programs.nvchad = {
    enable = true;
    extraConfig = nvimConfig;
    extraPlugins = nvimPlugins;
    extraPackages = with pkgs; [
      nodePackages.bash-language-server
      docker-compose-language-service
      dockerfile-language-server-nodejs
      emmet-language-server
      nil
      nixd
      (python3.withPackages (
        ps: with ps; [
          pyright
          clang-tools
        ]
      ))
    ];

    hm-activation = true;
    backup = true;
  };
  # Place Files Inside Home Directory
  home.file."Pictures/Wallpapers" = {
    source = ../config/wallpapers;
    recursive = true;
  };

  home.file."/.local/share/themes/rose-pine" = {
    source = ../config/gtk/rose-pine;
    recursive = true;
  };

  home.file.".config/swappy/config".text = ''
    [Default]
    save_dir=/home/${username}/Pictures/Screenshots
    save_filename_format=swappy-%Y%m%d-%H%M%S.png
    show_panel=false
    line_size=5
    text_size=20
    text_font=Ubuntu
    paint_mode=brush
    early_exit=true
    fill_shape=false
  '';

  # Install & Configure Git
  programs.git = {
    enable = true;
    userName = "${gitUsername}";
    userEmail = "${gitEmail}";
  };

  # Create XDG Dirs
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
    "org/gnome/desktop/default-applications/terminal" = {
      exec = "kitty";
      exec-arg = "-e";
    };
    "org/gnome/shell" = {

      disable-user-extensions = false;

      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "blur-my-shell@aunetx"
        "caffeine@patapon.info"
        "dash-to-dock@micxgx.gmail.com"
        "just-perfection-desktop@just-perfection"
        "mediacontrols@cliffniff.github.com"
        "quick-settings-audio-panel@rayzeq.github.io"
        "tailscale@joaophi.github.com"
        "tilingshell@ferrarodomenico.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "weathernorot@somepaulo.github.io"
      ];

    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "kitty";
      command = "kitty";
      binding = "<Super>Return";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "VSCode";
      command = "code";
      binding = "<Super>c";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      name = "Mission Center";
      command = "missioncenter";
      binding = "<Shift><Control>Escape";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      name = "Emote picker";
      command = "flatpak run com.tomjwatson.Emote";
      binding = "<Super>period";
    };

    "org/gnome/desktop/wm/keybindings" = {
      toggle-fullscreen = [ "<Super>f" ];
      close = [ "<Super>q" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
      name = "Web Browser";
      command = "firefox";
      binding = "<Super>w";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" = {
      name = "File Explorer";
      command = "nautilus";
      binding = "<Super>e";
    };
    "org/gnome/desktop/interface" = {
      gtk-theme = "rose-pine-gtk";
      icon-theme = "Papirus-Dark";
      cursor-theme = "Bibata-Modern-Ice";
      color-scheme = "prefer-dark"; # GTK4 aware apps
    };
  };

  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    exec = "kitty -e nvim";
    terminal = false;
    icon = "nvim";
    type = "Application";
    categories = [
      "Utility"
      "TextEditor"
    ];
  };
  home.sessionVariables.GTK_THEME = "rose-pine-gtk";
  gtk = {
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {

      name = "rose-pine-gtk";

      package = pkgs.rose-pine-gtk-theme;

    };

    cursorTheme = {

      name = "Bibata-Modern-Ice";

      package = pkgs.bibata-cursors;

    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  qt = {
    enable = true;

    # platformTheme.name = lib.mkForce "qt5ct";
  };

  xdg.configFile = {
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=GraphiteNordDark
    '';

    "Kvantum/GraphiteNord".source = "${pkgs.graphite-kde-theme}/share/Kvantum/GraphiteNord";
  };

  home.packages = with pkgs; [
    (import ../scripts/emopicker9000.nix { inherit pkgs; })
    (import ../scripts/task-waybar.nix { inherit pkgs; })
    (import ../scripts/squirtle.nix { inherit pkgs; })
    (import ../scripts/nvidia-offload.nix { inherit pkgs; })
    (import ../scripts/add-pkg.nix { inherit pkgs; })
    (import ../scripts/wallsetter.nix {
      inherit pkgs;
      inherit username;
    })
    (import ../scripts/web-search.nix { inherit pkgs; })
    (import ../scripts/changeMac.nix { inherit pkgs; })
    (import ../scripts/rofi-launcher.nix { inherit pkgs; })
    (import ../scripts/screenshootin.nix { inherit pkgs; })
    (import ../scripts/list-hypr-bindings.nix {
      inherit pkgs;
      inherit host;
    })

    gnomeExtensions.user-themes
    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator
    gnomeExtensions.caffeine
    gnomeExtensions.just-perfection
    gnomeExtensions.media-controls
    gnomeExtensions.quick-settings-audio-panel
    gnomeExtensions.tailscale-qs
    gnomeExtensions.tiling-shell
    gnomeExtensions.weather-or-not
    gnomeExtensions.blur-my-shell

  ];

  programs = {
    gh.enable = true;
    btop = {
      enable = true;
      settings = {
        vim_keys = false;
      };
    };

    nixcord = {
      enable = true; # eable Nixcord. Also installs discord package
      quickCss = "some CSS"; # quickCSS file
      config = {
        useQuickCss = true; # use our quickCSS
        themeLinks = [
          # or use an online theme
          "https://refact0r.github.io/midnight-discord/themes/flavors/midnight-rose-pine.theme.css"
        ];

        frameless = false; # set some Vencord options
        plugins = {
          hideAttachments.enable = true; # Enable a Vencord plugin
          invisibleChat.enable = true;
          loadingQuotes.enable = true;
          USRBG.enable = true;
          fakeProfileThemes.enable = true;
          emoteCloner.enable = true;
          customRPC.enable = true;
          betterUploadButton.enable = true;
          betterSettings.enable = true;
          alwaysTrust.enable = true;
          friendsSince.enable = true;
          vencordToolbox.enable = true;
          whoReacted.enable = true;
          youtubeAdblock.enable = true;
          shikiCodeblocks.enable = true;
          secretRingToneEnabler.enable = true;
          reviewDB.enable = true;
          userMessagesPronouns.enable = true;
          platformIndicators.enable = true;
          pictureInPicture.enable = true;
          moreCommands.enable = true;
          fakeNitro.enable = true;
          nsfwGateBypass.enable = true;
          decor.enable = true;
          ignoreActivities = {
            # Enable a plugin and set some options
            enable = true;
            ignorePlaying = true;
            ignoreWatching = true;
          };

        };
      };
    };

    kitty = {
      enable = true;
      package = pkgs.kitty;
      settings = {
        scrollback_lines = 2000;
        shell = "fish";
        wheel_scroll_min_lines = 1;
        window_padding_width = 0;
        tab_bar_style = "hidden";
        allow_remote_control = "yes";
        font-size = 14;
        confirm_os_window_close = 0;
      };
      extraConfig = ''
        tab_bar_style fade
        tab_fade 1
        active_tab_font_style   bold
        inactive_tab_font_style bold
        paste_actions confirm-if-large
      '';
    };

    starship = {
      enable = true;
      package = pkgs.starship;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    fish = {
      enable = true;
      shellAliases = {
        update = "sudo nixos-rebuild switch --flake ~/NixOME/#${host}";
        edit = "nvim ~/NixOME/";
        sv = "sudo nvim";
        fr = "nh os switch --hostname ${host} /home/${username}/NixOME";
        fu = "nh os switch --hostname ${host} --update /home/${username}/NixOME";
        ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
        v = "nvim";
        vim = "nvim";
        vi = "nvim";
        lg = "lazygit";
        cat = "bat";
        ls = "eza --icons";
        ll = "eza -lh --icons --grid --group-directories-first";
        la = "eza -lah --icons --grid --group-directories-first";
        ".." = "cd ..";
      };

      interactiveShellInit = "
      set -g fish_greeting
      set -gx PATH $HOME/bin $PATH
      set -gx PATH $HOME/.cargo/bin $PATH
      ";

    };

    home-manager.enable = true;

  };
}
