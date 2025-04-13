local isUIOpen = false

function RegisterItemsExport(Items)
    exports(Items, function(data, slot)
        exports.ox_inventory:useItem(data, function(used)
            if used then
                if not isUIOpen then
                    isUIOpen = true
                    SetNuiFocus(true, true) -- Active la saisie utilisateur dans l'UI
                    SetNuiFocusKeepInput(true)
                    SendNUIMessage({
                        action = 'openImage',
                        item = Items
                    })
                end
            end
        end)
    end)
end

for _, Items in ipairs(Config.items) do
    RegisterItemsExport(Items)
end

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

-- Fermer l'interface via un callback NUI
RegisterNUICallback('closeImage', function(_, cb)
    SetNuiFocus(false, false)
    isUIOpen = false
    cb('ok')
end)