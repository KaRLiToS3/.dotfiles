# ASUS ROG Arch Linux Auto-Install & Dotfiles

A specialized automated Arch Linux installation and configuration project designed specifically for ASUS ROG computers, following the official specifications from [ASUS Linux](https://asus-linux.org/guides/arch-guide/).

## ⚡ Features

- **Automated Arch Linux Installation**: Complete system setup from live USB
- **ASUS ROG Optimized**: Configured for ASUS hardware with proper drivers
- **Custom SDDM Theme**: Beautiful dark red theme with astronaut design
- **Hyprland Desktop**: Modern Wayland compositor setup
- **Security Tools**: Pre-configured penetration testing environment
- **Development Environment**: Complete coding setup with VS Code, Docker, and more
- **Audio/Video Production**: KDENlive, advanced audio tools, and hardware support

## 🖥️ Supported Hardware

This project is specifically designed for ASUS ROG laptops and follows the recommendations from the official ASUS Linux guide. It includes:

- NVIDIA driver support (both open and proprietary)
- ASUS-specific kernel configurations
- Audio optimization for ASUS hardware
- Power management for gaming laptops

## 📁 Project Structure

```
.dotfiles/
├── install/
│   ├── liveUSB.sh      # Main installation script
│   ├── postInstall.sh  # Post-installation configuration
│   └── gitSetup.sh     # Git and SSH setup (deprecated)
├── pkgs/
│   ├── install.sh      # Package installation script
│   ├── pkglist.txt     # Official repository packages filtered
│   ├── aurlist.txt     # AUR packages filtered
│   └── breeze/         # Custom SDDM theme files
├── sddm/
│   ├── setup.sh        # SDDM configuration script
│   ├── dark_and_red.conf # Custom theme configuration
│   └── sddm            # PAM configuration
├── imgs/               # Background images and assets
└── root/               # Root user configuration files
```

## 🚀 Quick Start

### Prerequisites

1. ASUS ROG laptop with UEFI boot
2. Arch Linux live USB
3. Internet connection
4. At least 20GB free disk space

### Installation

1. **Boot from Arch Linux live USB**

2. **Download and run the installation script**:
   ```bash
   curl -L https://raw.githubusercontent.com/KaRLiToS3/.dotfiles/main/install/liveUSB.sh | bash
   ```
   I recommend copying the file through ssh using the scp command, or a second USB.

3. **Follow the interactive prompts**:
   - Choose between ASUS-specific or generic kernel
   - Set up disk partitioning
   - Configure users and passwords
   - Optional: Clone dotfiles repository
   - Optional: Complete automated setup

4. **Reboot and enjoy your new system!**

## 📦 Included Software

### System & Desktop
- **Desktop Environment**: Hyprland (Wayland compositor)
- **Display Manager**: SDDM with custom astronaut theme
- **Terminal**: Alacritty, Foot
- **File Manager**: Thunar with volume management
- **Launcher**: Rofi (Wayland)
- **Status Bar**: Waybar
- **Notifications**: Dunst

### Development Tools
- **Editors**: VS Code, Vim, Nano
- **Version Control**: Git with SSH setup
- **Containers**: Docker, Docker Compose
- **Languages**: Full development environment ready

### Security & Networking
- **Penetration Testing**: Burp Suite, Metasploit, Hydra, Nmap
- **Network Analysis**: Wireshark
- **Network Management**: NetworkManager with GUI

### Multimedia & Productivity
- **Video Editing**: KDENlive
- **Office Suite**: LibreOffice
- **Audio**: Advanced ALSA/PipeWire setup with hardware support
- **Graphics**: Full NVIDIA driver support

### Hardware & System Tools
- **Monitoring**: htop, lm_sensors, psensor
- **File Tools**: bat (better cat), lsd (better ls)
- **Archive Support**: Full NTFS, exFAT support
- **Hardware Tools**: i2c-tools for hardware interaction

## 🎨 Customization

### SDDM Theme
The project includes a custom dark red theme based on the astronaut theme:
- Dark background with red accents
- Custom login fields with improved visibility
- Configurable virtual keyboard
- Spanish locale support

### Hyprland Configuration
- Optimized for ASUS hardware
- Custom keybindings and workspace management
- Integrated with Waybar and Rofi
- Screen capture tools (grim, slurp)

## 🔧 Manual Setup

If you prefer manual installation or want to use specific components:

1. **Install packages only**:
   ```bash
   sudo bash pkgs/install.sh
   ```

2. **Setup SDDM theme only**:
   ```bash
   sudo bash sddm/setup.sh
   ```

3. **Link dotfiles only**:
   ```bash
   sudo bash install/postInstall.sh
   ```

## 🔑 Security Features

- Secure user setup with proper sudo configuration
- SSH key generation and management
- GNOME Keyring integration
- Secure boot compatibility
- Encrypted storage support

## 📖 Configuration Files

The dotfiles include configurations for:
- Zsh with custom prompt and aliases
- Git with proper user setup
- Development tools and editors
- Audio/video production software
- Security and networking tools

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test on ASUS hardware if possible
4. Submit a pull request

## 📚 Credits & Resources

### Official Resources
- [ASUS Linux Project](https://asus-linux.org/) - Official ASUS Linux support
- [ASUS Arch Guide](https://asus-linux.org/guides/arch-guide/) - Hardware-specific installation guide

### Third-Party Projects
- [SDDM Astronaut Theme](https://github.com/keyitdev/sddm-astronaut-theme) - Base theme for login screen
- [Hyprland](https://hyprland.org/) - Wayland compositor
- [Waybar](https://github.com/Alexays/Waybar) - Status bar
- [Rofi](https://github.com/davatorium/rofi) - Application launcher

### Additional Resources
- [Arch Wiki](https://wiki.archlinux.org/) - Comprehensive Linux documentation
- [ASUS ROG Community]() - [Add your community links here]
- [Linux Gaming on ASUS]() - [Add gaming-specific resources here]

## ⚠️ Important Notes

1. **ASUS Hardware Requirement**: This setup is optimized for ASUS ROG hardware
2. **NVIDIA Support**: Includes both open and proprietary NVIDIA drivers
3. **Backup Recommended**: Always backup important data before installation
4. **Testing**: Test in a virtual machine or spare system first
5. **Updates**: Keep system updated for security and hardware compatibility

## 🆘 Troubleshooting

### Common Issues
- **Boot Issues**: Ensure UEFI boot is enabled and Secure Boot is properly configured
- **NVIDIA Problems**: Check ASUS Linux documentation for your specific model
- **Audio Issues**: Use `pavucontrol` to configure audio profiles
- **Network**: Ensure NetworkManager service is running

### Getting Help
- Check [ASUS Linux Forums]()
- Review Arch Wiki for hardware-specific issues
- Open GitHub issues for project-specific problems

---

**Made with for the ASUS ROG Linux community**
