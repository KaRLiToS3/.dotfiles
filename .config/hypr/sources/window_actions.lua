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

-- Mete la ventana activa en el grupo más cercano del workspace, midiendo
-- distancia entre centros. Si no hay ningún grupo, avisa y no hace nada.
function M.move_into_nearest_group()
    local w = hl.get_active_window()
    if w == nil then return end

    if w.group ~= nil then
        hl.notification.create({ text = "La ventana ya está en un grupo", timeout = 1500 })
        return
    end

    local ws = w.workspace
    if ws == nil then return end

    local cx = w.at.x + w.size.x / 2
    local cy = w.at.y + w.size.y / 2

    local best, bestDist

    for _, other in ipairs(hl.get_workspace_windows(ws)) do
        local group = other.group

        if group ~= nil and other.address ~= w.address then
            local ox = other.at.x + other.size.x / 2
            local oy = other.at.y + other.size.y / 2
            -- distancia al cuadrado: evita la raíz, el orden es el mismo
            local dist = (ox - cx) ^ 2 + (oy - cy) ^ 2

            if bestDist == nil or dist < bestDist then
                best, bestDist = group, dist
            end
        end
    end

    if best == nil then
        hl.notification.create({ text = "No hay ningún grupo en este workspace", timeout = 2000 })
        return
    end

    -- add() ya valida grupos denegados y ventanas no agrupables
    best:add(w)
end

function M.move_out_of_group()
    local w = hl.get_active_window()
    if w == nil then return end

    if w.group == nil then
        hl.notification.create({ text = "La ventana no está en ningún grupo", timeout = 1500 })
        return
    end

    w.group:remove(w)
end

return M
