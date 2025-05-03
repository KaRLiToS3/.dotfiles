#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "❌ The script can only run as root" >&2
  exit 1
fi

# --- SETUP PROCEDURE ---

if pacman-key --list-keys | grep -q "8B15A6B0E9A3FA35"; then
  echo "🔐 The g14 key is already installed"
else
  echo "🔑 The g14 key is not installed, installing it now..."
  wget "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x8b15a6b0e9a3fa35" -O ~/g14.sec
  pacman-key -a g14.sec

  if grep -q "\[g14\]" /etc/pacman.conf; then
    echo "📦 The g14 repository is already in pacman.conf"
  else
    echo "📦 Adding g14 repository to pacman.conf"
    echo -e "\n[g14]\nServer = https://arch.asus-linux.org" >> /etc/pacman.conf
  fi

  pacman-key --lsign-key 8B15A6B0E9A3FA35
  rm -f ~/g14.sec
fi

# --- FAN PROFILES ---
echo "🔧 Installing fan profiles..."
pacman -Syu --needed asusctl power-profiles-daemon
systemctl enable --now power-profiles-daemon.service

# --- ROG CONTROL CENTER ---
echo "🖥️ Installing ROG Control Center..."
pacman -S --needed supergfxctl switcheroo-control
systemctl enable --now supergfxd
systemctl enable --now switcheroo-control
pacman -S --needed rog-control-center

# --- CUSTOM KERNEL ---
echo "🧬 Installing custom kernel for G14..."
pacman -S --needed linux-g14 linux-g14-headers
grub-mkconfig -o /boot/grub/grub.cfg

# --- NVIDIA ---
echo "🖥️ Installing NVIDIA drivers..."
pacman -S nvidia-dkms

# --- CHECK AUDIO PROFILE ---
echo "🔊 Checking audio profile..."
PROFILE="output:analog-stereo+input:analog-stereo"
CARD_COUNT=0

echo "Found ${#CARDS[@]} audio cards"

pactl list short cards | awk '{print $2}' | while read -r CARD; do
  ((CARD_COUNT++))
  echo "Applying profile '$PROFILE' to card $CARD"
  pactl set-card-profile "$CARD" "$PROFILE"
done

# --- DONE ---
echo "✅ The script was successful!"
echo "🧠 Installed kernel version: $(uname -r)"
echo "🔁 Please reboot your system to apply the changes."
