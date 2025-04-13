local issearching = false

-- fonctions 

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


-- // AddModel

    exports.ox_target:addModel(
        Config.prop_smallgarbage,  -- Liste des modèles de Machine
        {  
            -- Option pour utliser la poubelle
            {
                name = "use_smallgarbage",
                label = "Utiliser la poubelle",
                icon = 'fa-solid fa-trash',
                distance = 1.5,
                onSelect = function(data)
                    garbageKind = 'small'
                    propCoords = json.encode(GetEntityCoords(data.entity)) 
                    TriggerServerEvent('qbx_Ab_Garbages:server:useGarbage', propCoords, garbageKind)  -- Envoie les coordonnées au serveur 
                    Wait(10)
                end,
            },
            -- Option pour vider la poubelle
            {
                name = "empty_smallgarbage",
                label = "Vider la poubelle",
                icon = 'fa-solid fa-trash-arrow-up',
                items = Config.smalltrash_item,
                groups = Config.jobRequired,
                distance = 1.5,
                onSelect = function(data)
                    garbageKind = 'small'
                    propCoords = json.encode(GetEntityCoords(data.entity)) 
                    TriggerServerEvent('qbx_Ab_Garbages:server:emptyGarbage', propCoords, garbageKind)  -- Envoie les coordonnées au serveur 
                    Wait(10)
                end,
            },        
        }
    )

    exports.ox_target:addModel(
        Config.prop_biggarbage,  -- Liste des modèles de Machine
        {  
            -- Option pour utliser la poubelle
            {
                name = "use_big garbage",
                label = "Utiliser la grande poubelle",
                icon = 'fa-solid fa-trash',
                distance = 1.5,
                onSelect = function(data)
                    garbageKind = 'big'
                    propCoords = json.encode(GetEntityCoords(data.entity)) 
                    TriggerServerEvent('qbx_Ab_Garbages:server:useGarbage', propCoords, garbageKind)  -- Envoie les coordonnées au serveur 
                    Wait(10)
                end,
            },
            -- Option pour vider la poubelle
            {
                name = "empty_biggarbage",
                label = "Vider la grande poubelle",
                icon = 'fa-solid fa-trash-arrow-up',
                items = Config.bigtrash_item,
                groups = Config.jobRequired,
                distance = 1.5,
                onSelect = function(data)
                    garbageKind = 'big'
                    propCoords = json.encode(GetEntityCoords(data.entity)) 
                    TriggerServerEvent('qbx_Ab_Garbages:server:emptyGarbage', propCoords, garbageKind)  -- Envoie les coordonnées au serveur 
                    Wait(10)
                end,
            },         
        }
    )

    exports.ox_target:addModel(
        Config.prop_benne,  -- Liste des modèles de Machine
        {  
            -- Option pour jeter un sac poubelle 
            {
                name = "throw_trashbag",
                label = "Jeter un sac poubelle plein",
                icon = 'fa-solid fa-dumpster',
                items = Config.smalltrash_item_full,
                groups = Config.jobRequired, 
                distance = 1.5,
                onSelect = function(data)
                    trashbag = 'small'
                    TriggerServerEvent('qbx_Ab_Garbages:server:throwTrashbag',trashbag)
                    Wait(10)
                end,
            },
            -- Option pour jeter un grand sac poubelle 
            {
                name = "throw_bigtrashbag",
                label = "Jeter un grand sac poubelle plein",
                icon = 'fa-solid fa-dumpster',
                items = Config.bigtrash_item_full,
                groups = Config.jobRequired, 
                distance = 1.5,
                onSelect = function(data)
                    trashbag = 'big'
                    TriggerServerEvent('qbx_Ab_Garbages:server:throwTrashbag',trashbag)
                    Wait(10)
                end,
            },
            -- Option pour fouiller dans une benne à ordure
            {
                name = "search_bin",
                label = "Fouiller dans la benne à ordure",
                icon = 'fa-solid fa-magnifying-glass',
                distance = 1.5,
                canInteract = function(entity, distance, coords)
                    if issearching then
                        return false
                    else
                        return true
                    end
                end,
                onSelect = function(data)
                    TriggerEvent('qbx_Ab_Garbages:client:searchBinAnimation')
                    issearching = true
                    Wait(10)
                end,
            },            
        }
    )

-- event pour ouvrir une poubelle :

    RegisterNetEvent('qbx_Ab_Garbages:server:openGarbage')
    AddEventHandler('qbx_Ab_Garbages:server:openGarbage', function(stashID)
        --print("open stash: " ..stashID)
        Wait(5)
        exports.ox_inventory:openInventory('stash', stashID)
    end)

    RegisterCommand('openG', function(source, args)
        exports.ox_inventory:openInventory('stash', 'garbage_9WmbYfD9xW')
    end, false)

-- Anim pour vider les poubelles 
    RegisterNetEvent('qbx_Ab_Garbages:server:emptyGarbageAnimation')
    AddEventHandler('qbx_Ab_Garbages:server:emptyGarbageAnimation', function()

        -- fonction perso d'animation (fonction a changer si on veut coller un props à la main)
        PlayAnimation("amb@prop_human_bum_bin@idle_a", "idle_a", 6000, 49) 

        --DeleteObject(prop) -- Supprimer la bonbonne après l'animation

        -- Si il se passe des chose
        TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.fatigue_up) -- augmente la fatigue

    end)


-- Anim pour jeter une poubelles 
RegisterNetEvent('qbx_Ab_Garbages:server:throwTrashbagAnimation')
AddEventHandler('qbx_Ab_Garbages:server:throwTrashbagAnimation', function(model)
    local playerPed = PlayerPedId()
    local animdict = 'anim@heists@narcotics@trash'
    local anim_name = 'throw_a'
    local propModel = model

    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.04, -0.02, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

    PlayAnimation(animdict, anim_name, 1000, 49) 

    DeleteObject(prop)

    -- Si il se passe des chose
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.fatigue_up) -- augmente la fatigue
    TriggerServerEvent("qbx_Ab_Archive_base:server:addDocToStash", "menage") -- ajoute un doc a trier pour archive

end)

-- Anim pour fouiller dans une benne
RegisterNetEvent('qbx_Ab_Garbages:client:searchBinAnimation')
AddEventHandler('qbx_Ab_Garbages:client:searchBinAnimation', function()

    -- fonction perso d'animation (fonction a changer si on veut coller un props à la main)
    PlayAnimation("amb@prop_human_bum_bin@idle_a", "idle_a", Config.search_duration, 1) 

    --DeleteObject(prop) -- Supprimer la bonbonne après l'animation

    -- Si il se passe des chose
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.search_fatigue_up) -- augmente la fatigue
    TriggerServerEvent('hud:server:GainStress',Config.search_stress_up)
    TriggerServerEvent('qbx_Ab_Garbages:server:searchBin')
    issearching = false

end)