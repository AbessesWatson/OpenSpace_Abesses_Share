function RandomizeNumber()
    math.randomseed(GetGameTimer()) -- Réinitialise la graine du générateur
    local randomNumber = math.random(1, 10)
    return randomNumber
end

-- Fonction pour désactiver les contrôles principaux
local function DisablePlayerActions()
    local controls = {
        24,  -- Attaque (clic gauche)
        25,  -- Visée (clic droit)
        30,  -- Déplacement gauche/droite
        31,  -- Déplacement avant/arrière
        36,  -- Accroupissement
        44,  -- Rechargement
        140, -- Attaque au corps à corps
        257, -- Attaque (contrôle secondaire)
        263  -- Visée (contrôle secondaire)
    }

    for _, control in ipairs(controls) do
        DisableControlAction(0, control, true)
    end
end

local ismanualvisible = false
local disabletargettoggle = false

CreateThread(function() -- utiliser le manuel
    while true do
        local interval = 2

        if ismanualvisible then
            AddTextEntry("Manual", "Appuyez sur ~b~BACKSPACE ~s~pour arrêter de lire le manuel des fichiers")
            DisplayHelpTextThisFrame("Manual", false)

            -- Appeler la fonction pour désactiver les actions
            DisablePlayerActions()
            if not disabletargettoggle then
                exports.ox_target:disableTargeting(true)
                disabletargettoggle = true
            end

            if IsControlJustPressed(1, 194) then -- Les choses se passent ici
                print('BACKSPACE PRESSED')
                ismanualvisible = false
                SetNuiFocus(false, false) -- Désactive l'interface NUI
                SendNUIMessage({ action = 'hideImage' }) 
            end
        elseif disabletargettoggle then
            exports.ox_target:disableTargeting(false)
            disabletargettoggle = false
        end

        Citizen.Wait(interval)
    end
end)


-- Callback NUI pour fermer l'interface lorsque le jeu est terminé
RegisterNUICallback('endgame', function(data, cb)
    isGameOpen = false
    local proba_number = RandomizeNumber()

    -- Récupérer l'ID de l'ordinateur
    local computerID = data.computerID
    local win = data.win
    if not computerID then
        print("Erreur : aucun computerID fourni par le NUI.")
        cb('error')
        return
    end


    -- Gérer le succès ou l'échec
    if win == false then 
        PlaySoundFrontend(-1, 'CHECKPOINT_MISSED', 'HUD_MINI_GAME_SOUNDSET', false)

        TriggerServerEvent('qbx_Ab_informatic:server:decreaseComputerHealth', computerID, Config.healthcomputer.healthdown_high) -- Réduction santé du pc 
        TriggerServerEvent('hud:server:GainStress', Config.upstress.strange_folder_S) -- Augmente le stress 
        TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.lowfatigue.strange_folder_F) -- augmente la fatigue 
        exports.qbx_core:Notify("Tu n'as pas rangé les fichiers correctement!", 'error', 7000)
        Wait(50) -- IMPORTANT POUR PAS DE CHEVAUCHEMENT DE SAVE DE HEALTH
        TriggerServerEvent('qbx_Ab_informatic:server:handleComputerfull_lock', computerID) -- passer l'ordi en fulllock
    elseif win == true then
        PlaySoundFrontend(-1, 'TENNIS_POINT_WON', 'HUD_AWARDS', false)
        if proba_number == 1 then
            TriggerServerEvent('qbx_Ab_informatic:server:decreaseComputerHealth', computerID, Config.healthcomputer.healthdown_high) -- Réduction santé du pc 
        elseif proba_number == 2 then
            TriggerServerEvent('qbx_Ab_informatic:server:decreaseComputerHealth', computerID, Config.healthcomputer.healthdown_low) -- Réduction santé du pc 
        end
        TriggerServerEvent('server:addProductivity', Config.upprod.strange_folder) -- Augmente la productivité
        TriggerServerEvent('server:addJobProductivity', 'archive', Config.upprod.strange_folder) -- Augmente la productivité du job
        TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.lowfatigue.strange_folder_F) -- augmente la fatigue
        TriggerServerEvent("qbx_Ab_Archive_base:server:addDocToStash", "archive") -- ajoute un doc a trier pour archive
        exports.qbx_core:Notify('Tu as reussi à ranger les fichier! ', 'success', 7000)
        Wait(50) -- IMPORTANT POUR PAS DE CHEVAUCHEMENT DE SAVE DE HEALTH
        TriggerServerEvent('qbx_Ab_informatic:server:handleComputerlock', computerID) -- passer l'ordi en lock 
    end

    SetNuiFocus(false, false)
    cb('ok')
end)




exports.ox_target:addModel(Config.prop_archive_lib, {
    { -- Strange Folder manual
    name = 'strange_folder_manual',
    label = 'Lire le manuel',
    icon = 'fa-solid fa-folder',
    groups = {"archive", "admin" },

    onSelect = function(data)
        
        if  not ismanualvisible then
            ismanualvisible = true
            SetNuiFocus(false, true)
            SendNUIMessage({ action = 'showImage' })   
        end
    end 
    }
})