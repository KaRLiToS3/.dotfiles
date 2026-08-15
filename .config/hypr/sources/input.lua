-- Teclado, ratón y touchpad.
-- Docs: https://wiki.hypr.land/Configuring/Basics/Variables/

---@module 'hl'

hl.config({
    input = {
        kb_layout = "es",

        follow_mouse = 1,
        -- Evita saltos de foco por microtemblores del ratón
        follow_mouse_threshold = 3,

        sensitivity = 0.7, -- -1.0 a 1.0, 0 = sin modificación

        touchpad = {
            natural_scroll          = true,
            middle_button_emulation = false,
            scroll_factor           = 0.5,
        },
    },

    misc = {
        middle_click_paste = false,
    },
})

-- Config por dispositivo
-- Docs: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
hl.device({
    name        = "hp-hp-pavilion-gaming-mouse-200",
    sensitivity = -0.3,
})

---------------
---- GESTOS ----
---------------
-- Docs: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/

-- 3 dedos en horizontal: cambiar de workspace (animación 1:1)
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- 4 dedos arriba: maximizar (no "fullscreen", que taparía waybar).
-- Si la ventana está flotante se devuelve a mosaico primero, para que al
-- desmaximizar vuelva al layout y no al tamaño flotante.
hl.gesture({
    fingers   = 4,
    direction = "up",
    action    = function()
        local w = hl.get_active_window()
        if w == nil then return end

        if w.floating then
            hl.dispatch(hl.dsp.window.float({ action = "off" }))
        end

        -- ojo: aquí el modo es "maximized", no "maximize" como en el gesto
        hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
    end,
})

-- 4 dedos abajo: alternar flotante con un tamaño razonable.
-- La acción "float" integrada llama a changeFloatingMode, que hereda el
-- tamaño tiled y en esta pantalla queda enorme, así que se usa una función.
local FLOAT_RATIO = 0.6

hl.gesture({
    fingers   = 4,
    direction = "down",
    action    = function()
        local w = hl.get_active_window()
        if w == nil then return end

        if w.floating then
            hl.dispatch(hl.dsp.window.float({ action = "off" }))
            return
        end

        hl.dispatch(hl.dsp.window.float({ action = "on" }))

        local m = hl.get_active_monitor()
        if m == nil then return end

        -- width/height son físicos; el tamaño de ventana es lógico
        hl.dispatch(hl.dsp.window.resize({
            x = math.floor(m.width  / m.scale * FLOAT_RATIO),
            y = math.floor(m.height / m.scale * FLOAT_RATIO),
        }))
        hl.dispatch(hl.dsp.window.center())
    end,
})

-- Pellizcar hacia dentro: abrir el scratchpad
hl.gesture({ fingers = 3, direction = "pinchin", action = "special", workspace_name = "hidden" })
