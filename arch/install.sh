#!/usr/bin/env bash

set -e

echo "=== Arch Post-Install Script ==="

# Prevent running as root
if [[ $EUID -eq 0 ]]; then
  echo "Do NOT run this script as root."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NIRI_SRC_CONFIG="$SCRIPT_DIR/config.kdl"
NIRI_DST_DIR="$HOME/.config/niri"
NIRI_DST_CONFIG="$NIRI_DST_DIR/config.kdl"
WAYBAR_CONFIG="$SCRIPT_DIR/waybar"
FUZZEL_CONFIG="$SCRIPT_DIR/fuzzel"
CONFIG_DIR="$HOME/.config/"
HOME_DIR="$HOME/"
WALLPAPER_DIR="$SCRIPT_DIR/Pictures"

# Update system
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install core packages
echo "Installing core packages..."
sudo pacman -S --noconfirm \
  sudo \
  niri \
  alacritty \
  fuzzel \
  code \
  waybar \
  chromium \
  swaybg \
  wl-clipboard \
  nano \
  nvim \
  htop \
  iwd \
  mako \
  openssh \
  polkit \
  smartmontools \
  swayidle \
  swaylock \
  wget \
  wireless_tools \
  wpa_supplicant \
  xdg-desktop-portal-gnome \
  xdg-utils \
  xorg-xwayland

echo "Installing Intel open-source graphics stack..."
pacman -S --noconfirm \
  mesa \
  vulkan-intel \
  intel-media-driver \
  libva-intel-driver \
  xorg-server \
  xorg-xinit

echo "Enabling essential services..."
systemctl enable iwd.service
systemctl enable sshd.service

# ALSA DSP fix
ALSA_CONF="/etc/modprobe.d/alsa-base.conf"
DSP_LINE="options snd-intel-dspcfg dsp_driver=1"

echo "Configuring ALSA..."
if ! grep -Fxq "$DSP_LINE" "$ALSA_CONF" 2>/dev/null; then
  echo "$DSP_LINE" | sudo tee -a "$ALSA_CONF" > /dev/null
  echo "ALSA option added."
else
  echo "ALSA option already present."
fi


# Install fish
echo "Installing fish..."
sudo pacman -S --noconfirm fish

echo "Setting fish as default shell..."
chsh -s "$(which fish)"

echo "Disabling fish greeting..."
fish -c 'set -U fish_greeting ""'

# Install yay
echo "Installing yay..."
sudo pacman -S --needed --noconfirm git base-devel

if ! command -v yay &>/dev/null; then
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
fi

# Install Nerd Font
echo "Installing JetBrains Mono Nerd Font..."
yay -S --noconfirm ttf-jetbrains-mono-nerd



# Install Niri config
echo "Installing Niri config..."

if [[ ! -f "$NIRI_SRC_CONFIG" ]]; then
  echo "ERROR: config.kdl not found next to post-install.sh"
  exit 1
fi

mkdir -p "$NIRI_DST_DIR"
cp -f "$NIRI_SRC_CONFIG" "$NIRI_DST_CONFIG"

echo "Niri config installed to $NIRI_DST_CONFIG"

echo "=== Setup Complete ==="
echo "Reboot recommended."

# Install waybar config
echo "Installing Waybar config..."

cp -r -f "$WAYBAR_CONFIG" "$CONFIG_DIR"

echo "Waybar config installed to $NIRI_DST_CONFIG"


# Install fuzzel config
echo "Installing Fuzzel config..."

cp -r -f "$FUZZEL_CONFIG" "$CONFIG_DIR"

echo "Fuzzel config installed to $NIRI_DST_CONFIG"

echo "=== Setup Complete ==="
echo "Reboot recommended."

cp -r -f "$WALLPAPER_DIR" "$HOME"

# Install greetd
echo "Installing greetd..."
sudo pacman -S --noconfirm greetd greetd-tuigreet

# Configure greetd
echo "Configuring greetd..."
sudo tee /etc/greetd/config.toml > /dev/null << 'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --remember --cmd niri --time"
user = "greeter"
EOF

# Enable greetd
echo "Enabling greetd..."
sudo systemctl enable greetd.service
sudo systemctl start greetd.service
