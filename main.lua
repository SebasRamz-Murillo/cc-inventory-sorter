-- ============================================================
--  main.lua
--  Loop principal del sistema de clasificación
--  Orquesta storage, classifier, monitors y dashboard
-- ============================================================

-- Agregar la carpeta del sorter al path de Lua
local base_path = fs.getDir(shell.getRunningProgram())
package.path = base_path .. "/?.lua;" ..
               base_path .. "/?/init.lua;" ..
               package.path

local Storage    = require("lib.storage")
local Classifier = require("lib.classifier")
local Monitor    = require("lib.monitor")
local Dashboard  = require("lib.dashboard")

-- ============================================================
--  CONFIG
-- ============================================================
local SOURCE_CONTROLLER = 5     -- El controller desordenado
local SCAN_INTERVAL     = 10    -- Segundos entre scans automáticos
local IDLE_UPDATE       = 30    -- Segundos entre updates en idle

-- ============================================================
--  Utilidades de consola
-- ============================================================
local function log(msg)
    local time = textutils.formatTime(os.time(), true)
    print(string.format("[%s] %s", time, msg))
end

local function clear()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
end

-- ============================================================
--  Verificar que todos los peripherals están conectados
-- ============================================================
local function checkPeripherals()
    local ok = true
    log("Verificando conexiones...")

    for i = 0, 5 do
        local name = "storagedrawers:controller_" .. i
        if peripheral.isPresent(name) then
            log("  OK: " .. name)
        else
            log("  ERROR: " .. name .. " no encontrado")
            ok = false
        end
    end

    for i = 0, 5 do
        local name = "monitor_" .. i
        if peripheral.isPresent(name) then
            log("  OK: " .. name)
        else
            log("  WARN: " .. name .. " no encontrado (no critico)")
        end
    end

    return ok
end

-- ============================================================
--  Un ciclo de clasificación completo
-- ============================================================
local function runSort()
    log("=== Iniciando clasificacion ===")

    -- Contar items en la fuente
    local source_items = Storage.list(SOURCE_CONTROLLER)
    local item_count   = 0
    for _ in pairs(source_items) do item_count = item_count + 1 end

    if item_count == 0 then
        log("Fuente vacia, nada que clasificar")
        Dashboard.idle()
        Monitor.updateAll()
        return
    end

    log(string.format("Items a clasificar: %d slots", item_count))

    -- Variables de progreso
    local moved_total = 0
    local processed   = 0

    -- Callback para actualizar UI en tiempo real
    local function onItemProcessed(result, total_moved, total_skip, total_proc)
        processed     = total_proc
        moved_total   = total_moved

        if result.moved > 0 then
            -- Actualizar dashboard con el item actual
            Dashboard.logMove(result)
            Dashboard.draw(result, processed, item_count, nil)

            -- Log en consola
            local short = result.item_name:match(":(.+)$") or result.item_name
            log(string.format("  %s x%d -> ctrl_%d [%s]",
                short, result.moved, result.dest_controller, result.category))
        end
    end

    -- Clasificar todo
    local run_result = Classifier.processAll(SOURCE_CONTROLLER, onItemProcessed)

    -- Actualizar estadísticas
    Dashboard.updateSession(run_result.total_moved)

    log(string.format("=== Clasificacion completa ==="))
    log(string.format("  Movidos:  %d items", run_result.total_moved))
    log(string.format("  Saltados: %d slots", run_result.total_skipped))

    -- Actualizar todos los monitores pequeños
    Monitor.updateAll()

    -- Dashboard en idle
    Dashboard.idle()

    -- Verificar alertas y flashear monitores con problemas
    for i = 0, 4 do
        local alert = Storage.alertLevel(i)
        if alert == "critical" then
            Monitor.flash(i, 5)
        elseif alert == "expand" then
            Monitor.flash(i, 2)
        end
    end
end

-- ============================================================
--  MAIN
-- ============================================================
clear()
print("========================================")
print("       INVENTORY SORTER v1.0")
print("       Create: Skies Above")
print("========================================")
print("")

-- Verificar conexiones
if not checkPeripherals() then
    print("")
    print("ERROR: Faltan peripherals. Revisa los modems.")
    print("Presiona cualquier tecla para continuar de todos modos...")
    os.pullEvent("key")
end

print("")
print("Iniciando sistema...")
print("Presiona [Q] para salir")
print("Presiona [S] para forzar un scan ahora")
print("")

-- Actualizar monitores al arrancar
Monitor.updateAll()
Dashboard.idle()

log("Sistema listo. Scan automatico cada " .. SCAN_INTERVAL .. "s")

-- ============================================================
--  Loop principal con timer y input de teclado
-- ============================================================
local scan_timer  = os.startTimer(SCAN_INTERVAL)
local idle_timer  = os.startTimer(IDLE_UPDATE)

while true do
    local event, p1 = os.pullEvent()

    if event == "timer" then
        if p1 == scan_timer then
            -- Scan automático
            runSort()
            scan_timer = os.startTimer(SCAN_INTERVAL)

        elseif p1 == idle_timer then
            -- Actualizar monitores en idle
            Monitor.updateAll()
            Dashboard.idle()
            idle_timer = os.startTimer(IDLE_UPDATE)
        end

    elseif event == "key" then
        local key = p1

        -- Q = salir
        if key == keys.q then
            log("Saliendo...")
            -- Limpiar monitores
            for i = 0, 4 do
                local m = peripheral.wrap("monitor_" .. i)
                if m then m.clear() end
            end
            local d = peripheral.wrap("monitor_5")
            if d then d.clear() end
            break

        -- S = scan manual inmediato
        elseif key == keys.s then
            log("Scan manual iniciado")
            os.cancelTimer(scan_timer)
            runSort()
            scan_timer = os.startTimer(SCAN_INTERVAL)
        end

    elseif event == "terminate" then
        log("Terminado por el usuario")
        break
    end
end

print("Sistema detenido.")
