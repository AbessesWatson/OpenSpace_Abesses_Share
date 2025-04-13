local isUIOpen = false

exports.ox_target:addModel(
    Config.mailreceptionlocation,  -- zone de livraison drone
    {  
        -- ouvrir la zone
        {
            name = "open mail reception",
            label = "Ouvrir zone de récéption du courrier",
            icon = "fa-regular fa-envelope",
            distance = 1.5,
            groups = Config.jobRequired,
            onSelect = function(data)
                exports.ox_inventory:openInventory(mailboxstash, 'mail_reception')
                print('open mail reception')
            end,
        },
    })

    -- POUR LE DEPOT DU COURRIER 
exports.ox_target:addModel(
    Config.goodpileprops,  -- zone de livraison drone
    {  
        -- ouvrir la zone
        {
            name = "goodpile deposit",
            label = "Déposé un courrier positif",
            icon = "fa-regular fa-envelope",
            distance = 1.5,
            groups = Config.jobRequired,
            onSelect = function(data)
                typepile = "good"
                TriggerServerEvent("qbx_Ab_ReadMail:server:openMailInterface", typepile)
            end,
        },
    })

exports.ox_target:addModel(
    Config.badpileprops,  -- zone de livraison drone
    {  
         -- ouvrir la zone
         {
            name = "goodpile deposit",
            label = "Déposé un courrier négatif",
            icon = "fa-regular fa-envelope",
            distance = 1.5,
            groups = Config.jobRequired,
            onSelect = function(data)
                typepile = "bad"
                TriggerServerEvent("qbx_Ab_ReadMail:server:openMailInterface", typepile)
            end,
            },
    })


    RegisterNetEvent("qbx_Ab_ReadMail:client:openInterface", function(items, pilekind)
        if not isUIOpen then
            isUIOpen = true
            SetNuiFocus(true, true) -- Active la saisie utilisateur dans l'UI
            SetNuiFocusKeepInput(true)
            SendNUIMessage({
                action = "open",
                items = items,
                pilekind = pilekind
            })
        end
    end) 

    Citizen.CreateThread(function()
        while true do
            if isUIOpen then
                Citizen.Wait(0)
    
                -- Désactiver toutes les entrées utilisateur
                DisableAllControlActions(0)
    
                -- Réactiver uniquement certaines touches
                EnableControlAction(0, 249, true) -- Push-to-Talk (N)
                EnableControlAction(0, 168, true) -- F7
            else
                Citizen.Wait(500)
            end
        end
    end)

    RegisterNUICallback("chooseItem", function(data, cb)
        SetNuiFocus(false, false) -- Désactive l'interface JS
        isUIOpen = false
        local itemName = data.itemName
        local pileKind = data.pileKind -- Récupère pileKind depuis le NUI
    
        print("Item à retirer : " .. itemName .. ", Type de pile : " .. pileKind)
        TriggerServerEvent("qbx_Ab_ReadMail:server:removeMailRead", itemName, pileKind) -- Envoie au serveur
        cb("ok")
    end)
    
    -- Gérer la fermeture manuelle de l'interface
    RegisterNUICallback("close", function(_, cb)
        SetNuiFocus(false, false)
        isUIOpen = false
        cb("ok")
    end)

    -- ///// Pour admin

    exports.ox_target:addModel(
    Config.adminprops,  -- zone de livraison drone
    {  
         -- activer récéption du courrier à lire
         {
            name = "activate readmail",
            label = "Activer récéption courrier à lire",
            icon = "fa-regular fa-envelope",
            groups = "admin",
            onSelect = function(data)
                TriggerServerEvent("qbx_Ab_ReadMail:server:activatereadmail")
                print("la reception de courrier à lire est maintenant activé (true).")
                exports.qbx_core:Notify("la reception de courrier à lire est maintenant activé (true).", 'inform', 5000)
            end,
            },
             -- désactiver récéption du courrier à lire
         {
            name = "desactivate readmail",
            label = "Désactiver récéption courrier à lire",
            icon = "fa-regular fa-envelope",
            groups = "admin",
            onSelect = function(data)
                TriggerServerEvent("qbx_Ab_ReadMail:server:desactivatereadmail")
                print("la reception de courrier à lire est maintenant désactivé.")
                exports.qbx_core:Notify("la reception de courrier à lire est maintenant désactivé.", 'inform', 5000)
            end,
            },
    })