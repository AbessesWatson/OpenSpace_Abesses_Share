-- Utilisation de ox_target pour détecter l'interaction avec les toilettes
exports.ox_target:addModel(
    Config.props_toilet,  -- Liste des modèles de Machine
    {  
        -- Option pour nettoyer
        {
            name = "toilet_clean",
            label = "Nettoyer les toilettes",
            icon = 'fa-solid fa-soap',
            items = Config.toiletbrushitem,
            groups = Config.jobRequired,
            onSelect = function(data)
                local propCoords = json.encode(GetEntityCoords(data.entity))
                propName = "Toilette"  
                TriggerServerEvent('qbx_Ab_CleanWipe:server:cleanToilet', propCoords, propName)  -- Envoie les coordonnées au serveur pour boire
            end,
        },
        -- Option pour vérifier le niveau de saleté
        {
            name = "check_dirt_toilet_level",
            label = "Vérifier la propreté",
            icon = 'fas fa-search',
            onSelect = function(data)
                local propCoords = json.encode(GetEntityCoords(data.entity))  -- Récupère les coordonnées de la Machine
                propName = "Toilette"
                TriggerServerEvent('qbx_Ab_CleanWipe:server:checkToiletDirt', propCoords, propName)  -- Envoie les coordonnées au serveur pour vérifier le niveau de cafe
            end,
        }

    }
)

-- Animation pour nettoyer les toilettes
RegisterNetEvent('qbx_Ab_CleanWipe:client:cleanToiletAnimation')
AddEventHandler('qbx_Ab_CleanWipe:client:cleanToiletAnimation', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local anim = "amb@world_human_bum_wash@male@high@base"  -- Exemple d'animation
    local propModel = Config.toiletbrushprop  -- props que l'on tien
    local duration = 10000

    -- Créer et attacher la bonbonne à la main
    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 57005), 0.15, 0.02, -0.02, 250.0, 0.0, 0.0, true, true, false, true, 1, true)

    -- Charger et jouer l'animation
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Wait(100)
    end

    TaskPlayAnim(playerPed, anim, "base", 3.0, 3.0, duration, 49, 0, false, false, false)

    Wait(duration)
    TriggerServerEvent('server:addProductivity', Config.prod_up) -- Event qui augmente la productivity
    TriggerServerEvent('server:addJobProductivity', Config.jobtoprod, Config.prod_up) -- Augmente la productivité du job
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.fatigue_up) -- augmente la fatigue
    TriggerServerEvent('hud:server:GainStress',Config.stress_up) -- auigment le stress
    ClearPedTasks(playerPed) -- Arrêter l'animation
    DeleteObject(prop) -- Supprimer la bonbonne après l'animation
end)


-- Utilisation de ox_target pour détecter l'interaction avec les tables
exports.ox_target:addModel(
    Config.props_table,  -- Liste des modèles de Machine
    {  
        -- Option pour nettoyer
        {
            name = "table_clean",
            label = "Nettoyer la table",
            icon = 'fa-solid fa-soap',
            items = Config.wipeitem,
            groups = Config.jobRequired,
            onSelect = function(data)
                local propCoords = json.encode(GetEntityCoords(data.entity))  
                propName = "Table"
                TriggerServerEvent('qbx_Ab_CleanWipe:server:cleanTable', propCoords, propName)  
            end,
        },
        -- Option pour vérifier le niveau de saleté
        {
            name = "check_dirt_table_level",
            label = "Vérifier la propreté",
            icon = 'fas fa-search',
            onSelect = function(data)
                local propCoords = json.encode(GetEntityCoords(data.entity))  -- Récupère les coordonnées de la Machine
                propName = "Table"
                TriggerServerEvent('qbx_Ab_CleanWipe:server:checkTableDirt', propCoords, propName)  -- Envoie les coordonnées au serveur pour vérifier le niveau de cafe
            end,
        }

    }
)

-- Animation pour nettoyer les toilettes
RegisterNetEvent('qbx_Ab_CleanWipe:client:cleanTableAnimation')
AddEventHandler('qbx_Ab_CleanWipe:client:cleanTableAnimation', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local anim = "missheistdocks2aleadinoutlsdh_2a_int"  -- Exemple d'animation
    local propModel = Config.wipeprop  -- props que l'on tien
    local duration = 10000

    -- Créer et attacher la bonbonne à la main
    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 57005), 0.15, 0.02, -0.02, 250.0, 0.0, 0.0, true, true, false, true, 1, true)

    -- Charger et jouer l'animation
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Wait(100)
    end

    TaskPlayAnim(playerPed, anim, "cleaning_wade", 3.0, 3.0, duration, 49, 0, false, false, false)

    Wait(duration)
    TriggerServerEvent('server:addProductivity', Config.prod_up) -- Event qui augmente la productivity
    TriggerServerEvent('server:addJobProductivity', Config.jobtoprod, Config.prod_up) -- Augmente la productivité du job
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.fatigue_up) -- augmente la fatigue
    TriggerServerEvent('hud:server:GainStress',Config.stress_up) -- auigment le stress
    TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'wipe_dirty')
    ClearPedTasks(playerPed) -- Arrêter l'animation
    DeleteObject(prop) -- Supprimer la bonbonne après l'animation
end)