-- ============================================================
--  lib/dashboard.lua
--  Monitor central 4x4 - Dashboard principal
--  Muestra actividad en tiempo real y estado global
-- ============================================================

local Storage    = require("lib.storage")
local categories = require("data.categories")

local Dashboard = {}

-- Monitor central (el 4x4 grande)
-- Cámbialo si tu monitor grande tiene un nombre diferente
local DASHBOARD_MONITOR = "monitor_5"
local dash = nil

-- Cola de movimientos recientes (para el live feed)
local move_log = {}
local MAX_LOG  = 12

-- Estadísticas globales de sesión
local session = {
    total_moved    = 0,
    total_runs     = 0,
    start_time     = os.clock(),
}

-- Inicializar monitor
local function init()
    if not dash then
        dash = peripheral.wrap(DASHBOARD_MONITOR)
        if dash then
            dash.setTextScale(0.5)
        end
    end
    return dash ~= nil
end

-- Barra de progreso inline
local function bar(pct, width, color_on, color_off)
    local filled = math.floor(pct * width)
    local result = ""
    -- Solo retorna el string, el caller pone el color
    return string.rep("|", filled) .. string.rep("-", width - filled)
end

-- Agregar entrada al log de movimientos
function Dashboard.logMove(result)
    -- Acortar nombre del item (quitar mod prefix)
    local short_name = result.item_name:match(":(.+)$") or result.item_name
    -- Acortar a 20 chars
    if #short_name > 18 then
        short_name = short_name:sub(1, 17) .. "."
    end

    local entry = {
        name  = short_name,
        count = result.moved,
        cat   = result.category,
        dest  = result.dest_controller,
        time  = textutils.formatTime(os.time(), true),
    }

    table.insert(move_log, 1, entry) -- insertar al frente
    if #move_log > MAX_LOG then
        table.remove(move_log)       -- quitar el más viejo
    end
end

-- ============================================================
--  Dibujar dashboard completo
-- ============================================================
function Dashboard.draw(current_item, total_moved, total_items, run_stats)
    if not init() then return end

    local w, h = dash.getSize()
    dash.setBackgroundColor(colors.black)
    dash.clear()

    -- ── HEADER ──────────────────────────────────────────────
    dash.setBackgroundColor(colors.blue)
    dash.setTextColor(colors.white)
    dash.setCursorPos(1, 1)
    dash.write(string.rep(" ", w))
    dash.setCursorPos(2, 1)
    dash.write("[ INVENTORY SORTER ]")
    dash.setCursorPos(w - 7, 1)
    dash.write(textutils.formatTime(os.time(), true))
    dash.setBackgroundColor(colors.black)

    -- ── COLUMNA IZQUIERDA: Item actual + log ─────────────────
    local col1_w = math.floor(w * 0.45)

    -- Item en movimiento
    dash.setTextColor(colors.yellow)
    dash.setCursorPos(1, 3)
    dash.write(">> MOVIENDO AHORA:")

    if current_item then
        local short = current_item.item_name:match(":(.+)$") or current_item.item_name
        dash.setTextColor(colors.white)
        dash.setCursorPos(1, 4)
        if #short > col1_w then short = short:sub(1, col1_w - 1) end
        dash.write(short)

        dash.setTextColor(colors.lightGray)
        dash.setCursorPos(1, 5)
        dash.write(string.format("x%d -> Ctrl_%d [%s]",
            current_item.count or 0,
            current_item.dest_controller or 0,
            current_item.category or "?"))
    else
        dash.setTextColor(colors.gray)
        dash.setCursorPos(1, 4)
        dash.write("En espera...")
    end

    -- Barra de progreso del run actual
    if total_items and total_items > 0 then
        local run_pct = total_moved / total_items
        dash.setTextColor(colors.cyan)
        dash.setCursorPos(1, 6)
        dash.write(string.format("Run: %d/%d", total_moved, total_items))
        dash.setCursorPos(1, 7)
        dash.setTextColor(colors.cyan)
        local filled = math.floor(run_pct * col1_w)
        dash.write(string.rep("|", filled))
        dash.setTextColor(colors.gray)
        dash.write(string.rep("-", col1_w - filled))
    end

    -- Log de movimientos recientes
    dash.setTextColor(colors.lightGray)
    dash.setCursorPos(1, 9)
    dash.write("RECIENTES:")
    for i, entry in ipairs(move_log) do
        if 9 + i > h - 2 then break end
        dash.setCursorPos(1, 9 + i)
        local cat = categories.categories[entry.cat]
        local icon = cat and cat.icon or "?"
        dash.setTextColor(colors.gray)
        dash.write(string.format("%s x%-4d %s", icon, entry.count, entry.name))
    end

    -- ── COLUMNA DERECHA: Estado de controllers ───────────────
    local col2_x   = col1_w + 2
    local bar_w    = w - col2_x - 5

    dash.setTextColor(colors.yellow)
    dash.setCursorPos(col2_x, 3)
    dash.write("MODULOS:")

    local alert_colors = {
        ok       = colors.green,
        upgrade  = colors.yellow,
        expand   = colors.orange,
        critical = colors.red,
    }

    for i = 0, 4 do
        local y       = 4 + i * 3
        local cat_key = categories.controllers[i]
        local cat     = categories.categories[cat_key]
        local stats   = Storage.stats(i)
        local alert   = Storage.alertLevel(i)
        local ac      = alert_colors[alert] or colors.white
        local icon    = cat and cat.icon or "?"
        local name    = cat and cat.name or ("Ctrl_" .. i)

        -- Nombre del módulo
        dash.setTextColor(ac)
        dash.setCursorPos(col2_x, y)
        local label = string.format("%s %s", icon, name)
        if #label > (w - col2_x) then label = label:sub(1, w - col2_x) end
        dash.write(label)

        -- Barra de uso
        dash.setCursorPos(col2_x, y + 1)
        dash.setTextColor(ac)
        local filled = math.floor(stats.avg_pct * bar_w)
        dash.write("[")
        dash.write(string.rep("|", filled))
        dash.setTextColor(colors.gray)
        dash.write(string.rep("-", bar_w - filled))
        dash.setTextColor(ac)
        dash.write("]")
        dash.setTextColor(colors.white)
        dash.write(string.format(" %3d%%", math.floor(stats.avg_pct * 100)))
    end

    -- ── FOOTER ──────────────────────────────────────────────
    dash.setBackgroundColor(colors.gray)
    dash.setTextColor(colors.white)
    dash.setCursorPos(1, h)
    dash.write(string.rep(" ", w))
    dash.setCursorPos(2, h)
    local elapsed = math.floor(os.clock() - session.start_time)
    local mins = math.floor(elapsed / 60)
    local secs = elapsed % 60
    dash.write(string.format("Total movidos: %d | Runs: %d | Uptime: %02d:%02d",
        session.total_moved,
        session.total_runs,
        mins, secs))
    dash.setBackgroundColor(colors.black)
end

-- ============================================================
--  Actualizar stats de sesión
-- ============================================================
function Dashboard.updateSession(moved)
    session.total_moved = session.total_moved + (moved or 0)
    session.total_runs  = session.total_runs  + 1
end

-- ============================================================
--  Pantalla de espera (idle)
-- ============================================================
function Dashboard.idle()
    if not init() then return end
    local w, h = dash.getSize()

    dash.setBackgroundColor(colors.black)
    dash.clear()

    dash.setBackgroundColor(colors.blue)
    dash.setTextColor(colors.white)
    dash.setCursorPos(1, 1)
    dash.write(string.rep(" ", w))
    dash.setCursorPos(2, 1)
    dash.write("[ INVENTORY SORTER ]")
    dash.setBackgroundColor(colors.black)

    dash.setTextColor(colors.gray)
    dash.setCursorPos(2, 3)
    dash.write("Estado: En espera...")
    dash.setCursorPos(2, 4)
    dash.write("Proximo scan en breve")

    -- Mostrar estado de controllers aunque este idle
    for i = 0, 4 do
        local cat_key = categories.controllers[i]
        local cat     = categories.categories[cat_key]
        local stats   = Storage.stats(i)
        local alert   = Storage.alertLevel(i)

        local alert_col = {
            ok="verde", upgrade="amarillo", expand="naranja", critical="rojo"
        }
        local col = { ok=colors.green, upgrade=colors.yellow,
                      expand=colors.orange, critical=colors.red }

        dash.setTextColor(col[alert] or colors.white)
        dash.setCursorPos(2, 6 + i)
        local icon = cat and cat.icon or "?"
        local name = cat and cat.name or ("Ctrl_"..i)
        dash.write(string.format("%s %-14s %3d%%  [%s]",
            icon, name,
            math.floor(stats.avg_pct * 100),
            alert:upper()))
    end

    dash.setBackgroundColor(colors.gray)
    dash.setTextColor(colors.white)
    dash.setCursorPos(1, h)
    dash.write(string.rep(" ", w))
    dash.setCursorPos(2, h)
    local elapsed = math.floor(os.clock() - session.start_time)
    local mins = math.floor(elapsed / 60)
    local secs = elapsed % 60
    dash.write(string.format("Movidos: %d | Runs: %d | Uptime: %02d:%02d",
        session.total_moved, session.total_runs, mins, secs))
    dash.setBackgroundColor(colors.black)
end

return Dashboard
