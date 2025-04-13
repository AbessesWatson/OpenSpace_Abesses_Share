poisoned = false
poisonlvl = 0

notifylvl = 0 

-- Fonction 

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

    local function stopPoison()
        notifylvl = 0
        poisoned = false
        TriggerEvent('qbx_Ab_SpecialRole:client:setpoison', 0)
        TriggerServerEvent("qbx_Ab_SpecialRole:server:UpdatepoisonLvl", poisonlvl)
    end

-- THREAD

CreateThread(function() -- Pour charger le niveau d'alcool au dépar

    while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
        Wait(100)
        --print("En attente des données du joueur (citizenid)...")
    end

    local citizenid = QBX.PlayerData.citizenid
    print (json.encode(citizenid).. "loaded go get p lvl")
    TriggerServerEvent("qbx_Ab_SpecialRole:server:GetpoisonLvl", citizenid)

end)

CreateThread(function() 

    while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
        Wait(100)
        --print("En attente des données du joueur (citizenid)...")
    end

    while true do

        Wait(Config.timeUpdatePoison)  -- augmentation et maj tout les x temps

        if poisoned then

            local player = PlayerPedId()
            local playerhealth = GetEntityHealth(player)

            poisonlvl = poisonlvl + 1
            print ('poisonlvl = ' ..poisonlvl)
            TriggerServerEvent("qbx_Ab_SpecialRole:server:UpdatepoisonLvl", poisonlvl)
            if poisonlvl <= Config.poison_p1 then
            elseif poisonlvl > Config.poison_p1 and poisonlvl <= Config.poison_p2 then
                if notifylvl ~= 1 then
                    exports.qbx_core:Notify('Vous vous sentez pas très bien.', 'error', 10000)
                    notifylvl = 1
                end
            elseif poisonlvl > Config.poison_p2 and poisonlvl <= Config.poison_p3 then
                if notifylvl ~= 2 then
                    exports.qbx_core:Notify('Vous vous avez très mal au ventre!', 'error', 10000)
                    notifylvl = 2
                end
                SetEntityHealth(player, playerhealth - 1)
            elseif poisonlvl > Config.poison_p3 and poisonlvl <= Config.poison_p4 then
                if notifylvl ~= 3 then
                    exports.qbx_core:Notify('Vous êtes empoisonné!', 'error', 10000)
                    notifylvl = 3
                end
                SetEntityHealth(player, playerhealth - 2)
            elseif poisonlvl > Config.poison_p4 then 
                if playerhealth <=0 then 
                    stopPoison()
                else
                    SetEntityHealth(player, playerhealth - 4)
                end
            else
                print('erreur pour definir plvl palier')
            end

        end
    end
end)

-- EVENTS

    RegisterNetEvent('qbx_Ab_SpecialRole:client:updatepoison')
    AddEventHandler('qbx_Ab_SpecialRole:client:updatepoison', function(recievedpoisonLvl)
        poisonlvl = recievedpoisonLvl
        if poisonlvl > 0 then
            poisoned = true
        end
        --print("Niveau de p lvl mis à jour " ..poisonlvl)
    end)


    RegisterNetEvent('qbx_Ab_SpecialRole:client:increasepoison')
    AddEventHandler('qbx_Ab_SpecialRole:client:increasepoison', function(value)
        poisonlvl = poisonlvl + value
        --print("Niveau de p lvl a augmenté de  " ..value.. " elle est désormais de: " ..poisonlvl)
    end)

    RegisterNetEvent('qbx_Ab_SpecialRole:client:setpoison')
    AddEventHandler('qbx_Ab_SpecialRole:client:setpoison', function(value)
        poisonlvl = value
        print("Niveau de p lvl est désormais de  " ..poisonlvl)
    end)

    RegisterNetEvent('qbx_Ab_SpecialRole:client:poisonActivated')
    AddEventHandler('qbx_Ab_SpecialRole:client:poisonActivated', function()
        if poisoned then
            TriggerEvent('qbx_Ab_SpecialRole:client:increasepoison', 60)
        else
            poisoned = true
            print("p activeted")
        end
    end)

    RegisterNetEvent('qbx_Ab_SpecialRole:client:poisonDesactivated')
    AddEventHandler('qbx_Ab_SpecialRole:client:poisonDesactivated', function()
        stopPoison()
        print("p desactiveted")
    end)

-- EXPORT

    -- a table 
        exports('hamburger_poison', function(data, slot)
            local player = PlayerPedId()
        
            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then
                    
                    exports.qbx_core:Notify("Un hamburger doit être mangé à table.", 'error', 5000)

                end
            end)
        
        end)

        exports('salade_tomate_poison', function(data, slot)
            local player = PlayerPedId()
        
            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then
                    
                    exports.qbx_core:Notify("Un hamburger doit être mangé à table.", 'error', 5000)

                end
            end)
        
        end)
    
    -- sans table

        exports('chococho_poison', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 15
            local soif_up = 14
            local duration = 5000
        
            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then
                    
                    PlayAnimation("amb@prop_human_seat_chair_drink@female@generic@base", "base", duration, 49)

                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress de 5
                    TriggerServerEvent('consumables:server:addThirst',soif_up)
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'goblet')
                    TriggerEvent('qbx_Ab_SpecialRole:client:poisonActivated')
                    --print ('soif up de '.. soif_up)
                end
            end)

        end)

        exports('medicament_poison', function(data, slot)
            local player = PlayerPedId()
    
            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then
                    PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 1500, 49)
                    TriggerEvent('qbx_Ab_SpecialRole:client:poisonActivated')
                end
            end)
    
        end)


        exports('plante_poison', function(data, slot)
            local player = PlayerPedId()
            local playerhealth = GetEntityHealth(player)
    
            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then
                    PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 4000, 49)
                    SetEntityHealth(player, playerhealth - 50)
                    exports.qbx_core:Notify("Vous recentez une forte douleur!", 'error', 5000)
                end
            end)
    
        end)

        exports('poudre_poison', function(data, slot)
            local player = PlayerPedId()
    
            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then
                    PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 4000, 49)
                    TriggerEvent('qbx_Ab_SpecialRole:client:poisonActivated')
                end
            end)
    
        end)

    -- antidote

    exports('antidote', function(data, slot)
        local player = PlayerPedId()

        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("amb@prop_human_seat_chair_drink@female@generic@base", "base", 2500, 49)
                TriggerEvent('qbx_Ab_SpecialRole:client:poisonDesactivated')
            end
        end)

    end)

