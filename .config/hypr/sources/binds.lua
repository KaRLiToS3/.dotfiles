-- Atajos de teclado.
-- Docs: https://wiki.hypr.land/Configuring/Basics/Binds/

---@module 'hl'

local apps    = require("sources.programs")
local mainMod = "SUPER"

---------------------
---- APLICACIONES ----
---------------------

hl.bind(mainMod .. " + Return",         hl.dsp.exec_cmd(apps.terminal))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(apps.terminal .. [[ --title "floating-terminal"]]))

hl.bind(mainMod .. " + F",              hl.dsp.exec_cmd(apps.browser))
hl.bind(mainMod .. " + SHIFT + F",      hl.dsp.exec_cmd(apps.browser .. [[ --new-window --app="floating-browser"]]))

hl.bind(mainMod .. " + D",              hl.dsp.exec_cmd(apps.fileManager))
hl.bind(mainMod .. " + SHIFT + D",      hl.dsp.exec_cmd(apps.fileManager .. [[ --name="floating-filemanager"]]))
hl.bind(mainMod .. " + E",              hl.dsp.exec_cmd(apps.fileManager))
hl.bind(mainMod .. " + SHIFT + E",      hl.dsp.exec_cmd(apps.fileManager .. [[ --name="floating-filemanager"]]))

hl.bind(mainMod .. " + R",              hl.dsp.exec_cmd(apps.menu))
hl.bind(mainMod .. " + SHIFT + R",      hl.dsp.exec_cmd(apps.menu .. [[ --gtk-application-id="floating-menu"]]))
hl.bind(mainMod .. " + A",              hl.dsp.exec_cmd("rofi -show drun"))

hl.bind(mainMod .. " + C",              hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + SHIFT + C",      hl.dsp.exec_cmd([[code --new-window --title="floating-code"]]))
hl.bind(mainMod .. " + I",              hl.dsp.exec_cmd("intellij-idea-ultimate-edition"))

hl.bind(mainMod .. " + SHIFT + W",      hl.dsp.exec_cmd("killall waybar && waybar"))

-- Capturas: al portapapeles / a archivo
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))
hl.bind(mainMod .. " + CTRL + S",  hl.dsp.exec_cmd([[grim -g "$(slurp)" ~/Imágenes/screenshots/$(date +"%Y-%m-%d_%H-%M-%S").png]]))

--------------------------
---- GESTIÓN DE VENTANAS ----
--------------------------

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle

-- Fija la ventana en todos los workspaces (útil con visores de imágenes)
hl.bind(mainMod .. " + T", hl.dsp.window.pin())

-- Opacidad de la ventana activa
hl.bind(mainMod .. " + SHIFT + equal", hl.dsp.window.set_prop({ prop = "opacity", value = "1.0" }))
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.set_prop({ prop = "opacity", value = "0.7" }))

-- Mover el foco con las flechas
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Mover / redimensionar con SUPER + botón del ratón
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

------------------
---- WORKSPACES ----
------------------

-- SUPER + [0-9] cambia de workspace, + SHIFT mueve la ventana activa
for i = 1, 10 do
    local key = i % 10 -- el 10 se mapea a la tecla 0
    hl.bind(mainMod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mainMod .. " + TAB", hl.dsp.workspace.toggle_special("hidden"))
hl.bind(mainMod .. " + Z",   hl.dsp.window.move({ workspace = "special:hidden" }))

-- Trae la ventana activa al workspace actual
hl.bind(mainMod .. " + less", function()
    local ws = hl.get_active_workspace()
    if ws then
        hl.dispatch(hl.dsp.window.move({ workspace = ws.id }))
    end
end)

-- Cambiar de workspace con la rueda del ratón
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-------------------------
---- TECLAS MULTIMEDIA ----
-------------------------

-- Este portátil envía F1-F12 en lugar de las teclas XF86
local media = { locked = true, repeating = true }

hl.bind("F1", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), media)
hl.bind("F2", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      media)
hl.bind("F3", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     media)
hl.bind("F4", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   media)
hl.bind("F5", hl.dsp.exec_cmd("brightnessctl s 10%-"),                           media)
hl.bind("F6", hl.dsp.exec_cmd("brightnessctl s 10%+"),                           media)

-- Teclas XF86 originales, por si alguna sí llega
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), media)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      media)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     media)
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   media)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"),                           media)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"),                           media)

-- Requiere playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Clic central: pega la selección primaria
hl.bind("mouse:274", hl.dsp.exec_cmd("wl-copy -pc"), { non_consuming = true })
