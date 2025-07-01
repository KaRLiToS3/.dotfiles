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

echo "$SUDO_USER ALL=(ALL) NOPASSWD: /usr/bin/pacman" >/etc/sudoers.d/01_yay_temp
chmod 440 /etc/sudoers.d/01_yay_temp

PKGS_DIR="$USER_HOME/.dotfiles/pkgs"

read -p "Do you want to install the filtered pacman packages? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    pacman -Syu
    while read -r line; do

        # Skip lines that start with #, whitespace, or are empty
        if [[ "$line" =~ ^[[:space:]]*[^a-zA-Z0-9[:space:]] ]] || [[ "$line" =~ ^[[:space:]]*$ ]]; then
            continue
        fi

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
fi

if ! pacman -Qi yay &>/dev/null; then
    echo "Installing yay..."
    git clone https://aur.archlinux.org/yay.git "$PKGS_DIR/yay"
    chown -R "$SUDO_USER" "$PKGS_DIR/yay"
    chmod -R 764 "$PKGS_DIR/yay"

    cd "$PKGS_DIR/yay" || {
        echo "❌ Failed to change directory to yay." >&2
        exit 1
    }
    if sudo -u "$SUDO_USER" makepkg -si --noconfirm; then
        rm -rf "$PKGS_DIR/yay"
        echo "✅ yay installed successfully."
    else
        echo "❌ Failed to install yay." >&2
        exit 1
    fi
else
    echo "yay is already installed."
fi

read -p "Do you want to install the AUR packages with yay? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    sudo -u "$SUDO_USER" yay -Syu
    while read -r line; do

        # Skip lines that start with #, whitespace, or are empty
        if [[ "$line" =~ ^[[:space:]]*[^a-zA-Z0-9[:space:]] ]] || [[ "$line" =~ ^[[:space:]]*$ ]]; then
            continue
        fi

        pkg=${line%% *}

        if sudo -u "$SUDO_USER" yay -Qi "$pkg" &>/dev/null; then
            echo "$pkg is already installed."
        else
            echo "Installing $pkg..."
            if sudo -u "$SUDO_USER" yay -S --noconfirm "$pkg"; then
                echo "✅ $pkg installed successfully."
            else
                echo "❌ Failed to install $pkg from AUR." >&2
            fi
        fi
    done <"$PKGS_DIR/aurlist.txt"
fi

rm -f /etc/sudoers.d/01_yay_temp

cd "$USER_HOME/.dotfiles"
echo "✅ Done."
