-- Déclaration de la variable globale côté serveur
local activationdelivery_reception = false

-- Commande pour activer/désactiver `activationread`
RegisterCommand("MailDeliveryReception", function(source, args)
    -- Vérifie si un argument est fourni (true/false)
    if args[1] == "true" then
        activationdelivery_reception = true
        print("la reception de courrier à distribuer est maintenant activé (true).")
    elseif args[1] == "false" then
        activationdelivery_reception = false
        print("la reception de courrier à distribuer est désactivé (false).")
    else
        -- Si aucun argument n'est fourni ou qu'il est invalide
        print("Utilisation : /MailDeliveryReception  [true|false]")
    end
end, true) -- "true" signifie que seule la console serveur ou un admin peut l'exécuter

-- Fonction pour obtenir un mail aléatoire
local function getRandomMail()

    -- Tirage aléatoire d'un item dans la liste des mails
    local selectedMail = Config.mail_location_delivery[math.random(#Config.mail_location_delivery)]

    -- Retourner le mailName, officeName et officeCoords
    return selectedMail.mailName
end

-- Gestion de l'ajout au stash
RegisterNetEvent("qbx_Ab_DeliveryMail:server:addToMail_reception", function()

    local mailchoosed = getRandomMail()

    local stashId = "mail_reception" -- Stash fixe
    local itemName = mailchoosed

    -- Validation des données
    if 1 <= Config.deliverymailslots then
        local success = exports.ox_inventory:AddItem(stashId, itemName, 1)

        if success then
            print(("[%s] Ajouté à la boîte de réception : %s"):format(stashId, itemName))
        else
            print(("[%s] Échec de l'ajout de l'item : %s"):format(stashId, itemName))
        end
    else
        print("Config.deliverymailslots est invalide ou égal à 0.")
    end
end)

-- LE THREAD POUR LA RECEPTION DU COURRIER A LIVRER
CreateThread(function()
    while true do
        Wait(Config.minute*60*1000)

        -- Vérification de l'état de `activationdelivery_reception`
        if activationdelivery_reception then
            -- Exécution de l'événement pour ajouter un courrier
            TriggerEvent("qbx_Ab_DeliveryMail:server:addToMail_reception")
        end

    end
end)

-- pour l'info serveur
CreateThread(function()
    while true do
        Wait(60*60*1000)

        -- Vérification de l'état de `activationdelivery_reception`
        if activationdelivery_reception then
            print("Un courrier à livrer a été ajouté automatiquement.")
        else
            print("La réception automatique est désactivée.")
        end

    end
end)

-- POUR LE DEPOT DU COURRIER DANS LES BUREAUX

-- Fonction pour récupérer les items whitelistés dans l'inventaire d'un joueur
local function getWhitelistedItems(player, whitelist)
    local whitelistedItems = exports.ox_inventory:Search(player, "slots", whitelist)
    local itemsForInterface = {}

    -- Vérifie si des items whitelistés existent
    if whitelistedItems and next(whitelistedItems) then
        -- Parcours des items de la whitelist
        for _, items in pairs(whitelistedItems) do
            -- Si l'élément dans le tableau n'est pas vide
            if items and #items > 0 then
                for _, item in pairs(items) do
                    if item.name and item.label then
                        table.insert(itemsForInterface, {
                            name = item.name,
                            label = item.label,
                            count = item.count
                        })
                    end
                end
            end
        end
    end

    return itemsForInterface
end

local function tableHasValue(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

RegisterNetEvent("qbx_Ab_DeliveryMail:server:openMailInterface", function(mailNameNeeded, officeName)
    local player = source

    -- Appelle la fonction pour récupérer les items whitelistés
    local itemsForInterface = getWhitelistedItems(player, Config.wh_deliveryItem)

    -- Vérifie s'il y a des items à envoyer à l'interface
    if #itemsForInterface > 0 then
        print("Mail needed: " ..mailNameNeeded.." Items envoyés : " .. json.encode(itemsForInterface))
        TriggerClientEvent("qbx_Ab_DeliveryMail:client:openInterface", player, itemsForInterface, mailNameNeeded, officeName)
    else
        TriggerClientEvent("ox_lib:notify", player, { type = "error", description = "Il n'y a pas de courrier dans votre inventaire." })
    end
end)

-- Supprime l'item choisi du joueur
RegisterNetEvent("qbx_Ab_DeliveryMail:server:removeMailRead", function(mailName, mailNameNeeded, officeName)
    local player = source

    -- Retirer l'item du joueur
    print (player.. " et l'item " ..mailName.. " et le bureau est " ..officeName)

    -- Vérification du type de pile et de l'appartenance à la liste correspondante
    if mailName == mailNameNeeded then
        --print("C'est un bon courrier déposé dans le bon bureau.")
        exports.qbx_core:Notify(player, "Ce courrier à était déposé au bon endroit.", "success", 7000)
        TriggerEvent('server:addProductivity', Config.upprod, player) -- Augmente la productivité
        TriggerEvent('server:addJobProductivity', Config.jobtoprod, Config.upprod) -- Augmente la productivité du job
        TriggerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue',Config.upfatigue, player) -- augmente la fatigue 
        TriggerEvent("qbx_Ab_Archive_base:server:addDocToStash", "accueil") -- ajoute un doc a trier pour archive
    else
        --print("Le mail ne correspond pas au bureau ou n'est pas dans la liste.")
        exports.qbx_core:Notify(player, "Ce courrier à était déposé au mauvais endroit.", "error", 7000)
        TriggerEvent('hud:server:GainStress',Config.upstress, player) -- Augmente le stress 
        TriggerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue',Config.upfatigue, player) -- augmente la fatigue 
    end

    Wait (10)
    local removed = exports.ox_inventory:RemoveItem(player, mailName, 1) -- Modifie le `1` si tu veux retirer plus d'items

end)

-- //// Pour Admin

RegisterNetEvent("qbx_Ab_DeliveryMail:server:activatereadmail", function()
    activationdelivery_reception = true
    print("la reception de courrier à livrer est maintenant activé. " ..tostring(activationdelivery_reception))
end)

RegisterNetEvent("qbx_Ab_DeliveryMail:server:desactivatereadmail", function()
    activationdelivery_reception = false
    print("la reception de courrier à livrer désactivé. " ..tostring(activationdelivery_reception))
end)