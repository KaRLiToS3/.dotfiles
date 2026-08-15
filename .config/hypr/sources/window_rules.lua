-- Reglas de ventanas y de capas.
-- Docs: https://wiki.hypr.land/Configuring/Basics/Window-Rules/
--
-- Las reglas se evalúan de arriba abajo: la última que casa gana.

---@module 'hl'

------------------------
---- REGLAS GENERALES ----
------------------------

-- Evita que las apps se maximicen automáticamente
hl.window_rule({
    name           = "suppress-maximize",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Mejoras XWayland
hl.window_rule({
    name     = "xwayland-fix-drags",
    match    = { class = "^$", title = "^$", xwayland = true },
    no_focus = true,
})

hl.window_rule({
    name      = "xwayland-tearing",
    match     = { xwayland = true },
    immediate = true,
})

--------------------------
---- VENTANAS FLOTANTES ----
--------------------------

hl.window_rule({
    name   = "float-portal-gtk",
    match  = { class = "^(xdg-desktop-portal-gtk)$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.5", "monitor_h*0.6" },
})

-- Diálogos de abrir/guardar (VS Code y similares)
hl.window_rule({
    name   = "float-open-save-dialogs",
    match  = { title = "^(Open|Save|Login).*" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.7", "monitor_h*0.75" },
})

hl.window_rule({
    name   = "float-brave-login",
    match  = { initial_title = "^(Sin título - Brave)$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.5", "monitor_h*0.6" },
})

-- Diálogos del sistema
hl.window_rule({
    name  = "float-system-dialogs",
    match = { class = "^(pavucontrol|blueman-manager|nm-connection-editor|gnome-system-monitor|htop|btop)$" },
    float = true,
})

-- Calculadoras
hl.window_rule({
    name  = "float-calculators",
    match = { class = "^(gnome-calculator|org.gnome.Calculator|calculator|Calculator|qalculate-gtk)$" },
    float = true,
})

hl.window_rule({
    name   = "size-gnome-calculator",
    match  = { class = "^(gnome-calculator|org.gnome.Calculator)$" },
    center = true,
    size   = { 400, 500 },
})

-- Visores de imágenes
hl.window_rule({
    name  = "float-image-viewers",
    match = { class = "^(eog|org.gnome.eog|feh|sxiv|imv)$" },
    float = true,
})

hl.window_rule({
    name    = "layout-eog",
    match   = { class = "^(eog|org.gnome.eog)$" },
    size    = { "monitor_w*0.5", "monitor_h*0.6" },
    move    = { "monitor_w*0.5", "monitor_h*0.2" },
    opacity = "0.9",
})

-- Ventanas lanzadas con los binds SUPER+SHIFT
hl.window_rule({
    name   = "float-filemanager-by-class",
    match  = { class = "^(floating-filemanager)$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.7", "monitor_h*0.75" },
})

hl.window_rule({
    name   = "float-filemanager-by-title",
    match  = { title = "^(floating-filemanager)$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.7", "monitor_h*0.75" },
})

hl.window_rule({
    name   = "float-browser",
    match  = { title = "^(floating-browser)$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.8", "monitor_h*0.8" },
})

hl.window_rule({
    name   = "float-code",
    match  = { title = "^(floating-code)$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.85", "monitor_h*0.85" },
})

-- Gestores de archivos comprimidos
hl.window_rule({
    name  = "float-archive-managers",
    match = { class = "^(file-roller|org.gnome.FileRoller)$" },
    float = true,
})

-- KiCad: flota todo menos la ventana principal del proyecto
hl.window_rule({
    name      = "kicad-floating",
    match     = {
        class         = "^(kicad)$",
        initial_title = "negative:^(.*— KiCad 10.0.*)$",
    },
    immediate = true,
    float     = true,
    center    = true,
    size      = { "monitor_w*0.7", "monitor_h*0.75" },
})

------------------------------
---- ASIGNACIÓN DE WORKSPACES ----
------------------------------

hl.window_rule({
    name      = "ws2-browsers",
    match     = { class = "^(brave-browser|firefox|chromium|google-chrome)$" },
    workspace = "2",
})

hl.window_rule({
    name      = "ws3-development",
    match     = { class = "^(code|Code|code-oss|code-url-handler|neovim|jetbrains-.*)$" },
    workspace = "3",
})

hl.window_rule({
    name      = "ws4-communication",
    match     = { class = "^(discord|telegram-desktop|Signal|slack|teams)$" },
    workspace = "4",
})

------------------------
---- REGLAS ESPECIALES ----
------------------------

hl.window_rule({
    name   = "float-mpv",
    match  = { class = "^(mpv)$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.6", "monitor_h*0.6" },
})

hl.window_rule({
    name  = "pip",
    match = { title = "^(Picture-in-Picture)$" },
    pin   = true,
    float = true,
    size  = { "monitor_w*0.25", "monitor_h*0.25" },
})

hl.window_rule({
    name       = "steam-games",
    match      = { class = "^(steam_app_.*)$" },
    immediate  = true,
    fullscreen = true,
})

-- Gestores de contraseñas
hl.window_rule({
    name  = "float-password-managers",
    match = { class = "^(keepassxc|bitwarden)$" },
    float = true,
})

hl.window_rule({
    name   = "size-keepassxc",
    match  = { class = "^(keepassxc)$" },
    center = true,
    size   = { 800, 600 },
})

-- Terminales
hl.window_rule({
    name    = "terminal-opacity",
    match   = { class = "^(Alacritty|alacritty|kitty)$" },
    opacity = "0.9",
})

hl.window_rule({
    name   = "float-terminal",
    match  = { title = "^(floating-terminal)$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.7", "monitor_h*0.6" },
})

----------------
---- DIÁLOGOS ----
----------------

hl.window_rule({
    name   = "size-zenity",
    match  = { class = "^(zenity)$" },
    center = true,
    size   = { 400, 300 },
})

hl.window_rule({
    name   = "float-polkit-agent",
    match  = { class = "^(polkit-gnome-authentication-agent-1)$" },
    float  = true,
    center = true,
})

--------------------
---- FOCO / TEARING ----
--------------------

hl.window_rule({
    name     = "no-focus-steam-toasts",
    match    = { class = "^(steam)$", title = "^(notificationtoasts_.*)$" },
    no_focus = true,
})

hl.window_rule({
    name     = "no-focus-discord-updater",
    match    = { class = "^(discord)$", title = "^(Discord Updater)$" },
    no_focus = true,
})

hl.window_rule({
    name      = "immediate-password-store",
    match     = { class = "^(password-store)$" },
    immediate = true,
})

hl.window_rule({
    name      = "immediate-password-titles",
    match     = { title = "^(.*[Pp]assword.*)$" },
    immediate = true,
})

------------------
---- LAYER RULES ----
------------------

hl.layer_rule({
    name         = "blur-waybar",
    match        = { namespace = "waybar" },
    blur         = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name         = "blur-wofi",
    match        = { namespace = "wofi" },
    blur         = true,
    ignore_alpha = 0.5,
})
