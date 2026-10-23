local QBCore = exports['qb-core']:GetCoreObject()
local robberyActive = false
local robbedDrawers = {}

-- ============ HACK TERMINAL (VarHack ps-ui) ============

local function hackTerminal(bankId)
    QBCore.Functions.TriggerCallback('qb-fleeca:server:canRob', function(ok, reason)
        if not ok then
            local msgs = {
                cooldown = 'Banque déjà braquée récemment.',
                active = 'Braquage déjà en cours ici.',
                playercooldown = 'Tu dois attendre avant de re-braquer.',
                cops = ('Il faut au moins ~r~%s~w~ policiers.'):format(Config.MinCops),
            }
            QBCore.Functions.Notify(msgs[reason] or 'Impossible de braquer.', 'error')
            return
        end

        QBCore.Functions.TriggerCallback('qb-fleeca:server:hasItem', function(hasItem)
            if not hasItem then
                QBCore.Functions.Notify(("Tu as besoin d'un ~r~%s~w~."):format(Config.HackItem), 'error')
                return
            end

            exports['ps-ui']:VarHack(function(success)
                if not success then
                    QBCore.Functions.Notify('Hack échoué ! La police a été alertée.', 'error')
                    TriggerEvent('qb-policejob:client:policeAlert', 'Tentative de braquage de banque')
                    return
                end

                QBCore.Functions.Notify('Hack réussi ! Téléchargement des données...', 'success')
                QBCore.Functions.Progressbar('fleeca_dl', 'Téléchargement...', 15000, false, true, {
                    disableMovement = true, disableCarMovement = true,
                    disableMouse = false, disableCombat = true,
                }, { animDict = 'anim@gangops@facility@servers@bodysearch@', anim = 'player_search', flags = 49 },
                {}, {}, function()
                    StopAnimTask(PlayerPedId(), 'anim@gangops@facility@servers@bodysearch@', 'player_search', 1.0)
                    TriggerServerEvent('qb-fleeca:server:startRobbery', bankId)
                end, function()
                    StopAnimTask(PlayerPedId(), 'anim@gangops@facility@servers@bodysearch@', 'player_search', 1.0)
                    QBCore.Functions.Notify('Annulé', 'error')
                end)
            end, Config.VarHack.blocks, Config.VarHack.length, Config.VarHack.timeout)
        end, Config.HackItem)
    end, bankId)
end

-- ============ FOUILLER UN TIROIR ============

local function searchDrawer(bankId, drawerId)
    if not robberyActive or robbedDrawers[drawerId] then
        if robbedDrawers[drawerId] then QBCore.Functions.Notify('Ce tiroir est déjà vide.', 'error') end
        return
    end

    QBCore.Functions.Progressbar('fleeca_drawer', 'Recherche du tiroir...', Config.SearchTime, false, true, {
        disableMovement = true, disableCarMovement = true,
        disableMouse = false, disableCombat = true,
    }, { animDict = 'mini@repair', anim = 'fixing_a_ped', flags = 49 },
    {}, {}, function()
        ClearPedTasks(PlayerPedId())
        robbedDrawers[drawerId] = true
        TriggerServerEvent('qb-fleeca:server:searchDrawer', bankId, drawerId)
    end, function()
        ClearPedTasks(PlayerPedId())
        QBCore.Functions.Notify('Annulé', 'error')
    end)
end

-- ============ THERMITE COFFRE ============

local function thermiteVault(bankId)
    QBCore.Functions.TriggerCallback('qb-fleeca:server:hasItem', function(hasItem)
        if not hasItem then
            QBCore.Functions.Notify(("Tu as besoin d'un ~r~%s~w~."):format(Config.ThermiteItem), 'error')
            return
        end

        QBCore.Functions.Progressbar('fleeca_thermite', 'Pose de la thermite...', Config.ThermiteTime, false, true, {
            disableMovement = true, disableCarMovement = true,
            disableMouse = false, disableCombat = true,
        }, { animDict = 'anim@gangops@facility@servers@bodysearch@', anim = 'player_search', flags = 49 },
        {}, {}, function()
            StopAnimTask(PlayerPedId(), 'anim@gangops@facility@servers@bodysearch@', 'player_search', 1.0)
            exports['ps-ui']:Thermite(function(success)
                if not success then
                    QBCore.Functions.Notify('La thermite a raté ! Fuis !', 'error')
                    return
                end
                TriggerServerEvent('qb-fleeca:server:openVault', bankId)
            end, 10, 8, 3000)
        end, function()
            StopAnimTask(PlayerPedId(), 'anim@gangops@facility@servers@bodysearch@', 'player_search', 1.0)
            QBCore.Functions.Notify('Annulé', 'error')
        end)
    end, Config.ThermiteItem)
end

-- ============ ÉVÉNEMENTS ============

RegisterNetEvent('qb-fleeca:client:robberyStarted', function(bankId)
    robberyActive = true
    robbedDrawers = {}
    QBCore.Functions.Notify('Système désactivé ! Vous avez ~r~5 minutes~w~ !', 'success')
end)

RegisterNetEvent('qb-fleeca:client:robberyOver', function()
    robberyActive = false
    QBCore.Functions.Notify('Le système est réactivé !', 'error')
end)

RegisterNetEvent('qb-fleeca:client:drawerResult', function(success, amount)
    if success then
        QBCore.Functions.Notify(('Tu as trouvé ~g~%s~w~ bills marqués !'):format(amount), 'success')
    else
        QBCore.Functions.Notify('Inventaire plein !', 'error')
    end
end)

RegisterNetEvent('qb-fleeca:client:vaultResult', function(success, amount)
    if success then
        QBCore.Functions.Notify(('~g~JACKPOT !~w~ %s bills marqués du coffre !'):format(amount), 'success')
    else
        QBCore.Functions.Notify('Inventaire plein pour le coffre !', 'error')
    end
end)

-- ============ QB-TARGET ============

CreateThread(function()
    for bankId, bank in pairs(Config.Banks) do
        -- Terminal de hack
        exports['qb-target']:AddBoxZone('fleeca_hack_' .. bankId, bank.hackCoords.xyz, 1.2, 1.2, {
            name = 'fleeca_hack_' .. bankId,
            heading = bank.hackCoords.w,
            debugPoly = false,
            minZ = bank.hackCoords.z - 1.0,
            maxZ = bank.hackCoords.z + 1.5,
        }, {
            options = {
                {
                    type = 'client',
                    icon = 'fas fa-laptop-code',
                    label = 'Hacker le terminal',
                    action = function() hackTerminal(bankId) end,
                    canInteract = function() return not robberyActive end,
                },
            },
            distance = 1.5,
        })

        -- Coffre (thermite)
        exports['qb-target']:AddBoxZone('fleeca_vault_' .. bankId, bank.thermiteCoords.xyz, 1.2, 1.2, {
            name = 'fleeca_vault_' .. bankId,
            heading = bank.thermiteCoords.w,
            debugPoly = false,
            minZ = bank.thermiteCoords.z - 1.0,
            maxZ = bank.thermiteCoords.z + 1.5,
        }, {
            options = {
                {
                    type = 'client',
                    icon = 'fas fa-fire',
                    label = 'Poser la thermite (coffre)',
                    action = function() thermiteVault(bankId) end,
                    canInteract = function() return robberyActive end,
                },
            },
            distance = 1.5,
        })

        -- Tiroirs
        for drawerId, drawer in ipairs(bank.drawers) do
            exports['qb-target']:AddBoxZone(('fleeca_drawer_%s_%d'):format(bankId, drawerId), drawer.coords, 0.8, 0.8, {
                name = ('fleeca_drawer_%s_%d'):format(bankId, drawerId),
                heading = 0.0, debugPoly = false,
                minZ = drawer.coords.z - 1.0,
                maxZ = drawer.coords.z + 1.0,
            }, {
                options = {
                    {
                        type = 'client',
                        icon = 'fas fa-box-open',
                        label = 'Fouiller le tiroir',
                        action = function() searchDrawer(bankId, drawerId) end,
                        canInteract = function()
                            return robberyActive and not robbedDrawers[drawerId]
                        end,
                    },
                },
                distance = 1.5,
            })
        end
    end
end)
