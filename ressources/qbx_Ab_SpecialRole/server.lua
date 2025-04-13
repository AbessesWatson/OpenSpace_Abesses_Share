RegisterCommand('specialclothes', function(source, args, rawCommand)
    -- Vérifie si le joueur est valide
    if source == 0 then return end

    -- Envoie un événement au client qui a tapé la commande
    TriggerClientEvent('qbx_Ab_SpecialRole:client:killermode', source)
end, false)

RegisterNetEvent('qbx_Ab_SpecialRole:server:notifykiller')
AddEventHandler('qbx_Ab_SpecialRole:server:notifykiller', function(onoff)

    TriggerClientEvent('qbx_Ab_SpecialRole:client:notifykiller', -1, onoff)

end)