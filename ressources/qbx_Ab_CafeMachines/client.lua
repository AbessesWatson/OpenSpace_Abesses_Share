
-- Utilisation de ox_target pour détecter l'interaction
exports.ox_target:addModel(
    Config.cafemachine_props,  -- Liste des modèles de Machine
    {  
        -- Option pour boire du café
        {
            name = "drink_cafe",
            label = "Boire un café",
            icon = 'fa-solid fa-mug-saucer', 
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de la Machine
                TriggerServerEvent('qbx_Ab_CafeMachines:server:drinkCafe', propCoords)  -- Envoie les coordonnées au serveur pour boire
            end,
        },
        -- Option pour vérifier le niveau de cafe
        {
            name = "check_cafe_level",
            label = "Vérifier la quantité de café",
            icon = 'fas fa-search',
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de la Machine
                TriggerServerEvent('qbx_Ab_CafeMachines:server:checkCafeLevel', propCoords)  -- Envoie les coordonnées au serveur pour vérifier le niveau de cafe
            end,
        },
        -- Option pour remplir la Machine
        {
            name = "refill_cafe",
            label = "Remettre un pack de café",
            icon = 'fa-solid fa-glass-water-droplet', 
            items = Config.refillitem,
            groups = Config.jobRequired,
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de la Machine
                TriggerServerEvent('qbx_Ab_CafeMachines:server:CafeRefill', propCoords)  -- Envoie les coordonnées au serveur pour vérifier le niveau de cafe
            end,
        }

    }
)

-- REGISTER EVENT

-- Animation pour boire du café
RegisterNetEvent('qbx_Ab_CafeMachines:client:drinkAnimation')
AddEventHandler('qbx_Ab_CafeMachines:client:drinkAnimation', function()
    local playerPed = PlayerPedId()
    local anim = "amb@code_human_wander_drinking@female@base"
    local propModel = "v_ind_cfcup"  -- Modèle de props
    local duration = 5000

   -- Créer le prop et l'attacher à la main gauche du joueur
   local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
   AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 57005), 0.15, 0.02, -0.02, 250.0, 0.0, 0.0, true, true, false, true, 1, true)

    
    -- On charge l'animation
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Wait(100)
    end

    -- Jouer l'animation
    TaskPlayAnim(playerPed, anim, "static", 3.0, 3.0, duration, 49, 0, false, false, false)

    Wait(duration)
    TriggerServerEvent('hud:server:GainStress',Config.stress_up) -- monte le stress
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.fatigue_down) -- baisse la fatigue
    ClearPedTasks(playerPed) -- Arrête l'animation après 5 secondes
    DeleteObject(prop)
end)

-- //// Remplir la machine 


-- Animation pour remplir la machine avec la bonbonne
RegisterNetEvent('qbx_Ab_CafeMachines:client:fillAnimation')
AddEventHandler('qbx_Ab_CafeMachines:client:fillAnimation', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local anim = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@" 
    local animname = "machinic_loop_mechandplayer"
    local duration = 10000

    -- Charger et jouer l'animation
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Wait(100)
    end

    TaskPlayAnim(playerPed, anim, animname, 3.0, 3.0, duration, 1, 0, false, false, false)

    Wait(duration)
    TriggerServerEvent('server:addProductivity', Config.prod_refill) -- Event qui augmente la productivity de 1
    TriggerServerEvent('server:addJobProductivity', Config.jobtoprod, Config.prod_refill) -- Augmente la productivité du job
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.fatigue_refill) -- augmente la fatigue 
    TriggerServerEvent("qbx_Ab_Archive_base:server:addDocToStash", "cafet") -- ajoute un doc a trier pour archive
    ClearPedTasks(playerPed) -- Arrêter l'animation
end)