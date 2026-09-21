-- Hyprland — configuración principal
-- Docs: https://wiki.hypr.land/Configuring/Start/

---@module 'hl'

-----------------
---- MONITOR ----
-----------------

-- 240 Hz con cargador, 60 Hz en batería (ahorra varios W en reposo).
-- Se aplica al cargar la config y, en caliente, desde scripts/refresh-on-power.sh
-- con `hyprctl eval 'set_refresh_for_power()'`.
local panel_modes = { ac = "2560x1600@240", battery = "2560x1600@60" }
local current_panel_mode = nil

function set_refresh_for_power()
    local f = io.open("/sys/class/power_supply/BAT0/status")
    local status = f and f:read("l") or ""
    if f then f:close() end

    local mode = status == "Discharging" and panel_modes.battery or panel_modes.ac
    -- La batería emite eventos cada poco; sin esto habría un modeset en cada uno
    if mode == current_panel_mode then return end
    current_panel_mode = mode

    hl.monitor({
        output   = "eDP-1",
        mode     = mode,
        position = "0x0",
        scale    = 1,
    })
end

set_refresh_for_power()

-------------------------------
---- VARIABLES DE ENTORNO ----
-------------------------------

-- Escritorio
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Fuerza backend Wayland nativo en Firefox y apps GDK
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("CLUTTER_BACKEND", "wayland")

-- Tema Qt (gestionado por nwg-look / qt5ct / qt6ct)
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Cursor
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "34")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "34")

-- Electron / Chrome
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

-- Agente SSH de gnome-keyring
hl.env("SSH_AUTH_SOCK", (os.getenv("XDG_RUNTIME_DIR") or "/run/user/1000") .. "/gnupg/S.gpg-agent.ssh")

-----------------
---- MÓDULOS ----
-----------------

require("sources.look_and_feel")
require("sources.input")
require("sources.binds")
require("sources.window_rules")

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- xsettingsd es necesario para que apps GTK antiguas lean la config de nwg-look
    hl.exec_cmd("xsettingsd")

    hl.exec_cmd("udiskie --tray")
    hl.exec_cmd('imwheel -b "45"')
    hl.exec_cmd("blueman-applet")

    -- 60 Hz en batería / 240 Hz con cargador (ver set_refresh_for_power)
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/refresh-on-power.sh")

    -- Ojo: bajo el gestor Lua, `hyprctl dispatch` espera una expresión Lua.
    hl.exec_cmd("swayidle -w "
        .. [[timeout 300 'hyprctl dispatch "hl.dsp.dpms({ action = \"off\" })"' ]]
        .. [[resume 'hyprctl dispatch "hl.dsp.dpms({ action = \"on\" })"' ]]
        .. "timeout 900 'systemctl suspend' "
        .. "before-sleep 'swaylock -f -c 000000'")
end)
