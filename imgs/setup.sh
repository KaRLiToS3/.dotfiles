#!/bin/bash

set -e

# Get the original user (non-root who called sudo)
REAL_USER="${SUDO_USER:-$(logname)}"
USER_HOME=$(eval echo "~$REAL_USER")

pacman -S sddm
systemctl enable sddm.service
cp $USER_HOME/.dotfiles/imgs/5120x2880.jpg "/usr/share/sddm/themes/breeze/"
