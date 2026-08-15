-- Programas por defecto.
-- Módulo compartido: lo usan tanto hyprland.lua como binds.lua.

---@module 'hl'

return {
    terminal    = "alacritty",
    fileManager = "nemo",
    browser     = "brave --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations",
    menu        = "wofi --show drun",
}
