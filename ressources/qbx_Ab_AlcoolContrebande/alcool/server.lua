
-- mettre a jour dans la bdd
RegisterNetEvent("qbx_Ab_AlcoolContrebande:server:UpdateDrunkLvl")
AddEventHandler("qbx_Ab_AlcoolContrebande:server:UpdateDrunkLvl", function(Drunklvl)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)

    if not player or not player.PlayerData then
        print("Erreur : impossible de récupérer les données du joueur pour l'ID source : " .. tostring(src))
        return
    end

    local citizenid = player.PlayerData.citizenid

    -- Mise à jour de la fatigue dans la base de données
    MySQL.Async.execute('UPDATE players SET drunk = ? WHERE citizenid = ?', {Drunklvl, citizenid}, function(rowsChanged)
        if rowsChanged and rowsChanged > 0 then
            --print("Drunklvl mise à jour de : " .. Drunklvl)

        else
            print("Erreur : mise à jour de Drunklvl a échouée")
        end
    end)    

end)

-- envoyé depuis la bdd vers le client le drunklvl
RegisterNetEvent("qbx_Ab_AlcoolContrebande:server:GetDrunkLvl")
AddEventHandler("qbx_Ab_AlcoolContrebande:server:GetDrunkLvl", function(citizenid)
    local src = source
    local drunklvl_get = nil

    if not citizenid then
        print("Erreur : citizenid est invalide.")
    else
        MySQL.Async.fetchScalar('SELECT drunk FROM players WHERE citizenid = @citizenid', {
            ['@citizenid'] = citizenid
        }, function(drunklvl_get)
            --print (drunklvl_get.. " drunk lvl reçu")
            TriggerClientEvent('qbx_Ab_AlcoolContrebande:client:updateDrunk', src, drunklvl_get)
        end)
    end

end)

RegisterNetEvent('qbx_Ab_AlcoolContrebande:server:openBottle', function(slot, itembase, itemresult, result_number, itemused, itemtrash)
    local src = source

    exports.ox_inventory:RemoveItem(src, itembase, 1)
    exports.ox_inventory:RemoveItem(src, itemused, result_number)
    exports.ox_inventory:AddItem(src, itemresult, result_number)
    exports.ox_inventory:AddItem(src, itemtrash, 1)

end)

RegisterNetEvent('qbx_Ab_AlcoolContrebande:server:openPack', function(slot, itembase, itemresult, result_number, itemtrash)
    local src = source

    exports.ox_inventory:RemoveItem(src, itembase, 1)
    exports.ox_inventory:AddItem(src, itemresult, result_number)
    exports.ox_inventory:AddItem(src, itemtrash, 1)

end)

RegisterNetEvent('qbx_Ab_AlcoolContrebande:server:water_alanis', function()

    local src = source

    exports.ox_inventory:RemoveItem(src, 'alanis_goblet', 1)
    exports.ox_inventory:AddItem(src, 'alanis_goblet_watered', 1)

end)


-- envoyé depuis la bdd vers le client le drunklvl
RegisterNetEvent("qbx_Ab_AlcoolContrebande:server:getTargetDrunklvl")
AddEventHandler("qbx_Ab_AlcoolContrebande:server:getTargetDrunklvl", function(target)
    local src = source
    local targetSource = target
    local targetPlayer = exports.qbx_core:GetPlayer(targetSource)
    --print (targetPlayer)

    if not targetPlayer or not targetPlayer.PlayerData then
        TriggerClientEvent('QBCore:Notify', src, "Joueur introuvable ou déconnecté.", "error")
        return
    end

    local citizenid = targetPlayer.PlayerData.citizenid
    --print (citizenid)

    if not citizenid then
        print("Erreur : citizenid est invalide.")
    else
        MySQL.Async.fetchScalar('SELECT drunk FROM players WHERE citizenid = @citizenid', {
            ['@citizenid'] = citizenid
        }, function(drunklvl_get)
            --print (drunklvl_get.. " drunk lvl de target reçu")
            TriggerClientEvent('qbx_Ab_AlcoolContrebande:client:showTargetDrunkLvl', src, drunklvl_get)
            exports.ox_inventory:RemoveItem(src, Config.item_ethylo, 1)
        end)
    end

end)