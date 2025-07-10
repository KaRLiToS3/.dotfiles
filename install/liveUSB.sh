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

if ! mountpoint -q "$MNT"; then
  echo "❌ Linux File System is not mounted to $MNT. Please mount it manually before running this script." >&2
  exit 1
fi

# Check if the disk is using GPT partition table
root_device=$(findmnt -no SOURCE "$MNT" | sed 's/[0-9]*$//')
if ! parted "$root_device" print | grep -q "Partition Table: gpt"; then
  echo "❌ The disk $root_device is not using a GPT partition table. This script requires GPT for UEFI boot." >&2
  read -p "This verification might fail if there are other partitions on the disk. Do you want to continue anyway? (y/N) " answer
  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "Aborting installation." >&2
    exit 1
  else
    echo "Continuing installation despite the warning."
    echo "⚠️ If there are any issues I recommend wiping the linux filesystem partition and starting over using GTP partition table."
  fi
fi

if [ -e "$MNT/etc/arch-release" ]; then
  echo "❌ Arch already installed in $MNT. Aborting." >&2
  exit 1
fi

if ! mountpoint -q "$MNT/boot"; then
  echo "❌ EFI partition not mounted to $MNT/boot. Please mount it manually before running this script." >&2
  exit 1
fi

pacstrap -K "$MNT" base base-devel linux-firmware grub efibootmgr networkmanager os-prober sudo git nano openssh xdg-utils xdg-user-dirs wget curl

# --- Creation of the fstab file ---
genfstab -U /mnt >> /mnt/etc/fstab

read -p "⚠️ Do you want to install the Custom Kernel for ASUS ROG Strix G14? (default is linux kernel) (y/N) " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then

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
    echo "❌ Failed to import key using the clean method." >&2
    wget "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x8b15a6b0e9a3fa35" -O /tmp/g14.sec
    cp /tmp/g14.sec "$MNT/tmp/g14.sec"

    if arch-chroot "$MNT" bash -c "
      pacman-key -a /tmp/g14.sec
      pacman-key --lsign-key 8B15A6B0E9A3FA35
      rm /tmp/g14.sec
    "; then 
      echo "✅ Key imported successfully using fallback method."
    else
      echo "❌ Failed to import key using fallback method." >&2
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
  "
  echo "✅ ASUS Kernel settings are now installed."
else
  echo "🔧 Installing the default linux kernel..."
  arch-chroot "$MNT" bash -c "
    pacman -S --noconfirm linux linux-headers
    echo '🖥️ Installing NVIDIA drivers, you will most likely need to reinstall them according to the specifications of your PC'
    pacman -S --needed --noconfirm nvidia-open
  "
  echo "✅ Generic Kernel settings are now installed."
fi

arch-chroot "$MNT" bash -c "mkinitcpio -P"

echo "🔧 Installing GRUB bootloader..."

arch-chroot "$MNT" bash -c "
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  sed -i 's/^#GRUB_DISABLE_OS_PROBER=false$/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
  grub-mkconfig -o /boot/grub/grub.cfg
"
echo "🔧 Preparing the timezone, users, passwords, etc."

# --- Configuration of the hosts, timezone, keyboard, users and services ---
arch-chroot "$MNT" bash -c "
  echo 'Setting up the timezone...'
  ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
  hwclock --systohc

  echo 'Configuring the keyboard layout...'
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
"

read -p "Do you want to set up the first user and the root user? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "Setting up the root and user passwords..."
  root_password=""
  username=""
  user_password=""

  while true; do
    read -p "Provide the root password for the new system (no spaces, tabs, etc): " root_password
    if [[ -z "$root_password" || "$root_password" =~ [[:space:]] ]]; then
      echo "❌ Password cannot be empty or contain spaces. Please try again."
      continue
    fi
    read -p "Confirm the root password: " root_password_confirm
    if [[ "$root_password" == "$root_password_confirm" ]]; then
      break
    else
      echo "❌ Passwords do not match. Please try again."
    fi
  done

  while true; do
    read -p "Provide the username for the new user (no spaces, tabs, etc): " username
    if [[ -z "$username" || "$username" =~ [[:space:]] ]]; then
      echo "❌ Username cannot be empty or contain spaces. Please try again."
      continue
    fi
    read -p "Confirm the username: " username_confirm
    if [[ "$username" == "$username_confirm" ]]; then
      break
    else
      echo "❌ Usernames do not match. Please try again."
    fi
  done

  while true; do
    read -p "Provide the password for the new user (no spaces, tabs, etc): " user_password
    if [[ -z "$user_password" || "$user_password" =~ [[:space:]] ]]; then
      echo "❌ Password cannot be empty or contain spaces. Please try again."
      continue
    fi
    read -p "Confirm the user password: " user_password_confirm
    if [[ "$user_password" == "$user_password_confirm" ]]; then
      break
    else
      echo "❌ Passwords do not match. Please try again."
    fi
  done

  arch-chroot "$MNT" useradd -m -G wheel,audio,video,input,storage,power -s /bin/bash "$username"
  arch-chroot "$MNT" chpasswd <<< "root:$root_password"
  arch-chroot "$MNT" chpasswd <<< "$username:$user_password"
  arch-chroot "$MNT" sed -i "s/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers
  arch-chroot "$MNT" sed -i "/^root ALL=(ALL:ALL) ALL$/a $username ALL=(ALL:ALL) ALL" /etc/sudoers
  arch-chroot "$MNT" su - $username -c "xdg-user-dirs-update || echo \"❌ Failed to update user directories for $username\" >&2"
fi

read -p "Do you want to clone the github repo with the dotfiles? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "🔄 Cloning the dotfiles repository..."
  arch-chroot "$MNT" su - $username -c "git clone --recurse-submodules https://github.com/KaRLiToS3/.dotfiles.git \"/home/$username/.dotfiles\""
  arch-chroot "$MNT" chown -R "$username:$username" "/home/$username/.dotfiles"
fi

read -p "Do you want to try to install everything now? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "🔄 Installing packages from the .dotfiles repository..."
  arch-chroot "$MNT" env SUDO_USER="$username" bash /home/$username/.dotfiles/install/postInstall.sh

  echo "🔄 Unmounting /mnt..."
  umount -lR "$MNT"

  echo "✅ Installation completed. Boot into the new System :)"

else 
  echo "🧾 To complete the setup, boot into the system and please run:"
  echo ".dotfiles/install/postInstall.sh"
fi
