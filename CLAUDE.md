# Dotfiles — ASUS ROG Arch Linux

Personal dotfiles and system configuration for an ASUS ROG laptop running Arch Linux with a Hyprland/Wayland desktop.

## System Overview

- **OS:** Arch Linux (rolling release)
- **Desktop:** Hyprland (Wayland) + Waybar + SDDM
- **Shell:** Zsh + oh-my-zsh + powerlevel10k
- **Terminal:** Alacritty
- **Theme:** Red/black across all UI components
- **Display:** 2560x1600 @ 240Hz

## Repo Structure

```
.dotfiles/
├── .config/          # App configs — selectively symlinked to ~/.config/
├── .zsh/             # Modular shell config — all .zsh files sourced automatically by .zshrc
├── install/          # Arch installation scripts (liveUSB.sh, postInstall.sh)
├── pkgs/             # Package lists (pkglist.txt = official, aurlist.txt = AUR)
├── pacman/           # Pacman hooks and config
├── sddm/             # Login screen theme
├── audio/            # ALSA hardware config
├── documentation/    # Fix logs and setup guides (one .md file per topic)
└── .themes/          # GTK themes
```

## Symlinking Convention

Selected app config folders are symlinked wholesale from `.dotfiles/.config/` to `~/.config/`:

```bash
~/.config/hypr     -> ~/.dotfiles/.config/hypr
~/.config/waybar   -> ~/.dotfiles/.config/waybar
~/.config/alacritty -> ~/.dotfiles/.config/alacritty
# ... etc.
```

Not every app in `~/.config/` is tracked — only those explicitly symlinked. To add a new app:
1. Move its config folder into `.dotfiles/.config/`
2. Create the symlink: `ln -s ~/.dotfiles/.config/<app> ~/.config/<app>`

## Package Management

**Preferred order:**
1. `sudo pacman -S <pkg>` — always try this first
2. `yay -S <pkg>` — if not in official repos
3. Other methods (compile from source, install script, etc.) — only if unavailable in pacman/AUR

`pkgs/pkglist.txt` and `pkgs/aurlist.txt` are updated automatically via the pacman hook — no manual editing needed.

For anything installed outside pacman/yay, log it in `pkgs/manual.md` with the name, source, install method, and reason it couldn't be packaged normally.

## Rules

### Documentation (mandatory)
Every fix, workaround, or non-trivial setup process must be documented as a `.md` file in `documentation/`. Keep it short: what the problem was, the fix, and the commands used. See existing files for the format.

### System-wide changes
- **Reading** anywhere on the system is always fine.
- **Modifying or deleting** system files, configs, or packages: always ask before acting.

## Scope

This agent helps with:
- Fixing system issues and documenting them
- Managing and extending dotfiles (new app configs, shell tweaks, theme changes)
- Maintaining and improving install scripts (`install/`)
- Post-update recovery (e.g. Hyprland breaking changes, Waybar config updates)
