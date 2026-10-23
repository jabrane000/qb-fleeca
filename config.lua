Config = {}

Config.MinCops = 2
Config.Cooldown = 45          -- minutes, cooldown global par banque
Config.PlayerCooldown = 60    -- minutes, par joueur

-- ITEMS
Config.HackItem = 'trojan_usb'
Config.ThermiteItem = 'thermite'

-- HACK (VarHack ps-ui) : nb blocs, longueur, timeout (sec)
Config.VarHack = { blocks = 6, length = 12, timeout = 15 }

-- Tiroirs (loot normal)
Config.DrawerLoot = { min = 2, max = 4, billMin = 500, billMax = 1500 }
Config.SearchTime = 8000

-- Coffre (loot bonus après thermite)
Config.VaultLoot = { min = 6, max = 10, billMin = 1000, billMax = 3000 }
Config.ThermiteTime = 20000

-- Durée du braquage (minutes)
Config.RobberyDuration = 5

Config.Banks = {
    ['fleeca1'] = {
        label = 'Fleeca - Legion Square',
        hackCoords = vector4(146.5, -1034.6, 29.3, 250.0),
        thermiteCoords = vector4(149.6, -1040.7, 29.3, 70.0),
        drawers = {
            { coords = vector3(148.9, -1042.0, 29.3) },
            { coords = vector3(147.9, -1043.6, 29.3) },
            { coords = vector3(146.9, -1045.2, 29.3) },
            { coords = vector3(145.9, -1046.8, 29.3) },
        },
    },
    ['fleeca2'] = {
        label = 'Fleeca - Hawick',
        hackCoords = vector4(-356.3, -54.4, 49.0, 160.0),
        thermiteCoords = vector4(-353.6, -49.4, 49.0, 250.0),
        drawers = {
            { coords = vector3(-354.3, -48.1, 49.0) },
            { coords = vector3(-355.3, -46.5, 49.0) },
        },
    },
}
