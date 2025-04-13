-- Déclaration de la variable globale côté serveur
local activationread_reception = false

-- Commande pour activer/désactiver `activationread`
RegisterCommand("MailReadReception", function(source, args)
    -- Vérifie si un argument est fourni (true/false)
    if args[1] == "true" then
        activationread_reception = true
        print("la reception de courrier à lire est maintenant activé (true).")
    elseif args[1] == "false" then
        activationread_reception = false
        print("la reception de courrier à lire désactivé (false).")
    else
        -- Si aucun argument n'est fourni ou qu'il est invalide
        print("Utilisation : /MailReadReception  [true|false]")
    end
end, true) -- "true" signifie que seule la console serveur ou un admin peut l'exécuter

mailboxstash = {
    id = 'mail_reception',
    label = 'Zone de récéption de courrier',
    slots = Config.deliverymailslots,
    weight = 0, 

}

-- /////

-- Fonction pour obtenir un mail aléatoire
local function getRandomMail()
    local mailType = math.random(1, 2)
    local selectedList = nil

    if mailType == 1 then
        selectedList = Config.goodMailItems
    elseif mailType == 2 then
        selectedList = Config.badMailItems
    end
    -- Tirage aléatoire d'un item dans la liste choisie
    local selectedItem = selectedList[math.random(#selectedList)]

    -- Retourner le type et l'item
    return selectedItem
end



AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
        exports.ox_inventory:RegisterStash(mailboxstash.id, mailboxstash.label, mailboxstash.slots, mailboxstash.weight)
    end
end)


-- Gestion de l'ajout au stash
RegisterNetEvent("qbx_Ab_ReadMail:server:addToMail_reception", function()

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



-- LE THREAD POUR LA RECEPTION DU COURRIER A LIRE
CreateThread(function()
    while true do
        Wait(Config.minute*60*1000)

        -- Vérification de l'état de `activationread_reception`
        if activationread_reception then
            -- Exécution de l'événement pour ajouter un courrier
            TriggerEvent("qbx_Ab_ReadMail:server:addToMail_reception")
        end

    end
end)

-- pour l'info serveur
CreateThread(function()
    while true do
        Wait(60*60*1000)

        -- Vérification de l'état de `activationread_reception`
        if activationread_reception then
            print("Un courrier à lire a été ajouté automatiquement.")
        else
            print("La réception automatique est désactivée.")
        end

    end
end)

-- POUR LE DEPOT DU COURRIER DANS LES PILE

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

RegisterNetEvent("qbx_Ab_ReadMail:server:openMailInterface", function(typepile)
    local player = source
    local pilekind = typepile

    -- Appelle la fonction pour récupérer les items whitelistés
    local itemsForInterface = getWhitelistedItems(player, Config.wh_readItem)

    -- Vérifie s'il y a des items à envoyer à l'interface
    if #itemsForInterface > 0 then
        print("Items envoyés : " .. json.encode(itemsForInterface))
        TriggerClientEvent("qbx_Ab_ReadMail:client:openInterface", player, itemsForInterface, pilekind)
    else
        TriggerClientEvent("ox_lib:notify", player, { type = "error", description = "Il n'y a pas de courrier dans votre inventaire." })
    end
end)


RegisterCommand("chooseGPMail", function(source, typepile)
    TriggerEvent("qbx_Ab_ReadMail:server:openMailInterface", source, typepile)
end, false)



-- Supprime l'item choisi du joueur
RegisterNetEvent("qbx_Ab_ReadMail:server:removeMailRead", function(itemName, pilekind)
    local player = source
    local typepile = pilekind

    -- Retirer l'item du joueur
    --print (player.. " et l'item " ..itemName.. " et le type de pile est " ..typepile)

    -- Vérification du type de pile et de l'appartenance à la liste correspondante
    if typepile == "good" then
         if tableHasValue(Config.goodMailItems, itemName) then
            --print("C'est un bon courrier mis dans la pile des courriers positifs.")
            exports.qbx_core:Notify(player, "Le courrier à été bien classé!", 'success', 7000)
            TriggerEvent('server:addProductivity', Config.upprod, player) -- Augmente la productivité
            TriggerEvent('server:addJobProductivity', Config.jobtoprod, Config.upprod) -- Augmente la productivité du job
            TriggerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue',Config.upfatigue, player) -- augmente la fatigue 
            TriggerEvent("qbx_Ab_Archive_base:server:addDocToStash", "accueil") -- ajoute un doc a trier pour archive
         elseif tableHasValue(Config.badMailItems, itemName) then
            print("C'est un mauvais courrier mis dans la pile des courriers positifs.")
            exports.qbx_core:Notify(player, "Le courrier n'a pas été mis dans la bonne pile!", 'error', 7000)
            TriggerEvent('hud:server:GainStress',Config.upstress, player) -- Augmente le stress 
            TriggerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue',Config.upfatigue, player) -- augmente la fatigue 
         end
    elseif typepile == "bad" then
        if tableHasValue(Config.badMailItems, itemName) then
            --print("C'est un mauvais courrier mis dans la pile des courriers négatifs.")
            exports.qbx_core:Notify(player, "Le courrier à été bien classé!", 'success', 7000)
            TriggerEvent('server:addProductivity', Config.upprod, player) -- Augmente la productivité
            TriggerEvent('server:addJobProductivity', Config.jobtoprod, Config.upprod) -- Augmente la productivité du job
            TriggerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue',Config.upfatigue, player) -- augmente la fatigue 
            TriggerEvent("qbx_Ab_Archive_base:server:addDocToStash", "accueil") -- ajoute un doc a trier pour archive
        elseif tableHasValue(Config.goodMailItems, itemName) then
            --print("C'est un bon courrier mis dans la pile des courriers négatifs.")
            exports.qbx_core:Notify(player, "Le courrier n'a pas été mis dans la bonne pile!", 'error', 7000)
            TriggerEvent('hud:server:GainStress',Config.upstress, player) -- Augmente le stress 
            TriggerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue',Config.upfatigue, player) -- augmente la fatigue 
        end
    else
        print("L'item ne correspond pas à la pile ou n'est pas dans la liste.")
        TriggerClientEvent("ox_lib:notify", player, { type = "error", description = "L'item ne correspond pas au type de pile." })
        return
    end

    Wait (10)
    local removed = exports.ox_inventory:RemoveItem(player, itemName, 1) -- Modifie le `1` si tu veux retirer plus d'items

end)

-- //// Pour Admin

RegisterNetEvent("qbx_Ab_ReadMail:server:activatereadmail", function()
    activationread_reception = true
    print("la reception de courrier à lire est maintenant activé. " ..tostring(activationread_reception))
end)

RegisterNetEvent("qbx_Ab_ReadMail:server:desactivatereadmail", function()
    activationread_reception = false
    print("la reception de courrier à lire désactivé. " ..tostring(activationread_reception))
end)