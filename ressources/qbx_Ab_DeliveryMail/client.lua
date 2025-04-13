local isUIOpen = false

-- POUR L'INTERACCTION


-- Fonction pour afficher le texte 3D
function DrawText3D(coords, text)
    local x, y, z = table.unpack(coords)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local dist = #(GetGameplayCamCoords() - vector3(x, y, z))

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

RegisterNetEvent("qbx_Ab_DeliveryMail:client:openInterface", function(itemsForInterface, mailNameNeeded, officeName)
    --print (mailNameNeeded.. ' mailNameNeeded est envoyé en nui')
    if not isUIOpen then
        isUIOpen = true
        SetNuiFocus(true, true) 
        SetNuiFocusKeepInput(true)
            SendNUIMessage({
                action = "open",
                itemsForInterface = itemsForInterface,
                mailNameNeeded = mailNameNeeded,
                officeName = officeName
        
        })
    end
end) 

-- Fonction pour vérifier si une valeur existe dans la table
local function isJobValid(job)
    for _, requiredJob in ipairs(Config.jobRequired) do
        if requiredJob == job then
            return true -- Le job est valide
        end
    end
    return false -- Le job n'est pas valide
end


-- Vérifiez la proximité des emplacements
CreateThread(function()
    while QBX.PlayerData == nil or QBX.PlayerData.job == nil do
        Wait(waitTime) -- Attendre que les données du joueur soient disponibles
    end

    while true do
        local waitTime = 500 -- Vérifie toutes les secondes
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local PlayerData = QBX.PlayerData

        if isJobValid(PlayerData.job.name) then
            for _, location in ipairs(Config.mail_location_delivery) do
                local dist = #(playerCoords - location.officeCoords)

                if dist < 1.5 then -- Si le joueur est proche d'un emplacement
                    waitTime = 0 -- Réduit le temps d'attente
                    DrawText3D(location.officeCoords, "[E] Deposer un courrier") -- Texte au-dessus

                    if IsControlJustReleased(0, 38) then -- Touche E pressée
                        TriggerServerEvent("qbx_Ab_DeliveryMail:server:openMailInterface", location.mailName, location.officeName)
                    end
                end
            end
        end

        Wait(waitTime)
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

-- Gestion des appels NUI
RegisterNUICallback("chooseItem", function(data, cb)
    SetNuiFocus(false, false) -- Désactive l'interface JS
    isUIOpen = false
    local mailName = data.mailName -- mail choisi
    local mailNameNeeded = data.mailNameNeeded -- Mail requis
    local officeName = data.officeName -- Bureau

    print("Item à retirer : " .. mailNameNeeded .. ", mail choisi: ".. mailName .." bureau : " .. officeName)
    TriggerServerEvent("qbx_Ab_DeliveryMail:server:removeMailRead", mailName, mailNameNeeded, officeName) -- Envoie au serveur
    cb("ok")
end)


-- Gérer la fermeture manuelle de l'interface
RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    isUIOpen = false
    cb("ok")
end)


    -- ///// Pour admin

    exports.ox_target:addModel(
    Config.adminprops,  -- zone de livraison drone
    {  
         -- activer récéption du courrier à lire
         {
            name = "activate deliverymail",
            label = "Activer récéption courrier à livrer",
            icon = "fa-regular fa-envelope",
            groups = "admin",
            onSelect = function(data)
                TriggerServerEvent("qbx_Ab_DeliveryMail:server:activatereadmail")
                print("la reception de courrier à livrer est maintenant activé (true).")
                exports.qbx_core:Notify("la reception de courrier à livrer est maintenant activé (true).", 'inform', 5000)
            end,
            },
             -- désactiver récéption du courrier à lire
         {
            name = "desactivate deliverymail",
            label = "Désactiver récéption courrier à livrer",
            icon = "fa-regular fa-envelope",
            groups = "admin",
            onSelect = function(data)
                TriggerServerEvent("qbx_Ab_DeliveryMail:server:desactivatereadmail")
                print("la reception de courrier à livrer est maintenant désactivé.")
                exports.qbx_core:Notify("la reception de courrier à livrer est maintenant désactivé.", 'inform', 5000)
            end,
            },
    })