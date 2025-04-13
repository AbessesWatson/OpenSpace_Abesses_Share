local function PlayAnimation(dict, name, duration,flag)
    local playerPed = PlayerPedId()

    -- Charger le dictionnaire d'animation
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(100)
    end

    -- Jouer l'animation
    TaskPlayAnim(playerPed, dict, name, 1.0, 1.0, duration, flag, 0, false, false, false)

    -- Attendre la durée de l'animation
    Wait(duration)

    -- Arrêter l'animation
    ClearPedTasks(playerPed)
    RemoveAnimDict(dict)
end

-- EXPORT DE USE ITEM 

    exports('anxiolytique', function(data, slot)
        local player = PlayerPedId()

        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 1500, 49)
                TriggerServerEvent('hud:server:RelieveStress',Config.upstress_low) -- event qui baisse le stress 
            end
        end)

    end)

    exports('beta_bloquant', function(data, slot)
        local player = PlayerPedId()

        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 1500, 49)
                TriggerServerEvent('hud:server:RelieveStress',Config.upstress_high) -- event qui baisse le stress

            end
        end)

    end)

    exports('vitamines', function(data, slot)
        local player = PlayerPedId()

        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 1500, 49)
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.downfatigue_low) -- augmente la fatigue
                TriggerEvent ('qbx_Ab_AlcoolContrebande:client:decreaseDrunk', 30)
            end
        end)

    end)

    exports('modafinil', function(data, slot)
        local player = PlayerPedId()

        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 1500, 49)
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.downfatigue_high) -- augmente la fatigue
            end
        end)

    end)

    exports('benzo_poudre', function(data, slot)
        local player = PlayerPedId()
        local health_low = 15
        local stress_up = 25
        local playerhealth = GetEntityHealth(player)
        local playerNewHealth = playerhealth - health_low

        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 5000, 49)
                exports.qbx_core:Notify("C'est probablement toxique... ", 'warning', 8000)
                SetEntityHealth(player, playerNewHealth)
                TriggerServerEvent('hud:server:GainStress',stress_up)
            end
        end)

    end)

    exports('hydro_poudre', function(data, slot)
        local player = PlayerPedId()
        local health_low = 25
        local stress_up = 35
        local playerhealth = GetEntityHealth(player)
        local playerNewHealth = playerhealth - health_low

        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 5000, 49)
                exports.qbx_core:Notify("C'est probablement toxique... ", 'warning', 8000)
                SetEntityHealth(player, playerNewHealth)
                TriggerServerEvent('hud:server:GainStress',stress_up)
            end
        end)

    end)

    exports('silice_poudre', function(data, slot)
        local player = PlayerPedId()
        local fatigue_up = 30
        local stress_up = 10

        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 5000, 49)
                exports.qbx_core:Notify("Vous vous sentez lourd... ", 'warning', 8000)
                TriggerServerEvent('hud:server:GainStress',stress_up)
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_up) -- augmente la fatigue
            end
        end)

    end)

    exports('modafinil_poudre', function(data, slot)
        local player = PlayerPedId()
        local health_low = 15
        local stress_up = 25
        local fatigue_down = -20
        local playerhealth = GetEntityHealth(player)
        local playerNewHealth = playerhealth - health_low

        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 5000, 49)
                exports.qbx_core:Notify("C'est probablement toxique... ", 'warning', 8000)
                SetEntityHealth(player, playerNewHealth)
                TriggerServerEvent('hud:server:GainStress',stress_up)
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_down) -- augmente la fatigue
            end
        end)

    end)

    exports('branche_ginseng', function(data, slot)
        local player = PlayerPedId()
        local fatigue_down = -5
        local hunger_up = 10

        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 20000, 49)
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_down) -- augmente la fatigue
                TriggerServerEvent('consumables:server:addHunger', hunger_up)
            end
        end)

    end)

    exports('ginseng', function(data, slot)
        local player = PlayerPedId()
        local fatigue_down = -2
        local hunger_up = 5

        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 10000, 49)
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_down) -- augmente la fatigue
                TriggerServerEvent('consumables:server:addHunger', hunger_up)
            end
        end)

    end)

    exports('medicament', function(data, slot)
        local player = PlayerPedId()

        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 1500, 49)
            end
        end)

    end)

    