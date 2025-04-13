-- FUNCTION
    -- Fonction pour lire la productivité d'un joueur
    function ViewPlayerFatigue(citizenid, callback)

        if not citizenid then
            print("Erreur : citizenid est invalide.")
            if callback then callback(nil) end
            return
        end

        MySQL.Async.fetchScalar('SELECT fatigue FROM players WHERE citizenid = @citizenid', {
            ['@citizenid'] = citizenid
        }, function(fatigue)
            if callback then
                callback(fatigue or 0)
            end
        end)
    end

-- EVENT
    -- Récupérer la fatigue d'un joueur pour l'afficher
    RegisterNetEvent('qbx_Ab_Fatigue:server:getPlayerFatigue')
    AddEventHandler('qbx_Ab_Fatigue:server:getPlayerFatigue', function(citizenid, cb)
        local src = source
        ViewPlayerFatigue(citizenid, function(fatigue)
            
            if cb then
                cb(fatigue)
            end
            TriggerClientEvent('qbx_Ab_Fatigue:client:updateFatigueDisplay', src, fatigue)
                --print (fatigue.. " envoyé")
            
        end)
    end)

    -- Récupérer la fatigue d'un joueur pour l'afficher
    RegisterNetEvent('qbx_Ab_Fatigue:server:sendPlayerFatigue')
    AddEventHandler('qbx_Ab_Fatigue:server:sendPlayerFatigue', function(citizenid, cb)
        local src = source
        --print ("sendPlayerFatigue trigger")
        ViewPlayerFatigue(citizenid, function(fatigue)
            -- Envoie la fatigue actuelle au client
            TriggerClientEvent('qbx_Ab_Fatigue:client:receivePlayerFatigue', src, fatigue or 0)
            --print (src.. " receivePlayerFatigue trigger " ..fatigue)
        end)
    end)

    -- Fonction pour mettre à jour la fatigue d'un joueur
    RegisterNetEvent('qbx_Ab_Fatigue:server:setPlayerFatigue')
    AddEventHandler('qbx_Ab_Fatigue:server:setPlayerFatigue', function(citizenid, newFatigue)
        local src = source
        if newFatigue < 0 then newFatigue = 0 end
        if newFatigue > 100 then newFatigue = 100 end

        MySQL.Async.execute('UPDATE players SET fatigue = ? WHERE citizenid = ?', {newFatigue, citizenid}, function()
            TriggerClientEvent('qbx_Ab_Fatigue:client:updateFatigueDisplay', src, newFatigue)  -- Met à jour l'affichage côté client
        end)
    end)


    -- Fonction pour modifier la fatigue d'un joueur
    RegisterNetEvent('qbx_Ab_Fatigue:server:local_modifyPlayerFatigue')
    AddEventHandler('qbx_Ab_Fatigue:server:local_modifyPlayerFatigue', function(value, src)
        src = src or source
        local player = exports.qbx_core:GetPlayer(src)

        if not player or not player.PlayerData then
            print("Erreur : impossible de récupérer les données du joueur pour l'ID source : " .. tostring(src))
            return
        end

        local citizenid = player.PlayerData.citizenid

        ViewPlayerFatigue(citizenid, function(currentFatigue)
            if currentFatigue == nil then
                print("Erreur : Impossible de récupérer la fatigue actuelle.")
                return
            end

            -- Calcul de la nouvelle fatigue
            local newFatigue = currentFatigue + value
            if newFatigue < 0 then newFatigue = 0 end
            if newFatigue > 100 then newFatigue = 100 end

            -- Mise à jour de la fatigue dans la base de données
            MySQL.Async.execute('UPDATE players SET fatigue = ? WHERE citizenid = ?', {newFatigue, citizenid}, function(rowsChanged)
                if rowsChanged and rowsChanged > 0 then
                    --("Fatigue mise à jour de : " .. newFatigue)
                    TriggerClientEvent('qbx_Ab_Fatigue:client:updateFatigueDisplay', src, newFatigue)  -- Met à jour l'affichage côté client

                else
                    print("Erreur : mise à jour de la fatigue échouée")
                end
            end)
        end)
    end)

    -- event pour voir la fatigue d'une cible 
    RegisterNetEvent('qbx_Ab_Fatigue:server:getTargetFatigue')
    AddEventHandler('qbx_Ab_Fatigue:server:getTargetFatigue', function(targetSource)
        local src = source
        local targetPlayer = exports.qbx_core:GetPlayer(targetSource)
        --print (targetPlayer)

        if not targetPlayer or not targetPlayer.PlayerData then
            TriggerClientEvent('QBCore:Notify', src, "Joueur introuvable ou déconnecté.", "error")
            return
        end

        local citizenid = targetPlayer.PlayerData.citizenid
        --print (citizenid)

        -- Récupérer la fatigue du joueur ciblé
        ViewPlayerFatigue(citizenid, function(fatigue)
            -- Envoie directement la fatigue au joueur ayant initié l'interaction
            TriggerClientEvent('qbx_Ab_Fatigue:client:showTargetFatigue', src, fatigue)
        end)
    end)

