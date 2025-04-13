    local plantstate = 'ready' -- ready or wait
    local plantpoisonstate = 'ready' -- ready or wait

    local currentPlaceIndex = 1
    local activePlaceTable = Config.all_places -- Table active par défaut
    local placesList = {}

-- Gestion de plante 

    RegisterNetEvent('qbx_Ab_SpecialPlant:server:PlantStatecheck')
    AddEventHandler('qbx_Ab_SpecialPlant:server:PlantStatecheck', function(plantkind)
        local src = source

        if plantkind == "special" then
            TriggerClientEvent("qbx_Ab_SpecialPlant:client:PlantState", src, plantkind, plantstate)

        elseif plantkind == "poison" then
            TriggerClientEvent("qbx_Ab_SpecialPlant:client:PlantState", src, plantkind, plantpoisonstate)
        end

    end)

    -- Fonction pour démarrer le thread lorsque la plante devient "growing"
    local function startGrowingThread()
        CreateThread(function()
            -- Vérifie que la plante est en train de pousser (c'est-à-dire l'état est "growing")
            while plantstate == 'wait' do
                print("growing start")
                Wait(Config.plantgrow_time)  -- Attends le temps de pousse

                -- Une fois que le temps est écoulé, la plante est prête
                plantstate = 'ready'
                print("La plante est maintenant : " .. plantstate)

            end
        end)
    end

     -- Fonction pour démarrer le thread lorsque la plante poison devient "growing"
    local function startGrowingPoisonThread()
        CreateThread(function()
            -- Vérifie que la plante est en train de pousser (c'est-à-dire l'état est "growing")
            while plantpoisonstate == 'wait' do
                print("growing start")
                Wait(Config.plantgrow_time)  -- Attends le temps de pousse

                -- Une fois que le temps est écoulé, la plante est prête
                plantpoisonstate = 'ready'
                print("La plante est maintenant : " .. plantstate)

            end
        end)
    end


    -- event pour récolter
    RegisterNetEvent('qbx_Ab_SpecialPlant:server:harvestPlant')
    AddEventHandler('qbx_Ab_SpecialPlant:server:harvestPlant', function(kindplant)
        local src = source


        if kindplant == 'special' then

            exports.ox_inventory:AddItem(src, Config.harvested_specialitem, 6)
            plantstate = 'wait'
            startGrowingThread()

        elseif kindplant == 'poison' then
            exports.ox_inventory:AddItem(src, Config.harvested_poisonitem, 1)
            plantpoisonstate = 'wait'
            startGrowingPoisonThread()

        end

        TriggerClientEvent('qbx_Ab_SpecialPlant:client:harvestPlantAnimation', src) -- Lance l'animation 

    end)

    -- event pour checker la plant
    RegisterNetEvent('qbx_Ab_SpecialPlant:server:checkPlant')
    AddEventHandler('qbx_Ab_SpecialPlant:server:checkPlant', function(plantkind)
        local src = source
        local durationotif = 8000

        if plantkind == 'special' then

            if plantstate == 'wait' then 
                exports.qbx_core:Notify(src, "Il n'y a plus de fleur sur la plante", 'inform', durationotif)
            elseif plantstate == 'ready' then 
                exports.qbx_core:Notify(src, "Il est possible de récolter les fleurs de cette plante", 'success', durationotif)
            else
                exports.qbx_core:Notify(src, "La plante a un problème, Veuillez avertir son propriétaire!", 'error', 10000)
            end

        elseif plantkind == 'poison' then

            if plantpoisonstate == 'wait' then 
                exports.qbx_core:Notify(src, "Il n'y a plus de pousses", 'inform', durationotif)
            elseif plantpoisonstate == 'ready' then 
                exports.qbx_core:Notify(src, "Il est possible de récolter des pousses de plante", 'success', durationotif)
            else
                exports.qbx_core:Notify(src, "La plante a un problème, Veuillez avertir son propriétaire!", 'error', 10000)
            end

        end


    end)

-- FAIRE DES JOINS

    RegisterNetEvent('qbx_Ab_SpecialPlant:server:craftJoin', function(slot)
        local src = source
        -- Vérifie si l'utilisateur a les items nécessaires
        local paperhere = exports.ox_inventory:GetItemCount(src, "os_rollpaper")
        local planthere = exports.ox_inventory:GetItemCount(src, Config.harvested_specialitem)
        local cighere = exports.ox_inventory:GetItemCount(src, "cigarette")
        local duration = 8000
        
        if paperhere >= 3 and planthere >= 1 and cighere >= 2 then
            -- Retirer un papier à rouler et une weed
            exports.ox_inventory:RemoveItem(src, "os_rollpaper", 3)
            exports.ox_inventory:RemoveItem(src, Config.harvested_specialitem, 1)
            exports.ox_inventory:RemoveItem(src, "cigarette", 2)
            -- Ajouter un joint
            exports.ox_inventory:AddItem(src, "joint_special", 1)
            TriggerClientEvent('qbx_core:Notify', src, "Tu as roulé un joint étrange!", 'success', duration)
        else
            TriggerClientEvent('qbx_core:Notify', src, "Il te manque des éléments pour rouler un joint", 'error', 8000)
        end
    end)

    RegisterNetEvent('qbx_Ab_SpecialPlant:server:craftTea', function(slot)
        local src = source
        -- Vérifie si l'utilisateur a les items nécessaires
        local planthere = exports.ox_inventory:GetItemCount(src, Config.harvested_specialitem)
        local teahere = exports.ox_inventory:GetItemCount(src, "ginseng_tea")
        local duration = 8000
        
        if teahere >= 1 and planthere >= 1 then
            exports.ox_inventory:RemoveItem(src, Config.harvested_specialitem, 1)
            exports.ox_inventory:RemoveItem(src, "ginseng_tea", 1)
            -- Ajouter un joint
            exports.ox_inventory:AddItem(src, "tea_special", 1)
            TriggerClientEvent('qbx_core:Notify', src, "Tu as du thé étrange!", 'success', duration)
        else
            TriggerClientEvent('qbx_core:Notify', src, "Il te manque des éléments pour préparer le thé", 'error', 8000)
        end
    end)

-- Gestion du voyage

    -- Fonction pour charger la table active
    local function loadPlaces(tableName)
        placesList = {}  -- Réinitialise la liste actuelle
        if tableName then
            for name, pos in pairs(tableName) do
                table.insert(placesList, {name = name, position = pos})
            end
            print("Places chargées depuis la table : " .. json.encode(tableName))
        else
            print("Erreur : La table '" .. json.encode(tableName) .. "' est introuvable.")
        end
    end

    -- Charger la table par défaut au démarrage
    loadPlaces(activePlaceTable)

    RegisterNetEvent('qbx_Ab_SpecialPlant:server:updateClientPos', function() -- pour update à la demande de un client
        
        local src = source
        local currentPlace = placesList[currentPlaceIndex]
        TriggerClientEvent("qbx_Ab_SpecialPlant:client:updateCurrentPlace", src, currentPlace.position)

    end)

    -- Commande pour changer de table active
    RegisterCommand('switchDreamPlaces', function(source, args, rawCommand)
        local newTable = args[1]
        if newTable and Config[newTable] then
            activePlaceTable = Config[newTable]
            loadPlaces(activePlaceTable)
            print("La table active est maintenant : " .. json.encode(activePlaceTable))
        else
            print("La table '" .. tostring(newTable) .. "' n'existe pas.")
        end
    end, false)

    RegisterNetEvent('qbx_Ab_SpecialPlant:server:saveClientPos', function(isdreaming, lastpos) -- 
        local src = source
        local player = exports.qbx_core:GetPlayer(src)


        if player then
            local citizenid = player.PlayerData.citizenid
            local dream_situation = isdreaming and 1 or 0
            local x,y,z = lastpos.x, lastpos.y, lastpos.z

            print ("SAVE Citizen ID : " ..citizenid.. " reve t il : " ..tostring(dream_situation).. " au position: " ..x.. " " ..y.. " " ..z)

            MySQL.Async.execute(
                [[
                    INSERT INTO Ab_SpecialPlant (citizenid, isdreaming, x, y, z)
                    VALUES (@citizenid, @isdreaming, @x, @y, @z)
                    ON DUPLICATE KEY UPDATE
                        isdreaming = @isdreaming,
                        x = @x,
                        y = @y,
                        z = @z
                ]], 
                {
                    ['@citizenid'] = citizenid,
                    ['@isdreaming'] = dream_situation,
                    ['@x'] = x,
                    ['@y'] = y,
                    ['@z'] = z,
                },
                    function()
                        print("Dreaming send for " ..citizenid)
                    end
            )

        else
            print("Erreur : Le joueur n'a pas été trouvé.")
        end
    end)

    RegisterNetEvent ('qbx_Ab_SpecialPlant:server:loadClientpos', function()
        local src = source
        local player = exports.qbx_core:GetPlayer(src)


        if player then
            local citizenid = player.PlayerData.citizenid
    
            -- Requête SQL pour récupérer la raison du coma
            MySQL.Async.fetchAll('SELECT isdreaming, x, y, z FROM Ab_SpecialPlant WHERE citizenid = @citizenid', { 
                ['@citizenid'] = citizenid },
            function(result)
                if result and result[1] then
                    local data = result[1]
                    local isdreaming = data.isdreaming == 1  -- Assumons que 1 représente true, 0 représente false
                    print("data.isdreaming : (" .. tostring(data.isdreaming) .. ")")
                    local lastpos = {
                        x = data.x,
                        y = data.y,
                        z = data.z
                    }
                    Wait(10)
                    print ("LOAD Citizen ID : " ..citizenid.. " reve t il : " ..tostring(isdreaming).. " au position: " ..json.encode(lastpos))
                    TriggerClientEvent('qbx_Ab_SpecialPlant:client:sendClientpos', src, isdreaming, lastpos)
                else
                    print ('dream data non trouvé')
                end
            end)
        end
    
    end)

    -- Thread Serveur pour changer de lieu toutes les minutes
    CreateThread(function()
        Wait (500)
        while true do
            local currentPlace = placesList[currentPlaceIndex]
            print("Lieu actuel : " .. currentPlace.name)

            -- Broadcast aux clients (si nécessaire)
            TriggerClientEvent("qbx_Ab_SpecialPlant:client:updateCurrentPlace", -1, currentPlace.position)

            -- Attente entre les changement d'endroit
            Wait(Config.time_placeschanging * 60 * 1000)

            -- Passer à la position suivante
            currentPlaceIndex = currentPlaceIndex + 1
            if currentPlaceIndex > #placesList then
                currentPlaceIndex = 1 -- Retour au début de la liste
            end
        end
    end)


    RegisterNetEvent ('qbx_Ab_SpecialPlant:server:showdreamlocation', function()
        local src = source
        local currentPlace = placesList[currentPlaceIndex]
        exports.qbx_core:Notify(source, 'Le lieu de rêve est: ' ..currentPlace.name, 'inform', 8000)
    
    end)
    

    -- CreateThread(function()
    --     Wait (500)
    --     while true do
    --         print(json.encode(placesList))
    --         Wait(1000)

    --     end
    -- end)

-- Creation de ped lors de voyage

    -- AddEventHandler('playerDropped', function()
    --     local playerId = source
    --     -- Suppression du PED
    --     print("delete ped from " ..playerId)
    --     TriggerClientEvent('qbx_Ab_SpecialPlant:client:Deleteped', playerId)
    -- end)

    -- RegisterCommand('createped', function(source, args)
    --     local targetId = tonumber(args[1])
    --     if not targetId then
    --         print('/CreatePed need source')
    --         return
    --     end

    --     -- On envoie la demande à TOUS les clients
    --     TriggerClientEvent('qbx_Ab_SpecialPlant:client:Createped', source, targetId)
    -- end, false)

    -- RegisterCommand('deleteped', function(source)

    --     -- Suppression synchronisée sur TOUS les clients
    --     TriggerClientEvent('qbx_Ab_SpecialPlant:client:Deleteped', source)
    -- end, false)
