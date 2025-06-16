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

pacman -Syu
while read -r line; do
    pkg=$(echo "$line" | cut -d' ' -f1)
    if pacman -Qi "$pkg" &>/dev/null; then
        echo "$pkg is already installed."
    else
        echo "Installing $pkg..."
        pacman -S --noconfirm "$pkg"
    fi
done < "$USER_HOME/.dotfiles/pkgs/pkglist.txt"

if pacman -Qi yay &>/dev/null; then 
    yay -Syu
    while read -r line; do
        pkg=$(echo "$line" | cut -d' ' -f1)
        if yay -Qi "$pkg" &>/dev/null; then
            echo "$pkg is already installed."
        else
            echo "Installing $pkg..."
            yay -S --noconfirm "$pkg"
        fi 
    done < "$USER_HOME/.dotfiles/pkgs/aurlist.txt"
else
    echo "yay is not installed. Please install yay first."
    exit 1
fi