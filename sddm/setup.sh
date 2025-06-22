#!/bin/bash

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "❌ The script can only run as root" >&2
    exit 1
fi

if [ -n "${SUDO_USER:-}" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

if ! command -v sddm &>/dev/null; then
    echo "Installing SDDM..."
    pacman -S --noconfirm sddm
fi
systemctl enable sddm.service
cat >/usr/share/sddm/scripts/Xsetup <<EOF
#!/bin/sh
setxkbmap -layout es
EOF

chmod +x /usr/share/sddm/scripts/Xsetup

if [ ! -d /usr/share/sddm/themes/sddm-astronaut-theme ]; then
    echo "Installing SDDM Astronaut Theme..."
    git clone -b master --depth 1 https://github.com/keyitdev/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme
    cp -r /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
    cp $USER_HOME/.dotfiles/imgs/dark_and_red.png /usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds
    cp $USER_HOME/.dotfiles/sddm/dark_and_red.conf /usr/share/sddm/themes/sddm-astronaut-theme/Themes
    echo "✅ Fonts, images and customized theme copied successfuly."

    # Check if gnome-keyring is installed, install if not
    if ! pacman -Q gnome-keyring &>/dev/null; then
        echo "Installing gnome-keyring..."
        pacman -S --noconfirm gnome-keyring
    else
        echo "gnome-keyring is already installed."
    fi

    # Ask user if they want to change SDDM PAM configuration
    read -p "Would you like to update the SDDM PAM configuration? (y/N) " update_pam
    if [[ "$update_pam" =~ ^[Yy]$ ]]; then
        # Backup existing configuration if it exists
        if [ -f /etc/pam.d/sddm ]; then
            cp /etc/pam.d/sddm /etc/pam.d/sddm.backup
            echo "📝 Backed up existing SDDM PAM configuration to /etc/pam.d/sddm.backup"
        fi
        cp $USER_HOME/.dotfiles/sddm/sddm /etc/pam.d/sddm
        echo "✅ SDDM PAM configuration updated."
    else
        echo "Keeping default SDDM PAM configuration."
    fi
    
    cat >/etc/sddm.conf <<EOF
[Autologin]
Relogin=false
Session=
User=

[General]
HaltCommand=/usr/bin/systemctl poweroff
InputMethod=
RebootCommand=/usr/bin/systemctl reboot

[Theme]
Current=sddm-astronaut-theme

[Users]
MaximumUid=60513
MinimumUid=1000
EOF
    echo "✅ SDDM configuration file created at /etc/sddm.conf"
    cat > /etc/sddm.conf.d/virtualkbd.conf <<EOF
[General]
InputMethod=qtvirtualkeyboard
EOF
    echo "✅ Virtual keyboard configuration file created at /etc/sddm.conf.d/virtualkbd.conf"

    sed -i '/^ConfigFile=$/c\ConfigFile=Themes/dark_and_red.conf' /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
    echo "✅ Theme configuration updated in /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop"
    
    read -p "Would you like to set the login text fields to fully opaque? (I recommend doing so) (y/N)" response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        sed -i '/^opacity: 0.2$/c\opacity: 1' /usr/share/sddm/themes/sddm-astronaut-theme/Components/Input.qml
        echo "Input field opacity set to 1 (fully opaque)."
    else
        echo "Keeping default opacity (0.2)."
    fi
else
    echo "❌ SDDM Astronaut Theme is already installed. Skipping the configuration (remove the theme to proceed)" >&2
fi
