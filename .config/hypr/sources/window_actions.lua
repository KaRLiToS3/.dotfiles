-- Acciones de ventana que necesitan lógica propia, más allá de un dispatcher.

---@module 'hl'

local M = {}

-- Proporción del monitor que ocupa una ventana al pasar a flotante
M.FLOAT_RATIO = 0.6

-- Alterna flotante. Al flotar dimensiona y centra: el comportamiento por
-- defecto hereda el tamaño en mosaico, que en esta pantalla queda enorme
-- y descolocado.
function M.float_toggle()
    local w = hl.get_active_window()
    if w == nil then return end

    if w.floating then
        hl.dispatch(hl.dsp.window.float({ action = "off" }))
        return
    end

    hl.dispatch(hl.dsp.window.float({ action = "on" }))

    local m = hl.get_active_monitor()
    if m == nil then return end

    -- width/height del monitor son físicos; el tamaño de ventana es lógico
    hl.dispatch(hl.dsp.window.resize({
        x = math.floor(m.width  / m.scale * M.FLOAT_RATIO),
        y = math.floor(m.height / m.scale * M.FLOAT_RATIO),
    }))
    hl.dispatch(hl.dsp.window.center())
end

return M
