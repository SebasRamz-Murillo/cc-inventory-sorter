-- ============================================================
--  lib/monitor.lua
--  Maneja los monitores 2x3 de cada módulo de drawers
--  Muestra estado y alertas de cada controller
-- ============================================================

local Storage    = require("lib.storage")
local categories = require("data.categories")

local Monitor = {}

-- Colores según nivel de alerta
local ALERT_COLORS = {
    ok       = { bg = colors.black,  fg = colors.green,  label = "OK",       symbol = "[OK]"  },
    upgrade  = { bg = colors.black,  fg = colors.yellow, label = "UPGRADE",  symbol = "[!!]"  },
    expand   = { bg = colors.black,  fg = colors.orange, label = "EXPAND",   symbol = "[!!!]" },
    critical = { bg = colors.black,  fg = colors.red,    label = "CRITICAL", symbol = "[!!!]" },
}

-- Obtener peripheral de monitor
local mon_cache = {}
local function getMonitor(index)
    if not mon_cache[index] then
        local name = "monitor_" .. index
        local m = peripheral.wrap(name)
        if m then
            m.setTextScale(0.5)
            mon_cache[index] = m
        end
    end
    return mon_cache[index]
end

-- Dibujar barra de progreso
local function drawBar(m, x, y, width, pct, color_fill, color_empty)
    local filled = math.floor(pct * width)
    m.setCursorPos(x, y)
    m.setTextColor(color_fill)
    m.write(string.rep("|", filled))
    m.setTextColor(color_empty or colors.gray)
    m.write(string.rep("-", width - filled))
end

-- Centrar texto en una línea
local function centerText(m, y, text, width)
    local x = math.floor((width - #text) / 2) + 1
    m.setCursorPos(x, y)
    m.write(text)
end

-- ============================================================
--  Actualizar UN monitor (para controller index 0-4)
-- ============================================================
function Monitor.update(controller_index)
    local m = getMonitor(controller_index)
    if not m then return end

    local w, h = m.getSize()
    m.setBackgroundColor(colors.black)
    m.clear()

    -- Obtener datos
    local stats = Storage.stats(controller_index)
    local alert = Storage.alertLevel(controller_index)
    local ac    = ALERT_COLORS[alert]

    -- Obtener nombre de categoría
    local cat_key = categories.controllers[controller_index]
    local cat     = categories.categories[cat_key]
    local cat_name = cat and cat.name or "Módulo " .. controller_index
    local cat_icon = cat and cat.icon or "?"

    -- ── Línea 1: Título ──────────────────────────────────────
    m.setBackgroundColor(ac.fg)
    m.setTextColor(colors.black)
    m.setCursorPos(1, 1)
    m.write(string.rep(" ", w))
    centerText(m, 1, cat_icon .. " " .. cat_name:upper(), w)

    -- ── Línea 2: Slots usados ────────────────────────────────
    m.setBackgroundColor(colors.black)
    m.setTextColor(colors.white)
    m.setCursorPos(1, 2)
    local slot_text = string.format("Slots: %d/%d", stats.used_slots, stats.total_slots)
    m.write(slot_text)

    -- ── Línea 3: Barra de uso promedio ───────────────────────
    m.setCursorPos(1, 3)
    m.setTextColor(colors.lightGray)
    m.write("Uso:")
    drawBar(m, 5, 3, w - 9, stats.avg_pct, ac.fg, colors.gray)
    m.setTextColor(colors.white)
    m.setCursorPos(w - 3, 3)
    m.write(string.format("%3d%%", math.floor(stats.avg_pct * 100)))

    -- ── Línea 4: Estado de alertas ───────────────────────────
    m.setCursorPos(1, 4)
    if alert == "ok" then
        m.setTextColor(colors.green)
        m.write("Estado: Todo bien")
    elseif alert == "upgrade" then
        m.setTextColor(colors.yellow)
        m.write(string.format("!! %d drawer(s) llenos", stats.needs_upgrade))
    elseif alert == "expand" then
        m.setTextColor(colors.orange)
        m.write(string.format("!! %d drawer(s) al maximo", stats.maxed_full))
    elseif alert == "critical" then
        m.setTextColor(colors.red)
        m.write("!! SIN ESPACIO LIBRE")
    end

    -- ── Línea 5: Recomendación ───────────────────────────────
    m.setTextColor(colors.lightGray)
    m.setCursorPos(1, 5)
    if alert == "ok" then
        m.setTextColor(colors.gray)
        m.write("Sin acciones necesarias")
    elseif alert == "upgrade" then
        m.setTextColor(colors.yellow)
        m.write("-> Agregar upgrades")
    elseif alert == "expand" then
        m.setTextColor(colors.orange)
        m.write("-> Agregar mas drawers")
    elseif alert == "critical" then
        m.setTextColor(colors.red)
        m.write("-> EXPANDIR MODULO YA")
    end

    -- ── Línea 6: Footer con timestamp ───────────────────────
    m.setBackgroundColor(colors.gray)
    m.setTextColor(colors.white)
    m.setCursorPos(1, 6)
    m.write(string.rep(" ", w))
    local time_str = textutils.formatTime(os.time(), true)
    centerText(m, 6, "Act: " .. time_str, w)
    m.setBackgroundColor(colors.black)
end

-- ============================================================
--  Actualizar todos los monitores (0-4)
-- ============================================================
function Monitor.updateAll()
    for i = 0, 4 do
        Monitor.update(i)
    end
end

-- ============================================================
--  Flash de alerta en un monitor (parpadeo)
-- ============================================================
function Monitor.flash(controller_index, times)
    local m = getMonitor(controller_index)
    if not m then return end
    times = times or 3

    for i = 1, times do
        m.setBackgroundColor(colors.red)
        m.clear()
        os.sleep(0.2)
        m.setBackgroundColor(colors.black)
        m.clear()
        os.sleep(0.2)
    end

    Monitor.update(controller_index)
end

return Monitor
