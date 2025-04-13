local isUIOpen = false

-- Fonction pour vérifier l'état d'un ordinateur
    local function checkComputerState(computerID)
        -- Retourner l'état de l'ordinateur localement stocké
        return computer[computerID] and computer[computerID].state or 'active'
    end


-- Trigger sur ordi
    exports.ox_target:addModel(Config.propscomputer, {
        {    -- check patient
        name = 'check_coma_reason',
        label = 'Dossier de patient',
        icon = 'fa-solid fa-hospital-user',
        groups = Config.jobRequired,
        distance = 1.5,
        canInteract = function(entity, distance, coords)
            local computerID = GetEntityCoords(entity)

            -- Vérifier l'état de l'ordinateur localement
            local state = checkComputerState(json.encode(computerID))

            -- Permettre l'interaction si l'état est 'active'
            if state == 'active' then
                return true
            else
                return false
            end
        end,

        onSelect = function(data)
            if not isUIOpen then
                isUIOpen = true
                SetNuiFocus(true, true) -- Active la saisie utilisateur dans l'UI
                --SetNuiFocusKeepInput(true)
                SendNUIMessage({
                    type = "open"
                })
            end

        end 
      
    },
    })

    -- Citizen.CreateThread(function()
    --     while true do
    --         if isUIOpen then
    --             Citizen.Wait(0)
    
    --             -- Désactiver toutes les entrées utilisateur
    --             DisableAllControlActions(0)
    
    --             -- Réactiver uniquement certaines touches
    --             EnableControlAction(0, 249, true) -- Push-to-Talk (N)
    --             EnableControlAction(0, 168, true) -- F7
    --         else
    --             Citizen.Wait(500)
    --         end
    --     end
    -- end)

-- interface stuff

   -- Callback NUI pour recevoir les données
    RegisterNUICallback('submitForm', function(data, cb)
        local firstname = data.firstname
        local lastname = data.lastname

        -- Traitez les données ici, par exemple :
        print('Firstname: ' .. firstname .. ', Lastname: ' .. lastname)

        -- Envoyer au serveur si nécessaire
        TriggerServerEvent('qbx_Ab_Medic_readlog:server:CheckComaReason', firstname, lastname)
        TriggerServerEvent("qbx_Ab_Archive_base:server:addDocToStash", "infirmerie") -- ajoute un doc a trier pour archive

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