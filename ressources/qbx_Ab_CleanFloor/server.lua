

local spawnedProps = {} -- Table pour suivre les props créés

local dirtplaces = {} --Table pour les location et leur niveau de saleté

local dirtytime = math.random(Config.dirtytimemmini, Config.dirtytimemaxi)

local spawnedSign = {}

-- FONCTION 

    -- Convertir un vector3 en clé SQL-friendly
    local function vectorToKey(vec)
        return string.format("%.2f,%.2f,%.2f", vec.x, vec.y, vec.z)
    end

    -- Fonction pour mettre à jour la variable aléatoire régulièrement
    local function updateRandomdirtytime()

        dirtytime = math.random(Config.dirtytimemmini, Config.dirtytimemaxi) -- Génère une nouvelle valeur aléatoire
        --print("Nouvelle valeur de dirtytime : " .. dirtytime)

    end

    -- Insère une nouvelle zone dans SQL si elle n'existe pas
    local function insertDirtPlaceInSQL(coords)
        local key = vectorToKey(coords)
            MySQL.Async.fetchAll("SELECT * FROM Ab_CleanFloor WHERE id = ?", { key }, function(result)
                if #result == 0 then -- Si la zone n'existe pas, on l'insère
                    MySQL.Async.execute(
                        "INSERT INTO Ab_CleanFloor (id, x, y, z, DirtLvl) VALUES (?, ?, ?, ?, ?)", 
                        { key, coords.x, coords.y, coords.z, 0},
                        function()
                            print("Dirt Place initialisé key : " ..key)
                        end
                    )
                end
            end)
    end

    local function loadDirtPlaceInTable()
        MySQL.Async.fetchAll('SELECT * FROM Ab_CleanFloor', {}, function(results)
            for _, row in pairs(results) do
                local coords = vec3(row.x, row.y, row.z)
                dirtplaces[row.id] = { coords = coords, dirtLvl = row.DirtLvl, spawned = false }
            end
            print('Les niveaux de saleté du sol ont été chargés avec succès.')
        end)
    end



-- ON ressource start

    -- Chargement des niveaux de saleté depuis la base de données au démarrage
    AddEventHandler('onResourceStart', function(resourceName)
        if resourceName == GetCurrentResourceName() then

            -- Insérer les places définies de config dans sql si elles n'existent pas
            for _, coords in pairs(Config.dirt_coord) do
                insertDirtPlaceInSQL(coords)
            end

            -- Charger toutes les zones en mémoire
            Wait(3000) -- Attendre l'insertion avant de charger
            loadDirtPlaceInTable()
            Wait(2000)
            for id, data in pairs(dirtplaces) do
                if data.dirtLvl == Config.needcleanlvl then
                    --print("La dirtplaces est sale.") 
                    if data.spawned == false then
                        data.spawned = true
                        -- Envoyer un événement au client pour créer le prop
                        TriggerClientEvent('qbx_Ab_CleanFloor:Client:spawnProp', -1, Config.props_dirt, data.coords) -- -1 = visible pour tous
                        table.insert(spawnedProps, {model = Config.props_dirt, coords = data.coords}) -- Ajout dans la liste
                    else
                        print("Prop déjà spawn.")
                    end
                end
            end
        end
    end)

    -- Événement pour envoyer les props coté client
    RegisterNetEvent('qbx_Ab_CleanFloor:Server:GetProps')
    AddEventHandler('qbx_Ab_CleanFloor:Server:GetProps', function()
        local src = source
    
        -- Vérifie si dirtplaces est vide
        if next(dirtplaces) == nil then
            -- Lancer une boucle qui attend que dirtplaces ne soit plus vide
            Citizen.CreateThread(function()
                while next(dirtplaces) == nil do
                    Wait(100) -- Vérifie regulierement
                end
    
                -- Une fois rempli, on envoie les données
                TriggerClientEvent('qbx_Ab_CleanFloor:Client:ReceiveDirtProps', src, dirtplaces)
            end)
        else
            -- Si déjà rempli, on envoie directement
            TriggerClientEvent('qbx_Ab_CleanFloor:Client:ReceiveDirtProps', src, dirtplaces)
        end
    end)

    -- Event quand un joueur se connecte
    RegisterNetEvent('qbx_Ab_CleanFloor:Server:GetSigns')
    AddEventHandler('qbx_Ab_CleanFloor:Server:GetSigns', function()
        local src = source
        print("Envoi des panneaux existants au joueur :", src)

        print("getSigns : " ..json.encode(spawnedSign))
        TriggerClientEvent('qbx_Ab_CleanFloor:Client:UpdateSign', src, spawnedSign)
    end)
    

-- EVENT

    RegisterNetEvent('qbx_Ab_CleanFloor:Server:CleanDirtPlace')
    AddEventHandler('qbx_Ab_CleanFloor:Server:CleanDirtPlace', function(recivedcoords)
        local key = vectorToKey(recivedcoords)

        if dirtplaces[key] then
            -- Mettre à jour le niveau de saleté en mémoire
            dirtplaces[key].dirtLvl = 0
            dirtplaces[key].spawned = false -- Le prop ne sera plus affiché
            dirtplaces[key].nextDirtyTime = os.time() + math.random(Config.dirtytimemmini, Config.dirtytimemaxi) * 60 -- Réinitialiser son propre timer
            print('CleanDirtPlace update :nextDirtyTime: ' ..os.date("%Y-%m-%d %H:%M:%S", dirtplaces[key].nextDirtyTime))

            -- Mise à jour dans la base de données
            MySQL.Async.execute(
                "UPDATE Ab_CleanFloor SET DirtLvl = ? WHERE id = ?", 
                { 0, key }, 
                function(rowsChanged)
                    if rowsChanged > 0 then
                        print("Dirt place nettoyée : " .. key)
                    end
                end
            )

            -- Envoyer un événement client pour supprimer le prop correspondant
            print('recivedcoords : ' ..recivedcoords)
            TriggerClientEvent('qbx_Ab_CleanFloor:Client:RemoveProp', -1, recivedcoords, dirtplaces)
        else
            print("Aucune dirt place trouvée pour ces coordonnées : " .. key)
        end

        for i, prop in ipairs(spawnedProps) do
            if prop.coords.x == recivedcoords.x and prop.coords.y == recivedcoords.y and prop.coords.z == recivedcoords.z then
                table.remove(spawnedProps, i)
                break
            end
        end

    end)


-- THREAD 

    Citizen.CreateThread(function()
        while true do
            updateRandomdirtytime()
            Wait(5*60*1000)
        end
    end)

    -- Fonction pour augmenter le niveau de salté de chaque place toutes les x minutes
    Citizen.CreateThread(function()
        while true do
            local currentTime = os.time() -- Récupère le temps actuel en secondes

            for id, data in pairs(dirtplaces) do

                -- Vérifier si la place a été nettoyée récemment
                if not data.nextDirtyTime then
                    data.nextDirtyTime = currentTime + math.random(Config.dirtytimemmini, Config.dirtytimemaxi) * 60 -- Définir un temps initial
                    --print('Thread update : by if not nextDirtyTime: ' ..os.date("%Y-%m-%d %H:%M:%S", data.nextDirtyTime).. ' pour ' ..id)

                else
                    -- Vérifier si le temps est écoulé pour cette dirtplace
                    if currentTime >= data.nextDirtyTime then
                        if data.dirtLvl == 0 then
                            data.dirtLvl = data.dirtLvl + 1

                            data.spawned = true
                            -- Envoyer un événement au client pour créer le prop
                            TriggerClientEvent('qbx_Ab_CleanFloor:Client:spawnProp', -1, Config.props_dirt, data.coords) -- -1 = visible pour tous
                            table.insert(spawnedProps, {model = Config.props_dirt, coords = data.coords}) -- Ajout dans la liste

                            -- Mise à jour de la base de données
                            MySQL.Async.execute(
                                "UPDATE Ab_CleanFloor  SET DirtLvl = ? WHERE id = ?", 
                                { data.dirtLvl, id }
                            )
                            print("La saleté des dirtplaces a augmenté.")
                            -- Définir un nouveau temps d'attente unique pour cet emplacement
                            data.nextDirtyTime = os.time() + math.random(Config.dirtytimemmini, Config.dirtytimemaxi) * 60
                            print('Thread update : by currentTime >= nextDirtyTime: ' ..os.date("%Y-%m-%d %H:%M:%S", data.nextDirtyTime).. ' pour ' ..id)

                        elseif data.dirtLvl > Config.needcleanlvl then
                            data.dirtLvl = Config.needcleanlvl

                            -- Mise à jour de la base de données
                            MySQL.Async.execute(
                                "UPDATE Ab_CleanFloor  SET DirtLvl = ? WHERE id = ?", 
                                { data.dirtLvl, id }
                            )
                            print("La saleté des dirtplaces a été équilibré.")
                            -- Définir un nouveau temps d'attente unique pour cet emplacement
                            data.nextDirtyTime = os.time() + math.random(Config.dirtytimemmini, Config.dirtytimemaxi) * 60
                            print('Thread update : by data.dirtLvl > Config.needcleanlvl : nextDirtyTime: ' ..os.date("%Y-%m-%d %H:%M:%S", data.nextDirtyTime).. ' pour ' ..id)

                        elseif data.dirtLvl == Config.needcleanlvl then
                            --print("La dirtplaces est sale.") 
                            if data.spawned == false then
                                data.spawned = true
                                -- Envoyer un événement au client pour créer le prop
                                TriggerClientEvent('qbx_Ab_CleanFloor:Client:spawnProp', -1, Config.props_dirt, data.coords) -- -1 = visible pour tous
                                table.insert(spawnedProps, {model = Config.props_dirt, coords = data.coords}) -- Ajout dans la liste

                                -- Définir un nouveau temps d'attente unique pour cet emplacement
                                data.nextDirtyTime = os.time() + math.random(Config.dirtytimemmini, Config.dirtytimemaxi) * 60  
                                print('Thread update : by data.dirtLvl == Config.needcleanlvl : nextDirtyTime: ' ..os.date("%Y-%m-%d %H:%M:%S", data.nextDirtyTime).. ' pour ' ..id)  
                            else
                                --TriggerClientEvent('qbx_Ab_CleanFloor:Client:Updatedirtplaces', -1, dirtplaces)
                            end
                    
                        end
                    end
                end
            end

            TriggerClientEvent('qbx_Ab_CleanFloor:Client:Updatedirtplaces', -1, dirtplaces)
            Wait(5000)
            

        end
    end)

-- COMMANDE DE DEBUG

    RegisterCommand('spawndirt', function(source, args, rawCommand)
        --local xPlayer = QBCore.Functions.GetPlayer(source)
        --if xPlayer then
            -- Vérifiez les arguments
            if #args < 3 then
                TriggerClientEvent('QBCore:Notify', source, "Usage: /spawndirt [x] [y] [z]", "error")
                return
            end

            local model = Config.props_dirt
            local x, y, z = tonumber(args[1]), tonumber(args[2]), (tonumber(args[3]))

            if model and x and y and z then
                -- Envoyer un événement au client pour créer le prop
                TriggerClientEvent('qbx_Ab_CleanFloor:Client:commandSpawnProp', -1, model, vector3(x, y, z)) -- -1 = visible pour tous
                table.insert(spawnedProps, {model = model, coords = vector3(x, y, z)}) -- Ajout dans la liste
            else
                TriggerClientEvent('QBCore:Notify', source, "Coordonnées ou modèle invalide.", "error")
            end
        --end
    end)

-- PARTIE POUR LE SEAU

    RegisterNetEvent('qbx_Ab_CleanFloor:Server:full_bucket')
    AddEventHandler('qbx_Ab_CleanFloor:Server:full_bucket', function()
        local src = source

        local allowfill = exports.ox_inventory:CanCarryItem(src, Config.cleanitem2full, 1)

        if allowfill then

            exports.ox_inventory:RemoveItem(src, Config.cleanitem2, 1)
            exports.ox_inventory:AddItem(src, Config.cleanitem2full, 1)
            TriggerClientEvent('qbx_Ab_CleanFloor:Client:full_bucketAnim', src)

        else
            exports.qbx_core:Notify(src, "Un seau rempli d'eau serait trop lourd à porter", 'error', 7000)
        end
    
    end)

    RegisterNetEvent('qbx_Ab_CleanFloor:Server:empty_bucket')
    AddEventHandler('qbx_Ab_CleanFloor:Server:empty_bucket', function()
        local src = source

        exports.ox_inventory:RemoveItem(src, Config.cleanitem2full, 1)
        exports.ox_inventory:AddItem(src, Config.cleanitem2, 1)
        TriggerClientEvent('qbx_Ab_CleanFloor:Client:empty_bucketAnim', src)
    
    end)

-- PARTIE POUR LE SIGN

    RegisterNetEvent('qbx_Ab_CleanFloor:Server:RegisterSign')
    AddEventHandler('qbx_Ab_CleanFloor:Server:RegisterSign', function(netId)
        table.insert(spawnedSign, netId)
    end)


    RegisterNetEvent('qbx_Ab_CleanFloor:Server:SpawnSign')
    AddEventHandler('qbx_Ab_CleanFloor:Server:SpawnSign', function(sourcevector, sourceheading)
        local src = source
        local srcPed = GetPlayerPed(src)
        local srcCoords = GetEntityCoords(srcPed)
        local forwardVector = sourcevector -- Récupérer la direction du regard
        local coords = srcCoords + (forwardVector * 0.5)
        local heading = sourceheading

        TriggerClientEvent('qbx_Ab_CleanFloor:Client:SpawnSign', src, coords, heading)
    end)

    RegisterNetEvent('qbx_Ab_CleanFloor:Server:RemoveSign')
    AddEventHandler('qbx_Ab_CleanFloor:Server:RemoveSign', function(netId)
        local src = source
        local allowcarry = exports.ox_inventory:CanCarryItem(src, Config.cleansignitem, 1)

        if allowcarry then
            -- Retirer l'objet de la liste
            for i, id in ipairs(spawnedSign) do
                if id == netId then
                    table.remove(spawnedSign, i)
                   break
                end
            end
        
            -- Envoyer l'ordre à tous les joueurs de le supprimer
            TriggerClientEvent('qbx_Ab_CleanFloor:Client:RemoveSign', -1, netId)
            exports.ox_inventory:AddItem(src, Config.cleansignitem, 1)
        else
            exports.qbx_core:Notify(src, "Vous portez déjà trop de choses !", 'error', 7000)
        end
    end)


-- OLD   
    -- -- Event pour spawn un prop lorsqu'un objet est utilisé
    -- RegisterNetEvent('qbx_Ab_CleanFloor:Server:SpawnSign')
    -- AddEventHandler('qbx_Ab_CleanFloor:Server:SpawnSign', function(sourcevector, sourceheading)
    --     local src = source
    --     local srcPed = GetPlayerPed(src)
    --     local srcCoords = GetEntityCoords(srcPed)
    --     local forwardVector = sourcevector -- Récupérer la direction du regard
    --     local coords = srcCoords + (forwardVector * 0.5)
    --     local heading = sourceheading
    --     local model = Config.cleansignprop -- Récupère le modèle du prop selon l'item utilisé

    --         -- Ajouter le prop à la liste
    --         table.insert(spawnedSign, { model = model, coords = coords, heading = heading})
    --         print ('spawn : ' ..json.encode(spawnedSign))
    --         -- Envoyer l'événement à tous les joueurs pour afficher le prop
    --         TriggerClientEvent('qbx_Ab_CleanFloor:Client:SpawnSign', src, coords, heading, true)

    -- end)

    -- -- Event pour retirer un prop
    -- RegisterNetEvent('qbx_Ab_CleanFloor:Server:RemoveSign')
    -- AddEventHandler('qbx_Ab_CleanFloor:Server:RemoveSign', function(coords)
    --     local src = source
    --     local allowcarry = exports.ox_inventory:CanCarryItem(src, Config.cleansignitem, 1)
        
    --     if allowcarry then
    --         local removedIndex = nil

    --         -- Trouver et supprimer le panneau en vérifiant avec une marge d'erreur
    --         for i, prop in ipairs(spawnedSign) do
    --             if #(vector3(prop.coords.x, prop.coords.y, prop.coords.z) - vector3(coords.x, coords.y, coords.z)) < 1.5 then
    --                 removedIndex = i
    --                 break
    --             end
    --         end

    --         if removedIndex then
    --             -- Supprimer du tableau
    --             table.remove(spawnedSign, removedIndex)

    --             -- Mettre à jour tous les clients
    --             TriggerClientEvent('qbx_Ab_CleanFloor:Client:RemoveSign', -1, coords)
    --             exports.ox_inventory:AddItem(src, Config.cleansignitem, 1)
    --         else
    --             exports.qbx_core:Notify(src, "Aucun panneau trouvé !", 'error', 7000)
    --         end
    --     else
    --         exports.qbx_core:Notify(src, "Vous portez déjà trop de choses !", 'error', 7000)
    --     end
    -- end)

    -- -- Event pour update un prop
    -- RegisterNetEvent('qbx_Ab_CleanFloor:Server:UpdateSign')
    -- AddEventHandler('qbx_Ab_CleanFloor:Server:UpdateSign', function(spawnedSignUpdate)
    --     -- Remplacer la liste des panneaux sur le serveur
    --     spawnedSign = spawnedSignUpdate
    --     -- Envoyer la liste mise à jour à tous les clients
    --     TriggerClientEvent('qbx_Ab_CleanFloor:Client:UpdateSign', -1, spawnedSign)
    -- end)
