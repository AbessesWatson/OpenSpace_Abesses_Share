local isUIOpen = false

-- Target 
    local JobDocTarget = {
        coords = vec3(87.42, 0.54, -19.0),
        name = 'area_jobdoc',
        radius = 1,
        debug = false,
        drawSprite = false,
        options = {  
            {
                name = "pick_jobdoc",
                label = "Récupérer une fiche de poste",
                icon = 'fa-solid fa-paste',
                distance = 1,
                onSelect = function(data)
                    TriggerEvent("qbx_Ab_JobDoc:client:OpenJobDocInterface")
                end,
            },
        }
    }

    exports.ox_target:addSphereZone(JobDocTarget)

-- EVENT et NUI

    -- ouverture de l'interface NUI pour réupéré un jobdoc
    RegisterNetEvent("qbx_Ab_JobDoc:client:OpenJobDocInterface", function()
        if not isUIOpen then
            isUIOpen = true
            SetNuiFocus(true, true) -- Active la saisie utilisateur dans l'UI
            SetNuiFocusKeepInput(true)
            SendNUIMessage({
                action = "open",
                jobs = Config.deliveryjobdoc
            })
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

    -- Gestion des données envoyées par l'interface
    RegisterNUICallback("submitData", function(data, cb)
        local job = data.job
        --print ("job = " ..json.encode(job))
        if data.job then
            TriggerServerEvent("qbx_Ab_JobDoc:server:additemJobdoc", job)
        else
            print ("erreur de donnée JobDoc")
        end

        -- Fermer l'interface
        SetNuiFocus(false, false)
        isUIOpen = false
        cb("ok")
    end)

    -- Fermer l'interface avec le bouton annuler
    RegisterNUICallback("close", function(_, cb)
        SetNuiFocus(false, false)
        isUIOpen = false
        cb("ok")
    end)