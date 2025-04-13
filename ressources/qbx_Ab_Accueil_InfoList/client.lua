local isUIOpen = false

local blackout = 'off'

-- Fonction pour vérifier l'état d'un ordinateur
    local function checkComputerState(computerID)
        -- Retourner l'état de l'ordinateur localement stocké
        return computer[computerID] and computer[computerID].state or 'active'
    end

    function RandomizeNumber()
        math.randomseed(GetGameTimer()) -- Réinitialise la graine du générateur
        local randomNumber = math.random(1, 100)
        return randomNumber
    end
    

-- Trigger sur ordi
    exports.ox_target:addModel(Config.propscomputer, {
        {    -- check list
        name = 'check_list',
        label = "Regarder les listes d'employés",
        icon = 'fa-solid fa-list',
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

-- Event ordi

RegisterNetEvent('qbx_Ab_Accueil_InfoList:client:brokeComputer', function(computerID)
    local proba_number = RandomizeNumber()

    --print ('brokeComputer with proba: ' ..proba_number)
    if proba_number < 11 then
        TriggerServerEvent('qbx_Ab_informatic:server:decreaseComputerHealth', computerID, Config.pcbighealth) -- Réduction santé du pc 
    elseif proba_number > 10 and proba_number < 40 then
        TriggerServerEvent('qbx_Ab_informatic:server:decreaseComputerHealth', computerID, Config.pcsmallhealth) -- Réduction santé du pc 
    end


end)

-- interface stuff

   -- Callback NUI pour recevoir les données
   RegisterNUICallback('submitForm', function(data, cb)
    local jobselected = data.job

    -- Envoyer au serveur si nécessaire
    if jobselected then
        TriggerServerEvent('qbx_Ab_Accueil_InfoList:server:CheckJobList', jobselected)
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

    RegisterNetEvent('qbx_Ab_Accueil_InfoList:client:showList', function(namelist, empty)
        local isempty = empty
        if not empty then
            if not isUIOpen then
                isUIOpen = true
                SetNuiFocus(true, true) -- Active la saisie utilisateur dans l'UI
                SetNuiFocusKeepInput(true)
                SendNUIMessage({
                    type = "showlist",
                    list = namelist
                })
            end
        else
            exports.qbx_core:Notify("Personne n'occupe ce poste", 'error', 7000)
        end
    end)


    -- event blackout 

RegisterNetEvent('qbx_Ab_Accueil_InfoList:client:blackout', function(isblackout)
    blackout = isblackout
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