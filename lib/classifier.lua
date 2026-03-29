-- ============================================================
--  lib/classifier.lua
--  Lógica de clasificación de items
--  Determina a qué controller va cada item
-- ============================================================

local categories = require("data.categories")
local Storage    = require("lib.storage")

local Classifier = {}

-- ============================================================
--  Clasificar un item por su nombre
--  Retorna: nombre de categoría, índice de controller destino
-- ============================================================
function Classifier.classify(item_name)
    local name_lower = item_name:lower()

    -- Recorrer en orden de prioridad
    for _, cat_key in ipairs(categories.priority) do
        local cat = categories.categories[cat_key]

        -- 1. Buscar en exact (más preciso)
        for _, exact in ipairs(cat.exact) do
            if name_lower == exact:lower() then
                return cat_key, cat.controller
            end
        end

        -- 2. Buscar en patterns (más flexible)
        for _, pattern in ipairs(cat.patterns) do
            if name_lower:find(pattern:lower(), 1, true) then
                return cat_key, cat.controller
            end
        end
    end

    -- Si no matchea nada → overflow
    local overflow = categories.categories.overflow
    return "overflow", overflow.controller
end

-- ============================================================
--  Procesar UN slot del controller fuente
--  Retorna: { item_name, count, category, dest_controller, moved, skipped }
-- ============================================================
function Classifier.processSlot(source_index, slot, item)
    local cat_key, dest_index = Classifier.classify(item.name)

    -- No mover si el destino es el mismo que el origen
    if dest_index == source_index then
        return {
            item_name       = item.name,
            count           = item.count,
            category        = cat_key,
            dest_controller = dest_index,
            moved           = 0,
            skipped         = true,
            reason          = "mismo controller",
        }
    end

    -- Verificar si hay espacio en destino
    if not Storage.hasSpace(dest_index, item.name) then
        return {
            item_name       = item.name,
            count           = item.count,
            category        = cat_key,
            dest_controller = dest_index,
            moved           = 0,
            skipped         = true,
            reason          = "sin espacio en destino",
        }
    end

    -- Mover
    local moved = Storage.move(source_index, dest_index, slot, item.count)

    return {
        item_name       = item.name,
        count           = item.count,
        category        = cat_key,
        dest_controller = dest_index,
        moved           = moved,
        skipped         = false,
        reason          = moved > 0 and "ok" or "fallo al mover",
    }
end

-- ============================================================
--  Procesar TODO el controller fuente
--  callback(result): llamado por cada item procesado (para UI)
--  Retorna: { total_items, total_moved, total_skipped, results }
-- ============================================================
function Classifier.processAll(source_index, callback)
    local items       = Storage.list(source_index)
    local total_moved = 0
    local total_skip  = 0
    local results     = {}

    for slot, item in pairs(items) do
        local result = Classifier.processSlot(source_index, slot, item)
        table.insert(results, result)

        if result.moved > 0 then
            total_moved = total_moved + result.moved
        else
            total_skip = total_skip + 1
        end

        -- Llamar callback para actualizar UI en tiempo real
        if callback then
            callback(result, total_moved, total_skip, #results)
        end

        -- Pequeña pausa para no saturar el juego
        os.sleep(0.05)
    end

    return {
        total_items  = #results,
        total_moved  = total_moved,
        total_skipped = total_skip,
        results      = results,
    }
end

return Classifier
