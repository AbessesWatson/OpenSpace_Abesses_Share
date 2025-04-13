
local DirtLvl = {}
local DirtMax = 10
local restoreDirt = 0

-- SQL STUFF

-- Initialiser un prop (toilette ou table) dans la base de données
local function initPropInDatabase(propId, propName)
    MySQL.Async.execute(
        "INSERT INTO Ab_PropToClean (id, prop_name, DirtLvl) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE DirtLvl = VALUES(DirtLvl)", 
        { propId, propName, restoreDirt},
        function()
            DirtLvl[propId] = 0
            local dirtlvlnotify = DirtLvl[propId]
            print("Prop initialisé avec ID:", propId, "Nom:", propName, "et Niveau de saleté:", dirtlvlnotify)
        end
    )
end

-- Chargement des niveaux de saleté depuis la base de données au démarrage
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then

        MySQL.Async.fetchAll('SELECT * FROM Ab_PropToClean', {}, function(results)
            for _, row in pairs(results) do
                DirtLvl[row.id] = row.DirtLvl
            end
            print('Les niveaux de saleté ont été chargés avec succès.')
        end)
    end
end)

-- PARTIE TOILETTE

    -- Événement pour nettoyer les toilettes
    RegisterNetEvent('qbx_Ab_CleanWipe:server:cleanToilet')
    AddEventHandler('qbx_Ab_CleanWipe:server:cleanToilet', function(coords, propName)
        local src = source
        local toiletId = coords
        local propName = propName

        -- Initialiser la quantité d'eau pour cette Machine à café si elle n'existe pas encore
        if not DirtLvl[toiletId] then
            initPropInDatabase(toiletId, propName)
        end
        Wait(300)
        -- Vérifier le niveau de saleté des toilettes
        --print (DirtLvl[toiletId])
        if DirtLvl[toiletId] > Config.needcleanlvl then
            -- Réduire le compteur de la Machine
            DirtLvl[toiletId] = restoreDirt

            -- Mise à jour de la base de données
            MySQL.Async.execute("UPDATE Ab_PropToClean SET DirtLvl = ? WHERE id = ?", { DirtLvl[toiletId], toiletId })

            TriggerClientEvent('qbx_Ab_CleanWipe:client:cleanToiletAnimation', src) -- Lance l'animation de boisson
            TriggerClientEvent('QBCore:Notify', src, "Vous nettoyez les toilettes.", "success", 5000)
            --exports.ox_inventory:RemoveItem(src, Config.toiletbrushitem, 0.1) -- reduit la durabilité d'une brosse à chiotte
        else
            TriggerClientEvent('QBCore:Notify', src, "Cette toilette n'a pas besoin d'être nettoyer", "error", 5000)
        end
    end)

    -- Événement pour vérifier le niveau de saleté
    RegisterNetEvent('qbx_Ab_CleanWipe:server:checkToiletDirt')
    AddEventHandler('qbx_Ab_CleanWipe:server:checkToiletDirt', function(coords, propName)
        local src = source
        local toiletId = coords
        local propName = propName

        -- Initialiser la la saleté si elle n'existe pas encore
        if not DirtLvl[toiletId] then
            initPropInDatabase(toiletId, propName)
        end
        Wait (300)
        -- Renvoyer le niveau de salté au client à adapter
        if DirtLvl[toiletId] == DirtMax then
            TriggerClientEvent('QBCore:Notify', src, "Cette toilette est très sale!", "warning", 5000)
        elseif DirtLvl[toiletId] > Config.needcleanlvl then 
            TriggerClientEvent('QBCore:Notify', src, "Cette toilette est sale!", "warning", 5000)
        elseif DirtLvl[toiletId] == Config.needcleanlvl or DirtLvl[toiletId] < Config.needcleanlvl then 
            if DirtLvl[toiletId] == 0 then
                TriggerClientEvent('QBCore:Notify', src, "Cette toilette est parfaitement propre", "info", 5000) 
            else
                TriggerClientEvent('QBCore:Notify', src, "Cette toilette est dans un état correcte", "info", 5000) 
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "Il n'est pas possible de definir l'état de cette toilette.", "warning", 5000)
        end
    end)


    -- Fonction pour augmenter le niveau de salté des toilette toutes les x minutes
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Config.dirtytimeToilet * 60 * 1000)  -- 15 minutes

            for toiletId, dirtLevel in pairs(DirtLvl) do
                if dirtLevel < DirtMax then
                    DirtLvl[toiletId] = dirtLevel + 1

                    Wait(100)

                    -- Mise à jour de la base de données
                    MySQL.Async.execute(
                        "UPDATE Ab_PropToClean SET DirtLvl = ? WHERE id = ? AND prop_name = ?", 
                        { DirtLvl[toiletId], toiletId, "Toilette" }
                    )
                    --print("La saleté des toilettes a augmenté.")
                elseif dirtLevel >= DirtMax then
                    DirtLvl[toiletId] = DirtMax

                    Wait(100)

                    -- Mise à jour de la base de données
                    MySQL.Async.execute(
                        "UPDATE Ab_PropToClean SET DirtLvl = ? WHERE id = ? AND prop_name = ?", 
                        { DirtLvl[toiletId], toiletId, "Toilette" }
                    )
                    --print("La saleté des toilettes a augmenté.")                  
                end
            end
        end
    end)

-- PARTIE Table

-- Événement pour salire les Table
RegisterNetEvent('qbx_Ab_CleanWipe:server:UpDirtyTable')
AddEventHandler('qbx_Ab_CleanWipe:server:UpDirtyTable', function(coords, propName)
    local src = source
    local tableId = coords
    local propName = propName
    local updirty = Config.updirty

    -- Initialiser la saleté si elle n'existe pas encore
    if not DirtLvl[tableId] then
        initPropInDatabase(tableId, propName)
    end
    Wait(300)
    -- Vérifier le niveau de saleté des tables
    if DirtLvl[tableId] < DirtMax then
        -- Réduire le compteur 
        DirtLvl[tableId] = DirtLvl[tableId] + updirty
        --print('salté augmenté de ' ..updirty)

        -- Mise à jour de la base de données
        MySQL.Async.execute("UPDATE Ab_PropToClean SET DirtLvl = ? WHERE id = ?", { DirtLvl[tableId], tableId })
    else
        --print("table déjà trop sale")
    end
end)

-- Événement pour nettoyer les Table
RegisterNetEvent('qbx_Ab_CleanWipe:server:cleanTable')
AddEventHandler('qbx_Ab_CleanWipe:server:cleanTable', function(coords, propName)
    local src = source
    local tableId = coords
    local propName = propName

    -- Initialiser la saleté si elle n'existe pas encore
    if not DirtLvl[tableId] then
        initPropInDatabase(tableId, propName)
    end
    Wait(300)
    -- Vérifier le niveau de saleté des tables
    --print (DirtLvl[tableId])
    if DirtLvl[tableId] > Config.needcleanlvl then
        -- Réduire le compteur 
        DirtLvl[tableId] = restoreDirt

        -- Mise à jour de la base de données
        MySQL.Async.execute("UPDATE Ab_PropToClean SET DirtLvl = ? WHERE id = ?", { DirtLvl[tableId], tableId })

        TriggerClientEvent('qbx_Ab_CleanWipe:client:cleanTableAnimation', src) -- Lance l'animation de boisson
        TriggerClientEvent('QBCore:Notify', src, "Vous nettoyez la table.", "success", 5000)
        exports.ox_inventory:RemoveItem(src, Config.wipeitem, 1) -- reduit la durabilité d'une brosse à chiotte
    else
        TriggerClientEvent('QBCore:Notify', src, "Cette table n'a pas besoin d'être nettoyer", "error", 5000)
    end
end)

-- Événement pour vérifier le niveau de saleté
RegisterNetEvent('qbx_Ab_CleanWipe:server:checkTableDirt')
AddEventHandler('qbx_Ab_CleanWipe:server:checkTableDirt', function(coords, propName)
    local src = source
    local tableId = coords
    local propName = propName

    -- Initialiser la saleté si elle n'existe pas encore
    if not DirtLvl[tableId] then
        initPropInDatabase(tableId, propName)
    end
    Wait(300)
    -- Renvoyer le niveau de salté au client à adapter
    if DirtLvl[tableId] == DirtMax then
        TriggerClientEvent('QBCore:Notify', src, "Cette table est très sale!", "warning", 5000)
    elseif DirtLvl[tableId] > Config.needcleanlvl then 
        TriggerClientEvent('QBCore:Notify', src, "Cette table est sale!", "warning", 5000)
    elseif DirtLvl[tableId] == Config.needcleanlvl or DirtLvl[tableId] < Config.needcleanlvl then 
        if DirtLvl[tableId] == 0 then
            TriggerClientEvent('QBCore:Notify', src, "Cette table est parfaitement propre", "info", 5000) 
        else
            TriggerClientEvent('QBCore:Notify', src, "Cette table est dans un état correcte", "info", 5000) 
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "Il n'est pas possible de definir l'état de cette table.", "warning", 5000)
    end

    -- Mise à jour de la base de données
    local dirtlvlnotify = DirtLvl[tableId]
    print ("save for " ..tableId.. " dirtlvl " ..DirtLvl[tableId])
    MySQL.Async.execute(
        "UPDATE Ab_PropToClean SET DirtLvl = ? WHERE id = ? AND prop_name = ?", 
        { DirtLvl[tableId], tableId, "Table" }
    )

end)


-- Fonction pour augmenter le niveau de salté des tables toutes les x minutes
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.dirtytimeTable * 60 * 1000)  -- 15 minutes

        for tableId, dirtLevel in pairs(DirtLvl) do
            if dirtLevel < DirtMax then
                DirtLvl[tableId] = dirtLevel + 1

                Wait(100)

                -- Mise à jour de la base de données
                MySQL.Async.execute(
                    "UPDATE Ab_PropToClean SET DirtLvl = ? WHERE id = ? AND prop_name = ?", 
                    { DirtLvl[tableId], tableId, "Table" }
                )
                --print("La saleté des tables a augmenté.")
            elseif dirtLevel >= DirtMax then
                DirtLvl[tableId] = DirtMax

                Wait(100)

                -- Mise à jour de la base de données
                MySQL.Async.execute(
                    "UPDATE Ab_PropToClean SET DirtLvl = ? WHERE id = ? AND prop_name = ?", 
                    { DirtLvl[tableId], tableId, "Table" }
                )
                --print("La saleté des tables a augmenté.")                
            end
        end
    end
end)
