local blackout = 'off'
local isGameOpen = false

-- Fonction pour vérifier l'état d'un ordinateur
local function checkComputerState(computerID)
    -- Retourner l'état de l'ordinateur localement stocké
    return computer[computerID] and computer[computerID].state or 'active'
end

RegisterNetEvent('qbx_Ab_minigame_BN:client:local_start_BN_minigame', function(computerID)
    
    if isGameOpen then
        return -- Empêche un nouveau déclenchement si déjà actif
    end

    isGameOpen = true
    Wait(10)
    
       -- print ("triggered local_start_BN_minigame")
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(true)
        SendNUIMessage({
            action = 'openGame', -- pour ouvrir l'ui
            computerID = computerID -- Inclure le computerID
        })

end, false)

Citizen.CreateThread(function()
    while true do
        if isGameOpen then
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

-- Callback NUI pour fermer l'interface lorsque le jeu est terminé
RegisterNUICallback('endgame', function(data, cb)
    isGameOpen = false

    -- Récupérer l'ID de l'ordinateur
    local computerID = data.computerID
    local win = data.win
    if not computerID then
        print("Erreur : aucun computerID fourni par le NUI.")
        cb('error')
        return
    end

    print("Computer ID :", computerID)

    -- Gérer le succès ou l'échec
        if win == true then
        TriggerServerEvent('qbx_Ab_informatic:server:decreaseComputerHealth', computerID, Config.lowhealth) -- Réduction santé du pc

        print('Fin de jeu.')

        Wait(50) -- IMPORTANT POUR PAS DE CHEVAUCHEMENT DE SAVE DE HEALTH
        TriggerServerEvent('qbx_Ab_informatic:server:handleComputerlock', computerID) -- passer l'ordi en lock 
    end

    Wait(100)
    SetNuiFocus(false, false)
    print("focus back?")
    cb('ok')
end)

exports.ox_target:addModel(Config.propscomputer, {
    {    
    name = 'BST',
    label = 'Jouer à Battleship Tables',
    icon = 'fa-solid fa-anchor',
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
        isGraphGameOpenEvent = false

        if not isGraphGameOpenEvent then
            TriggerEvent('qbx_Ab_minigame_BN:client:local_start_BN_minigame', computerID)
            --print ("trigger start_BN_minigame")
            Wait(10)
        end
    end 
    },
})


-- event blackout 

RegisterNetEvent('qbx_Ab_minigame_bataille_naval:client:blackout', function(isblackout)
    blackout = isblackout
end)