


-- Fonction pour obtenir un ID unique pour chaque Fountain d'eau basée sur ses coordonnées
local function FountainID(coords)
    return coords.x .. '_' .. coords.y .. '_' .. coords.z
end

local WaterLvl = {}
local WaterMax = 10
local WaterTorefill = 2

-- SQL STUFF

-- Charger les niveaux d'eau depuis la base de données au démarrage du serveur
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        MySQL.Async.fetchAll("SELECT * FROM water_fountains", {}, function(fountains)
            for _, fountain in pairs(fountains) do
                WaterLvl[fountain.id] = fountain.WaterLvl
            end
            print("Chargement des niveaux d'eau terminé.")
        end)
    end
end)

-- Initialiser le niveau d'eau d'une fontaine dans la base de données
local function initFountainInDatabase(fountainId)
    MySQL.Async.execute("INSERT INTO water_fountains (id, WaterLvl) VALUES (?, ?) ON DUPLICATE KEY UPDATE WaterLvl = VALUES(WaterLvl)", 
        { fountainId, WaterMax }, 
        function()
            WaterLvl[fountainId] = WaterMax
            print("Fontaine initialisée avec ID:", fountainId, "et Niveau:", WaterMax)
        end
    )
end

-- REGISTER EVENT
-- boire et verifié

-- Événement pour boire de l'eau avec une quantité limitée
RegisterNetEvent('qbx_Ab_Eau:server:alanisWater')
AddEventHandler('qbx_Ab_Eau:server:alanisWater', function(coords)
    local src = source
    local fountainId = FountainID(coords)

    -- Initialiser la quantité d'eau pour cette fontaine si elle n'existe pas encore
    if not WaterLvl[fountainId] then
        initFountainInDatabase(fountainId)
    end

    -- Vérifier s'il reste de l'eau dans la Fountain
    if WaterLvl[fountainId] > 0 then
        -- Réduire le compteur de la Fountain
        WaterLvl[fountainId] = WaterLvl[fountainId] - 1

        -- Mise à jour de la base de données
        MySQL.Async.execute("UPDATE water_fountains SET WaterLvl = ? WHERE id = ?", { WaterLvl[fountainId], fountainId })


        exports.ox_inventory:RemoveItem(src, 'alanis_goblet', 1)
        exports.ox_inventory:AddItem(src, 'alanis_goblet_watered', 1)
    else
        -- Notifier le joueur que la Fountain est vide
        TriggerClientEvent('QBCore:Notify', src, "La fontaine d'eau est vide.", "error", 5000)
    end
end)

-- Événement pour boire de l'eau avec une quantité limitée
RegisterNetEvent('qbx_Ab_Eau:server:drinkWater')
AddEventHandler('qbx_Ab_Eau:server:drinkWater', function(coords)
    local src = source
    local fountainId = FountainID(coords)

    -- Initialiser la quantité d'eau pour cette fontaine si elle n'existe pas encore
    if not WaterLvl[fountainId] then
        initFountainInDatabase(fountainId)
    end

    -- Vérifier s'il reste de l'eau dans la Fountain
    if WaterLvl[fountainId] > 0 then
        -- Réduire le compteur de la Fountain
        WaterLvl[fountainId] = WaterLvl[fountainId] - 1

        -- Mise à jour de la base de données
        MySQL.Async.execute("UPDATE water_fountains SET WaterLvl = ? WHERE id = ?", { WaterLvl[fountainId], fountainId })


        -- Ajouter un effet de boisson au joueur (ajuste la soif par exemple)
        --TriggerClientEvent('consumables:client:addThirst', src, 2)
        TriggerClientEvent('qbx_Ab_Eau:client:drinkAnimation', src) -- Lance l'animation de boisson
        TriggerClientEvent('QBCore:Notify', src, "Vous buvez de l'eau.", "success", 5000)
        exports.ox_inventory:AddItem(src, "goblet", 1) -- ajoute un goblet
    else
        -- Notifier le joueur que la Fountain est vide
        TriggerClientEvent('QBCore:Notify', src, "La fontaine d'eau est vide.", "error", 5000)
    end
end)

-- Événement pour vérifier le niveau d'eau de la fontaine
RegisterNetEvent('qbx_Ab_Eau:server:checkWaterLevel')
AddEventHandler('qbx_Ab_Eau:server:checkWaterLevel', function(coords)
    local src = source
    local fountainId = FountainID(coords)

    -- Initialiser la quantité d'eau pour cette fontaine si elle n'existe pas encore
    if not WaterLvl[fountainId] then
        initFountainInDatabase(fountainId)
    end

    -- Renvoyer le niveau d'eau au client
    local waterlvlnotify = WaterLvl[fountainId] or 0
    TriggerClientEvent('QBCore:Notify', src, "Le niveau d'eau de la fontaine est de " .. waterlvlnotify .. "0%.", "info", 5000)
end)


-- Refill la bonbonne

RegisterNetEvent('qbx_Ab_Eau:server:WaterRefill')
AddEventHandler('qbx_Ab_Eau:server:WaterRefill', function(coords)
    local src = source
    local fountainId = FountainID(coords)

    -- Vérifier si la fontaine existe dans la base de données
    if not WaterLvl[fountainId] then
        initFountainInDatabase(fountainId)
    end

    -- Si la fontaine peut être remplie, on l'augmente
    if  WaterLvl[fountainId] < WaterTorefill then
        WaterLvl[fountainId] = WaterMax

        -- Mise à jour dans la base de données
        MySQL.Async.execute("UPDATE water_fountains SET WaterLvl = ? WHERE id = ?", { WaterLvl[fountainId], fountainId })

        -- Retirer une bonbonne d'eau de l'inventaire du joueur
        exports.ox_inventory:RemoveItem(src, "bonbonne", 1)

        TriggerClientEvent('qbx_Ab_Eau:client:fillAnimation', src) -- Lance l'animation de boisson
        -- Notifier le joueur
        TriggerClientEvent('QBCore:Notify', src, "Tu remplis la fontaine !", "success", 10000)
    else
        TriggerClientEvent('QBCore:Notify', src, "La fontaine n'est pas assez vide.", "error", 5000)
    end
end)

-- THREAD EVENT

local minutes = 35

-- Fonction pour réduire le niveau de café toutes les 15 minutes
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(minutes * 60 * 1000)  

        for fountainId, waterLevel in pairs(WaterLvl) do
            if waterLevel > 0 then
                WaterLvl[fountainId] = waterLevel - 1

                -- Mise à jour de la base de données
                MySQL.Async.execute("UPDATE water_fountains SET WaterLvl = ? WHERE id = ?", { WaterLvl[fountainId], fountainId })
                --print("Le niveau d'eau des fontaine a baissé")

            end
        end
    end
end)