-- ============================================================
--  startup.lua
--  Se ejecuta automáticamente al encender la computadora
--  Colócalo en la raíz: /startup.lua
-- ============================================================

-- Esperar un momento para que los peripherals se inicialicen
os.sleep(1)

-- Lanzar el sorter
shell.run("/disk/sorter/main.lua")
