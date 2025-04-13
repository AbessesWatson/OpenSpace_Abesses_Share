local isUIOpen = false

local blackout = 'off'

-- Fonction pour vérifier l'état d'un ordinateur
    local function checkComputerState(computerID)
        -- Retourner l'état de l'ordinateur localement stocké
        return computer[computerID] and computer[computerID].state or 'active'
    end
    

-- Trigger sur ordi
    exports.ox_target:addModel(Config.propscomputer, {
        {    -- check list
        name = 'check_jobprod',
        label = "Regarder la productivité par postes",
        icon = 'fa-solid fa-magnifying-glass-chart',
        groups = Config.jobRequired,
        distance = 1.5,
        canInteract = function(entity, distance, coords)
            local computerID = GetEntityCoords(entity)
    
            -- Vérifier l'état de l'ordinateur localement
            local state = checkComputerState(json.encode(computerID))
    
            -- Permettre l'interaction si l'état est 'active'
            if blackout == 'off' then
                if state == 'active' then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end,

        onSelect = function(data)
            computerID = json.encode(GetEntityCoords(data.entity)) -- Inclure le computerID
            if not isUIOpen then
                isUIOpen = true
                SetNuiFocus(true, true) -- Active la saisie utilisateur dans l'UI
                SetNuiFocusKeepInput(true)
                SendNUIMessage({
                    type = "open",
                    jobs = Config.jobs
                })
                TriggerEvent ('qbx_Ab_Accueil_InfoList:client:brokeComputer', computerID)
            end

        end 
        },
    })    

    Citizen.CreateThread(function()
        while true do
            if isUIOpen then
                Citizen.Wait(0)
    
                -- Désactiver toutes les entrées utilisateur
                DisableAllControlActions(0)
    
                -- Réactiver uniquement certaines touches
                EnableControlAction(0, 249, true) -- Push-to-Talk (N)
                EnableControlAction(0, 168, true) -- F7
            else
                Citizen.Wait(500)
            end
        end
    end)

    -- Callback NUI pour recevoir les données
   RegisterNUICallback('submitjob', function(data, cb)
    local jobselected = data.job

    -- Envoyer au serveur si nécessaire
    if jobselected then
        TriggerServerEvent('qbx_Ab_Accueil_InfoJobProd:server:ProdJobSelected', jobselected)
        print ('tu as choisi :' ..jobselected)
    else
        print ('erreur de type de data recherché')
    end

    -- Fermer l'UI
    SetNuiFocus(false, false)
    isUIOpen = false

    cb('ok') -- Répond au NUI que tout est traité
    end)

    -- Fermer l'UI via la touche Échap
    RegisterNUICallback('closeUI', function(data, cb)
        SetNuiFocus(false, false)
        isUIOpen = false

        cb('ok')
    end)

-- event blackout 

    RegisterNetEvent('qbx_Ab_Accueil_InfoJobProd:client:blackout', function(isblackout)
        blackout = isblackout
    end)