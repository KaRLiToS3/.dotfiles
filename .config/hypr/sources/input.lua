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

-- Pellizcar hacia dentro: abrir el scratchpad
hl.gesture({ fingers = 3, direction = "pinchin", action = "special", workspace_name = "hidden" })
