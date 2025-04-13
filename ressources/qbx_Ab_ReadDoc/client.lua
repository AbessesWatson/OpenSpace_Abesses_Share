local isUIOpen = false

function RegisteritemsExport(items)
    exports(items, function(data, slot)
        exports.ox_inventory:useItem(data, function(used)
            if used then
                local text = Config.itemname[data.name] or "Texte non défini pour ce document."

                if not isUIOpen then
                    isUIOpen = true
                    SetNuiFocus(true, true) -- Active la saisie utilisateur dans l'UI
                    SetNuiFocusKeepInput(true)
                    SendNUIMessage({
                        action = 'openText',
                        text = text
                    })
                end
            end
        end)
    end)
end

for _, items in ipairs(Config.items) do
    RegisteritemsExport(items)
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
RegisterNUICallback('closeText', function(_, cb)
    SetNuiFocus(false, false)
    isUIOpen = false
    cb('ok')
end)