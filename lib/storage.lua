-- ============================================================
--  lib/storage.lua
--  Wrapper para los Drawer Controllers
--  Maneja toda la comunicación con los peripherals
-- ============================================================

local Storage = {}

-- Nombres de los controllers
local CONTROLLERS = {
    [0] = "storagedrawers:controller_0",
    [1] = "storagedrawers:controller_1",
    [2] = "storagedrawers:controller_2",
    [3] = "storagedrawers:controller_3",
    [4] = "storagedrawers:controller_4",
    [5] = "storagedrawers:controller_5", -- FUENTE
}

local BASE_LIMIT   = 512
local MAX_LIMIT    = 114688

-- Cache de peripherals para no hacer wrap() cada vez
local cache = {}

-- ============================================================
--  Obtener peripheral (con cache)
-- ============================================================
function Storage.get(index)
    if not cache[index] then
        local name = CONTROLLERS[index]
        if not name then
            error("Controller index " .. index .. " no existe")
        end
        local p = peripheral.wrap(name)
        if not p then
            error("No se pudo conectar a " .. name .. ". ¿Está el modem encendido?")
        end
        cache[index] = p
    end
    return cache[index]
end

-- ============================================================
--  Listar todos los items de un controller
--  Retorna: { slot = { name, count, limit, pct, maxed } }
-- ============================================================
function Storage.list(index)
    local p      = Storage.get(index)
    local items  = p.list()
    local result = {}

    for slot, item in pairs(items) do
        local limit = p.getItemLimit(slot)
        local pct   = item.count / limit

        result[slot] = {
            name   = item.name,
            count  = item.count,
            limit  = limit,
            pct    = pct,
            maxed  = (limit >= MAX_LIMIT),   -- ya tiene todos los upgrades
            full   = (item.count >= limit),   -- drawer lleno
        }
    end

    return result
end

-- ============================================================
--  Obtener estadísticas generales de un controller
--  Retorna: { total_slots, used_slots, full_slots, maxed_full_slots, avg_pct }
-- ============================================================
function Storage.stats(index)
    local p          = Storage.get(index)
    local items      = Storage.list(index)
    local total      = p.size()
    local used       = 0
    local full       = 0
    local maxed_full = 0
    local pct_sum    = 0

    for _, item in pairs(items) do
        used     = used + 1
        pct_sum  = pct_sum + item.pct

        if item.full then
            full = full + 1
            if item.maxed then
                maxed_full = maxed_full + 1
            end
        end
    end

    local avg_pct = used > 0 and (pct_sum / used) or 0

    return {
        total_slots    = total,
        used_slots     = used,
        empty_slots    = total - used,
        full_slots     = full,
        maxed_full     = maxed_full,   -- llenos Y con upgrades máximos → expandir
        needs_upgrade  = full - maxed_full, -- llenos pero sin upgrades máximos
        avg_pct        = avg_pct,
        pct            = used > 0 and avg_pct or 0,
    }
end

-- ============================================================
--  Estado de alerta de un controller
--  Retorna: "ok" | "upgrade" | "expand" | "critical"
-- ============================================================
function Storage.alertLevel(index)
    local s = Storage.stats(index)

    if s.maxed_full > 0 and s.empty_slots == 0 then
        return "critical"   -- lleno Y sin espacio para más drawers
    elseif s.maxed_full > 0 then
        return "expand"     -- algunos drawers con upgrades máximos llenos
    elseif s.needs_upgrade > 0 then
        return "upgrade"    -- drawers llenos pero pueden recibir upgrades
    else
        return "ok"
    end
end

-- ============================================================
--  Mover items de un controller a otro
--  source_index: controller origen
--  dest_index:   controller destino
--  slot:         slot en el origen
--  count:        cantidad a mover (nil = todo)
--  Retorna: cantidad movida
-- ============================================================
function Storage.move(source_index, dest_index, slot, count)
    local source      = Storage.get(source_index)
    local dest_name   = CONTROLLERS[dest_index]

    if not dest_name then
        return 0, "Destino inválido"
    end

    local moved = source.pushItems(dest_name, slot, count)
    return moved
end

-- ============================================================
--  Buscar si un item ya existe en un controller destino
--  Retorna: slot donde existe, o nil si no existe
-- ============================================================
function Storage.findItem(index, item_name)
    local items = Storage.list(index)
    for slot, item in pairs(items) do
        if item.name == item_name then
            return slot
        end
    end
    return nil
end

-- ============================================================
--  Verificar si hay espacio en un controller para un item
--  (hay un slot vacío o el item ya existe y no está full)
-- ============================================================
function Storage.hasSpace(index, item_name)
    local p     = Storage.get(index)
    local stats = Storage.stats(index)

    -- Si hay slots vacíos, cabe
    if stats.empty_slots > 0 then
        return true
    end

    -- Si el item ya existe y no está lleno, cabe
    local existing = Storage.findItem(index, item_name)
    if existing then
        local items = Storage.list(index)
        if items[existing] and not items[existing].full then
            return true
        end
    end

    return false
end

return Storage
