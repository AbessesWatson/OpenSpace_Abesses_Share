-- Fonction pour obtenir un ID unique pour chaque machine ç café basée sur ses coordonnées
local function CafeMachineID(coords)
    return coords.x .. '_' .. coords.y .. '_' .. coords.z
end

local CafeLvl = {}
local CafeMax = 10
local Cafetorefill = CafeMax

-- SQL STUFF

-- Charger les niveaux de café depuis la base de données au démarrage du serveur
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        MySQL.Async.fetchAll("SELECT * FROM Ab_CafeMachines", {}, function(CafeMachines)
            for _, CafeMachine in pairs(CafeMachines) do
                CafeLvl[CafeMachine.id] = CafeMachine.CafeLvl
            end
            print("Chargement des niveaux de café terminé.")
        end)
    end
end)

-- Initialiser le niveau de café d'une Machine à café dans la base de données
local function initCafeMachineInDatabase(CafeMachineId)
    MySQL.Async.execute("INSERT INTO Ab_CafeMachines (id, CafeLvl) VALUES (?, ?) ON DUPLICATE KEY UPDATE CafeLvl = VALUES(CafeLvl)", 
        { CafeMachineId, CafeMax }, 
        function()
            CafeLvl[CafeMachineId] = CafeMax
            print("Machine à café initialisée avec ID:", CafeMachineId, "et Niveau:", CafeMax)
        end
    )
end

-- REGISTER EVENT
-- boire et verifié

-- Événement pour boire du café avec une quantité limitée
RegisterNetEvent('qbx_Ab_CafeMachines:server:drinkCafe')
AddEventHandler('qbx_Ab_CafeMachines:server:drinkCafe', function(coords)
    local src = source
    local cafemachineId = CafeMachineID(coords)

    -- Initialiser la quantité d'eau pour cette Machine à café si elle n'existe pas encore
    if not CafeLvl[cafemachineId] then
        initCafeMachineInDatabase(cafemachineId)
    end

    -- Vérifier s'il reste de le cafe dans la machine
    if CafeLvl[cafemachineId] > 0 then
        -- Réduire le compteur de la Machine
        CafeLvl[cafemachineId] = CafeLvl[cafemachineId] - 1

        -- Mise à jour de la base de données
        MySQL.Async.execute("UPDATE Ab_CafeMachines SET CafeLvl = ? WHERE id = ?", { CafeLvl[cafemachineId], cafemachineId })


        -- Ajouter un effet de boisson au joueur (ajuste la soif par exemple)
        --TriggerClientEvent('consumables:client:addThirst', src, 2)
        TriggerClientEvent('qbx_Ab_CafeMachines:client:drinkAnimation', src) -- Lance l'animation de boisson
        TriggerClientEvent('QBCore:Notify', src, "Vous buvez du café.", "success", 5000)
        exports.ox_inventory:AddItem(src, "goblet", 1) -- ajoute un goblet
    else
        -- Notifier le joueur que la Machine est vide
        TriggerClientEvent('QBCore:Notify', src, "La Machine à café est vide.", "error", 5000)
    end
end)

-- Événement pour vérifier le niveau de café de la Machine à café
RegisterNetEvent('qbx_Ab_CafeMachines:server:checkCafeLevel')
AddEventHandler('qbx_Ab_CafeMachines:server:checkCafeLevel', function(coords)
    local src = source
    local cafemachineId = CafeMachineID(coords)

    -- Initialiser la quantité de café pour cette Machine à café si elle n'existe pas encore
    if not CafeLvl[cafemachineId] then
        initCafeMachineInDatabase(cafemachineId)
    end

    -- Renvoyer le niveau de café au client
    cafelvlnotify = CafeLvl[cafemachineId] or 0
    TriggerClientEvent('QBCore:Notify', src, "Le niveau de café de la machine est de " .. cafelvlnotify .. "0%.", "info", 5000)
end)


-- Refill le café

RegisterNetEvent('qbx_Ab_CafeMachines:server:CafeRefill')
AddEventHandler('qbx_Ab_CafeMachines:server:CafeRefill', function(coords)
    local src = source
    local cafemachineId = CafeMachineID(coords)

    -- Vérifier si la Machine à café existe dans la base de données
    if not CafeLvl[cafemachineId] then
        initCafeMachineInDatabase(cafemachineId)
    end

    -- Si la Machine à café peut être remplie, on l'augmente
    if  CafeLvl[cafemachineId] < Cafetorefill then
        CafeLvl[cafemachineId] = CafeMax

        -- Mise à jour dans la base de données
        MySQL.Async.execute("UPDATE Ab_CafeMachines SET CafeLvl = ? WHERE id = ?", { CafeLvl[cafemachineId], cafemachineId })

        -- Retirer une bonbonne de café de l'inventaire du joueur
        exports.ox_inventory:RemoveItem(src, Config.refillitem, 1)

        TriggerClientEvent('qbx_Ab_CafeMachines:client:fillAnimation', src) -- Lance l'animation de boisson
        -- Notifier le joueur
        TriggerClientEvent('QBCore:Notify', src, "Tu remplis la machine à café !", "success", 10000)
    else
        TriggerClientEvent('QBCore:Notify', src, "La Machine à café a encore du café.", "error", 5000)
    end
end)

-- THREAD EVENT

local minutes = 45

-- Fonction pour réduire le niveau de café toutes les 15 minutes
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(minutes * 60 * 1000)  -- 15 minutes

        for cafemachineId, cafeLevel in pairs(CafeLvl) do
            if cafeLevel > 0 then
                CafeLvl[cafemachineId] = cafeLevel - 1

                -- Mise à jour de la base de données
                MySQL.Async.execute("UPDATE Ab_CafeMachines SET CafeLvl = ? WHERE id = ?", { CafeLvl[cafemachineId], cafemachineId })
                --print("Le niveau de café des machine a baissé")
            end
        end
    end
end)