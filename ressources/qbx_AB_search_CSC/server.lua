RegisterNetEvent('qbx_Ab_minigame_CSC:server:checkDate', function(dateInput)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    local datechecked = dateInput
    print(datechecked.. 'est la date')
    
    -- Vérifie si la date saisie est valide
    if Config.validDates[datechecked] then
        local item = Config.validDates[datechecked]
        print(item.. " for " ..src)
        -- Donne l'objet associé à la date
        exports.ox_inventory:AddItem(src, item, 1) -- ajoute le document
        TriggerClientEvent('QBCore:Notify', src, "Vous avez trouvé le document !", 'success', 8000)
    else
        TriggerClientEvent('QBCore:Notify', src, "Aucun document ne correspond à cette date.", 'error', 8000)
    end
end)

