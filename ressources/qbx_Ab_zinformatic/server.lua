
-- Table pour gérer les ordinateurs dans les états `full_lock` et `lock`
local fullLockComputers = {}
local lockComputers = {}

-- Fonction pour récupérer la santé d'un ordinateur depuis la base de données
 function getComputerHealth(computerID, cb)
    MySQL.Async.fetchScalar('SELECT health FROM Ab_Computer WHERE id = ?', {computerID}, function(health)
        if health then
            local numberhealth = tonumber(health)
            cb(health)
        else
            print(("Ordinateur %s introuvable."):format(computerID))
            cb(nil)
        end
    end)
end

-- Fonction pour ajouter un ordinateur en état `full_lock`
function handleFullLock(computerID, health)
    if fullLockComputers[computerID] then
        print(("L'ordinateur %s est déjà en état full_lock."):format(computerID))
        return
    end

    -- Mettre à jour l'état à `full_lock`
    TriggerEvent('qbx_Ab_informatic:server:saveComputer', computerID, 'full_lock', health)

    -- Ajouter l'ordinateur à la gestion de `full_lock`
    fullLockComputers[computerID] = {
        health = health,
        startTime = GetGameTimer() -- Timestamp du début de `full_lock`
    }

    print(("Ordinateur %s est maintenant en full_lock pour 7 minutes."):format(computerID))
end

-- Fonction pour ajouter un ordinateur en état `lock` après `full_lock`
function handleLock(computerID, health)
    if lockComputers[computerID] then
        print(("L'ordinateur %s est déjà en état lock."):format(computerID))
        return
    end

    -- Mettre à jour l'état à `lock`
    TriggerEvent('qbx_Ab_informatic:server:saveComputer', computerID, 'lock', health)

    -- Ajouter l'ordinateur à la gestion de `lock`
    lockComputers[computerID] = {
        health = health,
        startTime = GetGameTimer() -- Timestamp du début de `lock`
    }

    print(("Ordinateur %s est maintenant en lock pour 3 minutes."):format(computerID))
end



-- Événement pour forcer un ordinateur à passer de `full_lock` à `lock`
RegisterNetEvent("qbx_Ab_informatic:server:force_lock", function(computerID)
    if not computerID then
        print("Erreur : Aucun ID d'ordinateur fourni pour l'événement force_lock.")
        return
    end

    if fullLockComputers[computerID] then
        -- Récupérer les données de l'ordinateur
        local computerData = fullLockComputers[computerID]

        -- Supprimer l'ordinateur de `fullLockComputers`
        fullLockComputers[computerID] = nil
        print(("Ordinateur %s supprimé de fullLockComputers."):format(computerID))

        handleLock(computerID, computerData.health)
        print(("Ordinateur %s est maintenant en état lock."):format(computerID))
        Wait(10)

        
    else
        print(("Ordinateur %s n'est pas dans l'état full_lock."):format(computerID))
    end
end)

-- ////////////////

-- Fonction pour gérer l'initialisation ou la mise à jour d'un prop
RegisterNetEvent('qbx_Ab_informatic:server:saveComputer', function(coords, state, health)
    local src = source
    local computerID = coords -- Générer l'ID basé sur les coordonnées

    -- Vérifie si le props existe dans la base de données
    MySQL.Async.fetchScalar('SELECT id FROM Ab_Computer WHERE id = ?', {computerID}, function(existingID)
        if existingID then
            -- Si l'ordinateur existe, on met à jour son état et sa santé
            MySQL.Async.execute(
                'UPDATE Ab_Computer SET state = ?, health = ? WHERE id = ?',
                {state, health, computerID},
                function(rowsChanged)
                    print("Mise à jour réussie pour l'ordinateur : " .. computerID)
                    TriggerClientEvent('qbx_Ab_informatic:client:syncComputer', -1, computerID, state, health) -- Synchronisation côté client
                end
            )
        else
            -- Si l'ordinateur n'existe pas, on l'ajoute
            MySQL.Async.execute(
                'INSERT INTO Ab_Computer (id, state, health) VALUES (?, ?, ?)',
                {computerID, state or 'active', health or 100},
                function(rowsChanged)
                    print("Ordinateur initialisé avec succès : " .. computerID)
                    TriggerClientEvent('qbx_Ab_informatic:client:syncComputer', src, computerID, state or 'active', health or 100) -- Synchronisation côté client
                end
            )
        end
    end)
end)

-- Récupérer les données d'un ordinateur
RegisterNetEvent('qbx_Ab_informatic:server:getComputerData', function(computerID, callback)
    -- Récupérer les données de l'ordinateur
    MySQL.Async.fetchAll('SELECT state, health FROM Ab_Computer WHERE id = ?', {computerID}, function(result)
        if result[1] then
            -- Renvoie l'état et la santé de l'ordinateur au client
            callback(result[1].state, result[1].health)
        else
            -- Si aucune donnée trouvée, renvoyer un état par défaut
            callback('active', 100)
        end
    end)
end)

RegisterServerEvent('qbx_Ab_informatic:server:getComputerState')
AddEventHandler('qbx_Ab_informatic:server:getComputerState', function(computerID, callback)
    -- Effectuer la requête SQL pour obtenir l'état de l'ordinateur
    MySQL.Async.fetchScalar('SELECT state FROM Ab_Computer WHERE id = @id', {
        ['@id'] = computerID
    }, function(state)
        -- Renvoyer l'état de l'ordinateur au client via la callback
        if state then
            callback(state)  -- Envoie l'état de l'ordinateur récupéré
        else
            callback('active')  -- Si aucun état trouvé, renvoie 'active'
        end
    end)
end)

RegisterNetEvent('qbx_Ab_informatic:server:getAllComputers', function()
    -- Récupérer tous les ordinateurs et leur état
    MySQL.Async.fetchAll('SELECT * FROM Ab_Computer', {}, function(results)
        for _, computer in ipairs(results) do
            TriggerClientEvent('qbx_Ab_informatic:client:syncComputer', -1, computer.id, computer.state, computer.health)
            --print("[SERVER SYNC] Ordinateur:", computer.id, "État:", computer.state, "Santé:", computer.health)
        end
    end)
end)

-- Fonction pour charger les props au démarrage
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    TriggerEvent('qbx_Ab_informatic:server:getAllComputers', function()
    end)
end)


-- commande

RegisterCommand('showAllComputers', function(source)
    -- Récupérer tous les ordinateurs depuis la base de données
    MySQL.Async.fetchAll('SELECT id FROM Ab_Computer', {}, function(results)
        if results and #results > 0 then
            for _, computer in ipairs(results) do
                local computerID = computer.id
                -- Demander les informations sur l'ordinateur à partir de la base de données
                MySQL.Async.fetchAll('SELECT state, health FROM Ab_Computer WHERE id = ?', {computerID}, function(result)
                    if result[1] then
                        -- Afficher les informations de l'ordinateur dans la console
                        print(string.format("Ordinateur ID: %s, État: %s, Santé: %d", computerID, result[1].state, result[1].health))
                    else
                        -- Afficher un message si l'ordinateur n'existe pas
                        print(string.format("Ordinateur ID: %s, Aucun état trouvé", computerID))
                    end
                end)
            end
        else
            print("Aucun ordinateur trouvé dans la base de données.")
        end
    end)
end, false)




-- Thread pour gérer l'état `full_lock`
CreateThread(function()
    while true do
        Wait(1000) -- Vérifier chaque seconde

        local currentTime = GetGameTimer()

        for computerID, data in pairs(fullLockComputers) do
            if currentTime - data.startTime >= Config.time.full_lock_time then
                -- Fin de `full_lock`, transition vers `lock`
                handleLock(computerID, data.health)

                -- Supprimer l'ordinateur de la table `fullLockComputers`
                fullLockComputers[computerID] = nil
            end
        end
    end
end)

-- Thread pour gérer l'état `lock`
CreateThread(function()
    while true do
        Wait(1000) -- Vérifier chaque seconde

        local currentTime = GetGameTimer()

        for computerID, data in pairs(lockComputers) do
            if currentTime - data.startTime >= Config.time.lock_time then
                -- Fin de `lock`, transition vers `active`
                TriggerEvent('qbx_Ab_informatic:server:saveComputer', computerID, 'active', data.health)

                print(("Ordinateur %s est maintenant actif."):format(computerID))

                -- Supprimer l'ordinateur de la table `lockComputers`
                lockComputers[computerID] = nil
            end
        end
    end
end)

-- SHARED /////////


-- Fonction pour gérer l'état `full_lock`
RegisterNetEvent('qbx_Ab_informatic:server:local_handleComputerfull_lock', function(computerID)
    local src = source

    getComputerHealth(computerID, function(health)
        print("full_lock: " ..computerID.. " ".. health)
        if health and health > 0 then
            handleFullLock(computerID, health)
        elseif health and health <= 0 then
            print(("L'ordinateur %s est déjà en panne (santé : %d)."):format(computerID, health))
        else
            TriggerClientEvent('QBCore:Notify', src, "Impossible de trouver l'ordinateur.", "error", 5000)
        end
    end)
end)

-- Fonction pour gérer l'état `lock`
RegisterNetEvent('qbx_Ab_informatic:server:local_handleComputerlock', function(computerID)
    local src = source

    getComputerHealth(computerID, function(health)
        print("full_lock: " ..computerID.. " ".. health)
        if health and health > 0 then
            handleLock(computerID, health)
        elseif health and health <= 0 then
            print(("L'ordinateur %s est déjà en panne (santé : %d)."):format(computerID, health))
        else
            TriggerClientEvent('QBCore:Notify', src, "Impossible de trouver l'ordinateur.", "error", 5000)
        end
    end)
end)

-- baisse la santé de l'ordi
RegisterNetEvent('qbx_Ab_informatic:server:local_decreaseComputerHealth', function(computerID, amount)
    local src = source
    print("decreaseComputerHealth activated")

    -- Récupérer la santé actuelle et l'état depuis la base de données
    MySQL.Async.fetchAll('SELECT health, state FROM Ab_Computer WHERE id = @id', {
        ['@id'] = computerID
    }, function(result)
        if result[1] then
            local currentHealth = result[1].health
            local currentState = result[1].state

            -- Calculer la nouvelle santé
            local newHealth = math.max(0, currentHealth - amount)

            -- Si la santé atteint zéro, mettre l'état à 'broken'
            local newState = currentState
            if newHealth == 0 then
                newState = 'broken'
            end

            -- Utiliser l'événement 'saveComputer' pour mettre à jour l'état et la santé
            TriggerEvent('qbx_Ab_informatic:server:saveComputer', computerID, newState, newHealth)
            print ("computer: " ..computerID.. "new save: " ..newState.. " " ..newHealth)

        else
            -- Si l'ordinateur n'est pas trouvé
            TriggerClientEvent('QBCore:Notify', src, "Ordinateur non trouvé.", "error", 5000)
        end
    end)
end)