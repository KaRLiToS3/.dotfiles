#!/bin/bash
set -e

########## NO LONGER NECESSARY ##########

if [ "$EUID" -e 0 ]; then
    echo "Do not run the script as root."
    exit 1
fi

if ping -q -w 1 -c 1 8.8.8.8 > /dev/null; then

    if command -v git &> /dev/null; then
        echo "Git is already installed."
    else
        echo "Installing git..."
        sudo pacman -S --noconfirm git
    fi

    # Start the SSH agent
    if [ -z "$SSH_AGENT_PID" ]; then
        eval "$(ssh-agent -s)"
    fi

    email=""

    while [[ -z "$email" ]]; do
        read -p "Provide your email to generate a SSH key: " email
    done

    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    read -p "Key name? (default: id_ed25519): " key_name
    key_name=${key_name:-id_ed25519}
    ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/$key_name -N "" && echo "SSH key:"
    cat ~/.ssh/$key_name.pub

    read -p "Copy the following public key to your GitHub account and press ANY key to continue " -n1 -s

    ssh-add ~/.ssh/$key_name
    echo -e "\nSSH key added to the SSH agent."

    read -p "Do you want to change the dotfiles repo from HTTPS to SSH? (y/n): " change_to_ssh

    if [[ "$change_to_ssh" =~ ^[Yy]$ ]]; then
        if cd ~/.dotfiles; then
            git remote set-url origin git@github.com:KaRLiToS3/.dotfiles.git
            echo "Repository URL changed to SSH."
        else
            echo "Failed to change directory to ~/.dotfiles. Please check if the directory exists."
            exit 1
        fi
    else
        echo "Repository URL unchanged."
    fi
else
    echo "No internet connection. Please check your network settings."
    exit 1
fi