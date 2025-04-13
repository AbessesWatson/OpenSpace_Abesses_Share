archive_cachettestash = {
    id = 'archive_cachette',
    label = 'Cachette',
    slots = 2,
    weight = 500, 

}

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
        exports.ox_inventory:RegisterStash(archive_cachettestash.id, archive_cachettestash.label, archive_cachettestash.slots, archive_cachettestash.weight)
    end
end)

RegisterCommand("emotetoplayer", function(source, args, rawCommand)
    -- Vérifier si un argument a été donné (ID cible)
    if #args < 1 then
        print("Usage : /moncommande [playerId] [autres_arguments...]")
        return
    end

    -- Récupérer la cible (premier argument)
    local targetId = tonumber(args[1])

    -- Vérifier si l'ID est valide
    if not targetId or not GetPlayerName(targetId) then
        print("Joueur introuvable !")
        return
    end

    -- Récupérer les arguments suivants
    local emotename = args[2]

    -- Exécuter l'action sur la cible
    TriggerClientEvent("monEvenementClient", targetId, emotename)
    TriggerClientEvent('scully_emotemenu:playEmoteByCommand', targetId, emotename)

end, false)