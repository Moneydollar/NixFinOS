{ pkgs }:

pkgs.writeShellScriptBin "changeMac" ''

  # Auto MAC changer script with Wi-Fi fallback
  # Usage:
  #   changeMac -r  # randomize current interface
  #   changeMac -p  # reset to permanent MAC

  usage() {
      echo "Usage: $0 [-r | -p]"
      echo "  -r : randomize MAC address"
      echo "  -p : reset to permanent hardware MAC address"
      exit 1
  }

  if ! command -v macchanger &>/dev/null; then
      echo "Error: macchanger is not installed."
      exit 1
  fi

  if [[ $EUID -ne 0 ]]; then
      echo "This script must be run as root."
      exit 1
  fi

  # Try to get default route interface
  IFACE=$(ip route | awk '/default/ { print $5; exit }')

  # If not found, fall back to first Wi-Fi interface
  if [[ -z "$IFACE" ]]; then
      IFACE=$(iw dev | awk '$1=="Interface"{print $2; exit}')
      if [[ -z "$IFACE" ]]; then
          echo "Error: No network interface found (wired or wireless)."
          exit 1
      else
          echo "No default interface found, falling back to Wi-Fi interface: $IFACE"
      fi
  else
      echo "Detected default interface: $IFACE"
  fi

  if [[ $# -ne 1 ]]; then
      usage
  fi

  ACTION="$1"

  ip link set "$IFACE" down || { echo "Failed to bring down interface $IFACE"; exit 1; }

  case "$ACTION" in
      -r)
          echo "Randomizing MAC address for $IFACE..."
          macchanger -r "$IFACE"
          ;;
      -p)
          echo "Resetting MAC address for $IFACE to permanent..."
          macchanger -p "$IFACE"
          ;;
      *)
          usage
          ;;
  esac

  ip link set "$IFACE" up || { echo "Failed to bring up interface $IFACE"; exit 1; }

  exit 0
''
