
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

-- ///////// COMMANDES ////////////////

    RegisterCommand("playanim", function(source, args)
        -- Vérifier si les arguments sont suffisants
        if #args < 2 then
            print("Utilisation : /playanim [dict] [name] [flag (optionnel)]")
            return
        end

        -- Récupérer les arguments
        local animDict = args[1]
        local animName = args[2]
        -- Vérifier si un flag est fourni, sinon utiliser la valeur par défaut (49)
        local animFlag = tonumber(args[3]) or 49

        -- Durée par défaut (peut être modifiée)
        local duration = 5000 -- 5 secondes

        -- Jouer l'animation
        PlayAnimation(animDict, animName, duration, animFlag)
        print ("Anim played")
    end, false) -- False : commande accessible à tous


    RegisterCommand("lowThirst", function(source, args, rawcommand)
        local player = PlayerPedId()
        TriggerServerEvent('consumables:server:setThirst',10)
    end,false)

    RegisterCommand("lowHunger", function(source, args, rawcommand)
        local player = PlayerPedId()
        TriggerServerEvent('consumables:server:setHunger',10)
    end,false)

-- ///////////// MANGER A TABLE

    exports.ox_target:addModel(
        Config.props_table,  -- Liste des modèles de table
        {  
            -- Option pour manger un burger
            {
                name = "eat_burger",
                label = "Manger un Hamburger",
                items = "hamburger",
                icon = "fa-solid fa-burger",
                onSelect = function(data)
                    local propCoords = json.encode(GetEntityCoords(data.entity))
                    local propName = "Table"
                    print(propCoords)
                    TriggerServerEvent('qbx_Ab_Consomable:server:eatburger',propCoords, propName)
                    Wait(10)
                end,
            },
            -- Option pour manger une omelette
            {
                name = "eat_omelette",
                label = "Manger une omelette",
                items = "omelette",
                icon = "fa-solid fa-utensils",
                onSelect = function(data)
                    local propCoords = json.encode(GetEntityCoords(data.entity)) 
                    local propName = "Table"
                    TriggerServerEvent('qbx_Ab_Consomable:server:eatomelette',propCoords, propName)  
                    Wait(10)
                end,
            },        
            -- Option pour manger une salade de tomate
            {
                name = "eat_saladetomate",
                label = "Manger une salade de tomate",
                items = "salade_tomate",
                icon = "fa-solid fa-plate-wheat",
                onSelect = function(data)
                    local propCoords = json.encode(GetEntityCoords(data.entity))  
                    local propName = "Table"
                    TriggerServerEvent('qbx_Ab_Consomable:server:eatsaladetomate',propCoords, propName) 
                    Wait(10) 
                end,
            },
            -- Option pour manger des frites
            {
                name = "eat_frite",
                label = "Manger des frites",
                items = "frite",
                icon = "fa-solid fa-utensils",
                onSelect = function(data)
                    local propCoords = json.encode(GetEntityCoords(data.entity)) 
                    local propName = "Table"
                    TriggerServerEvent('qbx_Ab_Consomable:server:eatfrite',propCoords, propName)  
                    Wait(10)
                end,
            }, 
            -- Option pour manger une pizza
            {
                name = "eat_pizza",
                label = "Manger une pizza",
                items = "pizza",
                icon = "fa-solid fa-pizza-slice",
                onSelect = function(data)
                    local propCoords = json.encode(GetEntityCoords(data.entity))
                    local propName = "Table"
                    print(propCoords)
                    TriggerServerEvent('qbx_Ab_Consomable:server:eatpizza',propCoords, propName)
                    Wait(10)
                end,
            },       
        }
    )

    -- Animation pour manger un burger
    RegisterNetEvent('qbx_Ab_CafetCraft:client:eatburgerAnimation')
    AddEventHandler('qbx_Ab_CafetCraft:client:eatburgerAnimation', function()
        local player = PlayerPedId()
        local propmodel = 'prop_cs_burger_01'

        local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
        AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.13, 0.05, 0.02, -50.0, 16.0, 60.0, true, true, false, true, 1, true)

        PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 8000, 49)

        DeleteObject(prop) -- Supprimer le prop après l'animation

        -- Si il se passe des chose
        local fatigue_up = 5
        local hungerup = 75

        TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_up) -- augmente la fatigue
        TriggerServerEvent('consumables:server:addHunger', hungerup)

    end)

    -- Animation pour manger une omelette
    RegisterNetEvent('qbx_Ab_CafetCraft:client:eatomeletteAnimation')
    AddEventHandler('qbx_Ab_CafetCraft:client:eatomeletteAnimation', function()
        local player = PlayerPedId()
        local propmodel = 'eaz_meal_03'

        local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
        AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.12, 0.05, 0.0, 270.0, 180.0, 0.0, true, true, false, true, 1, true)

        -- fonction perso d'animation (fonction a changer si on veut coller un props à la main)
        PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 8000, 49)

        DeleteObject(prop) -- Supprimer le prop après l'animation

        -- Si il se passe des chose
        local hungerup = 50

        TriggerServerEvent('consumables:server:addHunger', hungerup)

    end)

    -- Animation pour manger une salade de tomates
    RegisterNetEvent('qbx_Ab_CafetCraft:client:eatsaladetomateAnimation')
    AddEventHandler('qbx_Ab_CafetCraft:client:eatsaladetomateAnimation', function()
        local player = PlayerPedId()
        local propmodel = 'eaz_meal_02'

        local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
        AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.12, 0.05, 0.0, 300.0, 180.0, 0.0, true, true, false, true, 1, true)

        PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 8000, 49)

        DeleteObject(prop) -- Supprimer le prop après l'animation

        -- Si il se passe des chose
        local hungerup = 60

        TriggerServerEvent('consumables:server:addHunger', hungerup)

    end)

    -- Animation pour manger des frites
    RegisterNetEvent('qbx_Ab_CafetCraft:client:eatfriteAnimation')
    AddEventHandler('qbx_Ab_CafetCraft:client:eatfriteAnimation', function()
        local player = PlayerPedId()
        local propmodel = 'eaz_meal_01'

        local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
        AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.15, 0.05, 0.0, 100.0, 0.0, 180.0, true, true, false, true, 1, true)


        -- fonction perso d'animation (fonction a changer si on veut coller un props à la main)
        PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 4000, 49)

        DeleteObject(prop) -- Supprimer le prop après l'animation

        -- Si il se passe des chose
        local hungerup = 25

        TriggerServerEvent('consumables:server:addHunger', hungerup)
        TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'frite_carton')

    end)

    -- Animation pour manger un burger
    RegisterNetEvent('qbx_Ab_CafetCraft:client:eatpizzaAnimation')
    AddEventHandler('qbx_Ab_CafetCraft:client:eatpizzaAnimation', function()
        local player = PlayerPedId()
        local propmodel = 'eaz_meal_04'

        local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
        AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.13, 0.04, 0.0, 300.0, 140.0, 0.0, true, true, false, true, 1, true)

        PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 8000, 49)

        DeleteObject(prop) -- Supprimer le prop après l'animation

        -- Si il se passe des chose
        local fatigue_up = 10
        local hungerup = 50

        TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_up) -- augmente la fatigue
        TriggerServerEvent('consumables:server:addHunger', hungerup)

    end)

-- // notif pour dire qu'il faut manger à table

    exports('hamburger', function(data, slot)
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

    exports('pizza', function(data, slot)
        local player = PlayerPedId()
     
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                
                exports.qbx_core:Notify("Une pizza doit être mangé à table.", 'error', 5000)

            end
          end)
    
    end)

    exports('omelette', function(data, slot)
        local player = PlayerPedId()
     
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                
                exports.qbx_core:Notify("Une omelette doit être mangé à table.", 'error', 5000)

            end
          end)
    
    end)

    exports('salade_tomate', function(data, slot)
        local player = PlayerPedId()
     
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                
                exports.qbx_core:Notify("Une salade doit être mangé à table.", 'error', 5000)

            end
          end)
    
    end)

    exports('frite', function(data, slot)
        local player = PlayerPedId()
     
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                
                exports.qbx_core:Notify("Une frite doit être mangé à table.", 'error', 5000)

            end
          end)
    
    end)

-- // machine a bonbon

    exports.ox_target:addModel(
        Config.props_bonbon,  -- Liste des modèles de table
        {  
            -- Option pour manger un burger
            {
                name = "bonbon_jeton",
                label = "Inserer un bon point",
                items = "jeton",
                icon = "fa-solid fa-candy-cane",
                onSelect = function(data)
                    TriggerServerEvent('qbx_Ab_Consomable:server:eatcandy')  
                end,
            },
        }
    )

    -- Animation pour manger un burger
    RegisterNetEvent('qbx_Ab_CafetCraft:client:eatcandyAnimation')
    AddEventHandler('qbx_Ab_CafetCraft:client:eatcandyAnimation', function()

        -- fonction perso d'animation (fonction a changer si on veut coller un props à la main)
        PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 1000, 49)

        --DeleteObject(prop) -- Supprimer la bonbonne après l'animation

        -- Si il se passe des chose
        local stress_down = 5

        TriggerServerEvent('hud:server:RelieveStress',stress_down)

    end)


-- ///////////// CE QUE FONT LE OBJET LORSQUE USE

-- BOISSONS CHAUDES

    exports('chococho', function(data, slot)
        local player = PlayerPedId()
        local stress_down = 20
        local soif_up = 70
        local duration = 8000
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                local propmodel = 'p_amb_coffeecup_01'

                local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

                PlayAnimation("amb@prop_human_seat_chair_drink@female@generic@base", "base", duration, 49)

                DeleteObject(prop) -- Supprimer le prop après l'animation

                -- effet
                TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress de 5
                TriggerServerEvent('consumables:server:addThirst',soif_up)
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'goblet')
                --print ('soif up de '.. soif_up)
            end
        end)

    end)

    exports('namas_tea', function(data, slot)
        local player = PlayerPedId()
        local soif_up = 80
        local drunkdown = 10
        local duration = 8000
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                local propmodel = 'p_amb_coffeecup_01'

                local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

                PlayAnimation("amb@prop_human_seat_chair_drink@female@generic@base", "base", duration, 49)

                DeleteObject(prop) -- Supprimer le prop après l'animation

                TriggerServerEvent('consumables:server:addThirst',soif_up)
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'goblet')
                TriggerEvent ('qbx_Ab_AlcoolContrebande:client:decreaseDrunk', drunkdown)
                --print ('soif up de '.. soif_up)
            end
        end)

    end)

    exports('ginseng_tea', function(data, slot)
        local player = PlayerPedId()
        local soif_up = 80
        local fatigue_down = -10
        local stress_down = 10
        local drunkdown = 20
        local duration = 13000
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                local propmodel = 'v_ind_cfcup'

                local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

                PlayAnimation("amb@prop_human_seat_chair_drink@female@generic@base", "base", duration, 49)

                DeleteObject(prop) -- Supprimer le prop après l'animation

                TriggerServerEvent('consumables:server:addThirst',soif_up)
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_down)
                TriggerServerEvent('hud:server:RelieveStress',stress_down)
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'goblet')
                TriggerEvent ('qbx_Ab_AlcoolContrebande:client:decreaseDrunk', drunkdown)
                --print ('soif up de '.. soif_up)
            end
        end)

    end)

    exports('powcoffee', function(data, slot)
        local player = PlayerPedId()
        local soif_up = 15
        local stress_up = 5
        local fatigue_down = -15
        local duration = 8000
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then

                local propmodel = 'p_amb_coffeecup_01'

                local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

                PlayAnimation("amb@prop_human_seat_chair_drink@female@generic@base", "base", 5000, 49)

                DeleteObject(prop) -- Supprimer le prop après l'animation

                TriggerServerEvent('consumables:server:addThirst',soif_up)
                TriggerServerEvent('hud:server:GainStress',stress_up)
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_down) -- baisse la fatigue 
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'goblet')
                --print ('soif up de '.. soif_up)
            end
        end)

    end)

-- SODA

    exports('sprout', function(data, slot)
        local player = PlayerPedId()
        local stress_down = 5
        local soif_down = -5
        local propModel = 'eaz_sodacan_01'

    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then

                -- anim + item
                -- Créer le prop et l'attacher à la main gauche du joueur
                local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.06, -0.03, 0.04, 230.0, 260.0, 40.0, true, true, false, true, 1, true)
                PlayAnimation("mp_player_intdrink", "loop_bottle", 3000, 49)
                DeleteObject(prop)
                
                TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress de 5
                --print('[DEBUG CLIENT] AddThirst triggered from script:', json.encode(GetCurrentResourceName()), ' amount:', soif_down)
                TriggerServerEvent('consumables:server:addThirst',soif_down)
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'sprout_empty')

            end
        end)

    end)

    exports('jumbo', function(data, slot)
        local player = PlayerPedId()
        local soif_up = 10
        local hungerdown = -5
        local propModel = 'eaz_sodacan_02'
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                
                -- anim + item
                -- Créer le prop et l'attacher à la main gauche du joueur
                local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.06, -0.03, 0.04, 230.0, 260.0, 40.0, true, true, false, true, 1, true)
                PlayAnimation("mp_player_intdrink", "loop_bottle", 3000, 49)
                DeleteObject(prop)

                TriggerServerEvent('consumables:server:addThirst',soif_up)
                TriggerServerEvent('consumables:server:addHunger', hungerdown)
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'jumbo_empty')

            end
        end)

    end)

    exports('cocola', function(data, slot)
        local player = PlayerPedId()
        local stress_up = 8
        local fatigue_down = -5
        local propModel = 'eaz_sodacan_03'
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then

                -- anim + item
                -- Créer le prop et l'attacher à la main gauche du joueur
                local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.06, -0.03, 0.04, 230.0, 260.0, 40.0, true, true, false, true, 1, true)

                PlayAnimation("mp_player_intdrink", "loop_bottle", 3000, 49)
                DeleteObject(prop)

                TriggerServerEvent('hud:server:GainStress',stress_up)
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_down) -- baisse la fatigue
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'cocola_empty')

            end
        end)

    end)

-- SNACKS

    exports('roar', function(data, slot)
        local player = PlayerPedId()
        local stress_up = 4
        local fatigue_down = -5
        local hungerup = 10
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                local player = PlayerPedId()
                local propmodel = 'eaz_roar'
        
                local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.13, 0.05, 0.02, 260.0, 0.0, 0.0, true, true, false, true, 1, true)
        
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 3000, 49)
        
                DeleteObject(prop) -- Supprimer le prop après l'animation

                TriggerServerEvent('hud:server:GainStress',stress_up)
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_down) -- baisse la fatigue
                TriggerServerEvent('consumables:server:addHunger', hungerup)
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'roar_empty')

            end
        end)

    end)

    exports('bellevillewood', function(data, slot)
        local player = PlayerPedId()
        local stress_down = 4
        local fatigue_up = 10
        local hungerdown = -10
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                local player = PlayerPedId()
                local propmodel = 'eaz_belleville'
        
                local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.13, 0.05, 0.02, 260.0, 0.0, 0.0, true, true, false, true, 1, true)
        
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 1500, 49)
        
                DeleteObject(prop) -- Supprimer le prop après l'animation

                TriggerServerEvent('hud:server:RelieveStress',stress_down) -- event qui baisse le stress de 5
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_up) -- augmente la fatigue
                TriggerServerEvent('consumables:server:addHunger', hungerdown)
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'bellevillewood_empty')
            end
        end)

    end)

    exports('swacks', function(data, slot)
        local player = PlayerPedId()
        local stress_up = 4
        local fatigue_up = 5
        local hungerup = 20
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                local player = PlayerPedId()
                local propmodel = 'eaz_swacks'
        
                local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.13, 0.05, 0.02, 260.0, 0.0, 0.0, true, true, false, true, 1, true)
        
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 5000, 49)
        
                DeleteObject(prop) -- Supprimer le prop après l'animation
                
                
                TriggerServerEvent('hud:server:GainStress',stress_up)
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_up) -- baisse la fatigue
                TriggerServerEvent('consumables:server:addHunger', hungerup)
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'swacks_empty')

            end
        end)

    end)

-- INGREDIENT COMMESTIBLE 



    exports('salade', function(data, slot)
        local player = PlayerPedId()
        local hungerup = 10
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 10000, 49)
                TriggerServerEvent('consumables:server:addHunger', hungerup)

            end
        end)

    end)

    exports('feuille_salade', function(data, slot)
        local player = PlayerPedId()
        local hungerup = 5
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 5000, 49)
                TriggerServerEvent('consumables:server:addHunger', hungerup)

            end
        end)

    end)

    exports('tomate', function(data, slot)
        local player = PlayerPedId()
        local hungerup = 10
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 4000, 49)
                TriggerServerEvent('consumables:server:addHunger', hungerup)

            end
        end)

    end)

    exports('tomate_decoupe', function(data, slot)
        local player = PlayerPedId()
        local hungerup = 10
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 4000, 49)
                TriggerServerEvent('consumables:server:addHunger', hungerup)

            end
        end)

    end)

    exports('steakcuit', function(data, slot)
        local player = PlayerPedId()
        local hungerup = 30
        local fatigue_up = 5
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then

                local propmodel = 'prop_cs_steak'

                local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.15, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 4000, 49)

                DeleteObject(prop) -- Supprimer le prop après l'animation

                TriggerServerEvent('consumables:server:addHunger', hungerup)
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_up) -- augmente la fatigue

            end
        end)

    end)

    exports('pain', function(data, slot)
        local player = PlayerPedId()
        local hungerup = 10
        local soif_down = -10
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 4000, 49)
                TriggerServerEvent('consumables:server:addHunger', hungerup)
                TriggerServerEvent('consumables:server:addThirst',soif_down)

            end
        end)

    end)

-- AUTRE
