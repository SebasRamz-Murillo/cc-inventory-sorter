-- ============================================================
--  data/categories.lua
--  Librería de clasificación de items
--  Agregar items aquí para que el sorter los reconozca
--
--  CÓMO AGREGAR ITEMS:
--  1. Busca la categoría correcta
--  2. Agrega el mod:item_id al listado "exact"
--  3. O agrega un patrón parcial a "patterns" si son muchos items similares
--
--  PATRONES: coinciden si el item ID *contiene* ese texto
--  EXACT:    coincide solo si el item ID es exactamente ese
-- ============================================================

return {

    -- Mapeo controller -> categoría
    -- controller_5 es la FUENTE (desordenado), no va aquí
    controllers = {
        [0] = "overflow",
        [1] = "building",
        [2] = "nature",
        [3] = "metals",
        [4] = "ores",
    },

    -- Orden de prioridad de clasificación (más específico primero)
    priority = { "ores", "metals", "nature", "building", "overflow" },

    categories = {

        -- =====================================================
        --  ⛏️  ORES & RAW MATERIALS → controller_4
        -- =====================================================
        ores = {
            name     = "Ores & Raw",
            icon     = "*",
            color    = "yellow",
            controller = 4,

            patterns = {
                "_ore",           -- iron_ore, copper_ore, gold_ore, etc
                "raw_",           -- raw_iron, raw_copper, raw_gold
                "deepslate_",     -- deepslate_iron_ore, etc
                "_shard",         -- crystal shards
                "_crystal",
                "_gem",
                "crushed_",       -- Create: crushed ores
                "osmium",
                "fluorite",
                "lead_",
                "silver_",
                "uranium",
                "netherite_scrap",
                "ancient_debris",
                "nether_quartz",
            },

            exact = {
                "minecraft:coal",
                "minecraft:diamond",
                "minecraft:emerald",
                "minecraft:lapis_lazuli",
                "minecraft:redstone",
                "minecraft:quartz",
                "minecraft:amethyst_shard",
                "minecraft:raw_iron",
                "minecraft:raw_copper",
                "minecraft:raw_gold",
                "minecraft:gravel",
                "minecraft:flint",
                "minecraft:sand",
                "minecraft:red_sand",
                "minecraft:clay_ball",
                "minecraft:clay",
                "minecraft:cobblestone",
                "minecraft:stone",
                "minecraft:deepslate",
                "minecraft:cobbled_deepslate",
                "minecraft:netherrack",
                "minecraft:soul_sand",
                "minecraft:soul_soil",
                "minecraft:basalt",
                "minecraft:blackstone",
                "minecraft:end_stone",
                -- Ad Astra
                "ad_astra:moon_stone",
                "ad_astra:mars_stone",
                "ad_astra:venus_stone",
                "ad_astra:glacio_stone",
                "ad_astra:ice_shard",
                "ad_astra:desh_ore",
                "ad_astra:ostrum_ore",
                "ad_astra:calorite_ore",
                "ad_astra:raw_desh",
                "ad_astra:raw_ostrum",
                "ad_astra:raw_calorite",
            },
        },

        -- =====================================================
        --  🔩  METALS, CREATE & TECH → controller_3
        -- =====================================================
        metals = {
            name     = "Metals & Tech",
            icon     = "=",
            color    = "orange",
            controller = 3,

            patterns = {
                "_ingot",           -- iron_ingot, gold_ingot, copper_ingot
                "_nugget",          -- iron_nugget, gold_nugget
                "_plate",           -- iron_plate, brass_plate
                "_sheet",           -- zinc_sheet (Create)
                "_gear",            -- andesite_gear, brass_gear
                "_rod",             -- iron_rod
                "_blade",
                "andesite_",        -- Create: andesite alloy items
                "brass_",           -- Create: brass items
                "zinc_",            -- Create: zinc items
                "copper_",          -- processed copper items
                "electron_tube",
                "golden_sheet",
                "rose_quartz",
                "desh_",            -- Ad Astra processed
                "ostrum_",
                "calorite_",
                "netherite_",
                "refined_",
                "steel_",
                "invar_",
                "constantan_",
                "electrum_",
                "enderium_",
                "lumium_",
                "signalum_",
                "enderium_",
            },

            exact = {
                "minecraft:iron_ingot",
                "minecraft:gold_ingot",
                "minecraft:copper_ingot",
                "minecraft:iron_nugget",
                "minecraft:gold_nugget",
                "minecraft:netherite_ingot",
                -- Create
                "create:andesite_alloy",
                "create:brass_ingot",
                "create:zinc_ingot",
                "create:copper_ingot",
                "create:iron_sheet",
                "create:copper_sheet",
                "create:brass_sheet",
                "create:zinc_sheet",
                "create:golden_sheet",
                "create:andesite_sheet",
                "create:shaft",
                "create:cogwheel",
                "create:large_cogwheel",
                "create:electron_tube",
                "create:precision_mechanism",
                "create:rose_quartz",
                "create:refined_radiance",
                "create:shadow_steel",
                "create:crushed_iron",
                "create:crushed_copper",
                "create:crushed_gold",
                "create:crushed_zinc",
                "create:crushed_osmium",
                "create:crushed_silver",
                "create:crushed_lead",
                "create:crushed_nickel",
                "create:experience_nugget",
                "create:sturdy_sheet",
                "create:belt_connector",
                "create:filter",
                "create:brass_hand",
                "create:copper_hand",
                -- Ad Astra ingots
                "ad_astra:desh_ingot",
                "ad_astra:ostrum_ingot",
                "ad_astra:calorite_ingot",
                "ad_astra:steel_ingot",
            },
        },

        -- =====================================================
        --  🌿  NATURE & FARM → controller_2
        -- =====================================================
        nature = {
            name     = "Nature & Farm",
            icon     = "~",
            color    = "green",
            controller = 2,

            patterns = {
                "_log",             -- oak_log, birch_log
                "_wood",            -- oak_wood, stripped_
                "_plank",           -- oak_planks
                "_sapling",         -- oak_sapling
                "_leaves",          -- oak_leaves
                "_seed",            -- wheat_seeds
                "_seeds",
                "_crop",
                "wheat",
                "carrot",
                "potato",
                "beetroot",
                "melon",
                "pumpkin",
                "bamboo",
                "sugar_cane",
                "cactus",
                "vine",
                "lily",
                "fern",
                "grass",
                "flower",
                "mushroom",
                "kelp",
                "seagrass",
                "coral",
                "sponge",
                -- Mob drops
                "leather",
                "_feather",
                "_bone",
                "string",
                "spider_eye",
                "slimeball",
                "blaze_",
                "ender_",
                "ghast_",
                "magma_cream",
                "rabbit_",
                "mutton",
                "chicken",
                "beef",
                "porkchop",
                "fish",
                "salmon",
                "cod",
                "ink_sac",
                "gunpowder",
                "rotten_flesh",
                "egg",
                "honeycomb",
                "honey",
                -- Farmer's Delight
                "farmersdelight:",
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
                "minecraft:slimeball",
                "minecraft:magma_cream",
                "minecraft:blaze_rod",
                "minecraft:blaze_powder",
                "minecraft:ender_pearl",
                "minecraft:ender_eye",
                "minecraft:ghast_tear",
                "minecraft:rabbit_hide",
                "minecraft:rabbit_foot",
                "minecraft:nether_star",
                "minecraft:totem_of_undying",
                "minecraft:apple",
                "minecraft:golden_apple",
                "minecraft:enchanted_golden_apple",
                "minecraft:bread",
                "minecraft:cookie",
                "minecraft:cake",
                "minecraft:ink_sac",
                "minecraft:glow_ink_sac",
                "minecraft:egg",
                "minecraft:honey_bottle",
                "minecraft:honeycomb",
                "minecraft:lily_pad",
                "minecraft:moss_block",
                "minecraft:moss_carpet",
                "minecraft:rooted_dirt",
                "minecraft:dirt",
                "minecraft:grass_block",
                "minecraft:mycelium",
                "minecraft:podzol",
            },
        },

        -- =====================================================
        --  🏗️  BUILDING & DECO → controller_1
        -- =====================================================
        building = {
            name     = "Building & Deco",
            icon     = "#",
            color    = "cyan",
            controller = 1,

            patterns = {
                "_brick",           -- stone_bricks, nether_bricks
                "_bricks",
                "_slab",
                "_stairs",
                "_wall",
                "_fence",
                "_gate",
                "_door",
                "_trapdoor",
                "_button",
                "_pressure_plate",
                "glass",
                "concrete",
                "terracotta",
                "glazed_",
                "_wool",
                "_carpet",
                "smooth_",
                "polished_",
                "chiseled_",
                "cut_",
                "mossy_",
                "cracked_",
                "prismarine",
                "purpur",
                "quartz_block",
                "sandstone",
                "diorite",
                "granite",
                "andesite",        -- raw andesite (building)
                "calcite",
                "tuff",
                "dripstone",
                "amethyst_block",
                "budding_amethyst",
                "chest",
                "barrel",
                "bookshelf",
                "crafting_table",
                "furnace",
                "blast_furnace",
                "smoker",
                "anvil",
                "grindstone",
                "stonecutter",
                "lantern",
                "torch",
                "campfire",
                "candle",
                "banner",
                "sign",
                "painting",
                "item_frame",
                "armor_stand",
                "bell",
            },

            exact = {
                "minecraft:stone",
                "minecraft:cobblestone",
                "minecraft:gravel",
                "minecraft:obsidian",
                "minecraft:crying_obsidian",
                "minecraft:iron_bars",
                "minecraft:iron_door",
                "minecraft:iron_trapdoor",
                "minecraft:chain",
                "minecraft:lever",
                "minecraft:redstone_torch",
                "minecraft:redstone_lamp",
                "minecraft:piston",
                "minecraft:sticky_piston",
                "minecraft:dropper",
                "minecraft:dispenser",
                "minecraft:hopper",
                "minecraft:comparator",
                "minecraft:repeater",
                "minecraft:observer",
                "minecraft:daylight_detector",
                "minecraft:tripwire_hook",
                "minecraft:target",
                "minecraft:note_block",
                "minecraft:jukebox",
                "minecraft:tnt",
                "minecraft:soul_lantern",
                "minecraft:soul_torch",
                "minecraft:shroomlight",
                "minecraft:glowstone",
                "minecraft:sea_lantern",
                "minecraft:end_rod",
                "minecraft:conduit",
                -- Create decorative
                "create:industrial_iron_block",
                "create:refined_radiance_casing",
                "create:shadow_steel_casing",
                "create:brass_casing",
                "create:copper_casing",
                "create:andesite_casing",
            },
        },

        -- =====================================================
        --  ❓  OVERFLOW / MISC → controller_0
        --  Todo lo que no matchea ninguna categoría va aquí
        -- =====================================================
        overflow = {
            name     = "Overflow",
            icon     = "?",
            color    = "red",
            controller = 0,
            patterns = {},
            exact    = {},
        },
    },
}
