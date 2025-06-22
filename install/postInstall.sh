#!/bin/bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root. Please use sudo." >&2
    exit 1
fi

# Determine the real user's home directory (even when using sudo)
if [ -n "${SUDO_USER:-}" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

#Enable services
systemctl enable NetworkManager.service
systemctl start NetworkManager.service
systemctl start sshd.service

sleep 2  # Wait for NetworkManager to start

if ! ping -q -w 1 -c 1 8.8.8.8 > /dev/null; then
  echo "❌ No internet connection. Please check your network settings." >&2
  exit 1
fi

shopt -s dotglob nullglob
read -p "Do you want to create all links to the files in the .dotfiles? WARNING: All previous config files will be removed (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then

    echo "Removing the old files and linking to new ones..."

    # Remove old dotfiles and link new ones, excluding .git and going 1 depth in folders
    for dir in "$USER_HOME"/.dotfiles/.*; do
        basename=${dir##*/}
        
        # Skip . .. and .git* directories
        [[ "$basename" == "." || "$basename" == ".." || "$basename" == .git* ]] && continue

        if [[ -d "$dir" ]]; then
            # Create target directory once
            mkdir -p "$USER_HOME/$basename"
            
            for folder in "$dir"/*; do
                # Skip if folder doesn't exist (due to nullglob in empty dirs)
                [[ -e "$folder" ]] || continue
                
                # Use parameter expansion instead of basename command
                fname=${folder##*/}
                
                echo "Removing $USER_HOME/$basename/$fname..."
                rm -rf "$USER_HOME/$basename/$fname"
                echo "Linking $folder to $USER_HOME/$basename/$fname"
                ln -sf "$folder" "$USER_HOME/$basename/$fname"
            done
        else
            echo "Removing $USER_HOME/$basename..."
            rm -f "$USER_HOME/$basename"
            echo "Linking $dir to $USER_HOME/$basename"
            ln -sf "$dir" "$USER_HOME/$basename"
        fi
    done
fi

read -p "Do you want to copy the files for the root user? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    cp -r $USER_HOME/.dotfiles/root/* /root/
    cp -r $USER_HOME/.dotfiles/.zsh /root/
fi
shopt -u dotglob nullglob

# Install pacman packages
read -p "Do you want to install the packages (you will be prompted to choose pacman and/or yay lists)? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    if [[ -f $USER_HOME/.dotfiles/pkgs/install.sh ]]; then
        bash $USER_HOME/.dotfiles/pkgs/install.sh
    else
        echo "❌ The file $USER_HOME/.dotfiles/pkgs/install.sh doesn't exist." >&2
    fi
fi

# --- CHECK AUDIO PROFILE --- TODO
# echo "🔊 Checking audio profile..."
# PROFILE="output:analog-stereo+input:analog-stereo"

# pactl list short cards | awk '{print $2}' | while read -r CARD; do
#   echo "Applying profile '$PROFILE' to card $CARD"
#   pactl set-card-profile "$CARD" "$PROFILE"
# done

# Setup login and desktop environment
read -p "Do you want to setup the login and desktop environment? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    if [[ -f $USER_HOME/.dotfiles/sddm/setup.sh ]]; then
        bash $USER_HOME/.dotfiles/sddm/setup.sh
    else
        echo "❌ The file $USER_HOME/.dotfiles/sddm/setup.sh doesn't exist." >&2
    fi
fi