RegisterNetEvent('qbx_Ab_Form:server:switchform')
AddEventHandler('qbx_Ab_Form:server:switchform', function(url)
    local src = source
    
        exports.ox_inventory:AddItem(src, "formulaire_full", 1)
end)

RegisterNetEvent('qbx_Ab_Form:server:takeform')
AddEventHandler('qbx_Ab_Form:server:takeform', function(url)
    local src = source
    
        exports.ox_inventory:AddItem(src, "formulaire_empty", 1)
end)