{
  config,
  pkgs,
  host,
  username,
  options,
  inputs,
  ...
}:
let
  inherit (import ../hosts/${host}/variables.nix) keyboardLayout;

in
{
  imports = [
    ../hosts/${host}/hardware.nix
    ../hosts/${host}/users.nix
    ../modules/nvidia-drivers.nix
    ../modules/vm-guest-services.nix
    ../modules/local-hardware-clock.nix
  ];

  boot = {
    # Kernel
    kernelPackages = pkgs.linuxPackages_latest;
    # This is for OBS Virtual Cam Support
    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    # Needed For Some Steam Games
    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };
    # Bootloader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # Make /tmp a tmpfs
    tmp = {
      useTmpfs = true;
      tmpfsSize = "30%";
    };
    # Appimage Support
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };

    plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };
  };

  # Extra Module Options
  # drivers.amdgpu.enable = false;
  drivers.nvidia.enable = true;
  # drivers.nvidia-prime = {
  #   enable = false;
  #   intelBusID = "";
  #   nvidiaBusID = "";
  # };
  # drivers.intel.enable = false;
  vm.guest-services.enable = false;
  virtualisation.docker.enable = true;
  local.hardware-clock.enable = false;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = host;
  networking.timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
  # VPN
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  # Randomizes Wi-Fi Card MAC address on boot
  systemd.services.macchanger = {
    enable = true;
    description = "Randomize MAC address for wlp9s0";
    wants = [ "network-pre.target" ];
    before = [ "network-pre.target" ];
    after = [ "sys-subsystem-net-devices-wlp9s0.device" ];
    bindsTo = [ "sys-subsystem-net-devices-wlp9s0.device" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.runtimeShell} -c '${pkgs.iproute2}/bin/ip link set wlp9s0 down && ${pkgs.macchanger}/bin/macchanger -r wlp9s0 && ${pkgs.iproute2}/bin/ip link set wlp9s0 up'";
    };
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  hardware.steam-hardware.enable = true;
  programs = {
    starship = {
      enable = true;
      settings = {
        add_newline = false;
        buf = {
          symbol = " ";
        };
        c = {
          symbol = " ";
        };
        directory = {
          read_only = " 󰌾";
        };
        docker_context = {
          symbol = " ";
        };
        fossil_branch = {
          symbol = " ";
        };
        git_branch = {
          symbol = " ";
        };
        golang = {
          symbol = " ";
        };
        hg_branch = {
          symbol = " ";
        };
        hostname = {
          ssh_symbol = " ";
        };
        lua = {
          symbol = " ";
        };
        memory_usage = {
          symbol = "󰍛 ";
        };
        meson = {
          symbol = "󰔷 ";
        };
        nim = {
          symbol = "󰆥 ";
        };
        nix_shell = {
          symbol = " ";
        };
        nodejs = {
          symbol = " ";
        };
        ocaml = {
          symbol = " ";
        };
        package = {
          symbol = "󰏗 ";
        };
        python = {
          symbol = " ";
        };
        rust = {
          symbol = " ";
        };
        swift = {
          symbol = " ";
        };
        zig = {
          symbol = " ";
        };
      };
    };
    dconf.enable = true;
    seahorse.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    virt-manager.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

  };

  # Allow unfree packages for software that does not have a free license.
  nixpkgs.config.allowUnfree = true;

  users = {
    mutableUsers = true;
  };

  environment.gnome.excludePackages = with pkgs; [

    gnome-terminal
    epiphany
    gnome-console

    # these should be self explanatory
    gnome-characters
    gnome-maps
    yelp
    totem
    eog
    gnome-font-viewer
    gnome-logs
    gnome-system-monitor
    pkgs.gnome-connections
  ];

  environment.systemPackages = with pkgs; [

    # 🖥️ Essentials & CLI Tools
    vim
    wget
    killall
    ripgrep
    bat
    eza
    htop
    btop
    ncdu
    duf
    tree
    lshw
    pciutils
    lm_sensors
    iftop
    socat
    macchanger
    rose-pine-gtk-theme
    iw
    nmap

    unzip
    unrar
    file-roller
    bibata-cursors
    papirus-icon-theme
    adw-gtk3

    gcc
    clang
    go
    ghc
    rustup
    deno
    wezterm
    nodejs
    python3
    python312Packages.pip
    pipx
    ninja
    fzf
    meson
    pkg-config
    uv
    vscode
    geany
    micro
    gedit
    jetbrains-toolbox
    nixfmt-rfc-style
    nixd
    nh
    manix
    nil

    libvirt
    virt-viewer
    distrobox
    steam-run
    steam-devices-udev-rules
    libnotify
    pulseaudio
    pavucontrol
    angryipscanner
    pulsemixer
    nixpkgs-fmt

    wl-clipboard
    imagemagick
    swaynotificationcenter
    grim
    grimblast
    slurp
    swww
    swappy
    yad
    mission-center
    gnome-tweaks
    brightnessctl

    playerctl
    xfce.tumbler
    texliveFull
    lxqt.lxqt-policykit
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    kdePackages.kdenlive
    apostrophe
    texstudio

    vlc
    mpv
    ffmpeg
    yt-dlp
    ytmdl
    spotdl
    cava
    gnome-podcasts
    pinta
    gimp
    feh
    imv
    devpod
    clang-tools

    wineWowPackages.stable
    winetricks
    steam-run
    steam-devices-udev-rules

    chromium
    imagemagick
    gnome-extension-manager

    rpi-imager
    libreoffice
    gnome-calculator
    arduino-ide
    appimage-run
    gearlever

    git
    lazygit
    glab
    gh

    cmatrix
    lolcat
    cowsay
    pipes

    greetd.tuigreet
    ckb-next
  ];
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    bzip2
    cairo
    glibc
    cups
    curlWithGnuTls
    dbus
    dbus-glib
    desktop-file-utils
    e2fsprogs
    expat
    flac
    fontconfig
    freeglut
    freetype
    fribidi
    fuse
    fuse3
    gdk-pixbuf
    glew110
    glib
    gmp
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-ugly
    gst_all_1.gstreamer
    gtk2
    harfbuzz
    icu
    keyutils.lib
    libGL
    libGLU
    libappindicator-gtk2
    libcaca
    libcanberra
    libcap
    libclang.lib
    libdbusmenu
    libdrm
    libgcrypt
    libgpg-error
    libidn
    libjack2
    libjpeg
    libmikmod
    libogg
    libpng12
    libpulseaudio
    librsvg
    libsamplerate
    libthai
    libtheora
    libtiff
    libudev0-shim
    libusb1
    libuuid
    libvdpau
    libvorbis
    libvpx
    libxcrypt-legacy
    libxkbcommon
    libxml2
    mesa
    nspr
    nss
    openssl
    p11-kit
    pango
    pixman
    python3
    speex
    stdenv.cc.cc
    tbb
    udev
    vulkan-loader
    wayland
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXft
    xorg.libXi
    xorg.libXinerama
    xorg.libXmu
    xorg.libXrandr
    xorg.libXrender
    xorg.libXt
    xorg.libXtst
    xorg.libXxf86vm
    xorg.libpciaccess
    xorg.libxcb
    xorg.xcbutil
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    xorg.xkeyboardconfig
    xz
    zlib
  ];
  fonts = {
    packages = with pkgs; [
      noto-fonts-emoji
      noto-fonts-cjk-sans
      nerd-fonts.jetbrains-mono
      font-awesome
      # Commenting Symbola out to fix install this will need to be fixed or an alternative found.
      # symbola
      material-icons
    ];
  };

  environment.variables = {
    # ZANEYOS_VERSION = "2.2";
    # ZANEYOS = "true";
    # QT_QPA_PLATFORMTHEME = "qt5ct";
  };

  # Extra Portal Configuration
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal
    ];
  };

  # Services to start
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "${keyboardLayout}";
      variant = "";
    };
  };
  services = {

    smartd = {
      enable = false;
      autodetect = true;
    };
    libinput.enable = true;
    fstrim.enable = true;
    gvfs.enable = true;
    openssh.enable = true;

    # Enable Flatpak
    flatpak.enable = true;

    flatpak.update.onActivation = true;

    flatpak.packages = [
      "ca.desrt.dconf-editor"
      "com.bitwarden.desktop"
      "com.github.tchx84.Flatseal"
      "com.logseq.Logseq"
      "com.obsproject.Studio"
      "com.tomjwatson.Emote"
      "io.github.Foldex.AdwSteamGtk"
      "io.github.dvlv.boxbuddyrs"
      "io.github.flattool.Ignition"
      "io.github.flattool.Warehouse"
      "io.gitlab.adhami3310.Impression"
      "me.iepure.devtoolbox"
      "org.chocolate_doom.ChocolateDoom"
      "org.gnome.Builder"
      "org.gnome.Crosswords"
      "org.gnome.FontManager"
      "org.gnome.World.Citations"
      "org.prismlauncher.PrismLauncher"
    ];

    printing = {
      enable = true;
      drivers = [
        # pkgs.hplipWithPlugin
      ];
    };
    gnome.gnome-keyring.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable = true;
    syncthing = {
      enable = false;
      user = "${username}";
      dataDir = "/home/${username}";
      configDir = "/home/${username}/.config/syncthing";
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    rpcbind.enable = false;
    nfs.server.enable = false;
  };
  systemd.services.flatpak-repo = {
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
    disabledDefaultBackends = [ "escl" ];
  };

  # Extra Logitech Support
  hardware.logitech.wireless.enable = false;
  hardware.logitech.wireless.enableGraphical = false;

  # Bluetooth Support
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;

  # Security / Polkit
  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("users")
          && (
            action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
            action.id == "org.freedesktop.login1.power-off" ||
            action.id == "org.freedesktop.login1.power-off-multiple-sessions"
          )
        )
      {
        return polkit.Result.YES;
      }
    })
  '';
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  # Optimization settings and garbage collection automation
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  nix.nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
    "system=${toString "../"}"
    "home-manager=${inputs.home-manager}"
  ];
  # Virtualization / Containers
  virtualisation.libvirtd.enable = true;

  #Gamemode
  programs.gamemode.enable = true;

  # OpenGL
  hardware.graphics = {
    enable = true;
  };

  console.keyMap = "${keyboardLayout}";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
      ];
    };

  };
  # Uncomment to enable wireless support
  # wireless.enable = true;

  #CKB-Next
  hardware.ckb-next.enable = true;

  # Determines the NixOS release for default settings of stateful data.
  # Recommended to keep it at the version of the first install.
  # For more details, see: https://nixos.org/nixos/options.html#system.stateVersion
  system.stateVersion = "23.11"; # Did you read the comment?
}
