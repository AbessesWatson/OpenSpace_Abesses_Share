local tempo_paperlvl = nil

local function GetPrinterData(coords)
    TriggerServerEvent('qbx_Ab_Printer:server:getPrinterData', coords)
end

RegisterNetEvent('qbx_Ab_Printer:client:receivePrinterData')
AddEventHandler('qbx_Ab_Printer:client:receivePrinterData', function(data)
    --print("Niveau de papier du printer :", data)
    tempo_paperlvl = data
end)

local function PrintItTicket(propCoords, item)
    GetPrinterData(propCoords)
    
    Wait(500)

    -- Permettre l'interaction 
    if tempo_paperlvl > 0 then
        TriggerServerEvent("qbx_Ab_Printer:server:printTicket", item)
        TriggerServerEvent('qbx_Ab_Printer:server:PaperReduce', propCoords)
    else
        exports.qbx_core:Notify("Il n'y a plus de papier dans l'imprimante", 'error', 8000)
    end
    
end

-- Utilisation de ox_target pour détecter l'interaction
exports.ox_target:addModel(
    Config.printer_props,  -- Liste des modèles de Machine
    {  
        -- Option pour vérifier le niveau de papier
        {
            name = "check_paper_level",
            label = "Vérifier la quantité de papier",
            icon = 'fas fa-search',
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)  -- Récupère les coordonnées de la Machine
                --print (propCoords)
                TriggerServerEvent('qbx_Ab_Printer:server:checkPaperLevel', propCoords) 
            end,
        },
        -- Option pour remplir la Machine
        {
            name = "refill_papier",
            label = "Remettre une ramette de papier",
            icon = 'fa-solid fa-hand', 
            items = Config.refillitem,
            groups = Config.jobRequired,
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)   -- Récupère les coordonnées de la Machine
                TriggerServerEvent('qbx_Ab_Printer:server:PaperRefill', propCoords)  
            end,
        },
        {
            name = "print",
            label = "Imprimer un document",
            icon = "fas fa-print",
            groups = Config.jobRequired,
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)
                GetPrinterData(propCoords)
                
                Wait(500)
        
                -- Permettre l'interaction 
                if tempo_paperlvl > 0 then
                    TriggerEvent('nkt-printer-main:client:print')
                    TriggerServerEvent('qbx_Ab_Printer:server:PaperReduce', propCoords)
                else
                    exports.qbx_core:Notify("Il n'y a plus de papier dans l'imprimante", 'error', 8000)
                end
                
            end
        },
        {
            name = "print_jeton",
            label = "Imprimer un bon point",
            icon = "fa-solid fa-candy-cane",
            groups = "admin",
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)
                GetPrinterData(propCoords)
                
                Wait(500)
        
                -- Permettre l'interaction 
                if tempo_paperlvl > 0 then
                    TriggerServerEvent("qbx_Ab_Consomable:server:printJeton")
                    TriggerServerEvent('qbx_Ab_Printer:server:PaperReduce', propCoords)
                else
                    exports.qbx_core:Notify("Il n'y a plus de papier dans l'imprimante", 'error', 8000)
                end
                
            end
        },
    -- Partie l'impression de ticket admin
        {
            name = "print_ticket_it_ss",
            label = "Imprimer une demande CTG sous-sol",
            icon = "fa-solid fa-print",
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)
                PrintItTicket(propCoords, 'it_ticket_ss')
            end
        },
        {
            name = "print_ticket_it_rdc",
            label = "Imprimer une demande CTG RDC",
            icon = "fa-solid fa-print",
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)
                PrintItTicket(propCoords, 'it_ticket_rdc')
            end
        },
        {
            name = "print_ticket_it_1er",
            label = "Imprimer une demande CTG Cubicles",
            icon = "fa-solid fa-print",
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)
                PrintItTicket(propCoords, 'it_ticket_1')
            end
        },
        {
            name = "print_ticket_it_2eme",
            label = "Imprimer une demande CTG Bureaux",
            icon = "fa-solid fa-print",
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)
                PrintItTicket(propCoords, 'it_ticket_2')
            end
        },
        {
            name = "print_ticket_it_3eme",
            label = "Imprimer une demande CTG espace de vie",
            icon = "fa-solid fa-print",
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)
                PrintItTicket(propCoords, 'it_ticket_3')
            end
        },
        {
            name = "print_ticket_it_4eme",
            label = "Imprimer une demande CTG archives",
            icon = "fa-solid fa-print",
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)
                PrintItTicket(propCoords, 'it_ticket_4')
            end
        },
        {
            name = "print_ticket_it_5eme",
            label = "Imprimer une demande CTG CEO",
            icon = "fa-solid fa-print",
            distance = 1.5,
            onSelect = function(data)
                local propCoords = GetEntityCoords(data.entity)
                PrintItTicket(propCoords, 'it_ticket_5')
            end
        },

    }
)

-- Animation pour remplir la machine avec la bonbonne
RegisterNetEvent('qbx_Ab_Printer:client:fillAnimation')
AddEventHandler('qbx_Ab_Printer:client:fillAnimation', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local anim = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"  -- Exemple d'animation
    local animname = "machinic_loop_mechandplayer"
    --local propModel = Config.paper_prop  -- Modèle visuel de ramette
    local duration = 10000

    -- Créer et attacher la bonbonne à la main
    --local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 57005), 0.015000, -0.009000, 0.003000, 55.000000, 0.000000, 110.000000, true, true, false, true, 1, true)

    -- Charger et jouer l'animation
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Wait(100)
    end

    TaskPlayAnim(playerPed, anim, animname, 3.0, 3.0, duration, 1, 0, false, false, false)

    Wait(duration)
    TriggerServerEvent('server:addProductivity', Config.prod_refill) -- Event qui augmente la productivity de 1
    TriggerServerEvent('server:addJobProductivity', Config.jobtoprod, Config.prod_refill) -- Augmente la productivité du job
    TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.fatigue_refill) -- augmente la fatigue 
    TriggerServerEvent("qbx_Ab_Archive_base:server:addDocToStash", "communication") -- ajoute un doc a trier pour archive
    ClearPedTasks(playerPed) -- Arrêter l'animation
    --DeleteObject(prop) -- Supprimer la bonbonne après l'animation
end)