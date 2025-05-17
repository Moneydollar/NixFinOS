#!/usr/bin/env bash
set -euo pipefail

# --- Colors ---
bold=$(tput bold)
reset=$(tput sgr0)
cyan=$(tput setaf 6)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
red=$(tput setaf 1)

info()  { echo -e "${cyan}➜${reset} $1"; }
ok()    { echo -e "${green}✔${reset} $1"; }
warn()  { echo -e "${yellow}⚠${reset} $1"; }
error() { echo -e "${red}✖${reset} $1"; exit 1; }

# --- System Check ---
info "Checking for NixOS..."
if ! grep -iq nixos /etc/os-release; then
  error "This script must be run on NixOS."
fi
ok "NixOS detected."

# --- Ensure Git ---
if ! command -v git &> /dev/null; then
  warn "Git not found. Entering nix-shell..."
  nix-shell -p git --run "$0"
  exit 0
else
  ok "Git is installed."
fi

# --- Prompt User ---
echo
info "Welcome to ${bold}NixFinOS${reset} installer!"

read -rp "${bold}Enter your desired hostname [nixbox]: ${reset}" hostName
hostName=${hostName:-nixbox}

read -rp "${bold}Enter your username [$(whoami)]: ${reset}" username
username=${username:-$(whoami)}

read -rp "${bold}Enter your Git name [John Doe]: ${reset}" gitName
gitName=${gitName:-"John Doe"}

read -rp "${bold}Enter your Git email [example@domain.com]: ${reset}" gitEmail
gitEmail=${gitEmail:-"example@domain.com"}

read -rp "${bold}Enter your keyboard layout [us]: ${reset}" keyboardLayout
keyboardLayout=${keyboardLayout:-us}

# --- Clone Repo ---
cd ~

if [ -d NixFinOS ]; then
  warn "~/NixFinOS already exists."

  echo
  echo "${bold}How should we proceed?${reset}"
  echo "[1] Delete it"
  echo "[2] Backup and continue"
  echo "[3] Cancel installation"
  read -rp "${bold}Enter your choice [1/2/3]: ${reset}" choice

  case "$choice" in
    1)
      info "Deleting ~/NixFinOS..."
      rm -rf NixFinOS
      ;;
    2)
      backupName="NixFinOS.backup.$(date +%s)"
      info "Backing up existing directory to ~/$backupName"
      mv NixFinOS "$backupName"
      ;;
    *)
      error "Installation cancelled."
      ;;
  esac
fi

info "Cloning NixFinOS repository..."
git clone https://github.com/Moneydollar/NixFinOS.git
cd NixFinOS
ok "Repository cloned."

# --- Prepare Host Directory ---
if [ -d "hosts/$hostName" ]; then
  warn "Host '$hostName' already exists."

  read -rp "${bold}Do you want to overwrite it? This will remove all its contents. [y/N]: ${reset}" confirmOverwrite
  confirmOverwrite=${confirmOverwrite:-n}

  if [[ "$confirmOverwrite" =~ ^[Yy]$ ]]; then
    info "Overwriting existing directory..."
    rm -rf "hosts/$hostName"
  else
    error "Installation aborted. Host directory already exists."
  fi
fi

info "Creating new host directory at hosts/$hostName..."
mkdir -p "hosts/$hostName"

# --- Copy & Generate Host Files ---
info "Copying hardware.nix and users.nix..."
cp hosts/default/hardware.nix  hosts/"$hostName"/
ok "hardware.nix copied."

info "Generating users.nix..."
cat > "hosts/$hostName/users.nix" <<EOF
{ pkgs, username, ... }:

let
  inherit (import ./variables.nix) gitUsername;
in
{
  users.users."${username}" = {
    homeMode = "755";
    isNormalUser = true;
    description = "\${gitUsername}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "libvirtd"
      "scanner"
      "lp"
    ];
    shell = pkgs.bash;
    ignoreShellProgramCheck = true;
    packages = with pkgs; [];
  };
}
EOF
ok "users.nix created."

info "Generating variables.nix with Git info and layout..."
cat > "hosts/$hostName/variables.nix" <<EOF
{
  gitUsername = "$gitName";
  gitEmail = "$gitEmail";
  keyboardLayout = "$keyboardLayout";
}
EOF
ok "variables.nix created."

info "Creating host.nix with hostname and username..."
cat > "hosts/$hostName/host.nix" <<EOF
{
  username = "$username";
  host = "$hostName";
}
EOF
ok "host.nix created."

# --- Generate hardware.nix ---
info "Generating updated hardware configuration..."
sudo nixos-generate-config --show-hardware-config > hosts/$hostName/hardware.nix
ok "Hardware config generated."

# --- Write root-level host.nix for flake reference ---
info "Writing root-level host.nix for flake evaluation..."
cat > ./host.nix <<EOF
{
  host = "$hostName";
  username = "$username";
}
EOF
ok "host.nix created at root."


# --- Git Config ---
info "Removing remote origin..."
git remote remove origin || true
ok "Origin removed."

info "Setting Git user config for local repo..."
git config user.name "$gitName"
git config user.email "$gitEmail"
git add *
ok "Local Git user configured."

export HOSTNAME="$hostName"

# --- Done ---
echo
ok "${bold}NixFinOS setup complete!${reset}"
echo "${bold}To switch to your new config, run:${reset}"
echo
echo "  ${cyan}sudo nixos-rebuild switch --flake ~/NixFinOS#$hostName${reset}"
echo
echo "${bold}Don't forget to set your username if needed: $username${reset}"
