garbage_table_sql = {}

garbage_table = {}

smallgarbageStash = {
    label = 'Petite Poubelle',
    slots = 5,
    weight = 5000, 

}

biggarbageStash = {
    label = 'Grande Poubelle',
    slots = 20,
    weight = 20000, 

}

-- ///////// LE BORDEL TECHNIQUE (qui sert a enregistré les poubelles dans la base de donné en fonction de leur type et de faire des stock automatiquement)

    -- Modif de la table pour stocker StashID, label, slots, et weight
    local function updateGarbageTable(row)
        garbage_table_sql[row.CoordID] = {
            StashID = row.StashID,
            GarbageKind = row.GarbageKind,
            label = row.label, 
            slots = row.slots, 
            weight = row.weight 
        }
    end

    -- Fonction pour générer une chaîne aléatoire avec un préfixe "garbage_"
    local function generateRandomID(length)
        local chars = 'abcdefghijklmnopqrstuvwxyz0123456789'
        local randomID = 'garbage_' -- Préfixe fixe
        for i = 1, length do
            local rand = math.random(1, #chars)
            randomID = randomID .. chars:sub(rand, rand)
        end
        return randomID
    end

    -- Initialiser un prop  dans la base de données
    local function initPropInDatabase(CoordID, garbageKind)

    StashID = generateRandomID(10)

        if garbageKind == 'small' then
            MySQL.Async.execute(
                "INSERT INTO Ab_Garbages (StashID, CoordID, GarbageKind, label, slots, weight) VALUES (?,?,?,?,?,?)", 
                { StashID, CoordID, garbageKind, smallgarbageStash.label, smallgarbageStash.slots, smallgarbageStash.weight},
                function()
                    print("Prop initialisé avec StashID:" ..StashID.. " et CoordID:" ..CoordID.. " Garbage kind : " ..garbageKind)
                    garbage_table_sql[CoordID] = {
                        StashID = StashID,
                        GarbageKind = garbageKind,
                        label = smallgarbageStash.label,
                        slots = smallgarbageStash.slots,
                        weight = smallgarbageStash.weight
                    }
                    garbage_table[CoordID] = StashID
                end
            )

            exports.ox_inventory:RegisterStash(StashID, smallgarbageStash.label, smallgarbageStash.slots, smallgarbageStash.weight)

        elseif garbageKind == 'big' then
            MySQL.Async.execute(
                "INSERT INTO Ab_Garbages (StashID, CoordID, GarbageKind, label, slots, weight) VALUES (?,?,?,?,?,?)", 
                { StashID, CoordID, garbageKind, biggarbageStash.label, biggarbageStash.slots, biggarbageStash.weight},
                function()
                    print("Prop initialisé avec StashID:" ..StashID.. " et CoordID:" ..CoordID.. " Garbage kind : " ..garbageKind)
                    garbage_table_sql[CoordID] = {
                        StashID = StashID,
                        GarbageKind = garbageKind,
                        label = biggarbageStash.label,
                        slots = biggarbageStash.slots,
                        weight = biggarbageStash.weight
                    }
                    garbage_table[CoordID] = StashID
                end
            )

            exports.ox_inventory:RegisterStash(StashID, biggarbageStash.label, biggarbageStash.slots, biggarbageStash.weight)
        else 
            print ('nécéssite un garbageKind entre "small" ou "big" pour être initialisé')
        end

    end

    -- Fonction pour récupérer le StashID à partir du CoordID
    local function getStashIDFromCoordID(CoordID, cb)
        -- Vérifier si le CoordID existe dans la table en mémoire
        if garbage_table[CoordID] then
            --print(('CoordID %s trouvé en mémoire, StashID : %s'):format(CoordID, garbage_table[CoordID]))
            cb(garbage_table[CoordID]) -- Retourne directement depuis la mémoire
        else
            -- Si le CoordID n'est pas en mémoire, le chercher dans la base de données
            MySQL.Async.fetchScalar(
                'SELECT StashID, GarbageKind, label, slots, weight FROM Ab_Garbages WHERE CoordID = ?', 
                { CoordID }, 
                function(result)
                    if result then
                        -- Mettre à jour la table en mémoire pour éviter de futures requêtes
                        garbage_table_sql[CoordID] = {
                            StashID = result.StashID,
                            GarbageKind = result.garbageKind,
                            label = result.label,
                            slots = result.slots,
                            weight = result.weight
                        }
                        garbage_table[CoordID] = result.StashID

                        print(('CoordID %s trouvé en base de données'):format(CoordID))
                    else
                        print(('CoordID %s introuvable en mémoire ou en base de données.'):format(CoordID))
                    end
                    cb(result)
                end
            )
        end
    end

    -- Chargement des niveaux de saleté depuis la base de données au démarrage
    AddEventHandler('onResourceStart', function(resourceName)
        if resourceName == GetCurrentResourceName() then

            MySQL.Async.fetchAll('SELECT * FROM Ab_Garbages', {}, function(results)
                for _, row in pairs(results) do
                    garbage_table[row.CoordID] = row.StashID

                    -- Réenregistrement des stashs dans Ox Inventory

                    updateGarbageTable(row)

                    exports.ox_inventory:RegisterStash(row.StashID, row.label, row.slots, row.weight)
                    --print(('Stash réenregistré : CoordID %s -> StashID %s'):format(row.CoordID, row.StashID))                
                end
                print('Les poubelles ont été chargés avec succès.')
            end)
        end
    end)



-- LES EVENTS

    -- Événement pour utiliser la poubelle 
    RegisterNetEvent('qbx_Ab_Garbages:server:useGarbage')
    AddEventHandler('qbx_Ab_Garbages:server:useGarbage', function(propCoords, garbageKind)
        local src = source
        local garbageId = propCoords
        local garbageKind = garbageKind
        

        -- Initialiser la quantité d'eau pour cette Machine à café si elle n'existe pas encore
        if not garbage_table[garbageId] then
            initPropInDatabase(garbageId, garbageKind)
        end

        -- Obtenir le StashID après vérification ou initialisation
        getStashIDFromCoordID(garbageId, function(stashID)
            if stashID then
                TriggerClientEvent('qbx_Ab_Garbages:server:openGarbage', src, stashID)
            else
                print(("Impossible d'ouvrir la poubelle : CoordID %s introuvable."):format(garbageId))
            end
        end)

    end)

    -- Événement pour vider la poubelle 
        RegisterNetEvent('qbx_Ab_Garbages:server:emptyGarbage')
        AddEventHandler('qbx_Ab_Garbages:server:emptyGarbage', function(propCoords, garbageKind)
            local src = source
            local garbageId = propCoords
            local garbageKind = garbageKind
            local smallslots = biggarbageStash.slots
            local bigslots = biggarbageStash.slots
            
    
            -- Initialiser la quantité d'eau pour cette Machine à café si elle n'existe pas encore
            if not garbage_table[garbageId] then
                initPropInDatabase(garbageId, garbageKind)
            end
    

            -- Obtenir le StashID après vérification ou initialisation
            getStashIDFromCoordID(garbageId, function(stashID)
                if stashID then

                    if garbageKind == 'small' then
                        if exports.ox_inventory:CanCarryWeight(stashID, smallgarbageStash.weight) then 
                            exports.qbx_core:Notify(src, "La poubelle est vide.", 'inform', 5000)
                        else
                            if exports.ox_inventory:CanCarryItem(src, Config.smalltrash_item_full, 1) then
                                exports.ox_inventory:RemoveItem(src, Config.smalltrash_item, 1)
                                exports.ox_inventory:AddItem(src, Config.smalltrash_item_full, 1)
                                exports.ox_inventory:ClearInventory(stashID)
                                TriggerClientEvent('qbx_Ab_Garbages:server:emptyGarbageAnimation', src)
                            else
                                exports.qbx_core:Notify(src, "Vous n'avez pas la place pour récupéré le sac poubelle plein", 'error', 5000)
                            end                            
                        end
                    elseif garbageKind == 'big' then
                        if exports.ox_inventory:CanCarryWeight(stashID, biggarbageStash.weight) then 
                            exports.qbx_core:Notify(src, "La poubelle est vide.", 'inform', 5000)
                        else
                            if exports.ox_inventory:CanCarryItem(src, Config.bigtrash_item_full, 1) then
                                exports.ox_inventory:RemoveItem(src, Config.bigtrash_item, 1)
                                exports.ox_inventory:AddItem(src, Config.bigtrash_item_full, 1)
                                exports.ox_inventory:ClearInventory(stashID)
                                TriggerClientEvent('qbx_Ab_Garbages:server:emptyGarbageAnimation', src)
                            else
                                exports.qbx_core:Notify(src, "Vous n'avez pas la place pour récupéré le sac poubelle plein", 'error', 5000)
                            end
                        end
                    else 
                        print ('No garbageKind found')
                    end

                else
                    print(("Impossible d'ouvrir la poubelle : CoordID %s introuvable."):format(garbageId))
                end
            end)
    
        end)

    -- Event pour jeter un sac poubelle 
        RegisterNetEvent('qbx_Ab_Garbages:server:throwTrashbag')
        AddEventHandler('qbx_Ab_Garbages:server:throwTrashbag', function(trashbag)
            local src = source
            local trashbag = trashbag

            if trashbag == 'small' then
                local propmodel = 'ng_proc_binbag_02a'
                exports.ox_inventory:RemoveItem(src, Config.smalltrash_item_full, 1)
                TriggerClientEvent('qbx_Ab_Garbages:server:throwTrashbagAnimation', src, propmodel)
            elseif trashbag == "big" then
                local propmodel = 'prop_cs_street_binbag_01'
                exports.ox_inventory:RemoveItem(src, Config.bigtrash_item_full, 1)
                TriggerClientEvent('qbx_Ab_Garbages:server:throwTrashbagAnimation', src, propmodel)
            else
                print ("unknown trashbag!")
            end
        end) 

    -- Event pour fouiller dans une benne

    RegisterNetEvent('qbx_Ab_Garbages:server:searchBin')
    AddEventHandler('qbx_Ab_Garbages:server:searchBin', function()
        local src = source
        local probakind = math.random(1, 10)
        local loot = nil

        if probakind == 1 then
            exports.qbx_core:Notify(src, "Vous n'avez rien trouvez dans la benne", 'error', 5000) 
        elseif probakind > 1 and probakind < Config.search_proba then
            loot = Config.gooditem_wh[math.random(#Config.gooditem_wh)]
            exports.ox_inventory:AddItem(src, loot, 1)
        else
            loot = Config.trashitem_wh[math.random(#Config.trashitem_wh)]
            exports.ox_inventory:AddItem(src, loot, 1)
        end
    end)

    -- Event pour ajouter un trash item

    RegisterNetEvent('qbx_Ab_Garbages:server:addTrash')
    AddEventHandler('qbx_Ab_Garbages:server:addTrash', function(trash_item)
        local src = source

        exports.ox_inventory:AddItem(src, trash_item, 1)
    end)

    
