-- Fonction pour obtenir un ID unique pour chaque printer basée sur ses coordonnées
local function PrinterID(coords)
    return coords.x .. '_' .. coords.y .. '_' .. coords.z
end

local PaperLvl = {}
local PaperMax = 10
local Papertorefill = 0

-- SQL STUFF

    -- Charger les niveaux de papier depuis la base de données au démarrage du serveur
    AddEventHandler('onResourceStart', function(resource)
        if resource == GetCurrentResourceName() then
            MySQL.Async.fetchAll("SELECT * FROM Ab_Printers", {}, function(Printer)
                for _, Printer in pairs(Printer) do
                    PaperLvl[Printer.id] = Printer.PaperLvl
                end
                print("Chargement des niveaux de papier terminé.")
            end)
        end
    end)

    -- Initialiser le niveau de papier dans les printer dans la base de données
    local function initPrinterInDatabase(PrinterId)
        print ('PrinterId ' ..PrinterId)
        print ('PrinterId tostering' ..tostring(PrinterId))
        MySQL.Async.execute("INSERT INTO Ab_Printers (id, PaperLvl) VALUES (?, ?) ON DUPLICATE KEY UPDATE PaperLvl = VALUES(PaperLvl)", 
            { PrinterId, 0 }, 
            function(affectedRows)
                if affectedRows then
                    PaperLvl[PrinterId] = 0
                    print("Printer initialisée avec ID:" ..PrinterId.. "et Niveau: " ..0)
                else
                    print("Impossible d'initialiser le Printer ID: " ..PrinterId)
                end
            end
        )
    end

-- EVENT 

    -- Récupérer les données d'un printer
    RegisterNetEvent('qbx_Ab_Printer:server:getPrinterData', function(coords, callback)
        local src = source
        local PrinterId = PrinterID(coords)

        local paperlvlnotify = PaperLvl[PrinterId] or 0 -- Assure que ce n'est pas nil
        print(json.encode(PrinterId).. 'a pour lvl ' ..paperlvlnotify)

        TriggerClientEvent('qbx_Ab_Printer:client:receivePrinterData', src, PaperLvl[PrinterId])
    end)

    -- Événement pour vérifier le niveau de papier dans le printer
    RegisterNetEvent('qbx_Ab_Printer:server:checkPaperLevel')
    AddEventHandler('qbx_Ab_Printer:server:checkPaperLevel', function(coords)
        local src = source
        local PrinterId = PrinterID(coords)

        -- Initialiser la quantité de papier pour le printer si elle n'existe pas encore
        if not PaperLvl[PrinterId] then
            initPrinterInDatabase(PrinterId)
        end

        local paperlvlnotify = PaperLvl[PrinterId] or 0 -- Assure que ce n'est pas nil

        -- Renvoyer le niveau de papier au client
        TriggerClientEvent('QBCore:Notify', src, "Le niveau de papier est de " ..paperlvlnotify.. "0%.", "info", 8000)
    end)


    -- Refill papier

    RegisterNetEvent('qbx_Ab_Printer:server:PaperRefill')
    AddEventHandler('qbx_Ab_Printer:server:PaperRefill', function(coords)
        local src = source
        local PrinterId = PrinterID(coords)

        -- Vérifier si le printer existe dans la base de données
        if not PaperLvl[PrinterId] then
            initPrinterInDatabase(PrinterId)
        end

        -- Si la Machine à papier peut être remplie, on l'augmente
        if  PaperLvl[PrinterId] <= Papertorefill then
            PaperLvl[PrinterId] = PaperMax

            -- Mise à jour dans la base de données
            MySQL.Async.execute("UPDATE Ab_Printers SET PaperLvl = ? WHERE id = ?", { PaperLvl[PrinterId], PrinterId })

            -- Retirer une ramette de papier de l'inventaire du joueur
            exports.ox_inventory:RemoveItem(src, Config.refillitem, 1)

            TriggerClientEvent('qbx_Ab_Printer:client:fillAnimation', src) -- Lance l'animation de boisson
            -- Notifier le joueur
            TriggerClientEvent('QBCore:Notify', src, "Tu remplis la machine avec une ramette de papier !", "success", 10000)
        else
            TriggerClientEvent('QBCore:Notify', src, "L'imprimante a encore du papier.", "error", 8000)
        end
    end)


    RegisterNetEvent('qbx_Ab_Printer:server:PaperReduce')
    AddEventHandler('qbx_Ab_Printer:server:PaperReduce', function(coords)
        local src = source
        local PrinterId = PrinterID(coords)

        -- Vérifier si le printer existe dans la base de données
        if not PaperLvl[PrinterId] then
            initPrinterInDatabase(PrinterId)
        end

        if  PaperLvl[PrinterId] > 0 then
            PaperLvl[PrinterId] = PaperLvl[PrinterId] - 1

            -- Mise à jour dans la base de données
            MySQL.Async.execute("UPDATE Ab_Printers SET PaperLvl = ? WHERE id = ?", { PaperLvl[PrinterId], PrinterId })

            local paperlvlnotify = PaperLvl[PrinterId] or 0 -- Assure que ce n'est pas nil
            print ('réduction de la quantité de papier pour ' ..json.encode(PrinterId).. 'maintenant de ' ..paperlvlnotify)

        else
            print ('impossible de reduire le papier')
        end

    end)

    RegisterNetEvent('qbx_Ab_Printer:server:printTicket')
    AddEventHandler('qbx_Ab_Printer:server:printTicket', function(item)
        local src = source
        
        exports.ox_inventory:AddItem(src, item, 1)
        exports.qbx_core:Notify(src, "Vous avez imprimé un ticket de demande d'intervention aux chargés de télégestion", 'inform', 10000)

    end)

    -- faire des boule de papier

    RegisterNetEvent('qbx_Ab_Printer:server:paperball', function(slot)
        local src = source

        exports.ox_inventory:RemoveItem(src, "paper", 1)
        exports.ox_inventory:AddItem(src, "WEAPON_PAPER_BALL ", 10)

    end)