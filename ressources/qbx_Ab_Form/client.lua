local isUIOpen = false

RegisterNetEvent('qbx_Ab_Form:client:openform')
AddEventHandler('qbx_Ab_Form:client:openform', function(url)
    if not isUIOpen then
        isUIOpen = true
        SetNuiFocus(true, true) -- Active la saisie utilisateur dans l'UI
        --SetNuiFocusKeepInput(true)
        SendNUIMessage({
            action = "openWebPage",
            url = url
        })
    end
end)

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

RegisterNUICallback('closeform', function()
    SetNuiFocus(false, false)
    isUIOpen = false
    TriggerServerEvent('qbx_Ab_Form:server:switchform')
    exports.qbx_core:Notify('Vous avez terminé de remplir le formulaire', 'inform', 10000)
end)



exports('formulaire_empty', function(data, slot)
    local player = PlayerPedId()
 
    -- Triggers internal-code to correctly use items.
    -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
    exports.ox_inventory:useItem(data, function(used)
        -- The server has verified the item can be used.
        if used then
            
            TriggerEvent('qbx_Ab_Form:client:openform', Config.link)

        end
      end)

end)

exports('formulaire_full', function(data, slot)
    local player = PlayerPedId()
 
    -- Triggers internal-code to correctly use items.
    -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
    exports.ox_inventory:useItem(data, function(used)
        -- The server has verified the item can be used.
        if used then
            
            exports.qbx_core:Notify('Ce formulaire est déjà rempli veuillez le rendre à un superieur', 'inform', 10000)

        end
      end)

end)

local zoneform = {
    coords = vec3(-22.1, 159.85, -20.6),
    name = 'area_form',
    radius = 0.8,
    debug = false,
    drawSprite = false,
    options = {  
        {
            name = "takeform",
            label = "Prendre un formulaire",
            icon = 'fa-solid fa-file-lines',
            distance = 1.5,
            onSelect = function(data)
                TriggerServerEvent('qbx_Ab_Form:server:takeform')
            end,
        },
    }
}
exports.ox_target:addSphereZone(zoneform)