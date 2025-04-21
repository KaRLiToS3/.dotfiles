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
for pkg in $(cat "$USER_HOME/.dotfiles/pkgs/pkglist.txt"); do
    if pacman -Qi "$pkg" &>/dev/null; then
        echo "$pkg is already installed."
    else
        echo "Installing $pkg..."
        #sudo pacman -S --noconfirm "$pkg"
    fi
done