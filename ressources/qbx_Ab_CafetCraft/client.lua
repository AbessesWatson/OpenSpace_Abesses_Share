local iscooking = false

local function PlayAnimation(dict, name, duration)
    local playerPed = PlayerPedId()
    local flag = 1

    -- Charger le dictionnaire d'animation
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(100)
    end

    -- Jouer l'animation
    TaskPlayAnim(playerPed, dict, name, 3.0, 3.0, duration, flag, 0, false, false, false)

    -- Attendre la durée de l'animation
    Wait(duration)

    -- Arrêter l'animation
    ClearPedTasks(playerPed)
    RemoveAnimDict(animdict)
end

-- REMPLIR DE L'EAU

exports.ox_target:addModel(
    Config.propslavabo,  -- Liste des modèles de fontaine
    {  
        {-- Option pour remplir un casserole
            name = "remplir_casserole",
            label = "Remplir une casserole d'eau",
            groups = Config.jobRequired,
            icon = "fa-solid fa-droplet",
            distance = 1.5,
            canInteract = function(entity, distance, coords)
                if iscooking then
                    return false
                else
                    return true
                end
            end,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de l'evier
                TriggerServerEvent('qbx_Ab_CafetCraft:server:fillcasserole', propCoords)  
                iscooking = true 
            end,
        },
    }
)

-- Animation pour remplir la casserole
RegisterNetEvent('qbx_Ab_CafetCraft:client:casseroleAnimation')
AddEventHandler('qbx_Ab_CafetCraft:client:casseroleAnimation', function()
    local playerPed = PlayerPedId()
    local animdic = "missmechanic"  -- dictionaire d'animation
    local animname = "work2_in" -- name animation
    local flag = 1
    local propModel = "v_ret_fh_pot01"  -- Modèle de props

   -- Créer le prop et l'attacher à la main gauche du joueur
   local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
   AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 0x188E), 0.25, 0.00, 0.00, 0.0, 0.0, 180.0, true, true, false, true, 1, true)

    -- Charger et jouer l'animation
    RequestAnimDict(animdic)
    while not HasAnimDictLoaded(animdic) do
        Wait(100)
        print ('no HasAnimDictLoaded')
    end

    TaskPlayAnim(playerPed, animdic, animname, 3.0, 3.0, Config.refilltime, flag, 0, false, false, false)
    exports.qbx_core:Notify("Vous remplissez une casserole d'eau", 'inform', Config.refilltime)
    iscooking = false
    Wait(5000)
    ClearPedTasks(playerPed) -- Arrêter l'animation
    DeleteObject(prop) -- Supprimer le props après anim
end)

-- MOUDRE DU CAFE

exports.ox_target:addModel(
    Config.propscafegrinder,  -- Liste des modèles de fontaine
    {  
        -- Option pour moudre le café
        {
            name = "grind_cafe",
            label = "Moudre du café",
            groups = Config.jobRequired,
            items = "cafesac",
            icon = "fa-solid fa-mortar-pestle",
            distance = 1.5,
            canInteract = function(entity, distance, coords)
                if iscooking then
                    return false
                else
                    return true
                end
            end,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de l'evier
                TriggerServerEvent('qbx_Ab_CafetCraft:server:grindcafe', propCoords)  
                iscooking = true 
            end,
        },
    }
)

-- Animation pour remplir grinder le café
RegisterNetEvent('qbx_Ab_CafetCraft:client:grindcafeAnimation')
AddEventHandler('qbx_Ab_CafetCraft:client:grindcafeAnimation', function()

    -- fonction perso d'animation (fonction a changer si on veut coller un props à la main)
    PlayAnimation("missmechanic", "work2_in", 10000)

    --DeleteObject(prop) -- Supprimer la bonbonne après l'animation

    -- Si il se passe des chose
    TriggerServerEvent('server:addProductivity', Config.basecraft_produp) -- Event qui augmente la productivity
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.basecraft_bigfatigueup) -- augmente la fatigue 
    iscooking = false

end)

-- Utiliser la Cuisinière

exports.ox_target:addModel(
    Config.propscooker,  -- Liste des modèles de fontaine
    {  
        -- Option pour bouillir l'eau
        {
            name = "boil_water",
            label = "Bouillir de l'eau",
            groups = Config.jobRequired,
            items = "eau_casserole",
            icon = 'fa-solid fa-fire-burner', 
            distance = 1.5,
            canInteract = function(entity, distance, coords)
                if iscooking then
                    return false
                else
                    return true
                end
            end,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de l'evier
                TriggerServerEvent('qbx_Ab_CafetCraft:server:boilwater', propCoords)  
                iscooking = true 
            end,
        },
        -- Option pour cuire une omelette
        {
            name = "cook_omelette",
            label = "Faire une omlette",
            groups = Config.jobRequired,
            items = "oeuf_battu",
            icon = 'fa-solid fa-fire-burner',
            distance = 1.5,
            canInteract = function(entity, distance, coords)
                if iscooking then
                    return false
                else
                    return true
                end
            end,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de l'evier
                TriggerServerEvent('qbx_Ab_CafetCraft:server:cookomelette', propCoords)  
                iscooking = true 
            end,
        },
        -- Option pour cuire un steak
        {
            name = "cook_steak",
            label = "Cuire un steak haché",
            groups = Config.jobRequired,
            items = "steakcru",
            icon = 'fa-solid fa-fire-burner',
            distance = 1.5,
            canInteract = function(entity, distance, coords)
                if iscooking then
                    return false
                else
                    return true
                end
            end, 
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de l'evier
                TriggerServerEvent('qbx_Ab_CafetCraft:server:cooksteak', propCoords)  
                iscooking = true 
            end,
        }, 
        {
            name = "cook_pizza",
            label = "Cuire une pizza surgelée",
            groups = Config.jobRequired,
            items = "pizza_surgelee",
            icon = 'fa-solid fa-fire-burner',
            distance = 1.5,
            canInteract = function(entity, distance, coords)
                if iscooking then
                    return false
                else
                    return true
                end
            end, 
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de l'evier
                TriggerServerEvent('qbx_Ab_CafetCraft:server:cookpizza', propCoords)  
                iscooking = true 
            end,
        },       
    }
)

-- Animation pour bouillir l'eau
RegisterNetEvent('qbx_Ab_CafetCraft:client:boilwater')
AddEventHandler('qbx_Ab_CafetCraft:client:boilwater', function()
    local duration = 10000
    local player = PlayerPedId()
    local propmodel = 'v_ret_fh_pot01'

    local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 28422), 0.0, -0.25, 0.00, 0.0, 0.0, 90.0, true, true, false, true, 1, true)

    -- fonction perso d'animation (fonction a changer si on veut coller un props à la main)
    PlayAnimation("amb@prop_human_bbq@male@idle_a", "idle_b", 10000)

    DeleteObject(prop) -- Supprimer le prop après l'animation

    -- Si il se passe des chose
    TriggerServerEvent('server:addProductivity', Config.basecraft_produp) -- Event qui augmente la productivity
    TriggerServerEvent('hud:server:GainStress', Config.basecraft_stressup) -- Augmente le stress 
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.basecraft_fatigueup) -- augmente la fatigue 
    iscooking = false

end)

-- Animation pour cuire une omelette
RegisterNetEvent('qbx_Ab_CafetCraft:client:cookomeletteAnimation')
AddEventHandler('qbx_Ab_CafetCraft:client:cookomeletteAnimation', function()
    local duration = 6000
    local player = PlayerPedId()
    local propmodel = 'prop_fish_slice_01'

    local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    
    PlayAnimation("amb@prop_human_bbq@male@idle_a", "idle_b", 5000)

    DeleteObject(prop) -- Supprimer le prop après l'animation

    -- Si il se passe des chose
    TriggerServerEvent('server:addProductivity', Config.basecraft_produp) -- Event qui augmente la productivity
    TriggerServerEvent('hud:server:GainStress', Config.basecraft_stressup) -- Augmente le stress 
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.basecraft_fatigueup) -- augmente la fatigue 
    iscooking = false

end)

-- Animation pour cuire un steak
RegisterNetEvent('qbx_Ab_CafetCraft:client:cooksteakAnimation')
AddEventHandler('qbx_Ab_CafetCraft:client:cooksteakAnimation', function()
    local duration = 8000
    local player = PlayerPedId()
    local propmodel = 'prop_fish_slice_01'

    local prop= CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

    PlayAnimation("amb@prop_human_bbq@male@idle_a", "idle_b", duration)

    DeleteObject(prop) -- Supprimer le prop après l'animation

    -- Si il se passe des chose
    TriggerServerEvent('server:addProductivity', Config.basecraft_produp) -- Event qui augmente la productivity
    TriggerServerEvent('hud:server:GainStress', Config.basecraft_stressup) -- Augmente le stress 
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.basecraft_fatigueup) -- augmente la fatigue 
    iscooking = false

end)

-- Animation pour cuire un steak
RegisterNetEvent('qbx_Ab_CafetCraft:client:cookpizzaAnimation')
AddEventHandler('qbx_Ab_CafetCraft:client:cookpizzaAnimation', function()
    local duration = 8000
    local player = PlayerPedId()


    PlayAnimation("random@shop_tattoo", "_idle_a", duration)


    -- Si il se passe des chose
    TriggerServerEvent('server:addProductivity', Config.basecraft_produp) -- Event qui augmente la productivity
    TriggerServerEvent('hud:server:GainStress', Config.basecraft_stressup) -- Augmente le stress 
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.basecraft_fatigueup) -- augmente la fatigue 
    iscooking = false

    PlaySoundFrontend(-1, "PIN_BUTTON", "ATM_SOUNDS", true)

end)

-- découper des ingrédient

exports.ox_target:addModel(
    Config.propscutzone,  -- Liste des modèles de fontaine
    {  
        -- Option pour couper la salade
        {
            name = "cut_salade",
            label = "Découper la salade",
            groups = Config.jobRequired,
            items = "salade",
            icon = "fa-solid fa-utensils",
            distance = 1.5,
            canInteract = function(entity, distance, coords)
                if iscooking then
                    return false
                else
                    return true
                end
            end,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de l'evier
                TriggerServerEvent('qbx_Ab_CafetCraft:server:cutsalade', propCoords)  
                iscooking = true 
            end,
        },
        -- Option pour couper un tomate
        {
            name = "cut_tomate",
            label = "Découper une tomate",
            groups = Config.jobRequired,
            items = "tomate",
            icon = "fa-solid fa-utensils",
            distance = 1.5,
            canInteract = function(entity, distance, coords)
                if iscooking then
                    return false
                else
                    return true
                end
            end,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de l'evier
                TriggerServerEvent('qbx_Ab_CafetCraft:server:cuttomate', propCoords)  
                iscooking = true 
            end,
        },
        -- Option pour couper une patate
        {
            name = "cut_patate",
            label = "Découper une pomme de terre",
            groups = Config.jobRequired,
            items = "patate",
            icon = "fa-solid fa-utensils",
            distance = 1.5,
            canInteract = function(entity, distance, coords)
                if iscooking then
                    return false
                else
                    return true
                end
            end,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de l'evier
                TriggerServerEvent('qbx_Ab_CafetCraft:server:cutpatate', propCoords)  
                iscooking = true 
            end,
        },
        -- Option pour couper une patate
        {
            name = "cut_ginseng",
            label = "Découper du ginseng",
            groups = Config.jobRequired,
            items = "branche_ginseng",
            icon = "fa-solid fa-utensils",
            distance = 1.5,
            canInteract = function(entity, distance, coords)
                if iscooking then
                    return false
                else
                    return true
                end
            end,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de l'evier
                TriggerServerEvent('qbx_Ab_CafetCraft:server:cutginseng', propCoords)  
                iscooking = true 
            end,
        },              
    }
)

-- Animation pour découper des ingredients
RegisterNetEvent('qbx_Ab_CafetCraft:client:cutAnimation')
AddEventHandler('qbx_Ab_CafetCraft:client:cutAnimation', function()

    -- fonction perso d'animation (fonction a changer si on veut coller un props à la main)
    PlayAnimation("missmechanic", "work2_in", 10000)

    --DeleteObject(prop) -- Supprimer la bonbonne après l'animation

    -- Si il se passe des chose
    -- pas de up de prod intentionnel
    TriggerServerEvent('hud:server:GainStress', Config.basecraft_stressup) -- Augmente le stress 
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.basecraft_fatigueup) -- augmente la fatigue 
    iscooking = false

end)

-- mélanger 

exports.ox_target:addModel(
    Config.propsmanualmix,  -- Liste des modèles de fontaine
    {  
        -- Option pour battre un oeuf
        {
            name = "mixegg",
            label = "Battre un oeuf",
            groups = Config.jobRequired,
            items = "oeuf",
            icon = "fa-solid fa-utensils",
            distance = 1.5,
            canInteract = function(entity, distance, coords)
                if iscooking then
                    return false
                else
                    return true
                end
            end,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de l'evier
                TriggerServerEvent('qbx_Ab_CafetCraft:server:mixegg', propCoords)  
                iscooking = true 
            end,
        },
    }
)

-- Animation pour découper des ingredients
RegisterNetEvent('qbx_Ab_CafetCraft:client:mixAnimation')
AddEventHandler('qbx_Ab_CafetCraft:client:mixAnimation', function()

    -- fonction perso d'animation (fonction a changer si on veut coller un props à la main)
    PlayAnimation("missmechanic", "work2_in", 10000)

    --DeleteObject(prop) -- Supprimer la bonbonne après l'animation

    -- Si il se passe des chose
    TriggerServerEvent('hud:server:GainStress', Config.basecraft_stressup) -- Augmente le stress 
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.basecraft_fatigueup) -- augmente la fatigue 
    iscooking = false

end)


-- Cuire les frite

exports.ox_target:addModel(
    Config.propsfriteuse,  -- Liste des modèles de fontaine
    {  
        -- Option pour cuire les frite
        {
            name = "cookfrite",
            label = "Cuire les frites",
            groups = Config.jobRequired,
            items = "patate_decoupe",
            icon = 'fa-solid fa-fire-burner',
            distance = 1.5,
            canInteract = function(entity, distance, coords)
                if iscooking then
                    return false
                else
                    return true
                end
            end,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de l'evier
                TriggerServerEvent('qbx_Ab_CafetCraft:server:cookfrite', propCoords) 
                iscooking = true 
            end,
        },
    }
)

-- Animation pour cuire les frite
RegisterNetEvent('qbx_Ab_CafetCraft:client:cookfriteAnimation')
AddEventHandler('qbx_Ab_CafetCraft:client:cookfriteAnimation', function()

    -- fonction perso d'animation (fonction a changer si on veut coller un props à la main)
    PlayAnimation("amb@prop_human_bbq@male@idle_a", "idle_b", 10000)

    --DeleteObject(prop) -- Supprimer la bonbonne après l'animation

    -- Si il se passe des chose
    TriggerServerEvent('server:addProductivity', Config.basecraft_produp) -- Event qui augmente la productivity
    TriggerServerEvent('hud:server:GainStress', Config.basecraft_stressup) -- Augmente le stress 
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.basecraft_fatigueup) -- augmente la fatigue 
    iscooking = false

end)

RegisterNetEvent('qbx_Ab_CafetCraft:client:isnotcooking')
AddEventHandler('qbx_Ab_CafetCraft:client:isnotcooking', function()
 
    iscooking = false

end)