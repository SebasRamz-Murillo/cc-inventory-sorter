-- ============================================================
--  reorganize.lua
--  1. Recorre los controllers 0-4 y saca items mal clasificados
--  2. Consolida items duplicados en un solo slot
--  3. Mueve todo al controller_5 (fuente) y deja que el
--     sorter principal lo reclasifique correctamente
--
--  Uso: shell.run("/disk/sorter/reorganize.lua")
-- ============================================================

-- Path setup
local base_path = fs.getDir(shell.getRunningProgram())
package.path = base_path .. "/?.lua;" .. base_path .. "/?/init.lua;" .. package.path

local categories = require("data.categories")

local TEMP_CONTROLLER = 5  -- destino temporal (fuente)
local MON_NAME        = "monitor_5"

-- ── Monitor ─────────────────────────────────────────────────
local mon = peripheral.wrap(MON_NAME)
if mon then mon.setTextScale(0.5) end

local mon_lines = {}
local function monPrint(text, color)
    if not mon then return end
    local w, h = mon.getSize()
    table.insert(mon_lines, { text = text, color = color or colors.white })
    while #mon_lines > (h - 3) do table.remove(mon_lines, 1) end
    mon.setBackgroundColor(colors.black)
    mon.clear()
    -- Header
    mon.setBackgroundColor(colors.purple)
    mon.setTextColor(colors.white)
    mon.setCursorPos(1, 1)
    mon.write(string.rep(" ", w))
    mon.setCursorPos(2, 1)
    mon.write("[ REORGANIZANDO ]")
    mon.setBackgroundColor(colors.black)
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
    mon.write("Reorganizando inventario...")
    mon.setBackgroundColor(colors.black)
end

-- ── Log en consola ───────────────────────────────────────────
local function log(msg, color)
    local time = textutils.formatTime(os.time(), true)
    if color then term.setTextColor(color) end
    print(string.format("[%s] %s", time, msg))
    term.setTextColor(colors.white)
    monPrint(msg, color)
end

-- ── Clasificador inline (sin require de classifier) ──────────
local function classify(item_name)
    local name_lower = item_name:lower()
    for _, cat_key in ipairs(categories.priority) do
        local cat = categories.categories[cat_key]
        for _, exact in ipairs(cat.exact) do
            if name_lower == exact:lower() then
                return cat_key, cat.controller
            end
        end
        for _, pattern in ipairs(cat.patterns) do
            if name_lower:find(pattern:lower(), 1, true) then
                return cat_key, cat.controller
            end
        end
    end
    return "overflow", categories.categories.overflow.controller
end

-- ── Obtener peripheral con validación ───────────────────────
local function getCtrl(index)
    local name = "storagedrawers:controller_" .. index
    local p = peripheral.wrap(name)
    if not p then
        log("ERROR: No se pudo conectar a " .. name, colors.red)
        return nil
    end
    return p, name
end

-- ============================================================
--  PASO 1: Sacar items mal clasificados de cada controller
-- ============================================================
local function reclassify()
    log("=== PASO 1: Reclasificando controllers ===", colors.yellow)
    local total_moved = 0

    for ctrl_i = 0, 4 do
        local p, p_name = getCtrl(ctrl_i)
        if not p then goto continue_ctrl end

        local cat_key     = categories.controllers[ctrl_i]
        local expected_ctrl = categories.categories[cat_key].controller
        local items       = p.list()
        local moved_here  = 0

        log(string.format("Revisando ctrl_%d [%s]...", ctrl_i, cat_key), colors.lightGray)

        for slot, item in pairs(items) do
            local _, correct_ctrl = classify(item.name)

            -- Si el item NO pertenece a este controller → moverlo al temp
            if correct_ctrl ~= ctrl_i then
                local short = item.name:match(":(.+)$") or item.name
                local dest_name = "storagedrawers:controller_" .. TEMP_CONTROLLER
                local moved = p.pushItems(dest_name, slot, item.count)

                if moved > 0 then
                    moved_here  = moved_here  + 1
                    total_moved = total_moved + 1
                    log(string.format("  SACADO: %s x%d -> temp [deberia: ctrl_%d]",
                        short, moved, correct_ctrl), colors.orange)
                end

                os.sleep(0.05)
            end
        end

        if moved_here == 0 then
            log(string.format("  ctrl_%d OK, nada fuera de lugar", ctrl_i), colors.green)
        else
            log(string.format("  ctrl_%d: %d slots movidos al temp", ctrl_i, moved_here), colors.yellow)
        end

        ::continue_ctrl::
    end

    log(string.format("Paso 1 completo. %d slots enviados al temp.", total_moved), colors.green)
    return total_moved
end

-- ============================================================
--  PASO 2: Consolidar slots duplicados en cada controller
--  (mismo item en varios slots → juntarlos)
-- ============================================================
local function consolidate()
    log("=== PASO 2: Consolidando slots duplicados ===", colors.yellow)
    local total_consolidated = 0

    for ctrl_i = 0, 5 do
        local p, p_name = getCtrl(ctrl_i)
        if not p then goto continue_cons end

        local items   = p.list()
        local label   = ctrl_i == 5 and "temp/fuente" or ("ctrl_" .. ctrl_i)

        -- Agrupar slots por item name
        local by_item = {}
        for slot, item in pairs(items) do
            if not by_item[item.name] then
                by_item[item.name] = {}
            end
            table.insert(by_item[item.name], { slot = slot, count = item.count })
        end

        local consolidated_here = 0

        for item_name, slots in pairs(by_item) do
            -- Solo hay algo que consolidar si hay 2+ slots del mismo item
            if #slots > 1 then
                local short = item_name:match(":(.+)$") or item_name

                -- Ordenar por cantidad descendente (el más lleno primero = destino)
                table.sort(slots, function(a, b) return a.count > b.count end)

                local main_slot = slots[1].slot

                -- Mover todos los otros slots hacia el slot principal
                for i = 2, #slots do
                    local src_slot = slots[i].slot
                    local src_count = slots[i].count

                    -- pushItems de src_slot a main_slot dentro del mismo controller
                    -- En CC:Tweaked, pushItems puede apuntar al mismo peripheral
                    local moved = p.pushItems(p_name, src_slot, src_count, main_slot)

                    if moved and moved > 0 then
                        consolidated_here = consolidated_here + 1
                        total_consolidated = total_consolidated + 1
                        log(string.format("  [%s] %s: slot %d -> slot %d (%d items)",
                            label, short, src_slot, main_slot, moved), colors.cyan)
                    end

                    os.sleep(0.05)
                end
            end
        end

        if consolidated_here == 0 then
            log(string.format("  %s: sin duplicados", label), colors.green)
        else
            log(string.format("  %s: %d merges realizados", label, consolidated_here), colors.cyan)
        end

        ::continue_cons::
    end

    log(string.format("Paso 2 completo. %d consolidaciones.", total_consolidated), colors.green)
    return total_consolidated
end

-- ============================================================
--  PASO 3: Recordatorio de correr el sorter principal
-- ============================================================
local function remindSort()
    log("", colors.white)
    log("=== PASO 3: Listo para re-clasificar ===", colors.yellow)
    log("Los items mal clasificados estan en ctrl_5 (temp).", colors.white)
    log("Corre el sorter principal para clasificarlos:", colors.white)
    log("  shell.run('/disk/sorter/main.lua')", colors.cyan)
    log("O presiona [S] en el main si ya esta corriendo.", colors.cyan)
end

-- ============================================================
--  MAIN
-- ============================================================
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)

print("========================================")
print("       REORGANIZADOR DE INVENTARIO")
print("========================================")
print("")
print("Este script hara 2 cosas:")
print("  1. Sacar items mal clasificados de cada modulo")
print("  2. Consolidar items duplicados en un solo slot")
print("")
print("Los items sacados iran al ctrl_5 (temp) para")
print("que el sorter principal los reclasifique.")
print("")
print("Presiona [R] para reorganizar, [Q] para salir")
print("")

monPrint("Listo. Presiona [R] para reorganizar.", colors.green)

while true do
    local event, key = os.pullEvent("key")

    if key == keys.r then
        log("Iniciando reorganizacion...", colors.yellow)

        local moved      = reclassify()
        local merged     = consolidate()
        remindSort()

        log("", colors.white)
        log(string.format("RESUMEN: %d items movidos, %d slots consolidados",
            moved, merged), colors.green)
        log("Presiona [Q] para salir.", colors.white)

    elseif key == keys.q then
        log("Saliendo...")
        if mon then mon.clear() end
        break
    end
end

print("Reorganizador detenido.")