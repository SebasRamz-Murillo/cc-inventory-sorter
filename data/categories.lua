-- ============================================================
--  data/categories.lua
--  Librería de clasificación - Basada en scan real del modpack
--  Create: Skies Above + Simple Storage Network + CC:Tweaked
--
--  CÓMO AGREGAR ITEMS:
--  1. Busca la categoría correcta abajo
--  2. Agrega el mod:item_id completo a "exact"
--  3. O agrega un patrón parcial a "patterns" si son muchos
--
--  PATRONES: coinciden si el item ID *contiene* ese texto
--  EXACT:    coincide solo si el item ID es exactamente ese
-- ============================================================

return {

    -- Mapeo controller -> categoría
    controllers = {
        [0] = "overflow",
        [1] = "building",
        [2] = "nature",
        [3] = "metals",
        [4] = "ores",
    },

    -- Orden de prioridad (más específico primero)
    priority = { "ores", "metals", "nature", "building", "overflow" },

    categories = {

        -- =====================================================
        --  ⛏️  ORES & RAW MATERIALS → controller_4
        -- =====================================================
        ores = {
            name       = "Ores & Raw",
            icon       = "*",
            color      = "yellow",
            controller = 4,

            patterns = {
                "_ore",           -- coal_ore, iron_ore, copper_ore, zinc_ore
                "raw_",           -- raw_iron, raw_copper, raw_gold
                "deepslate_",     -- deepslate_iron_ore, etc
                "crushed_raw_",   -- create: crushed_raw_copper, etc
            },

            exact = {
                "minecraft:coal",
                "minecraft:diamond",
                "minecraft:emerald",
                "minecraft:lapis_lazuli",
                "minecraft:redstone",
                "minecraft:quartz",
                "minecraft:amethyst_shard",
                "minecraft:flint",
                "minecraft:gravel",
                "minecraft:sand",
                "minecraft:red_sand",
                "minecraft:cobblestone",
                "minecraft:stone",
                "minecraft:deepslate",
                "minecraft:cobbled_deepslate",
                "minecraft:granite",
                "minecraft:diorite",
                "minecraft:andesite",
                "minecraft:netherrack",
                "minecraft:soul_sand",
                "minecraft:soul_soil",
                "minecraft:basalt",
                "minecraft:blackstone",
                "minecraft:end_stone",
                "minecraft:ancient_debris",
                "minecraft:netherite_scrap",
            },
        },

        -- =====================================================
        --  🔩  METALS, CREATE & TECH → controller_3
        -- =====================================================
        metals = {
            name       = "Metals & Tech",
            icon       = "=",
            color      = "orange",
            controller = 3,

            patterns = {
                "_ingot",
                "_nugget",
                "_sheet",
                "_wire",
                -- Create máquinas y componentes
                "create:shaft",
                "create:cogwheel",
                "create:large_cogwheel",
                "create:gearbox",
                "create:gearshift",
                "create:clutch",
                "create:encased_chain",
                "create:vertical_gearbox",
                "create:mechanical_",
                "create:andesite_funnel",
                "create:andesite_tunnel",
                "create:brass_funnel",
                "create:chute",
                "create:depot",
                "create:deployer",
                "create:spout",
                "create:filter",
                "create:belt_connector",
                "create:fluid_pipe",
                "create:fluid_tank",
                "create:propeller",
                "create:windmill_bearing",
                "create:portable_storage",
                "create:item_drain",
                "create:hand_crank",
                "create:steam_engine",
                "create:stressometer",
                "create:blaze_burner",
                "create:electron_tube",
                "create:wrench",
                "create:encased_fan",
                "create:water_wheel",
                "create:large_water_wheel",
                "create:white_sail",
                "create:metal_girder",
                "create:adjustable_chain",
                "create:copycat_panel",
                "create:encased_chain_drive",
                -- Addons de Create (todos van a metals)
                "create_new_age:",
                "create_sa:",
                "createaddition:",
                "createsifter:",
                "createutilities:",
                "createchromaticreturn:",
                "createdeco:andesite_sheet",
                "createdeco:andesite_support",
            },

            exact = {
                -- Minecraft metals
                "minecraft:iron_ingot",
                "minecraft:gold_ingot",
                "minecraft:copper_ingot",
                "minecraft:iron_nugget",
                "minecraft:gold_nugget",
                "minecraft:netherite_ingot",
                "minecraft:iron_bars",
                "minecraft:bucket",
                "minecraft:hopper",
                "minecraft:cauldron",
                -- Create
                "create:andesite_alloy",
                "create:brass_ingot",
                "create:brass_sheet",
                -- Storage Drawers upgrades
                "storagedrawers:one_stack_upgrade",
                "storagedrawers:emerald_storage_upgrade",
                "storagedrawers:fill_level_upgrade",
                -- Apotheosis
                "apotheosis:gem",
            },
        },

        -- =====================================================
        --  🌿  NATURE & FARM → controller_2
        -- =====================================================
        nature = {
            name       = "Nature & Farm",
            icon       = "~",
            color      = "green",
            controller = 2,

            patterns = {
                "_log",
                "_wood",
                "_planks",
                "_sapling",
                "_leaves",
                "_fence",
                "_seed",
                "_seeds",
                "croptopia:",
            },

            exact = {
                "minecraft:bone",
                "minecraft:bone_meal",
                "minecraft:feather",
                "minecraft:leather",
                "minecraft:string",
                "minecraft:gunpowder",
                "minecraft:rotten_flesh",
                "minecraft:spider_eye",
                "minecraft:slime_ball",
                "minecraft:magma_cream",
                "minecraft:blaze_rod",
                "minecraft:blaze_powder",
                "minecraft:ender_pearl",
                "minecraft:ender_eye",
                "minecraft:ghast_tear",
                "minecraft:arrow",
                "minecraft:bow",
                "minecraft:apple",
                "minecraft:golden_apple",
                "minecraft:bread",
                "minecraft:paper",
                "minecraft:stick",
                "minecraft:egg",
                "minecraft:honeycomb",
                "minecraft:honey_bottle",
                "minecraft:ink_sac",
                "minecraft:glow_ink_sac",
                "minecraft:lily_pad",
                "minecraft:moss_block",
                "minecraft:moss_carpet",
                "minecraft:dirt",
                "minecraft:grass_block",
                "minecraft:mycelium",
                "minecraft:podzol",
                "minecraft:beehive",
                "minecraft:lead",
            },
        },

        -- =====================================================
        --  🏗️  BUILDING & DECO → controller_1
        -- =====================================================
        building = {
            name       = "Building & Deco",
            icon       = "#",
            color      = "cyan",
            controller = 1,

            patterns = {
                "_slab",
                "_stairs",
                "_wall",
                "_bricks",
                "_brick",
                "polished_",
                "smooth_",
                "chiseled_",
                "cut_",
                "mossy_",
                "cracked_",
                "glass",
                "concrete",
                "terracotta",
                "glazed_",
                "_wool",
                "_carpet",
                "sandstone",
                "prismarine",
                "purpur",
                "createdeco:andesite_catwalk",
                "createdeco:decal_",
                "storagedrawers:oak_full_drawers",
                "storagedrawers:compacting_drawers",
            },

            exact = {
                "minecraft:torch",
                "minecraft:redstone_torch",
                "minecraft:soul_torch",
                "minecraft:lantern",
                "minecraft:soul_lantern",
                "minecraft:glowstone",
                "minecraft:sea_lantern",
                "minecraft:shroomlight",
                "minecraft:end_rod",
                "minecraft:campfire",
                "minecraft:soul_campfire",
                "minecraft:chest",
                "minecraft:barrel",
                "minecraft:bookshelf",
                "minecraft:crafting_table",
                "minecraft:furnace",
                "minecraft:blast_furnace",
                "minecraft:smoker",
                "minecraft:anvil",
                "minecraft:grindstone",
                "minecraft:stonecutter",
                "minecraft:lever",
                "minecraft:repeater",
                "minecraft:comparator",
                "minecraft:observer",
                "minecraft:piston",
                "minecraft:sticky_piston",
                "minecraft:dropper",
                "minecraft:dispenser",
                "minecraft:redstone_lamp",
                "minecraft:note_block",
                "minecraft:jukebox",
                "minecraft:tnt",
                "minecraft:target",
                "minecraft:lectern",
                "minecraft:lapis_block",
                "minecraft:emerald_block",
                "minecraft:iron_block",
                "minecraft:gold_block",
                "create:andesite_casing",
                "create:copper_casing",
                "create:cuckoo_clock",
                "create:clipboard",
            },
        },

        -- =====================================================
        --  ❓  OVERFLOW / MISC → controller_0
        --  Infraestructura, cables, cosmetics, backpacks
        -- =====================================================
        overflow = {
            name       = "Overflow",
            icon       = "?",
            color      = "red",
            controller = 0,

            patterns = {
                "storagenetwork:",
                "storagedrawers:controller",
                "cosmeticarmoursmod:",
                "sophisticatedbackpacks:",
            },

            exact = {
                "storagedrawers:controller_slave",
            },
        },
    },
}
