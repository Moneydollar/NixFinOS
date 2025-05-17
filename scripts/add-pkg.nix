{ pkgs }:

pkgs.writeShellScriptBin "add-package" ''
  if [ "$#" -ne 1 ]; then
    echo "Usage: add-package <package-name>"
    exit 1
  fi

  PACKAGE="$1"
  CONFIG_PATH="$HOME/.config/nixos/hosts/cashc/config.nix"

  if [ ! -f "$CONFIG_PATH" ]; then
    echo "Error: config.nix not found at $CONFIG_PATH"
    exit 1
  fi

  if grep -q "$PACKAGE" "$CONFIG_PATH"; then
    echo "Package $PACKAGE is already in environment.systemPackages."
  else
    sed -i "/environment\\.systemPackages = with pkgs; \\[/ a \\  $PACKAGE" "$CONFIG_PATH"
    echo "Package $PACKAGE added to environment.systemPackages."
  fi

  echo "Updating system..."
  sudo nixos-rebuild switch --flake ~/.config/nixos/
''
