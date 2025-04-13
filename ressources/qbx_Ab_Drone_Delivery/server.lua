
deliverystash = {
    id = 'drone_delivery',
    label = 'Zone de livraison',
    slots = Config.deliveryslots,
    weight = 0, 

}

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
        exports.ox_inventory:RegisterStash(deliverystash.id, deliverystash.label, deliverystash.slots, deliverystash.weight)
    end
end)


-- Envoyer la liste des objets au client
RegisterNetEvent("qbx_Ab_Drone_Delivery:server:fetchItems", function(listkind)
    local src = source
    if listkind == 'classic' then
    TriggerClientEvent("qbx_Ab_Drone_Delivery:client:setItems", src, Config.deliveryitems)
    print("item fetch : ".. json.encode(Config.deliveryitems))
    elseif listkind == 'medical' then
        TriggerClientEvent("qbx_Ab_Drone_Delivery:client:setItems", src, Config.deliveryitems_medical)
        print("item fetch : ".. json.encode(Config.deliveryitems_medical))
    elseif listkind == 'black_market' then
        TriggerClientEvent("qbx_Ab_Drone_Delivery:client:setItems", src, Config.deliveryitems_blackmarket)
        print("item fetch : ".. json.encode(Config.deliveryitems_blackmarket))
    else
        print ('erreur de list pour fetchItems')
    end
end)

-- Gestion de l'ajout au stash
RegisterNetEvent("qbx_Ab_Drone_Delivery:server:addToStash", function(data)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local stashId = "drone_delivery" -- Stash fixe
    local itemName = data.name
    local itemCount = tonumber(data.count)

    -- Validation des données
    if itemName and itemCount and itemCount > 0 and itemCount <= Config.deliveryslots then
        local success = exports.ox_inventory:AddItem(stashId, itemName, itemCount)
        if success then
            TriggerClientEvent("QBCore:Notify", src, "la livraison à eu lieu en au 5ème étages !", "success", 8000)
        else
            TriggerClientEvent("QBCore:Notify", src, "Erreur de livraison ou stockage plein", "error", 8000)
        end
    else
        TriggerClientEvent("QBCore:Notify", src, "Données invalides fournies ou limite dépassée (max 5).", "error", 8000)
    end
end)

-- black market item delete?
RegisterNetEvent("qbx_Ab_Drone_Delivery:server:blackMarketItemRandomize", function()
    local src = source
    local probamax = 2
    local proba = math.random(1, 2)

    if proba == probamax then
        exports.ox_inventory:RemoveItem(src, Config.blackmarket_item, 1)
        exports.ox_inventory:AddItem(src, Config.blackmarket_item_broken, 1)
        exports.qbx_core:Notify(src, 'Le CD-ROM vient de se casser!', 'warning', 15000)
    end

end)