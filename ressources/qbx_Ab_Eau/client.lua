
-- Utilisation de ox_target pour détecter l'interaction
exports.ox_target:addModel(
    Config.fontaine_props,  -- Liste des modèles de fontaine
    {  
        -- Option pour boire de l'eau
        {
            name = "drink_water",
            label = "Boire un verre d'eau",
            icon = 'fa-solid fa-glass-water', 
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de la fontaine
                TriggerServerEvent('qbx_Ab_Eau:server:drinkWater', propCoords)  -- Envoie les coordonnées au serveur pour boire
            end,
        },
        -- Option pour vérifier le niveau d'eau
        {
            name = "check_water_level",
            label = "Vérifier le niveau d'eau",
            icon = 'fas fa-search',
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de la fontaine
                TriggerServerEvent('qbx_Ab_Eau:server:checkWaterLevel', propCoords)  -- Envoie les coordonnées au serveur pour vérifier le niveau d'eau
            end,
        },
        -- Option pour remplir la fontaine
        {
            name = "refill_water",
            label = "Remplir la fontaine à eau",
            icon = 'fa-solid fa-glass-water-droplet', 
            items = "bonbonne",
            groups = Config.jobRequired,
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de la fontaine
                TriggerServerEvent('qbx_Ab_Eau:server:WaterRefill', propCoords)  -- Envoie les coordonnées au serveur pour vérifier le niveau d'eau
            end,
        },
        {
            name = "fount_alaniswater",
            label = "Ajouter de l'eau à l'Al'Anis",
            icon = 'fa-solid fa-droplet', 
            items = 'alanis_goblet',
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de la fontaine
                TriggerServerEvent('qbx_Ab_Eau:server:alanisWater', propCoords)  -- Envoie les coordonnées au serveur pour boire
            end,
        },

    }
)


function GetNearbyPeds(playerPed, radius)
    local playerCoords = GetEntityCoords(playerPed)
    local nearbyPeds = {}
    
    for _, ped in ipairs(GetGamePool('CPed')) do
        local pedCoords = GetEntityCoords(ped)
        local distance = #(playerCoords - pedCoords)

        -- Vérifie si le ped est dans le rayon, et qu'il n'est pas le joueur
        if distance <= radius and ped ~= playerPed then
            table.insert(nearbyPeds, ped)
        end
    end

    return nearbyPeds
end

-- REGISTER EVENT


-- Animation pour boire de l'eau
RegisterNetEvent('qbx_Ab_Eau:client:drinkAnimation')
AddEventHandler('qbx_Ab_Eau:client:drinkAnimation', function()
    local playerPed = PlayerPedId()
    local animdict = "amb@code_human_wander_drinking@female@base"
    local animname = "static"
    local propModel = "v_ind_cfcup"  -- Modèle de props
    local duration = 5000
    local thirstup = 20

   -- Créer le prop et l'attacher à la main gauche du joueur
   local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
   AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 57005), 0.15, 0.02, -0.02, 250.0, 0.0, 0.0, true, true, false, true, 1, true)

    
    -- On charge l'animation
    RequestAnimDict(animdict)
    while not HasAnimDictLoaded(animdict) do
        Wait(100)
    end

    -- Jouer l'animation
    TaskPlayAnim(playerPed, animdict, animname, 3.0, 3.0, duration, 49, 0, false, false, false)

    Wait(duration)
    TriggerServerEvent('consumables:server:addThirst',thirstup)
    ClearPedTasks(playerPed) -- Arrête l'animation après 5 secondes
    DeleteObject(prop)
    RemoveAnimDict(animdict)
end)

-- //// Remplir la fontaine 


-- Animation pour remplir la fontaine avec la bonbonne
RegisterNetEvent('qbx_Ab_Eau:client:fillAnimation')
AddEventHandler('qbx_Ab_Eau:client:fillAnimation', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local animdict = "random@mugging4"  -- Exemple d'animation
    local animname = "struggle_loop_b_thief"
    local propModel = Config.bonbonne_prop  -- Modèle de bonbonne d'eau
    local duration = 10000

    -- Créer et attacher la bonbonne à la main
    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 57005), 0.15, 0.02, -0.02, 250.0, 0.0, 0.0, true, true, false, true, 1, true)

    -- Charger et jouer l'animation
    RequestAnimDict(animdict)
    while not HasAnimDictLoaded(animdict) do
        Wait(100)
    end

    TaskPlayAnim(playerPed, animdict, animname, 3.0, 3.0, duration, 1, 0, false, false, false)

    Wait(duration)
    TriggerServerEvent('server:addProductivity', Config.prod_refill) -- Event qui augmente la productivity de 1
    TriggerServerEvent('server:addJobProductivity', Config.jobtoprod, Config.prod_refill) -- Augmente la productivité du job
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.fatigue_refill) -- augmente la fatigue
    TriggerServerEvent("qbx_Ab_Archive_base:server:addDocToStash", "cafet") -- ajoute un doc a trier pour archive
    ClearPedTasks(playerPed) -- Arrêter l'animation
    DeleteObject(prop) -- Supprimer la bonbonne après l'animation
    RemoveAnimDict(animdict)
end)



-- Exemple d'utilisation côté client (peut être déclenché par une commande ou une interaction)
RegisterCommand('startAnimation', function()
    local animationDict = 'missfbi5ig_5'
    local animationName = 'holdup_sec_dave'
    local duration = 3000 -- Durée en millisecondes

    -- Charger le dictionnaire d'animation
    RequestAnimDict(animationDict)
    while not HasAnimDictLoaded(animationDict) do
        Wait(10)
    end

    -- Jouer l'animation
    local playerPed = PlayerPedId()
    TaskPlayAnim(playerPed, animationDict, animationName, 8.0, 8.0, duration, 49, 0, false, false, false)

    -- Décharger le dictionnaire après la fin de l'animation
    Wait(duration)
    RemoveAnimDict(animationDict)
end)