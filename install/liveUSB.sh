#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "❌ This script must be run as root." >&2
  exit 1
fi

if ! ping -q -w 1 -c 1 8.8.8.8 > /dev/null; then
  echo "❌ No internet connection. Please check your network settings." >&2
  exit 1
fi

MNT="/mnt"

if [ -e "$MNT/etc/arch-release" ]; then
  echo "❌ Arch already installed in $MNT. Aborting."
  exit 1
fi

if ! mountpoint -q "$MNT/boot"; then
  echo "❌ EFI partition not mounted to $MNT/boot. Please mount it manually before running this script."
  exit 1
fi

# --- Creation of the fstap file ---
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot "$MNT" bash -c "
  echo 'Installing the basic packages...'
  pacman -S --noconfirm base base-devel linux-firmware grub efibootmgr networkmanager os-prober sudo git nano
"

# --- Get the repository in pacman using 2 methods ---
echo "🔑 Importing G14 key into chroot environment..."
echo "Trying the cleanest way..."
if arch-chroot "$MNT" bash -c "
  pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
  pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
  pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
  pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
"; then
  echo "✅ Key imported successfully."
else
  echo "❌ Failed to import key using the clean method."
  wget "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x8b15a6b0e9a3fa35" -O /tmp/g14.sec
  cp /tmp/g14.sec "$MNT/tmp/g14.sec"

  if arch-chroot "$MNT" bash -c "
    pacman-key -a /tmp/g14.sec
    pacman-key --lsign-key 8B15A6B0E9A3FA35
    rm /tmp/g14.sec
  "; then 
    echo "✅ Key imported successfully using fallback method."
  else
    echo "❌ Failed to import key using fallback method."
    exit 1
  fi
fi

# --- Add the repository ---
if ! grep -q "\[g14\]" "$MNT/etc/pacman.conf"; then
  echo "📦 Adding g14 repository to pacman.conf in chroot"
  echo -e '\n[g14]\nServer = https://arch.asus-linux.org' >> "$MNT/etc/pacman.conf"
fi

# --- Update the packages for the asus system ---
arch-chroot "$MNT" bash -c "
  echo '🔧 Installing fan profiles...'
  pacman -Sy --needed --noconfirm asusctl power-profiles-daemon
  systemctl enable power-profiles-daemon.service

  echo '🖥️ Installing ROG Control Center...'
  pacman -S --needed --noconfirm supergfxctl switcheroo-control rog-control-center
  systemctl enable supergfxd
  systemctl enable switcheroo-control

  echo '🧬 Installing custom kernel...'
  pacman -S --needed --noconfirm linux-g14 linux-g14-headers

  echo '🖥️ Installing NVIDIA drivers...'
  pacman -S --needed --noconfirm nvidia-dkms

  echo '🔧 Generating GRUB config...'
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  grub-mkconfig -o /boot/grub/grub.cfg

  mkinitcpio -P
"
echo "✅ ROG settings are now installed."
echo "🔧 Preparing the timezone, users, passwords, etc."

# --- Configuration of the hosts, timezone, keyboard, users and services ---
arch-chroot "$MNT" bash -c "
  echo 'Setting up the timezone...'
  ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
  hwclock --systohc

  echo 'Configuring the keyboadard layout...'
  echo 'KEYMAP=es' > /etc/vconsole.conf

  echo 'Configuring the locale...'
  sed -i 's/^#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
  locale-gen
  echo 'LANG=es_ES.UTF-8' > /etc/locale.conf

  echo 'Configuring the hostname...'
  echo 'ASUS_STRIX' > /etc/hostname

  cat > /etc/hosts <<EOF
  127.0.0.1               localhost
  ::1                     localhost
  127.0.1.1               ASUS_STRIX.localadmin                   ASUS_STRIX
  EOF

  echo 'NetworkManager enabling...'
  systemctl enable NetworkManager
  systemctl enable bluetooth
"

echo "Setting up the root and user passwords..."

root_password=""
username=""
user_password=""

while [[ -z "$root_password" || "$root_password" =~ [[:space:]] ]]; do
  read -p "Provide the root password for the new system (no spaces, tabs, etc): " -s root_password
  echo
done
while [[ -z "$username" || "$username" =~ [[:space:]] ]]; do
  read -p "Provide the username for the new user (no spaces, tabs, etc): " username
done
while [[ -z "$user_password" || "$user_password" =~ [[:space:]] ]]; do
  read -p "Provide the password for the new user (no spaces, tabs, etc): " -s user_password
  echo
done

arch-chroot "$MNT" useradd -m -G wheel,audio,video,input,storage,power -s /bin/bash "$username"
arch-chroot "$MNT" chpasswd <<< "root:$root_password"
arch-chroot "$MNT" chpasswd <<< "$username:$user_password"
arch-chroot "$MNT" sed -i "s/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers

echo "🔄 Unmounting /mnt..."
umount -lR "$MNT"

echo "✅ Installation inside /mnt completed. Now boot into the new system a follow the next steps."
echo "🧾 To complete the setup, please run:"
echo "1. gitSetup.sh   # to clone your dotfiles"
echo "2. postInstall.sh # to finish package setup and enable SDDM"

