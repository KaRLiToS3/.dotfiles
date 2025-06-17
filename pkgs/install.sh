#!/bin/bash

set -euo pipefail

# Determine the real user's home directory (even when using sudo)
if [ "$EUID" -ne 0 ]; then
    echo "❌ The script can only run as root" >&2
    exit 1
fi

if [ -n "${SUDO_USER:-}" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

PKGS_DIR="$USER_HOME/.dotfiles/pkgs"

pacman -Syu
while read -r line; do
    # Extract the package name (element 1) from each line
    pkg=${line%% *}

    if pacman -Qi "$pkg" &>/dev/null; then
        echo "$pkg is already installed."
    else
        echo "Installing $pkg..."
        if pacman -S --noconfirm "$pkg"; then
            echo "✅ $pkg installed successfully."
        else
            echo "❌ Failed to install $pkg." >&2
        fi
    fi
done <"$PKGS_DIR/pkglist.txt"

if ! pacman -Qi yay &>/dev/null; then
    echo "Installing yay..."
    git clone https://aur.archlinux.org/yay.git "$PKGS_DIR/yay"
    cd "$PKGS_DIR/yay"
    su - "$SUDO_USER" -c "makepkg -si --noconfirm"
    rm -rf "$PKGS_DIR/yay"
    echo "✅ yay installed successfully."
else
    echo "yay is already installed."
fi

su - "$SUDO_USER" -c "yay -Syu"
while read -r line; do
    pkg=${line%% *}
    
    if su - "$SUDO_USER" -c "yay -Qi \"$pkg\" &>/dev/null"; then
        echo "$pkg is already installed."
    else
        echo "Installing $pkg..."
        if su - "$SUDO_USER" -c "yay -S --noconfirm \"$pkg\" &>/dev/null"; then
            echo "✅ $pkg installed successfully."
        else
            echo "❌ Failed to install $pkg from AUR." >&2
        fi
    fi
done <"$PKGS_DIR/aurlist.txt"

cd "$USER_HOME/.dotfiles"
echo "✅ All packages installed successfully."
