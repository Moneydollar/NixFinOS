# NixFinOS

[![Stars](https://img.shields.io/github/stars/Moneydollar/NixFinOS?style=social)](https://github.com/Moneydollar/NixFinOS/stargazers)
[![Issues](https://img.shields.io/github/issues/Moneydollar/NixFinOS)](https://github.com/Moneydollar/NixFinOS/issues)
[![Last Commit](https://img.shields.io/github/last-commit/Moneydollar/NixFinOS)](https://github.com/Moneydollar/NixFinOS/commits/main)
[![License](https://img.shields.io/github/license/Moneydollar/NixFinOS)](./LICENSE)

> ✨ Powered by [Nix Flakes](https://nixos.wiki/wiki/Flakes)  
> 🧰 Managed with [Home Manager](https://nix-community.github.io/home-manager)  
> 🎨 Theming powered by [Rose Pine](https://rosepinetheme.com/) and GTK/QT integration

---

## 🛠 Features

- ✅ Flake-based system + user config  
- ✅ Automated host-specific scaffolding  
- ✅ Modular config for system, apps, and services  
- ✅ Neovim with Nix4NvChad integration  
- ✅ Preconfigured Gnome desktop + extensions  
- ✅ Optional tools and scripts (Rofi launcher, emoji picker, hardware offloading)  
- ✅ Git, Tailscale, Flatpak, Zsh/Fish, Starship, Discord theming and more  

---

## 🚀 Quickstart

### 1. Clone and Run the Installer

```bash
bash <(curl -s https://raw.githubusercontent.com/Moneydollar/NixFinOS/main/nixfinos-installer.sh)
```

The installer will:

- Prompt you for hostname, username, and Git info
- Clone the repo to `~/NixFinOS`
- Generate a new host config under `hosts/<your-hostname>`
- Set up `host.nix`, `variables.nix`, `users.nix`, and `hardware.nix`
- Set up Git config and ignore machine-local files

### 2. Apply the Configuration

```bash
sudo nixos-rebuild switch --flake ~/NixFinOS#<your-hostname>
```

---

## 🧱 Project Structure

```
NixFinOS/
├── flake.nix                 # Entry point for system and user configuration
├── flake.lock                # Locked dependency versions
├── nixfinos-installer.sh     # Automated bootstrap script
├── hosts/
│   ├── default/              # Template files for new hosts
│   └── <your-host>/          # Host-specific config (generated)
├── common/                   # Shared config for all systems
│   ├── config.nix
│   └── home.nix
├── config/                   # App configuration (Neovim, wallpapers, etc.)
├── modules/                  # Custom NixOS modules (drivers, apps)
├── scripts/                  # CLI utilities and helpers
└── README.md
```

---

## 🧑‍💻 Host Configuration

Each host gets its own directory in `hosts/<hostname>/` containing:

- `host.nix` — defines `host` and `username`
- `variables.nix` — Git identity and keyboard layout
- `users.nix` — NixOS user definition
- `hardware.nix` — generated from `nixos-generate-config`

---

## ✨ Extras

- GNOME with curated extensions and theming
- Kvantum + GTK 4/3 themes (Papirus, Rose Pine)
- Neovim powered by NvChad and LSP support
- Flatpak integration
- Discord theming via Nixcord
- CLI scripts for screenshots, emoji picker, GPU switching, etc.

---

## 🧩 Requirements

- NixOS (flake support enabled)
- Git
- Internet connection

To enable flakes, add this to `/etc/nix/nix.conf`:

```ini
experimental-features = nix-command flakes
```

---

## 🛠 Development & Contributions

This repo is intended as a personal system config but you're welcome to fork it for your own use.

Pull requests, issues, and suggestions are welcome!

---

## 📄 License

[MIT](./LICENSE)

---

## 💬 Credits

Inspired by and built with help from:

- [nix-configs](https://github.com/Misterio77/nix-config)
- [nix4nvchad](https://github.com/nix-community/nix4nvchad)
- [rose-pine](https://github.com/rose-pine)
- [ZaneyOS](https://github.com/ZaneyOS/ZaneyOS) — for creative inspiration, modular system layout, and scripts
- [Jorge Castro](https://github.com/castrojo) and the [Bluefin](https://github.com/ublue-os) team 

> Built with 💙 and a love for declarative configuration.
