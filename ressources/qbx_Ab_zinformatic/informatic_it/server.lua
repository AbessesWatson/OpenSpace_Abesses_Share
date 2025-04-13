math.randomseed(os.time()) 

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


RegisterNetEvent('qbx_Ab_informatic:server:attemptRepair', function(coords, src)
    local src = src or source
    local player = exports.qbx_core:GetPlayer(src)
    local citizenid = player.PlayerData.citizenid

    if not player then
        print("Erreur : joueur introuvable pour src : " .. tostring(src))
        return
    end

    -- Utiliser directement la fonction ViewPlayerFatigue pour récupérer la fatigue
    ViewPlayerFatigue(citizenid, function(fatigue)
        local successRate = 0
        
        -- Définir le taux de réussite en fonction de la fatigue
        if fatigue < 50 then
            successRate = 85
        elseif fatigue >= 50 and fatigue < 75 then
            successRate = 70
        elseif fatigue >= 75 and fatigue < 100 then
            successRate = 50
        elseif fatigue == 100 then
            successRate = 10
        end
        print('Fatigue: ' .. fatigue .. ', Success Rate: ' .. successRate .. ' for ' .. citizenid)

        -- Calculer si la réparation réussit ou échoue
        if math.random(1, 100) <= successRate then
            -- Réussite

            TriggerClientEvent('qbx_Ab_informatic:client:repairComputerAnimation', src)
            TriggerClientEvent('QBCore:Notify', src, "Tu essayes de réparer l'ordinateur", "success", Config.time.repair_time)

            Wait(Config.time.repair_time)

            TriggerClientEvent('QBCore:Notify', src, "Réparation réussie ! ", "success", 2500)
            TriggerEvent('hud:server:GainStress',Config.upstress.repairComputergood ,src) -- augmente le stress
            TriggerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', src, 10) -- augmente la fatigue
            exports.ox_inventory:RemoveItem(src, "good_carte_mere", 1) -- Retirer la bonne carte
            exports.ox_inventory:AddItem(src, "bad_carte_mere", 1) -- Ajouter une carte cassée


            -- Informer le client de lancer l'event saveComputer
            TriggerClientEvent('qbx_Ab_informatic:client:repairSuccess', src, coords)
        else
            -- Échec
            TriggerClientEvent('qbx_Ab_informatic:client:repairComputerAnimation', src)
            TriggerClientEvent('QBCore:Notify', src, "Tu essayes de réparer l'ordinateur", "success", Config.time.repair_time)
            Wait(Config.time.repair_time)
            TriggerClientEvent('QBCore:Notify', src, "Échec de la réparation !", "error", 2500)
            TriggerEvent('hud:server:GainStress',Config.upstress.repairComputerbad ,src) -- augmente le stress
            TriggerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', src, 10) -- augmente la fatigue
        end
    end)

    -- Pas besoin de `Wait(50)` ici, sauf si vous avez besoin de gérer une logique asynchrone particulière
end)

