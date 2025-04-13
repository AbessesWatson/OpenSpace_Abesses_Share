local plantstate = nil

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
        RemoveAnimDict(animdict)
    end

    -- Fonction pour appliquer l'effet de défoncé
    function applyHighEffect(duration)
        local playerPed = PlayerPedId()

        -- Appliquer un effet visuel (exemple : effet de flou sur l'écran)
        --print("modifier")
        AnimpostfxPlay('BeastLaunch', duration, true)

        -- Lancer un thread dédié pour arrêter l'effet après la durée
        Citizen.CreateThread(function()
            Wait(duration) -- Attend la durée sans bloquer d'autres threads
            AnimpostfxStop('BeastLaunch')
            --print("endmodifier")
        end)

    end

-- PLANTE GESTION

    -- Écoute la réception de la variable plantstate
    RegisterNetEvent("qbx_Ab_Weed:client:PlantState")
    AddEventHandler("qbx_Ab_Weed:client:PlantState", function(state)
        plantstate = state
    end)

    -- Écoute la réception de la variable plantstate
    RegisterNetEvent("qbx_Ab_Weed:client:highEffect")
    AddEventHandler("qbx_Ab_Weed:client:highEffect", function(duration)
        print('applyHighEffect')
        applyHighEffect(duration)
    end)


    -- Utilisation de ox_target pour détecter l'interaction
    exports.ox_target:addModel(
        Config.plantprops,  
        {  
            -- Option pour arroser la plante methode cafet 
            {
                name = "water_plant_cafet",
                label = "Arroser la Plante avec la casserole",
                icon = 'fa-solid fa-water', 
                items = Config.wateritem_cafet,
                distance = 1.5,
                canInteract = function(entity, distance, coords)
                    TriggerServerEvent('qbx_Ab_Weed:server:PlantStatecheck')
                    Wait (2)
                        
                    if plantstate == 'needW' then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    TriggerServerEvent('qbx_Ab_Weed:server:waterPlant', Config.wateritem_cafet)  
                end,
            },
            -- Option pour arroser la plante methode menage
            {
                name = "water_plant_menage",
                label = "Arroser la Plante avec le seau d'eau",
                icon = 'fa-solid fa-water', 
                items = Config.wateritem_menage,
                distance = 1.5,
                canInteract = function(entity, distance, coords)
                    TriggerServerEvent('qbx_Ab_Weed:server:PlantStatecheck')
                    Wait (2)
                        
                    if plantstate == 'needW' then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    TriggerServerEvent('qbx_Ab_Weed:server:waterPlant', Config.wateritem_menage)  
                end,
            },
            -- Option pour arroser la plante methode classic
            {
                name = "water_plant_classic",
                label = "Arroser la Plante avec l'arrosoir",
                icon = 'fa-solid fa-water', 
                items = Config.wateritem_classic,
                distance = 1.5,
                canInteract = function(entity, distance, coords)
                     TriggerServerEvent('qbx_Ab_Weed:server:PlantStatecheck')
                    Wait (2)
                                
                    if plantstate == 'needW' then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    TriggerServerEvent('qbx_Ab_Weed:server:waterPlant', Config.wateritem_classic)  
                    end,
            },
            -- Option pour récolter
            {
                name = "harvest_plant",
                label = "récolté",
                icon = 'fa-regular fa-hand',
                distance = 1.5,
                canInteract = function(entity, distance, coords)
                    TriggerServerEvent('qbx_Ab_Weed:server:PlantStatecheck')
                    Wait (2)
                        if plantstate == 'ready' then
                            return true
                        else
                            return false
                        end
                end,
                onSelect = function(data)
                    TriggerServerEvent('qbx_Ab_Weed:server:harvestPlant') 
                end,
            },
            -- Option pour verifier la plant
            {
                name = "check_plant",
                label = "Regarder l'état de la plante",
                icon = 'fas fa-search', 
                distance = 1.5,
                onSelect = function(data)
                    TriggerServerEvent('qbx_Ab_Weed:server:checkPlant') 
                end,
            }

        }
    )

-- Gestion arrosoir

     -- Utilisation de ox_target pour détecter l'interaction avec le lavabo
     exports.ox_target:addModel(
        Config.waterfillprop,  
       {  
            -- Option pour remplir un arrosoir
            {
                name = "full_can",
                label = "Remplir l'arrosoir",
                icon = 'fa-solid fa-droplet', 
                items = Config.wateritem_classic_empty,
                distance = 1.5,
                onSelect = function()
                    TriggerServerEvent('qbx_Ab_Weed:Server:full_can')
                end,
            },
            -- Option pour vider un arrosoir
            {
                name = "empty_can",
                label = "Vider l'arrosoir",
                icon = 'fa-solid fa-droplet-slash',
                items = Config.wateritem_classic,
                onSelect = function()
                    TriggerServerEvent('qbx_Ab_Weed:Server:empty_can')
                end,
            }
    
        }
    )

-- Target cigar

local areaTargetCigare = {
    coords = vec3(38.24, -14.93, 238.71),
    name = 'boite_cigare',
    radius = 0.5,
    debug = false,
    drawSprite = false,
    options = {  
        {
            name = "takecigare",
            label = "Prendre un Cigare",
            icon = 'fa-solid fa-smoking',
            distance = 1.5,
            onSelect = function(data)
                TriggerServerEvent('qbx_Ab_Weed:server:TakeCigare')  
            end,
        },
    }
}

exports.ox_target:addSphereZone(areaTargetCigare)

-- EXPORT ITEMS

    exports('os_joint', function(data, slot)
        local player = PlayerPedId()
        local hunger_down = -10
        local stress_down = 25
        local fatigue_up = 10
        local duration = Config.highduration
        local animduration = 20000
        local propmodel = 'p_cs_joint_02'
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                
                -- Créer et attacher le prop
                local prop = CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

                PlayAnimation("amb@world_human_smoking@female@idle_a", "idle_b", animduration, 49)

                DeleteObject(prop) -- Supprimer le prop après l'animation

                TriggerServerEvent('consumables:server:addHunger', hunger_down)
                TriggerServerEvent('hud:server:RelieveStress',stress_down)
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_up) -- baisse la fatigue
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'joint_butt')
                
                -- Appliquer un effet de défoncé temporaire
                TriggerEvent("qbx_Ab_Weed:client:highEffect", duration)
                            
            end
        end)

    end)

    exports('cigarette', function(data, slot)
        local player = PlayerPedId()
        local soif_down = -5
        local stress_down = 5
        local animduration = 15000
        local propmodel = 'prop_cs_ciggy_01'
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                
                -- Créer et attacher le prop
                local prop = CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

                PlayAnimation("amb@world_human_smoking@female@idle_a", "idle_b", animduration, 49)

                DeleteObject(prop) -- Supprimer le prop après l'animation
                TriggerServerEvent('consumables:server:addThirst', soif_down)
                TriggerServerEvent('hud:server:RelieveStress',stress_down)
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'cig_butt')
                
                -- Appliquer un effet de défoncé temporaire
                        
            end
        end)

    end)

    exports('cigare', function(data, slot)
        local player = PlayerPedId()
        local soif_down = -5
        local stress_down = 10
        local animduration = 10000
        local smokeduration = 60*1000
        local propmodel = 'prop_cigar_02'
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                
                -- Créer et attacher le prop
                local prop = CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 47419), 0.01, 0.0, 0.0, 50.0, 0.0, -80.0, true, true, false, true, 1, true)

                PlayAnimation("amb@world_human_smoking@male@male_a@enter", "enter", animduration, 49)
                Wait (smokeduration)
                DeleteObject(prop) -- Supprimer le prop après l'animation
                TriggerServerEvent('consumables:server:addThirst', soif_down)
                TriggerServerEvent('hud:server:RelieveStress',stress_down)
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'cigare_butt')
                
                -- Appliquer un effet de défoncé temporaire
                        
            end
        end)

    end)


-- EVENT D'ANIMATION 

    -- Animation pour arroser la plante
    RegisterNetEvent('qbx_Ab_Weed:client:waterPlantAnimation')
    AddEventHandler('qbx_Ab_Weed:client:waterPlantAnimation', function()

    
        PlayAnimation("amb@world_human_gardener_plant@male@idle_a", "idle_a", 5000, 64)

        -- Si il se passe des chose
        local fatigue_up = 5

        TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_up) -- augmente la fatigue

    end)

    -- Animation pour récolter la plante
    RegisterNetEvent('qbx_Ab_Weed:client:harvestPlantAnimation')
    AddEventHandler('qbx_Ab_Weed:client:harvestPlantAnimation', function()

    
        PlayAnimation("anim@move_m@trash", "pickup", 15000, 1)

        -- Si il se passe des chose


    end)

    -- Animation pour remplir un seau
    RegisterNetEvent('qbx_Ab_Weed:Client:full_canAnim')
    AddEventHandler('qbx_Ab_Weed:Client:full_canAnim', function()
        local playerPed = PlayerPedId()
        local animdic = "missmechanic"  -- dictionaire d'animation
        local animname = "work2_base" -- name animation
        local propModel = 'prop_wateringcan'  -- Modèle de props
        local durationAnim = 10000

    -- Créer le prop et l'attacher à la main gauche du joueur
    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 0x188E), 0.25, 0.00, -0.15, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

        -- Charger et jouer l'animation
        RequestAnimDict(animdic)
        while not HasAnimDictLoaded(animdic) do
            Wait(100)
            print ('no HasAnimDictLoaded')
        end

        TaskPlayAnim(playerPed, animdic, animname, 2.0, 2.0, durationAnim, 1, 0, false, false, false)
        exports.qbx_core:Notify("Vous remplissez un arrosoir", 'inform', durationAnim)
        Wait(durationAnim)
        ClearPedTasks(playerPed) -- Arrêter l'animation
        DeleteObject(prop) -- Supprimer le props après anim
    end)

    -- Animation pour vider un seau
    RegisterNetEvent('qbx_Ab_Weed:Client:empty_canAnim')
    AddEventHandler('qbx_Ab_Weed:Client:empty_canAnim', function()
        local playerPed = PlayerPedId()
        local animdic = "anim@heists@narcotics@trash"  -- dictionaire d'animation
        local animname = "throw_a" -- name animation
        local propModel = 'prop_wateringcan'  -- Modèle de props
        local durationAnim = 1000
    
    -- Créer le prop et l'attacher à la main gauche du joueur
    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 0x188E), 0.30, 0.00, -0.15, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    
        -- Charger et jouer l'animation
        RequestAnimDict(animdic)
        while not HasAnimDictLoaded(animdic) do
            Wait(100)
            print ('no HasAnimDictLoaded')
        end
    
        TaskPlayAnim(playerPed, animdic, animname, 0.8, 0.8, durationAnim, 1, 0, false, false, false)
    Wait(durationAnim)
        ClearPedTasks(playerPed) -- Arrêter l'animation
        DeleteObject(prop) -- Supprimer le props après anim
    end)


