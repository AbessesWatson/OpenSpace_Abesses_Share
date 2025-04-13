local isUIOpen = false

local playertarget = nil

-- target 

exports.ox_target:addModel(
    Config.adminprops,  -- zone de livraison drone
    {  
         -- activer récéption du courrier à lire
         {
            name = "get_formulaire_mutation",
            label = "Récupérer un formulaire de mutation",
            icon = "fa-regular fa-clipboard",
            groups = "admin",
            onSelect = function(data)
                TriggerServerEvent('qbx_Ab_Admin:server:GetItem', Config.mutation_item)
            end,
            },
    })

exports.ox_target:addGlobalPlayer({

    {
        name = 'player_mutation',
        icon = 'fa-solid fa-clipboard',
        label = '[Admin] Muter à un autre poste',
        distance = 1.5, -- Distance pour interagir avec un autre joueur
        groups = Config.jobRequired,
        items = Config.mutation_item,
        onSelect = function(data)
            if playertarget == nil then
                if not isUIOpen then
                    isUIOpen = true
                    SetNuiFocus(true, true) -- Active la saisie utilisateur dans l'UI
                    SetNuiFocusKeepInput(true)
                    SendNUIMessage({
                        type = "open",
                        jobs = Config.jobs
                    })
                
                    playertarget = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)) 
                end

            else
                playertarget = nil
                exports.qbx_core:Notify('Veuillez recommencer', 'error', 7000)
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

-- retour du NUI
    -- Callback NUI pour recevoir les données
    RegisterNUICallback('submitjob', function(data, cb)
        local jobselected = data.job
    
        -- Envoyer au serveur si nécessaire
        if jobselected then
            TriggerServerEvent('qbx_Ab_Admin:server:deleteItem', Config.mutation_item)
            TriggerServerEvent('qbx_Ab_Admin:server:setnewjob', playertarget, jobselected)
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

-- couteau

CreateThread(function()
    while true do
        Wait(0) -- Vérifie en continu

        -- Vérifie si le joueur utilise un couteau
        if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("WEAPON_KNIFE") then
            SetWeaponDamageModifierThisFrame(GetHashKey("WEAPON_KNIFE"), 999.0)
        end
    end
end)

