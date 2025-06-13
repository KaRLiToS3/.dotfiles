#!/bin/bash
set -euo pipefail

# Determine the real user's home directory (even when using sudo)
if [ -n "${SUDO_USER:-}" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

echo "Removing the old files and linking to new ones..."
shopt -s dotglob nullglob

# Remove old dotfiles and link new ones, excluding .git and going 1 depth in folders, ignores visible files
for dir in $USER_HOME/.dotfiles/.*; do
    basename=$(basename "$dir")
    
    if [[ "$basename" == "." || "$basename" == ".." || "$basename" == .git* ]]; then    #Just in case
        continue
    fi

    if [[ -d "$dir" ]]; then        #TODO check . and .. dir
        for folder in "$dir"/*; do

            fname=$(basename "$folder")
            if [[ "$fname" == "." || "$fname" == ".." ]]; then  #Just in case
                continue
            fi

            echo "Removing $USER_HOME/$basename/$fname..."
            # rm -rf "$USER_HOME/$basename/$(basename "$folder")"
            echo "Linking $folder to $USER_HOME/$basename/$fname"
            # ln -sf "$folder" "$USER_HOME/$basename/$(basename "$folder")"
        done
    else
        echo "Removing $USER_HOME/$basename..."
        # rm -f "$USER_HOME/$basename"
        echo "Linking $dir to $USER_HOME/$basename"
        # ln -sf "$dir" "$USER_HOME/$basename"
    fi
done

shopt -u dotglob nullglob

# --- CHECK AUDIO PROFILE --- TODO
echo "🔊 Checking audio profile..."
PROFILE="output:analog-stereo+input:analog-stereo"

pactl list short cards | awk '{print $2}' | while read -r CARD; do
  echo "Applying profile '$PROFILE' to card $CARD"
  pactl set-card-profile "$CARD" "$PROFILE"
done

# Install pacman packages
read -p "Do you want to install the pacman packages? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    if [[ -f $USER_HOME/.dotfiles/pkgs/install.sh ]]; then
        bash $USER_HOME/.dotfiles/pkgs/install.sh
    else
        echo "El archivo $USER_HOME/.dotfiles/pkgs/install.sh no existe."
    fi
fi

# Setup login and desktop environment
read -p "Do you want to setup the login and desktop environment? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    systemctl enable sddm.service
    cp $USER_HOME/.dotfiles/imgs/5120x2880.jpg "/usr/share/sddm/themes/breeze/"
fi