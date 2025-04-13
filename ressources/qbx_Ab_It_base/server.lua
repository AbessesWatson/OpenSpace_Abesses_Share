
ticketstash = {
    id = 'it_box',
    label = 'Boite à tickets',
    slots = Config.ticketslots,
    weight = 5000, 

}

local virus_spend = {
    a = false,
    b = false,
    c = false,
    d = false,
    e = false,
    f = false,
    g = false,
    h = false,
    i = false,
    j = false,
    k = false,
    l = false,
    m = false,
    n = false,
    o = false,
    p = false,
    q = false,
    r = false,
    s = false,
    sbis = false,
    t = false,
    u = false,
    v = false,
    x = false,
    twinL = false,
    twinG = false,

}

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
        exports.ox_inventory:RegisterStash(ticketstash.id, ticketstash.label, ticketstash.slots, ticketstash.weight)
    end
end)

-- event

    RegisterNetEvent ('qbx_Ab_It_base:Server:GetvirusSpending')
    AddEventHandler('qbx_Ab_It_base:Server:GetvirusSpending', function()
        local src = source

        TriggerClientEvent('qbx_Ab_It_base:Client:recievevirusSpending', src, virus_spend)
    end)

    RegisterNetEvent ('qbx_Ab_It_base:Server:updatevirusSpending')
    AddEventHandler('qbx_Ab_It_base:Server:updatevirusSpending', function(dataspending)
        local src = source

        virus_spend = dataspending
        print ('recievevirusSpending : ' ..json.encode(virus_spend))

        Wait(10)
        TriggerClientEvent('qbx_Ab_It_base:Client:recievevirusSpending', -1, virus_spend)
    end)

    RegisterNetEvent('qbx_Ab_It_base:Server:brokeFloppyDisk')
    AddEventHandler('qbx_Ab_It_base:Server:brokeFloppyDisk', function()
        local src = source

        exports.ox_inventory:RemoveItem(src, Config.antivirusitem, 1)
        exports.ox_inventory:AddItem(src, Config.antivirusitem_trash, 1)
    end)

-- thread

CreateThread(function()
    while true do
        Wait(Config.spendingvirus_time * 1000) -- 15 minutes en millisecondes
        
        local virus_keys = {}
        
        -- Remplir une table avec les clés qui sont encore à false
        for k, v in pairs(virus_spend) do
            if not v then
                table.insert(virus_keys, k)
            end
        end

        -- Si on a des clés disponibles
        if #virus_keys > 0 then
            local randomKey = virus_keys[math.random(1, #virus_keys)]
            virus_spend[randomKey] = true

            print("Virus détecté sur : " .. randomKey)

            -- Notifier tous les joueurs (optionnel)
            TriggerClientEvent('qbx_Ab_It_base:Client:recievevirusSpending', -1, virus_spend)
        end
    end
end)
