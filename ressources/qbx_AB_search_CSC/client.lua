local isUIOpen = false

-- /////////////// SOLUCE GAMEPLAY

exports.ox_target:addModel(
    Config.docprops, 
    {  
        {
        name = 'doc_soluce_location',
        icon = 'fas fa-search',
        label = 'Chercher un document statistique',
        groups = Config.jobRequired,
        distance = 1.5,
        onSelect = function(data)
           TriggerEvent('qbx_Ab_minigame_CSC:client:openInterface')
        end,
        }
    }
)

RegisterNetEvent('qbx_Ab_minigame_CSC:client:openInterface', function()
    if not isUIOpen then
        isUIOpen = true
        SetNuiFocus(true, true) -- Active la saisie utilisateur dans l'UI
        SetNuiFocusKeepInput(true)
        SendNUIMessage({ actiondate = 'opendate' })
    end
end)

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

-- Événement pour récupérer la date saisie
RegisterNUICallback('submitDate', function(data, cb)
    local dateInput = data.date -- La date saisie dans l'interface
    print (dateInput)
    TriggerServerEvent('qbx_Ab_minigame_CSC:server:checkDate', dateInput)
    SetNuiFocus(false, false)
    isUIOpen = false
    cb('ok')
end)

-- Fermer l'interface
RegisterNUICallback('closedate', function(_, cb)
    SetNuiFocus(false, false)
    isUIOpen = false
    cb('ok')
end)