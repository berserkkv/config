#!/bin/bash
set -e   # Exit on any error
set -o pipefail

# Function to print messages
info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

# Update system
info "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install essential packages via apt
info "Installing basic packages..."
sudo apt install -y git curl wget build-essential

# -------------------------------
# Install Google Chrome
# -------------------------------
info "Installing Google Chrome..."
wget -O ~/Downloads/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ~/Downloads/google-chrome.deb
rm ~/Downloads/google-chrome.deb

# -------------------------------
# Install Visual Studio Code
# -------------------------------
info "Installing VS Code..."
wget -O ~/Downloads/vscode.deb https://update.code.visualstudio.com/latest/linux-deb-x64/stable
sudo apt install -y ~/Downloads/vscode.deb
rm ~/Downloads/vscode.deb

# -------------------------------
# Install Snap packages (optional)
# -------------------------------
info "Installing Snap packages..."
sudo snap install spotify


# -------------------------------
# Apply Intel DSP audio fix
# -------------------------------
info "Applying Intel DSP audio fix..."

# Backup the original config just in case
sudo cp /etc/modprobe.d/alsa-base.conf /etc/modprobe.d/alsa-base.conf.bak

# Append the options line if it doesn't already exist
if ! grep -q "options snd-intel-dspcfg dsp_driver=1" /etc/modprobe.d/alsa-base.conf; then
    echo "options snd-intel-dspcfg dsp_driver=1" | sudo tee -a /etc/modprobe.d/alsa-base.conf
    info "Added 'options snd-intel-dspcfg dsp_driver=1' to alsa-base.conf"
else
    info "Intel DSP option already exists, skipping..."
fi

# -------------------------------
# Install Node.js (LTS)
# -------------------------------
info "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# -------------------------------
# Install Rust
# -------------------------------
info "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
export PATH="$HOME/.cargo/bin:$PATH"

# -------------------------------
# Install Go
# -------------------------------
sudo snap install --classic go


# -------------------------------
# Cleanup
# -------------------------------
info "Cleaning up..."
sudo apt autoremove -y
sudo apt clean

info "Post-install script finished!"