
local activeProps = {} -- Table pour garder les références des props

local dirtplaces = {}

local spawnedSign = {}

-- FUNCTION 

    local function SpawnProp (model, coords)

        local propModel = GetHashKey(model)
        RequestModel(propModel)

        while not HasModelLoaded(propModel) do
            Wait(0)
        end

        --Wait(1500)

        --local ground, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
        local prop = CreateObject(propModel, coords.x, coords.y, coords.z -0.99, false, true, false)
        SetEntityCollision(prop, true, true)
        SetEntityAsMissionEntity(prop, true, true)


        PlaceObjectOnGroundProperly(prop)
        FreezeEntityPosition(prop, true) -- Immobilise le prop
        table.insert(activeProps, prop) -- Stocke le prop
        --print("SPAWN PROP :" ..json.encode(coords))

    end

    local function RemoveProp (prop)
        if DoesEntityExist(prop) then
            DeleteEntity(prop) -- Supprime le prop
        end
    end

    local function RemoveAllProp ()
        for _, prop in pairs(activeProps) do
            if DoesEntityExist(prop) then
                DeleteEntity(prop) -- Supprime le prop
            end
        end
        activeProps = {} -- Vide la table des props actifs
    end

    local function RemovePropAtCoords(coords)

        print("Fonction a reçu : " .. json.encode(coords) .. " et la table " .. json.encode(activeProps))
    
        for i = #activeProps, 1, -1 do -- Parcours la table à l'envers pour éviter les problèmes de suppression
            local prop = activeProps[i]
            local propCoords = GetEntityCoords(prop)
    
            print(string.format("Vérification du prop %d aux coordonnées: x=%.2f, y=%.2f, z=%.2f", 
                prop, propCoords.x, propCoords.y, propCoords.z))
    
            -- Vérifier si les coordonnées correspondent avec une tolérance
            local distance = #(propCoords - coords)
            print("Distance calculée : " .. distance)
    
            if distance < 1.0 then  -- Ajuste la tolérance si nécessaire
                DeleteEntity(prop) -- Supprime l'entité
                table.remove(activeProps, i) -- Retire de la table
                print("Prop supprimé à : " .. json.encode(coords))
                break
            end
        end
    end

    local function PlayAnimation(dict, name, duration,flag)
        local playerPed = PlayerPedId()
    
        -- Charger le dictionnaire d'animation
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(100)
        end
    
        -- Jouer l'animation
        TaskPlayAnim(playerPed, dict, name, 1.0, 1.0, duration, flag, 0, false, false, false)
    
        -- Attendre la durée de l'animation
        Wait(duration)
    
        -- Arrêter l'animation
        ClearPedTasks(playerPed)
        RemoveAnimDict(dict)
    end
    

-- Charger les props au départ et les recharger

    CreateThread(function() -- pour le lancement du jeu
            while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
                Wait(100)
                --print("En attente des données du joueur (citizenid)...")
            end
        Wait(500)
        TriggerServerEvent('qbx_Ab_CleanFloor:Server:GetProps')
        TriggerServerEvent('qbx_Ab_CleanFloor:Server:GetSigns')
        print('onClientGameTypeStart')
        

    end)

    -- Citizen.CreateThread(function()
        
    --     while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
    --         Wait(100)
    --         --print("En attente des données du joueur (citizenid)...")
    --     end

    --     Wait(8000)

    --     while true do
    --         local playerPed = PlayerPedId()
    --         local playerCoords = GetEntityCoords(playerPed)

    --         Wait(1500)

    --         -- pour les dirtplace
    --         for id, place in pairs(dirtplaces) do
    --             local distance = #(playerCoords - place.coords)
    
    --             if distance < 50.0 then -- Si le joueur est dans la zone
    
    --                 if place.spawned then
    --                     -- Vérifier si un prop existe déjà à cet endroit
    --                     local propExists = false
    --                     for _, prop in pairs(activeProps) do
    --                         local propCoords = GetEntityCoords(prop)
    --                         local dist = #(propCoords - place.coords)
                            
    --                         if dist < 2.0 then -- Tolérance de 1m
    --                             propExists = true
    --                             break
    --                         end
    --                     end
    
    --                     if not propExists then
    --                         Wait (100)
    --                         SpawnProp(Config.props_dirt, place.coords)

    --                         print(" Reload du prop ID " .. id .. " car le joueur est revenu dans la zone.")
    --                     end
    --                 end
    --             else
    --                 place.spawned = false
    --             end
    --         end

    --         -- pour les sign
    --         for key, prop in pairs(spawnedSign) do
    --             local dist = #(playerCoords - vector3(prop.coords.x, prop.coords.y, prop.coords.z))
    --             Wait(500)
    --             -- Si le prop n'existe plus mais qu'on est proche, on le respawn
    --             if dist < 50.0 and not DoesEntityExist(prop.obj) then
    --                 print("Respawn du panneau à ", prop.coords)
    --                 TriggerServerEvent('qbx_Ab_CleanFloor:Server:SpawnSign', prop.coords, prop.heading)
    --             elseif dist > 100.0 and DoesEntityExist(prop.obj) then
    --                 print("Le joueur est trop loin, suppression du panneau :", prop.coords)
    --                 DeleteEntity(prop.obj)
    --             end
    --         end
    
    --         Wait(4000) -- Vérification toutes les 4 secondes pour éviter trop de charge
    --     end
    -- end)
    
    RegisterNetEvent('qbx_Ab_CleanFloor:Client:Updatedirtplaces', function(data)
        dirtplaces = data
        --print("dirtplaces updated")
    end)

    RegisterNetEvent('qbx_Ab_CleanFloor:Client:ReceiveDirtProps', function(data)
        dirtplaces = data
        dataview = json.encode(dirtplaces)
        print ("Reception des props de saleté : " ..dataview)

        Wait(100)

        for id, places in pairs (dirtplaces) do
            if places.spawned == true then
                SpawnProp(Config.props_dirt, places.coords)
                --print ("props id : " ..id.. " placé à : " ..places.coords)
            end
        end

    end)

-- EVENT

    RegisterNetEvent('qbx_Ab_CleanFloor:Client:spawnProp', function(model, coords)
        SpawnProp (model, coords)
        --print("SPAWN PROP :" ..json.encode(coords).. ' from serv')
    end)

    RegisterNetEvent('qbx_Ab_CleanFloor:Client:RemoveProp')
    AddEventHandler('qbx_Ab_CleanFloor:Client:RemoveProp', function(coords, data)
        dirtplaces = data
        print("dirtplaces maj go fonction avec coords" ..coords)
        Wait(10)
        RemovePropAtCoords(coords)
    end)

    -- Animation pour nettoyer le sol
    RegisterNetEvent('qbx_Ab_CleanFloor:client:cleanFloorAnimation')
    AddEventHandler('qbx_Ab_CleanFloor:client:cleanFloorAnimation', function(roundedCoords)
        print('cleanFloorAnimation activeated')
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local animdict = "move_mop"  -- Exemple d'animation
        local animname = "idle_scrub_small_player"
        local propModel = Config.cleanprop  -- props que l'on tien
        local duration = Config.animduration

        local buckethere = exports.ox_inventory:GetItemCount(Config.cleanitem2)
        local bucketfullhere = exports.ox_inventory:GetItemCount(Config.cleanitem2full)

        if bucketfullhere > 0 then
            -- Créer et attacher la bonbonne à la main
            local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
            AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.00, -0.012, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

            -- Charger et jouer l'animation
            RequestAnimDict(animdict)
            while not HasAnimDictLoaded(animdict) do
                Wait(100)
            end

            TaskPlayAnim(playerPed, animdict, animname, 1.0, 1.0, duration, 1, 0, false, false, false)

            Wait(duration)

            TriggerServerEvent('qbx_Ab_CleanFloor:Server:CleanDirtPlace', roundedCoords)

            TriggerServerEvent('server:addProductivity', Config.prod_up) -- Event qui augmente la productivity
            TriggerServerEvent('server:addJobProductivity', Config.jobtoprod, Config.prod_up) -- Augmente la productivité du job
            TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.fatigue_up) -- augmente la fatigue
            TriggerServerEvent('hud:server:GainStress',Config.stress_up) -- auigment le stress
            ClearPedTasks(playerPed) -- Arrêter l'animation
            DeleteObject(prop) -- Supprimer le prop après l'anim
        elseif buckethere > 0 then
            exports.qbx_core:Notify("Il faut remplir le seau d'eau pour pouvoir passer la serpillère.", 'error', 7000)
        else
            exports.qbx_core:Notify("Une serpillère est inutile si elle n'est pas accompagné d'eau.", 'error', 7000)
        end
    end)


-- Target

    -- Utilisation de ox_target pour détecter l'interaction avec le sol
    exports.ox_target:addModel(
        Config.props_dirt,  
        {  
            -- Option pour nettoyer
            {
                name = "floor_clean",
                label = "Nettoyer le sol",
                icon = 'fa-solid fa-soap',
                items = Config.cleanitem,
                groups = Config.jobRequired,
                distance = 1.5,
                onSelect = function(data)
                    local propCoords = GetEntityCoords(data.entity)

                    local playerPed = PlayerPedId() -- Récupère l'ID du joueur
                    local playerCoords = GetEntityCoords(playerPed) -- Récupère les coordonnées du joueur

                    -- Arrondir chaque coordonnée à 2 décimales
                    local roundedX = math.floor(propCoords.x * 100 + 0.5) / 100
                    local roundedY = math.floor(propCoords.y * 100 + 0.5) / 100
                    local roundedZ = math.floor(playerCoords.z * 100 + 0.5) / 100

                    -- Reconstruire un vector3 avec les valeurs arrondies
                    local roundedCoords = vector3(roundedX, roundedY, roundedZ)

                    print('propCoords : ' ..roundedCoords)
                    TriggerEvent('qbx_Ab_CleanFloor:client:cleanFloorAnimation', roundedCoords)
                end,
            },
            -- Option pour vérifier le niveau de saleté
            {
                name = "check_floor",
                label = "Inspecter",
                icon = 'fas fa-search',
                distance = 1.5,
                onSelect = function(data)
                    local propCoords = GetEntityCoords(data.entity)

                    local playerPed = PlayerPedId() -- Récupère l'ID du joueur
                    local playerCoords = GetEntityCoords(playerPed) -- Récupère les coordonnées du joueur

                    -- Arrondir chaque coordonnée à 2 décimales
                    local roundedX = math.floor(propCoords.x * 100 + 0.5) / 100
                    local roundedY = math.floor(propCoords.y * 100 + 0.5) / 100
                    local roundedZ = math.floor(playerCoords.z * 100 + 0.5) / 100

                    -- Reconstruire un vector3 avec les valeurs arrondies
                    local roundedCoords = vector3(roundedX, roundedY, roundedZ)

                    print('propCoords : ' ..roundedCoords)
                    exports.qbx_core:Notify("Cette énorme tache mériterait d'être nettoyée", 'inform', 7000)
                end,
            }

        }
    )

     -- Utilisation de ox_target pour détecter l'interaction avec le lavabo
    exports.ox_target:addModel(
        Config.waterfillprop,  
       {  
            -- Option pour remplir un seau d'eau
            {
                name = "full_bucker",
                label = "Remplir un seau d'eau",
                icon = 'fa-solid fa-droplet', 
                items = Config.cleanitem2,
                distance = 1.5,
                onSelect = function()
                    TriggerServerEvent('qbx_Ab_CleanFloor:Server:full_bucket')
                end,
            },
            -- Option pour vider un seau d'eau
            {
                name = "empty_bucket",
                label = "Vider un seau d'eau",
                icon = 'fa-solid fa-droplet-slash',
                items = Config.cleanitem2full,
                distance = 1.5,
                onSelect = function()
                    TriggerServerEvent('qbx_Ab_CleanFloor:Server:empty_bucket')
                end,
            }
    
        }
    )

    -- Utilisation de ox_target pour détecter l'interaction avec le lsign
    exports.ox_target:addModel(
        Config.cleansignprop,  
       {  
            -- Option pour ramasser le panneau
            {
                name = "pickup_sign",
                label = "Ramasser le panneau",
                icon = 'fa-solid fa-hand',
                distance = 1.5,
                onSelect = function(data)
                    local coords = GetEntityCoords(data.entity) -- Récupérer les coords du panneau
                    print("trigger with coord: " ..json.encode(coords))
                    TriggerServerEvent('qbx_Ab_CleanFloor:Server:RemoveSign', ObjToNet(data.entity))
                    PlayAnimation("anim@mp_snowball", "pickup_snowball", -1, 64)
                end,
            },
    
        }
    )

-- Event pour bucket

    -- Animation pour remplir un seau
    RegisterNetEvent('qbx_Ab_CleanFloor:Client:full_bucketAnim')
    AddEventHandler('qbx_Ab_CleanFloor:Client:full_bucketAnim', function()
        local playerPed = PlayerPedId()
        local animdic = "missmechanic"  -- dictionaire d'animation
        local animname = "work2_base" -- name animation
        local propModel = Config.cleanitem2prop  -- Modèle de props
        local durationAnim = 10000

    -- Créer le prop et l'attacher à la main gauche du joueur
    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 0x188E), 0.25, 0.00, -0.15, 0.0, 0.0, 180.0, true, true, false, true, 1, true)

        -- Charger et jouer l'animation
        RequestAnimDict(animdic)
        while not HasAnimDictLoaded(animdic) do
            Wait(100)
            print ('no HasAnimDictLoaded')
        end

        TaskPlayAnim(playerPed, animdic, animname, 2.0, 2.0, durationAnim, 1, 0, false, false, false)
        exports.qbx_core:Notify("Vous remplissez un sceau d'eau", 'inform', durationAnim)
        Wait(durationAnim)
        ClearPedTasks(playerPed) -- Arrêter l'animation
        DeleteObject(prop) -- Supprimer le props après anim
    end)

    -- Animation pour vider un seau
    RegisterNetEvent('qbx_Ab_CleanFloor:Client:empty_bucketAnim')
    AddEventHandler('qbx_Ab_CleanFloor:Client:empty_bucketAnim', function()
        local playerPed = PlayerPedId()
        local animdic = "anim@heists@narcotics@trash"  -- dictionaire d'animation
        local animname = "throw_a" -- name animation
        local propModel = Config.cleanitem2prop  -- Modèle de props
        local durationAnim = 1000
    
    -- Créer le prop et l'attacher à la main gauche du joueur
    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 0x188E), 0.30, 0.00, -0.15, 0.0, 0.0, 180.0, true, true, false, true, 1, true)
    
        -- Charger et jouer l'animation
        RequestAnimDict(animdic)
        while not HasAnimDictLoaded(animdic) do
            Wait(100)
            print ('no HasAnimDictLoaded')
        end
    
        TaskPlayAnim(playerPed, animdic, animname, 0.8, 0.8, durationAnim, 1, 0, false, false, false)
    Wait(durationAnim)
        ClearPedTasks(playerPed) -- Arrêter l'animation
        DeleteObject(prop) -- Supprimer le props après anim
    end)

-- Event pour le sign

    -- pour le use de l'item
    exports('clean_sign', function(data, slot)
        local player = PlayerPedId()
        local playerVector = GetEntityForwardVector(player)
        local playerHeading = GetEntityHeading(player)


        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then

                -- anim + item
                -- Créer le prop et l'attacher à la main gauche du joueur
                local prop = CreateObject(GetHashKey(Config.cleansignprop), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.06, -0.03, 0.04, 230.0, 260.0, 40.0, true, true, false, true, 1, true)
                PlayAnimation("anim@mp_snowball", "pickup_snowball", -1, 64)
                Wait(1000)
                DeleteObject(prop)

                TriggerServerEvent('qbx_Ab_CleanFloor:Server:SpawnSign', playerVector, playerHeading)

            end
        end)

    end)


-- NEW

    RegisterNetEvent('qbx_Ab_CleanFloor:Client:SpawnSign')
    AddEventHandler('qbx_Ab_CleanFloor:Client:SpawnSign', function(coords, heading)
        local object = CreateObject(GetHashKey(Config.cleansignprop), coords.x, coords.y, coords.z, true, true, true)
    
        while not DoesEntityExist(object) do
            Wait(10)
        end
    

        SetEntityAsMissionEntity(object, true, true)
        SetEntityHeading(object, heading)
        PlaceObjectOnGroundProperly(object)
        FreezeEntityPosition(object, true) -- Pour éviter qu'il tombe

    
        local netId = ObjToNet(object) -- Convertir en Network ID
        SetNetworkIdCanMigrate(netId, true) -- Permet la migration entre joueurs
        SetNetworkIdExistsOnAllMachines(netId, true) -- Synchroniser pour tous
    
        -- Envoyer au serveur le Network ID
        TriggerServerEvent('qbx_Ab_CleanFloor:Server:RegisterSign', netId)
    end)

    RegisterNetEvent('qbx_Ab_CleanFloor:Client:RemoveSign')
    AddEventHandler('qbx_Ab_CleanFloor:Client:RemoveSign', function(netId)
        local object = NetToObj(netId)

        if DoesEntityExist(object) then
            DeleteEntity(object)
        else
            print("Erreur: Impossible de récupérer l'objet avec le Network ID " .. netId)
        end
    end)
    

-- OLD
    -- RegisterNetEvent('qbx_Ab_CleanFloor:Client:SpawnSign')
    -- AddEventHandler('qbx_Ab_CleanFloor:Client:SpawnSign', function(coords, heading, mission)
    --     local model = Config.cleansignprop
    --     RequestModel(model)
    --     while not HasModelLoaded(model) do
    --         Wait(10)
    --     end

    --     local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    --     SetEntityAsMissionEntity(obj, mission, true)
    --     SetEntityHeading(obj, heading)
    --     PlaceObjectOnGroundProperly(obj)
    --     FreezeEntityPosition(obj, true)

    --     -- Ajouter correctement à la liste
    --     table.insert(spawnedSign, { 
    --         object = obj, 
    --         coords = coords, 
    --         heading = heading 
    --     })

    --     print ('spawnedSign après ajout : ' .. json.encode(spawnedSign))
    -- end)


    -- RegisterNetEvent('qbx_Ab_CleanFloor:Client:RemoveSign')
    -- AddEventHandler('qbx_Ab_CleanFloor:Client:RemoveSign', function(coords)
    --     print("Pre-remove : ", json.encode(spawnedSign))
    
    --     local foundKey  = nil
    

    -- -- Recherche du panneau à supprimer (en utilisant les coordonnées comme clé)
    -- for key, obj in pairs(spawnedSign) do
    --     if obj and type(obj) == "number" and DoesEntityExist(obj) then
    --         local signCoords = GetEntityCoords(obj)
    --         if #(vector3(signCoords.x, signCoords.y, signCoords.z) - vector3(coords.x, coords.y, coords.z)) < 1.5 then
    --             foundKey = key
    --             break
    --         end
    --     end
    -- end
    
    --     if foundKey  then
    --         -- Supprimer localement l'entité
    --         local obj = spawnedSign[foundKey]
    --         if DoesEntityExist(obj) then
    --             DeleteEntity(obj)
    --         end
    
    --         -- Retirer du tableau
    --         spawnedSign[foundKey ] = nil
    
    --         print("Panneau supprimé avec succès !")
    --     else
    --         print("Aucun panneau trouvé à ces coordonnées : ", coords)
    --     end
    -- end)
    

    -- RegisterNetEvent('qbx_Ab_CleanFloor:Client:UpdateSign')
    -- AddEventHandler('qbx_Ab_CleanFloor:Client:UpdateSign', function(spawnedSignUpdate)
    
    --     print('Mise à jour complète des panneaux : ' .. json.encode(spawnedSignUpdate))
    
    --     -- Supprime les panneaux existants proprement
    --     for _, signData in ipairs(spawnedSign) do
    --         if DoesEntityExist(signData.object) then
    --             DeleteEntity(signData.object)
    --         end
    --     end
    
    --     -- Réinitialise la liste
    --     spawnedSign = {}
    
    --     -- Création des nouveaux panneaux
    --     for _, signData in ipairs(spawnedSignUpdate) do
    --         local model = signData.model
    --         local coords = signData.coords
    --         local heading = signData.heading
    
    --         RequestModel(model)
    --         while not HasModelLoaded(model) do
    --             Wait(10)
    --         end
    
    --         local obj = CreateObject(model, coords.x, coords.y, coords.z-1.2, true, true, false)
    --         SetEntityAsMissionEntity(obj, true, true)
    --         SetEntityHeading(obj, heading)
    --         PlaceObjectOnGroundProperly(obj)
    --         FreezeEntityPosition(obj, true)
    
    --         -- Ajouter correctement à la liste
    --         table.insert(spawnedSign, {
    --             object = obj,
    --             coords = coords,
    --             heading = heading
    --         })
    --     end
    -- end)
    
    

-- Event pour commandes

    RegisterNetEvent('qbx_Ab_CleanFloor:Client:commandSpawnProp', function(model, coords)
        SpawnProp (model, coords)
        print("SPAWN PROP :" ..json.encode(coords).. ' un commande')
    end)

    
    RegisterCommand('dirtplaces', function(source, args, rawCommand)
        print('dirtplaces : ' ..json.encode(dirtplaces))
    end)
