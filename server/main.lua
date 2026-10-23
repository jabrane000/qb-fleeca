local QBCore = exports['qb-core']:GetCoreObject()

local bankCooldowns = {}   -- [bankId] = os.time() du dernier braquage
local playerCooldowns = {}
local activeBanks = {}     -- [bankId] = true pendant un braquage
local drawerState = {}     -- [bankId][drawerId] = true si fouillé
local vaultState = {}      -- [bankId] = true si coffre ouvert

local function countCops()
    local n = 0
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v and v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
            n = n + 1
        end
    end
    return n
end

QBCore.Functions.CreateCallback('qb-fleeca:server:canRob', function(source, cb, bankId)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false, 'error') end

    if bankCooldowns[bankId] and (os.time() - bankCooldowns[bankId]) < Config.Cooldown * 60 then
        return cb(false, 'cooldown')
    end
    if activeBanks[bankId] then return cb(false, 'active') end
    if playerCooldowns[source] and (os.time() - playerCooldowns[source]) < Config.PlayerCooldown * 60 then
        return cb(false, 'playercooldown')
    end
    if countCops() < Config.MinCops then return cb(false, 'cops') end
    cb(true)
end)

QBCore.Functions.CreateCallback('qb-fleeca:server:hasItem', function(source, cb, itemName)
    local Player = QBCore.Functions.GetPlayer(source)
    cb(Player and Player.Functions.GetItemByName(itemName) ~= nil)
end)

RegisterNetEvent('qb-fleeca:server:startRobbery', function(bankId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Config.Banks[bankId] or activeBanks[bankId] then return end

    Player.Functions.RemoveItem(Config.HackItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.HackItem], 'remove')

    activeBanks[bankId] = true
    drawerState[bankId] = {}
    vaultState[bankId] = false
    playerCooldowns[src] = os.time()

    TriggerEvent('qb-policejob:server:policeAlert',
        ('Braquage en cours : %s'):format(Config.Banks[bankId].label))

    TriggerClientEvent('qb-fleeca:client:robberyStarted', src, bankId)

    -- Timer du braquage (serveur = vérité absolue, anti-cheat)
    SetTimeout(Config.RobberyDuration * 60 * 1000, function()
        if activeBanks[bankId] then
            activeBanks[bankId] = nil
            drawerState[bankId] = {}
            vaultState[bankId] = false
            bankCooldowns[bankId] = os.time()
            TriggerClientEvent('qb-fleeca:client:robberyOver', -1, bankId)
        end
    end)
end)

RegisterNetEvent('qb-fleeca:server:searchDrawer', function(bankId, drawerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not activeBanks[bankId] then return end

    if drawerState[bankId] and drawerState[bankId][drawerId] then
        return -- tiroir déjà fouillé (anti-cheat)
    end

    drawerState[bankId] = drawerState[bankId] or {}
    drawerState[bankId][drawerId] = true

    local amount = math.random(Config.DrawerLoot.min, Config.DrawerLoot.max)
    local info = { worth = math.random(Config.DrawerLoot.billMin, Config.DrawerLoot.billMax) }
    if Player.Functions.AddItem('markedbills', amount, false, info) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], 'add')
        TriggerClientEvent('qb-fleeca:client:drawerResult', src, true, amount)
    else
        drawerState[bankId][drawerId] = false -- inventaire plein
        TriggerClientEvent('qb-fleeca:client:drawerResult', src, false)
    end
end)

RegisterNetEvent('qb-fleeca:server:openVault', function(bankId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not activeBanks[bankId] or vaultState[bankId] then return end

    if not Player.Functions.RemoveItem(Config.ThermiteItem, 1) then return end
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ThermiteItem], 'remove')

    vaultState[bankId] = true

    local amount = math.random(Config.VaultLoot.min, Config.VaultLoot.max)
    local info = { worth = math.random(Config.VaultLoot.billMin, Config.VaultLoot.billMax) }
    if Player.Functions.AddItem('markedbills', amount, false, info) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], 'add')
        TriggerClientEvent('qb-fleeca:client:vaultResult', src, true, amount)
    else
        TriggerClientEvent('qb-fleeca:client:vaultResult', src, false)
    end
end)

AddEventHandler('playerDropped', function()
    playerCooldowns[source] = nil
end)
