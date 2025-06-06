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
        for file in "$dir"/*; do

            fname=$(basename "$file")
            if [[ "$fname" == "." || "$fname" == ".." ]]; then  #Just in case
                continue
            fi

            echo "Removing $USER_HOME/$basename/$fname..."
            # rm -rf "$USER_HOME/$basename/$(basename "$file")"
            echo "Linking $file to $USER_HOME/$basename/$fname"
            # ln -sf "$(pwd)/$file" "$USER_HOME/$basename/$(basename "$file")"
        done
    else
        echo "Removing $USER_HOME/$basename..."
        # rm -f "$USER_HOME/$basename"
        echo "Linking $dir to $USER_HOME/$basename"
        # ln -sf "$(pwd)/$dir" "$USER_HOME/$basename"
    fi
done

shopt -u dotglob nullglob

# Install the ASUS configuration
read -p "Do you want to install the Asus configuration? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    if [[ -f ./AsusInstall/install.sh ]]; then
        bash ./AsusInstall/install.sh
    else
        echo "El archivo ./AsusInstall/install.sh no existe."
    fi
fi

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
    if [[ -f $USER_HOME/.dotfiles/setup.sh ]]; then
        bash $USER_HOME/.dotfiles/imgs/setup.sh
    else
        echo "El archivo $USER_HOME/.dotfiles/setup.sh no existe."
    fi
fi