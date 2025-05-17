#!/usr/bin/env bash
set -euo pipefail

### Colors ###
bold=$(tput bold)
reset=$(tput sgr0)
cyan=$(tput setaf 6)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
red=$(tput setaf 1)

### Functions ###
info()  { echo -e "${cyan}➜${reset} $1"; }
ok()    { echo -e "${green}✔${reset} $1"; }
warn()  { echo -e "${yellow}⚠${reset} $1"; }
error() { echo -e "${red}✖${reset} $1"; exit 1; }

### Check for NixOS ###
info "Checking if running on NixOS..."
if ! grep -iq nixos /etc/os-release; then
  error "This script must be run on NixOS."
fi
ok "NixOS detected."

### Ensure Git is Installed ###
if ! command -v git &> /dev/null; then
  warn "Git is not installed. Entering nix shell with Git..."
  nix-shell -p git --run "$0"
  exit 0
else
  ok "Git is installed."
fi

### Prompt for User Info ###
echo
info "Welcome to ${bold}NixFin${reset} installer!"

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

### Setup Working Directory ###
cd ~
if [ -d nixfin ]; then
  warn "~/nixfin already exists. Backing it up..."
  mv nixfin "nixfin.backup.$(date +%s)"
fi

info "Cloning NixFin repository..."
git clone https://github.com/Moneydollar/nixfin.git
cd nixfin
ok "Repository cloned."

### Setup Host Directory ###
if [ -d hosts/$hostName ]; then
  warn "Host '$hostName' already exists. Backing it up..."
  mv hosts/$hostName "hosts/$hostName.bak.$(date +%s)"
fi

info "Creating host configuration for '$hostName'..."
mkdir -p hosts/"$hostName"
cp hosts/default/*.nix hosts/"$hostName"
ok "Host directory created."

### Update host.nix ###
info "Setting host and username in host.nix..."
cat > "hosts/$hostName/host.nix" <<EOF
{
  username = "$username";
  host = "$hostName";
}
EOF
ok "host.nix updated."

### Update variables.nix ###
info "Updating Git configuration in variables.nix..."
sed -i "s|gitUsername = \".*\";|gitUsername = \"$gitName\";|" hosts/$hostName/variables.nix
sed -i "s|gitEmail = \".*\";|gitEmail = \"$gitEmail\";|" hosts/$hostName/variables.nix
sed -i "s|keyboardLayout = \".*\";|keyboardLayout = \"$keyboardLayout\";|" hosts/$hostName/variables.nix
ok "variables.nix updated."

### Generate hardware config ###
info "Generating hardware configuration for $hostName..."
sudo nixos-generate-config --show-hardware-config > hosts/$hostName/hardware.nix
ok "hardware.nix created."

### Local Git Setup ###
info "Removing remote origin to detach from upstream repo..."
git remote remove origin || true
ok "Origin removed."

info "Disabling Git tracking of host-specific files..."
{
  echo "hosts/"
  echo "*/host.nix"
} >> .git/info/exclude
ok "'hosts/' and 'host.nix' are now ignored (locally only)."

info "Setting Git config locally in this repo..."
git config user.name "$gitName"
git config user.email "$gitEmail"
ok "Local Git user configuration set."


### Completion ###
echo
ok "${bold}NixFin setup complete!${reset}"
echo "${bold}To switch to your new config, run:${reset}"
echo
echo "  ${cyan}sudo nixos-rebuild switch --flake ~/nixfin#$hostName${reset}"
echo
