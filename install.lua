-- ============================================================
--  install.lua
--  Descarga el sistema completo desde GitHub
--  Uso: wget run https://raw.githubusercontent.com/SebasRamz-Murillo/cc-inventory-sorter/main/install.lua
-- ============================================================

local REPO = "https://raw.githubusercontent.com/SebasRamz-Murillo/cc-inventory-sorter/main"

local files = {
    { url = REPO .. "/main.lua",              path = "/disk/sorter/main.lua"              },
    { url = REPO .. "/startup.lua",           path = "/startup.lua"                        },
    { url = REPO .. "/lib/storage.lua",       path = "/disk/sorter/lib/storage.lua"       },
    { url = REPO .. "/lib/classifier.lua",    path = "/disk/sorter/lib/classifier.lua"    },
    { url = REPO .. "/lib/monitor.lua",       path = "/disk/sorter/lib/monitor.lua"       },
    { url = REPO .. "/lib/dashboard.lua",     path = "/disk/sorter/lib/dashboard.lua"     },
    { url = REPO .. "/data/categories.lua",   path = "/disk/sorter/data/categories.lua"   },
}

-- Crear directorios
local function mkdirs()
    local dirs = {
        "/disk/sorter",
        "/disk/sorter/lib",
        "/disk/sorter/data",
    }
    for _, dir in ipairs(dirs) do
        if not fs.exists(dir) then
            fs.makeDir(dir)
        end
    end
end

-- Descargar un archivo
local function download(url, path)
    local res = http.get(url)
    if not res then
        return false, "No se pudo descargar: " .. url
    end
    local content = res.readAll()
    res.close()

    local f = fs.open(path, "w")
    f.write(content)
    f.close()
    return true
end

-- ── Main ────────────────────────────────────────────────────
term.setTextColor(colors.yellow)
print("========================================")
print("   INVENTORY SORTER - Installer")
print("   SebasRamz-Murillo/cc-inventory-sorter")
print("========================================")
term.setTextColor(colors.white)
print("")

-- Verificar HTTP
if not http then
    term.setTextColor(colors.red)
    print("ERROR: HTTP no esta habilitado.")
    print("Activa http en CC:Tweaked config.")
    return
end

print("Creando directorios...")
mkdirs()
print("")

local ok_count   = 0
local fail_count = 0

for _, file in ipairs(files) do
    term.setTextColor(colors.lightGray)
    io.write("  Descargando " .. file.path .. "... ")

    local ok, err = download(file.url, file.path)
    if ok then
        term.setTextColor(colors.green)
        print("OK")
        ok_count = ok_count + 1
    else
        term.setTextColor(colors.red)
        print("FALLO")
        print("    " .. (err or ""))
        fail_count = fail_count + 1
    end
end

print("")
if fail_count == 0 then
    term.setTextColor(colors.green)
    print("Instalacion completa! (" .. ok_count .. " archivos)")
    term.setTextColor(colors.white)
    print("")
    print("Reinicia la computadora para arrancar")
    print("o corre: /disk/sorter/main.lua")
else
    term.setTextColor(colors.yellow)
    print(string.format("Completo con %d errores (%d/%d archivos)",
        fail_count, ok_count, ok_count + fail_count))
    term.setTextColor(colors.white)
    print("Revisa tu conexion o el repo de GitHub")
end

term.setTextColor(colors.white)