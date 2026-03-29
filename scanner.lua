-- ============================================================
--  scanner.lua
--  Escanea TODOS los items del controller_5 (fuente)
--  y de todos los controllers (0-5), guarda los IDs únicos
--  en /disk/sorter/logs/items.log y los muestra en monitor_5
--
--  Uso: shell.run("/disk/sorter/scanner.lua")
--  O presiona [S] para escanear, [Q] para salir
-- ============================================================

local SOURCE   = 5
local LOG_FILE = "/disk/sorter/logs/items.log"
local MON_NAME = "monitor_5"

-- ── Crear directorio de logs si no existe ───────────────────
if not fs.exists("/disk/sorter/logs") then
    fs.makeDir("/disk/sorter/logs")
end

-- ── Monitor ─────────────────────────────────────────────────
local mon = peripheral.wrap(MON_NAME)
if mon then
    mon.setTextScale(0.5)
end

-- ── Utilidades ──────────────────────────────────────────────
local function log(msg)
    local time = textutils.formatTime(os.time(), true)
    print(string.format("[%s] %s", time, msg))
end

-- Escribir en monitor con scroll automático
local mon_lines = {}
local function monPrint(text, color)
    if not mon then return end
    local w, h = mon.getSize()
    table.insert(mon_lines, { text = text, color = color or colors.white })
    -- Mantener solo las últimas h-3 líneas
    while #mon_lines > (h - 3) do
        table.remove(mon_lines, 1)
    end
    -- Redibujar
    mon.setBackgroundColor(colors.black)
    mon.clear()
    -- Header
    mon.setBackgroundColor(colors.blue)
    mon.setTextColor(colors.white)
    mon.setCursorPos(1, 1)
    mon.write(string.rep(" ", w))
    mon.setCursorPos(2, 1)
    mon.write("[ ITEM SCANNER ]")
    mon.setCursorPos(w - 7, 1)
    mon.write(textutils.formatTime(os.time(), true))
    mon.setBackgroundColor(colors.black)
    -- Líneas
    for i, line in ipairs(mon_lines) do
        mon.setTextColor(line.color or colors.white)
        mon.setCursorPos(1, i + 1)
        local t = line.text
        if #t > w then t = t:sub(1, w) end
        mon.write(t)
    end
    -- Footer
    mon.setBackgroundColor(colors.gray)
    mon.setTextColor(colors.white)
    mon.setCursorPos(1, h)
    mon.write(string.rep(" ", w))
    mon.setCursorPos(2, h)
    mon.write("[S]scan [Q]salir")
    mon.setBackgroundColor(colors.black)
end

-- ── Escanear todos los controllers ──────────────────────────
local function scanAll()
    log("Escaneando todos los controllers...")
    monPrint("=== SCAN INICIADO ===", colors.yellow)

    -- Tabla de IDs únicos: { [item_name] = { count, controllers[] } }
    local unique = {}

    for ctrl_i = 0, 5 do
        local name = "storagedrawers:controller_" .. ctrl_i
        if peripheral.isPresent(name) then
            local p     = peripheral.wrap(name)
            local items = p.list()
            local label = ctrl_i == 5 and "FUENTE" or ("ctrl_" .. ctrl_i)

            monPrint(string.format("Escaneando %s...", label), colors.lightGray)

            for slot, item in pairs(items) do
                if not unique[item.name] then
                    unique[item.name] = { count = 0, controllers = {} }
                end
                unique[item.name].count = unique[item.name].count + item.count
                -- Agregar controller si no está ya
                local found = false
                for _, c in ipairs(unique[item.name].controllers) do
                    if c == ctrl_i then found = true; break end
                end
                if not found then
                    table.insert(unique[item.name].controllers, ctrl_i)
                end
            end
        end
    end

    -- Ordenar por nombre
    local sorted = {}
    for item_name, data in pairs(unique) do
        table.insert(sorted, {
            name        = item_name,
            count       = data.count,
            controllers = data.controllers,
        })
    end
    table.sort(sorted, function(a, b) return a.name < b.name end)

    -- ── Guardar en archivo ───────────────────────────────────
    local f = fs.open(LOG_FILE, "w")
    local timestamp = os.date and os.date("%Y-%m-%d") or textutils.formatTime(os.time(), true)
    f.writeLine("========================================")
    f.writeLine("  ITEM SCAN - " .. timestamp)
    f.writeLine("  Total items unicos: " .. #sorted)
    f.writeLine("========================================")
    f.writeLine("")

    -- Agrupar por mod
    local by_mod = {}
    for _, item in ipairs(sorted) do
        local mod = item.name:match("^([^:]+):") or "unknown"
        if not by_mod[mod] then by_mod[mod] = {} end
        table.insert(by_mod[mod], item)
    end

    -- Ordenar mods
    local mod_keys = {}
    for mod in pairs(by_mod) do table.insert(mod_keys, mod) end
    table.sort(mod_keys)

    for _, mod in ipairs(mod_keys) do
        f.writeLine("── " .. mod:upper() .. " ──")
        for _, item in ipairs(by_mod[mod]) do
            local ctrls = table.concat(item.controllers, ",")
            f.writeLine(string.format("  %-50s  x%-8d  [ctrl: %s]",
                item.name, item.count, ctrls))
        end
        f.writeLine("")
    end

    f.close()

    -- ── Mostrar en monitor y consola ─────────────────────────
    monPrint(string.format("Total: %d items unicos", #sorted), colors.green)
    monPrint("Guardado en: " .. LOG_FILE, colors.cyan)
    monPrint("", colors.white)

    -- Mostrar por mod en monitor
    for _, mod in ipairs(mod_keys) do
        local items_in_mod = by_mod[mod]
        monPrint(string.format("[ %s ] (%d items)", mod:upper(), #items_in_mod), colors.yellow)
        for _, item in ipairs(items_in_mod) do
            local short = item.name:match(":(.+)$") or item.name
            local ctrls = table.concat(item.controllers, ",")
            monPrint(string.format("  %s  x%d  [%s]", short, item.count, ctrls), colors.white)
            -- También imprimir en consola
            log(string.format("  %s  x%d", item.name, item.count))
        end
    end

    monPrint("", colors.white)
    monPrint("=== SCAN COMPLETO ===", colors.green)
    log(string.format("Scan completo. %d items unicos. Log: %s", #sorted, LOG_FILE))

    return #sorted
end

-- ============================================================
--  MAIN
-- ============================================================
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)

print("========================================")
print("       ITEM SCANNER")
print("========================================")
print("")
print("Presiona [S] para escanear")
print("Presiona [Q] para salir")
print("Log se guarda en: " .. LOG_FILE)
print("")

monPrint("Listo. Presiona [S] para escanear.", colors.green)

-- Loop de input
while true do
    local event, key = os.pullEvent("key")

    if key == keys.s then
        scanAll()

    elseif key == keys.q then
        log("Saliendo del scanner")
        if mon then mon.clear() end
        break
    end
end

print("Scanner detenido.")
