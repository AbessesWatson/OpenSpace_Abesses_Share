local display = false

-- Fonction pour afficher/cacher l'interface
function SetDisplay(bool, text, image)
    display = bool 

    SetNuiFocus(bool, bool) -- Activer/désactiver la souris et le clavier
    SendNUIMessage({
        type = "ui",
        status = bool,
        message = text,
        image = image
    })
end

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
        local waitTime = 500 -- Vérifie toutes les secondes
        Wait(waitTime) -- Attendre que les données du joueur soient disponibles
    end

    while true do
        local waitTime = 500 -- Vérifie toutes les secondes
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local PlayerData = QBX.PlayerData

        if isJobValid(PlayerData.job.name) then  
            for _, location in ipairs(Config.labfilelocations) do
                local dist = #(playerCoords - location.coords)

                if dist < 1.5 then -- Si le joueur est proche d'un emplacement
                    waitTime = 0 -- Réduit le temps d'attente
                    DrawText3D(location.coords, "[E] Connaitre le dossier de rangement") -- Texte au-dessus

                    if IsControlJustReleased(0, 38) then -- Touche E pressée
                        SetDisplay(true, location.text, location.image)
                    end
                end
            end
        end

        Wait(waitTime)
    end
end)

Citizen.CreateThread(function()
    while true do
        if display then
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
RegisterNUICallback("exit", function(data, cb)
    SetDisplay(false, "") -- Fermer l'interface
    cb("ok")
end)

