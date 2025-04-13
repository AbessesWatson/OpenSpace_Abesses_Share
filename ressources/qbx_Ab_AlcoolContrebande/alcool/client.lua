local player_drunk_level = 0 -- LA FONCTION DE BASE DU NIVEAU D'EBRIETE
local Player_drunk_step = 0

-- FONCTION 
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

    -- effet de perte d'équilibre
    local function StartDrunkStumble(ped, interval, duration, level)
        Citizen.CreateThread(function()
            local endTime = GetGameTimer() + duration
            while GetGameTimer() < endTime do
                Citizen.Wait(interval)  -- Attendre X secondes entre chaque perte d'équilibre
                
                if not IsPedOnFoot(ped) then break end -- Stopper si le joueur est en véhicule
                
                local speed = GetEntitySpeed(ped)  -- Récupérer la vitesse du personnage
                
                -- Définir la probabilité de trébucher en fonction de la vitesse
                local stumbleChance = 10

                if Player_drunk_step >= 3 then
                    if speed < 1.0 then -- Chance de trébucher plus faible si lent
                        if level == 3 then 
                            stumbleChance = 10  
                        elseif level == 4 then
                            stumbleChance = 9
                        elseif level == 5 then
                            stumbleChance = 7
                        else
                            print ("erreur stumbleChance drunk effect")
                        end
                    elseif speed >= 1.0 and speed < 3.0 then -- Chance de trébucher si course
                        if level == 3 then 
                            stumbleChance = 6
                        elseif level == 4 then
                            stumbleChance = 4
                        elseif level == 5 then
                            stumbleChance = 2
                        else
                            print ("erreur stumbleChance drunk effect")
                        end
                    else -- Chance de trébucher si marche normal
                        if level == 3 then 
                            stumbleChance = 9 
                        elseif level == 4 then
                            stumbleChance = 7
                        elseif level == 5 then
                            stumbleChance = 4
                        else
                            print ("erreur stumbleChance drunk effect")
                        end
                    end
                else
                    stumbleChance = 10
                end
                
                -- Appliquer un ragdoll avec la probabilité ajustée en fonction de la vitesse
                if math.random(1, 10) > stumbleChance then  -- Plus le nombre est bas, plus la probabilité est élevée
                    SetPedToRagdoll(ped, math.random(200, 800), math.random(400, 1000), 2, false, false, false)
                end
            end
        end)
    end

    -- retiré les effet
    local function ClearDrunkEffect ()

        local playerPed = PlayerPedId()
        ClearTimecycleModifier()
        ResetPedMovementClipset(playerPed, 0)
        SetPedMotionBlur(playerPed, false)
        StopGameplayCamShaking(true)
    end

    local function ApplyDrunkEffect(level, duration, iscommand)
        local playerPed = PlayerPedId()
        local stambleduration = duration

        --print ("command: " ..json.encode(iscommand).. " stamble " ..stambleduration)

        -- Désactiver les effets précédents
        ClearDrunkEffect()

            -- Charger le clipset ivre et attendre qu'il soit prêt
            if level == 2 or level == 3 then
                local clipset = "move_m@drunk@moderatedrunk"  -- Par défaut pour le niveau 2
                if level == 3 then
                    clipset = "move_m@drunk@verydrunk"  -- Niveau 3, mouvement plus chaotique
                end
                
                RequestAnimSet(clipset)  -- Charger le clipset
                while not HasAnimSetLoaded(clipset) do  -- Attendre que le clipset soit chargé
                    Citizen.Wait(100)
                end
            end
        
        
        if level == 1 then 
            ShakeGameplayCam("DRUNK_SHAKE", 0.2)
            SetPedMotionBlur(playerPed, true)
        
        
        elseif level == 2 then
            ShakeGameplayCam("DRUNK_SHAKE", 0.5)
            SetPedMotionBlur(playerPed, true)
            SetTimecycleModifier("spectator3")
            SetPedIsDrunk(playerPed, true)

        
        elseif level == 3 then
            ShakeGameplayCam("DRUNK_SHAKE", 1.0)
            SetPedMotionBlur(playerPed, true)
            SetTimecycleModifier("spectator3") -- spectator6 est not use moins fort mais interessant
            SetPedMovementClipset(playerPed, "move_m@drunk@slightlydrunk", true)
            SetPedIsDrunk(playerPed, true)
            if player_drunk_level > 0 then 
                StartDrunkStumble(playerPed, 2000, stambleduration,3) -- Perte d'équilibre 
            end
        elseif level == 4 then
            ShakeGameplayCam("DRUNK_SHAKE", 1.5)
            SetPedMotionBlur(playerPed, true)
            SetTimecycleModifier("spectator5") -- spectator6 est not use moins fort mais interessant
            SetPedMovementClipset(playerPed, "move_m@drunk@moderatedrunk", true)
            SetPedIsDrunk(playerPed, true)
            StartDrunkStumble(playerPed, 2000, stambleduration,4) -- Perte d'équilibre 
        elseif level == 5 then
            ShakeGameplayCam("DRUNK_SHAKE", 2.0)
            SetPedMotionBlur(playerPed, true)
            SetTimecycleModifier("spectator5") -- spectator6 est not use moins fort mais interessant
            SetPedMovementClipset(playerPed, "move_m@drunk@verydrunk", true)
            SetPedIsDrunk(playerPed, true)
            StartDrunkStumble(playerPed, 2000, stambleduration,5) -- Perte d'équilibre 
        end

        if iscommand then
            -- Supprime l'effet après 12 secondes
            Citizen.SetTimeout(duration, function()
                ClearDrunkEffect()
                print ("this person was drunk by command")
            end)
        else
            --print ("this person was not drunk by command")
        end
    end

-- THREAD

    CreateThread(function() -- Pour charger le niveau d'alcool au dépar

        while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
            Wait(100)
            --print("En attente des données du joueur (citizenid)...")
        end

        local citizenid = QBX.PlayerData.citizenid
        print (json.encode(citizenid).. "loaded go get dunk lvl")
        TriggerServerEvent("qbx_Ab_AlcoolContrebande:server:GetDrunkLvl", citizenid)

    end)

    CreateThread(function() 
        while true do 
            Wait(500)  -- Vérification moins fréquente, plus optimisée
    
            if player_drunk_level > 0 then
                -- Déterminer le niveau d'ivresse et appliquer l'effet si nécessaire
                if player_drunk_level < Config.drunk_palier1 then
                    if Player_drunk_step ~= 0 then 
                        ClearDrunkEffect()
                        Player_drunk_step = 0
                    end
                elseif player_drunk_level >= Config.drunk_palier1 and player_drunk_level < Config.drunk_palier2 then
                    if Player_drunk_step ~= 1 then  -- Appliquer l'effet uniquement si le step a changé
                        ApplyDrunkEffect(1, 200*1000, false)
                        Player_drunk_step = 1
                    end
                elseif player_drunk_level >= Config.drunk_palier2 and player_drunk_level < Config.drunk_palier3 then
                    if Player_drunk_step ~= 2 then
                        ApplyDrunkEffect(2, 200*1000, false)
                        Player_drunk_step = 2
                    end
                elseif player_drunk_level >= Config.drunk_palier3 and player_drunk_level < Config.drunk_palier4 then
                    if Player_drunk_step ~= 3 then
                        ApplyDrunkEffect(3, 200*1000, false)
                        Player_drunk_step = 3
                    end
                elseif player_drunk_level >= Config.drunk_palier4 and player_drunk_level < Config.drunk_palier5 then
                    if Player_drunk_step ~= 4 then
                        ApplyDrunkEffect(4, 200*1000, false)
                        Player_drunk_step = 4
                    end
                elseif player_drunk_level >= Config.drunk_palier5 and player_drunk_level < Config.drunk_paliermax then
                    if Player_drunk_step ~= 5 then
                        ApplyDrunkEffect(5, 200*1000, false)
                        Player_drunk_step = 5
                    end
                elseif player_drunk_level >= Config.drunk_paliermax then
                    if Player_drunk_step ~= 6 then
                        local playerPed = PlayerPedId()
                        SetEntityHealth(playerPed, 0)
                        Player_drunk_step = 6
                        exports.qbx_core:Notify('Vous avez fait un coma éthylique', 'warning', 15000)
                    end
                end
    
                -- Réduction du niveau d'ivresse
                player_drunk_level = player_drunk_level - 1
                TriggerServerEvent("qbx_Ab_AlcoolContrebande:server:UpdateDrunkLvl", player_drunk_level)
                --print (Player_drunk_step.. " est le step drunk")
    
                Wait(Config.tic_time_undrunk)  -- Attendre avant de diminuer à nouveau
            else
                if Player_drunk_step ~= 0 then 
                    Player_drunk_step = 0
                    ClearDrunkEffect()
                    TriggerServerEvent("qbx_Ab_AlcoolContrebande:server:UpdateDrunkLvl", player_drunk_level)
                end
            end
        end
    end)
    


-- EVENTS

    RegisterNetEvent('qbx_Ab_AlcoolContrebande:client:updateDrunk')
    AddEventHandler('qbx_Ab_AlcoolContrebande:client:updateDrunk', function(recievedDrunkLvl)
        player_drunk_level = recievedDrunkLvl
        --print("Niveau de Drunk lvl mis à jour " ..player_drunk_level)
    end)

    RegisterNetEvent('qbx_Ab_AlcoolContrebande:client:increaseDrunk')
    AddEventHandler('qbx_Ab_AlcoolContrebande:client:increaseDrunk', function(value)
        player_drunk_level = player_drunk_level + value
        --print("Niveau de Drunk lvl a augmenté de  " ..value.. " elle est désormais de: " ..player_drunk_level)
    end)

    RegisterNetEvent('qbx_Ab_AlcoolContrebande:client:decreaseDrunk')
    AddEventHandler('qbx_Ab_AlcoolContrebande:client:decreaseDrunk', function(value)
        player_drunk_level = player_drunk_level - value
        --print("Niveau de Drunk lvl a réduit de  " ..value.. " elle est désormais de: " ..player_drunk_level)
    end)

    RegisterNetEvent('qbx_Ab_AlcoolContrebande:client:setDrunk')
    AddEventHandler('qbx_Ab_AlcoolContrebande:client:setDrunk', function(value)
        player_drunk_level = value
        print("Niveau de Drunk lvl est désormais de  " ..player_drunk_level)
    end)

    -- Réception du drunklvl de la cible
    RegisterNetEvent('qbx_Ab_AlcoolContrebande:client:showTargetDrunkLvl')
    AddEventHandler('qbx_Ab_AlcoolContrebande:client:showTargetDrunkLvl', function(drunkLvl)
        --print ("cette personne a pour drunkLvl " ..drunkLvl)
        local notifDuration = 15000

        if drunkLvl > 0 and drunkLvl < Config.drunk_palier1 then
            exports.qbx_core:Notify("Cette personne a moins de 0.25mg d'alcool par litre d'air expiré.", "inform", notifDuration)
            Wait (500)
        elseif drunkLvl >= Config.drunk_palier1 and drunkLvl < Config.drunk_palier2 then
            exports.qbx_core:Notify("Cette personne a environ 0.50mg d'alcool par litre d'air expiré.", "warning", notifDuration)
            Wait (500)
        elseif drunkLvl >= Config.drunk_palier2 and drunkLvl < Config.drunk_palier3 then
            exports.qbx_core:Notify("Cette personne a environ 1.00mg d'alcool par litre d'air expiré.", "warning", notifDuration)
            Wait (500)
        elseif drunkLvl >= Config.drunk_palier3 and drunkLvl < Config.drunk_palier4 then
            exports.qbx_core:Notify("Cette personne a environ 1.50mg d'alcool par litre d'air expiré.", "warning", notifDuration)
            Wait (500)
        elseif drunkLvl >= Config.drunk_palier4 and drunkLvl < Config.drunk_palier5 then
            exports.qbx_core:Notify("Cette personne a environ 2.0mg d'alcool par litre d'air expiré.", "warning", notifDuration)
            Wait (500)
        elseif drunkLvl >= Config.drunk_palier5 then
            exports.qbx_core:Notify("Cette personne a plus de 2.5mg d'alcool par litre d'air expiré.", "warning", notifDuration)
            Wait (500)
        else
            exports.qbx_core:Notify("Cette personne n'est pas alcoolisée.", "success", notifDuration)
            Wait (500)
        end
    end)    

-- EXPORT D'ITEM 
    -- gin
        exports('gin_bottle', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 25
            local propModel = 'prop_bottle_brandy'
            local drunklvl_up = 79
            local duration = 10000


            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then

                    -- anim + item
                    -- Créer le prop et l'attacher à la main gauche du joueur
                    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.0, -0.26, 0.1, 240.0, -60.0, 0.0, true, true, false, true, 1, true)
                    PlayAnimation("mp_player_intdrink", "loop_bottle", duration, 49)
                    DeleteObject(prop)
                    
                    TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'gin_empty')


                end
            end)

        end)

        exports('gin_goblet', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 5
            local propModel = 'v_ind_cfcup'
            local drunklvl_up = 18
            local duration = 5000


            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then

                    -- anim + item
                    -- Créer le prop et l'attacher à la main gauche du joueur
                    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.13, 0.02, -0.01, 270.0, 0.0, 0.0, true, true, false, true, 1, true)
                    PlayAnimation("mp_player_intdrink", "loop_bottle", 5000, 49)
                    DeleteObject(prop)
                    
                    TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'goblet')


                end
            end)

        end)

    -- pastis
    exports('alanis_bottle', function(data, slot)
        local player = PlayerPedId()
        local stress_down = 20
        local propModel = 'prop_bottle_brandy'
        local drunklvl_up = 60
        local duration = 10000


        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then

                -- anim + item
                -- Créer le prop et l'attacher à la main gauche du joueur
                local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.0, -0.26, 0.1, 240.0, -60.0, 0.0, true, true, false, true, 1, true)
                PlayAnimation("mp_player_intdrink", "loop_bottle", duration, 49)
                DeleteObject(prop)
                
                TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'alanis_empty')


            end
        end)

    end)

    exports('alanis_goblet', function(data, slot)
        local player = PlayerPedId()
        local stress_down = 4
        local propModel = 'v_ind_cfcup'
        local drunklvl_up = 12
        local duration = 5000


        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then

                -- anim + item
                -- Créer le prop et l'attacher à la main gauche du joueur
                local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.13, 0.02, -0.01, 270.0, 0.0, 0.0, true, true, false, true, 1, true)
                PlayAnimation("mp_player_intdrink", "loop_bottle", 5000, 49)
                DeleteObject(prop)
                
                TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'goblet')


            end
        end)

    end)

    exports('alanis_goblet_watered', function(data, slot)
        local player = PlayerPedId()
        local stress_down = 4
        local propModel = 'v_ind_cfcup'
        local drunklvl_up = 12
        local soif_up = 10
        local duration = 5000


        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then

                -- anim + item
                -- Créer le prop et l'attacher à la main gauche du joueur
                local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.13, 0.02, -0.01, 270.0, 0.0, 0.0, true, true, false, true, 1, true)
                PlayAnimation("mp_player_intdrink", "loop_bottle", 5000, 49)
                DeleteObject(prop)
                
                TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                TriggerServerEvent('consumables:server:addThirst',soif_up)
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'goblet')


            end
        end)

    end)    

    -- champagne
        exports('champagne_bottle', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 10
            local propModel = 'prop_bottle_brandy'
            local drunklvl_up = 35
            local duration = 10000


            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then

                    -- anim + item
                    -- Créer le prop et l'attacher à la main gauche du joueur
                    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.0, -0.26, 0.1, 240.0, -60.0, 0.0, true, true, false, true, 1, true)
                    PlayAnimation("mp_player_intdrink", "loop_bottle", duration, 49)
                    DeleteObject(prop)
                    
                    TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'champagne_empty')


                end
            end)

        end)

        exports('champagne_flute', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 2
            local propModel = 'prop_drink_champ'
            local drunklvl_up = 8
            local duration = 5000


            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then

                    -- anim + item
                    -- Créer le prop et l'attacher à la main gauche du joueur
                    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.10, 0.02, -0.02, 270.0, 340.0, 0.0, true, true, false, true, 1, true)
                    PlayAnimation("anim@heists@humane_labs@finale@keycards", "ped_a_enter_loop", 5000, 49)
                    DeleteObject(prop)
                    
                    TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'flute_empty')


                end
            end)

        end)
    
    -- Windy
        exports('windy_bottle_orange', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 15
            local propModel = 'prop_vodka_bottle'
            local drunklvl_up = 40
            local duration = 10000


            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then

                    -- anim + item
                    -- Créer le prop et l'attacher à la main gauche du joueur
                    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.0, -0.26, 0.1, 240.0, -60.0, 0.0, true, true, false, true, 1, true)
                    PlayAnimation("mp_player_intdrink", "loop_bottle", duration, 49)
                    DeleteObject(prop)
                    
                    TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'windy_empty')


                end
            end)

        end)

        exports('windy_goblet_orange', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 3
            local propModel = 'v_ind_cfcup'
            local drunklvl_up = 10
            local duration = 5000


            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then

                    -- anim + item
                    -- Créer le prop et l'attacher à la main gauche du joueur
                    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.13, 0.02, -0.01, 270.0, 0.0, 0.0, true, true, false, true, 1, true)
                    PlayAnimation("mp_player_intdrink", "loop_bottle", 5000, 49)
                    DeleteObject(prop)
                    
                    TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'goblet')


                end
            end)

        end)

        exports('windy_bottle_rose', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 15
            local propModel = 'prop_vodka_bottle'
            local drunklvl_up = 35
            local duration = 10000


            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then

                    -- anim + item
                    -- Créer le prop et l'attacher à la main gauche du joueur
                    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.0, -0.26, 0.1, 240.0, -60.0, 0.0, true, true, false, true, 1, true)
                    PlayAnimation("mp_player_intdrink", "loop_bottle", duration, 49)
                    DeleteObject(prop)
                    
                    TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'windy_empty')


                end
            end)

        end)

        exports('windy_goblet_rose', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 3
            local propModel = 'v_ind_cfcup'
            local drunklvl_up = 9
            local duration = 5000


            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then

                    -- anim + item
                    -- Créer le prop et l'attacher à la main gauche du joueur
                    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.13, 0.02, -0.01, 270.0, 0.0, 0.0, true, true, false, true, 1, true)
                    PlayAnimation("mp_player_intdrink", "loop_bottle", 5000, 49)
                    DeleteObject(prop)
                    
                    TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'goblet')


                end
            end)

        end)
        
        exports('windy_bottle_bleu', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 15
            local propModel = 'prop_vodka_bottle'
            local drunklvl_up = 50
            local duration = 10000


            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then

                    -- anim + item
                    -- Créer le prop et l'attacher à la main gauche du joueur
                    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.0, -0.26, 0.1, 240.0, -60.0, 0.0, true, true, false, true, 1, true)
                    PlayAnimation("mp_player_intdrink", "loop_bottle", duration, 49)
                    DeleteObject(prop)
                    
                    TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'windy_empty')


                end
            end)

        end)

        exports('windy_goblet_bleu', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 3
            local propModel = 'v_ind_cfcup'
            local drunklvl_up = 12
            local duration = 5000


            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then

                    -- anim + item
                    -- Créer le prop et l'attacher à la main gauche du joueur
                    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.13, 0.02, -0.01, 270.0, 0.0, 0.0, true, true, false, true, 1, true)
                    PlayAnimation("mp_player_intdrink", "loop_bottle", 5000, 49)
                    DeleteObject(prop)
                    
                    TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'goblet')


                end
            end)

        end)

        exports('windy_bottle_jaune', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 15
            local propModel = 'prop_vodka_bottle'
            local drunklvl_up = 45
            local duration = 10000


            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then

                    -- anim + item
                    -- Créer le prop et l'attacher à la main gauche du joueur
                    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.0, -0.26, 0.1, 240.0, -60.0, 0.0, true, true, false, true, 1, true)
                    PlayAnimation("mp_player_intdrink", "loop_bottle", duration, 49)
                    DeleteObject(prop)
                    
                    TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'windy_empty')


                end
            end)

        end)

        exports('windy_goblet_jaune', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 3
            local propModel = 'v_ind_cfcup'
            local drunklvl_up = 11
            local duration = 5000


            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then

                    -- anim + item
                    -- Créer le prop et l'attacher à la main gauche du joueur
                    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.13, 0.02, -0.01, 270.0, 0.0, 0.0, true, true, false, true, 1, true)
                    PlayAnimation("mp_player_intdrink", "loop_bottle", 5000, 49)
                    DeleteObject(prop)
                    
                    TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'goblet')


                end
            end)

        end)

        exports('windy_bottle_verte', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 35
            local propModel = 'prop_vodka_bottle'
            local drunklvl_up = 50
            local duration = 10000


            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then

                    -- anim + item
                    -- Créer le prop et l'attacher à la main gauche du joueur
                    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.0, -0.26, 0.1, 240.0, -60.0, 0.0, true, true, false, true, 1, true)
                    PlayAnimation("mp_player_intdrink", "loop_bottle", duration, 49)
                    DeleteObject(prop)
                    
                    TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'windy_empty')


                end
            end)

        end)

        exports('windy_goblet_verte', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 7
            local propModel = 'v_ind_cfcup'
            local drunklvl_up = 12
            local duration = 5000


            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then

                    -- anim + item
                    -- Créer le prop et l'attacher à la main gauche du joueur
                    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.13, 0.02, -0.01, 270.0, 0.0, 0.0, true, true, false, true, 1, true)
                    PlayAnimation("mp_player_intdrink", "loop_bottle", 5000, 49)
                    DeleteObject(prop)
                    
                    TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'goblet')


                end
            end)

        end)

    -- biere
        exports('beer', function(data, slot)
            local player = PlayerPedId()
            local stress_down = 5
            local propModel = 'prop_beer_bottle'
            local drunklvl_up = 8
            local duration = 5000


            -- Triggers internal-code to correctly use items.
            -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
            exports.ox_inventory:useItem(data, function(used)
                -- The server has verified the item can be used.
                if used then

                    -- anim + item
                    -- Créer le prop et l'attacher à la main gauche du joueur
                    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.04, -0.14, 0.1, 240.0, -60.0, 0.0, true, true, false, true, 1, true)
                    PlayAnimation("mp_player_intdrink", "loop_bottle", 5000, 49)
                    DeleteObject(prop)
                    
                    TriggerEvent ('qbx_Ab_AlcoolContrebande:client:increaseDrunk', drunklvl_up)
                    TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress 
                    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'beer_empty')


                end
            end)

        end)    

-- TARGET

    -- Cibler les joueurs pour voir leur niveau de d'alcoolémie
    exports.ox_target:addGlobalPlayer({

        {
            icon = 'fas fa-bed', -- Icône pour l'interaction
            label = "Utiliser l'éthylotest",
            distance = 1.5, -- Distance pour interagir avec un autre joueur
            icon = 'fa-solid fa-martini-glass',
            groups = Config.ethylo_jobRequired,
            items = Config.item_ethylo,
            onSelect = function(data)
                local targetPlayerIndex = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                --print ('targetPlayerIndex : ' ..targetPlayerIndex)
                TriggerServerEvent('qbx_Ab_AlcoolContrebande:server:getTargetDrunklvl', targetPlayerIndex)
            end
        }

    })

    exports.ox_target:addModel(
        Config.waterfillprop,  
       {  
            -- Option pour remplir un arrosoir
            {
                name = "alanisWater",
                label = "Ajouter de l'eau à l'Al'Anis",
                icon = 'fa-solid fa-droplet', 
                items = 'alanis_goblet',
                distance = 1.5,
                onSelect = function()
                    TriggerServerEvent('qbx_Ab_AlcoolContrebande:server:water_alanis')
                end,
            },
    
        }
    )

-- COMMANDES
    -- Commande pour appliquer l'effet en précisant un niveau
    RegisterCommand("drunk", function(source, args)
        local level = tonumber(args[1])
        local duration = 12000
        local command = true
        if level and level >= 1 and level <= 5 then
            ApplyDrunkEffect(level, duration, command)
        else 
            print("Utilisation: /drunk [1-5]")
        end
    end, false)

