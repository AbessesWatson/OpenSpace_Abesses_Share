local blackout = 'off'
local islabfileGameOpen = false

function RandomizeNumber()
    math.randomseed(GetGameTimer()) -- Réinitialise la graine du générateur
    local randomNumber = math.random(1, 10)
    return randomNumber
end


-- Fonction pour vérifier l'état d'un ordinateur
local function checkComputerState(computerID)
    -- Retourner l'état de l'ordinateur localement stocké
    return computer[computerID] and computer[computerID].state or 'active'
end

RegisterNetEvent('qbx_Ab_minigame_CSC:client:local_start_labfile_minigame', function(computerID)
    
    if islabfileGameOpen then
        return -- Empêche un nouveau déclenchement si déjà actif
    end

    islabfileGameOpen = true
    Wait(10)
    
        print ("triggered start_labfile_minigame")
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(true)
        SendNUIMessage({
            action = 'openGamelabfile', -- pour ouvrir l'ui
            computerID = computerID -- Inclure le computerID
        })

end, false)

Citizen.CreateThread(function()
    while true do
        if islabfileGameOpen then
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
    islabfileGameOpen = false
    local proba_number = RandomizeNumber()

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
    if win == false then 
        PlaySoundFrontend(-1, 'CHECKPOINT_MISSED', 'HUD_MINI_GAME_SOUNDSET', false)

        TriggerServerEvent('qbx_Ab_informatic:server:decreaseComputerHealth', computerID, Config.pcbighealth) -- Réduction santé du pc 
        TriggerServerEvent('hud:server:GainStress', Config.upstress) -- Augmente le stress 
        TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.lowfatigue) -- augmente la fatigue 
        exports.qbx_core:Notify("Tu n'as pas ranger le ficher dans le bon dossier!", 'error', 7000)
        Wait(50) -- IMPORTANT POUR PAS DE CHEVAUCHEMENT DE SAVE DE HEALTH
        TriggerServerEvent('qbx_Ab_informatic:server:handleComputerfull_lock', computerID) -- passer l'ordi en fulllock
    elseif win == true then
        PlaySoundFrontend(-1, 'TENNIS_POINT_WON', 'HUD_AWARDS', false)
        if proba_number == 1 then
            TriggerServerEvent('qbx_Ab_informatic:server:decreaseComputerHealth', computerID, Config.pcbighealth) -- Réduction santé du pc 
        elseif proba_number == 2 then
            TriggerServerEvent('qbx_Ab_informatic:server:decreaseComputerHealth', computerID, Config.pcsmallhealth) -- Réduction santé du pc 
        end
        TriggerServerEvent('server:addProductivity', Config.produp) -- Augmente la productivité
        TriggerServerEvent('server:addJobProductivity', Config.jobtoprod, Config.produp) -- Augmente la productivité du job
        TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.lowfatigue) -- augmente la fatigue
        TriggerServerEvent("qbx_Ab_Archive_base:server:addDocToStash", "archive") -- ajoute un doc a trier pour archive
        exports.qbx_core:Notify("Tu as réussi à ranger le ficher dans le bon dossier!", 'success', 7000)
        Wait(50) -- IMPORTANT POUR PAS DE CHEVAUCHEMENT DE SAVE DE HEALTH
        TriggerServerEvent('qbx_Ab_informatic:server:handleComputerlock', computerID) -- passer l'ordi en lock 
    end

    Wait(100)
    SetNuiFocus(false, false)
    print("focus back?")
    cb('ok')
end)

exports.ox_target:addModel(Config.propscomputer, {
    {    -- CSC
    name = 'CSC',
    label = 'Ranger le fichier des bureaux',
    icon = 'fa-solid fa-file',
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
        islabfileGameOpenEvent = false

        if not islabfileGameOpenEvent then
            TriggerEvent('qbx_Ab_minigame_CSC:client:local_start_labfile_minigame', computerID)
            print ("trigger start_labfile_minigame")
            Wait(10)
        end
    end 
    },
})


-- event blackout 

RegisterNetEvent('qbx_Ab_minigame_labfile:client:blackout', function(isblackout)
    blackout = isblackout
end)