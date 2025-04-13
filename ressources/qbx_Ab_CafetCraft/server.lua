-- REMPLIR DE L'EAU

local function EvierID(coords)
    return coords.x .. '_' .. coords.y .. '_' .. coords.z
end

-- Remplir casserole

RegisterNetEvent('qbx_Ab_CafetCraft:server:fillcasserole')
AddEventHandler('qbx_Ab_CafetCraft:server:fillcasserole', function(coords)
    local src = source
    local evier = EvierID(coords)


    exports.ox_inventory:AddItem(src, "eau_casserole", 1)
    TriggerClientEvent('qbx_Ab_CafetCraft:client:casseroleAnimation', src) -- Lance l'animation de boisson


end)

-- MOUDRE DU CAFE

local function CafeGrinderID(coords)
    return coords.x .. '_' .. coords.y .. '_' .. coords.z
end

-- grinder le café

RegisterNetEvent('qbx_Ab_CafetCraft:server:grindcafe')
AddEventHandler('qbx_Ab_CafetCraft:server:grindcafe', function(coords)
    local src = source
    local grinder = CafeGrinderID(coords)

    exports.ox_inventory:RemoveItem(src, "cafesac", 1)
    exports.ox_inventory:AddItem(src, "cafe_moulu", 15)

    TriggerClientEvent('qbx_Ab_CafetCraft:client:grindcafeAnimation', src) -- Lance l'animation 


end)

-- UTILISER LE COOKER

local function CookerID(coords)
    return coords.x .. '_' .. coords.y .. '_' .. coords.z
end

-- event pour faire bouillir de l'eau
RegisterNetEvent('qbx_Ab_CafetCraft:server:boilwater')
AddEventHandler('qbx_Ab_CafetCraft:server:boilwater', function(coords)
    local src = source
    local cooker = CookerID(coords)

    exports.ox_inventory:RemoveItem(src, "eau_casserole", 1)
    exports.ox_inventory:AddItem(src, "eau_bouillante", 1)

    TriggerClientEvent('qbx_Ab_CafetCraft:client:boilwater', src) -- Lance l'animation 

end)

-- event pour faire une omelette
RegisterNetEvent('qbx_Ab_CafetCraft:server:cookomelette')
AddEventHandler('qbx_Ab_CafetCraft:server:cookomelette', function(coords)
    local src = source
    local cooker = CookerID(coords)

    exports.ox_inventory:RemoveItem(src, "oeuf_battu", 1)
    exports.ox_inventory:AddItem(src, "omelette", 1)

    TriggerClientEvent('qbx_Ab_CafetCraft:client:cookomeletteAnimation', src) -- Lance l'animation 

end)

-- event pour cuire un steak
RegisterNetEvent('qbx_Ab_CafetCraft:server:cooksteak')
AddEventHandler('qbx_Ab_CafetCraft:server:cooksteak', function(coords)
    local src = source
    local cooker = CookerID(coords)

    exports.ox_inventory:RemoveItem(src, "steakcru", 1)
    exports.ox_inventory:AddItem(src, "steakcuit", 1)

    TriggerClientEvent('qbx_Ab_CafetCraft:client:cooksteakAnimation', src) -- Lance l'animation 

end)

local function CutplaceID(coords)
    return coords.x .. '_' .. coords.y .. '_' .. coords.z
end

-- event pour cuire une pizza
RegisterNetEvent('qbx_Ab_CafetCraft:server:cookpizza')
AddEventHandler('qbx_Ab_CafetCraft:server:cookpizza', function(coords)
    local src = source
    local cooker = CookerID(coords)

    exports.ox_inventory:RemoveItem(src, "pizza_surgelee", 1)
    exports.ox_inventory:AddItem(src, "pizza", 1)

    TriggerClientEvent('qbx_Ab_CafetCraft:client:cookpizzaAnimation', src) -- Lance l'animation 

end)

local function CutplaceID(coords)
    return coords.x .. '_' .. coords.y .. '_' .. coords.z
end

-- EVENT DECOUPE 
    -- event pour découper la salade
    RegisterNetEvent('qbx_Ab_CafetCraft:server:cutsalade')
    AddEventHandler('qbx_Ab_CafetCraft:server:cutsalade', function(coords)
        local src = source
        local cutplace = CutplaceID(coords)

        exports.ox_inventory:RemoveItem(src, "salade", 1)
        exports.ox_inventory:AddItem(src, "feuille_salade", 5)

        TriggerClientEvent('qbx_Ab_CafetCraft:client:cutAnimation', src) -- Lance l'animation 

    end)

    -- event pour découper une tomate
    RegisterNetEvent('qbx_Ab_CafetCraft:server:cuttomate')
    AddEventHandler('qbx_Ab_CafetCraft:server:cuttomate', function(coords)
        local src = source
        local cutplace = CutplaceID(coords)

        exports.ox_inventory:RemoveItem(src, "tomate", 1)
        exports.ox_inventory:AddItem(src, "tomate_decoupe", 2)

        TriggerClientEvent('qbx_Ab_CafetCraft:client:cutAnimation', src) -- Lance l'animation 

    end)

    -- event pour découper une patate
    RegisterNetEvent('qbx_Ab_CafetCraft:server:cutpatate')
    AddEventHandler('qbx_Ab_CafetCraft:server:cutpatate', function(coords)
        local src = source
        local cutplace = CutplaceID(coords)

        exports.ox_inventory:RemoveItem(src, "patate", 1)
        exports.ox_inventory:AddItem(src, "patate_decoupe", 1)

        TriggerClientEvent('qbx_Ab_CafetCraft:client:cutAnimation', src) -- Lance l'animation 

    end)

    local function MixplaceID(coords)
        return coords.x .. '_' .. coords.y .. '_' .. coords.z
    end

    -- event pour découper du ginseng
    RegisterNetEvent('qbx_Ab_CafetCraft:server:cutginseng')
    AddEventHandler('qbx_Ab_CafetCraft:server:cutginseng', function(coords)
        local src = source
        local cutplace = CutplaceID(coords)

        exports.ox_inventory:RemoveItem(src, "branche_ginseng", 1)
        exports.ox_inventory:AddItem(src, "ginseng", 5)

        TriggerClientEvent('qbx_Ab_CafetCraft:client:cutAnimation', src) -- Lance l'animation 

    end)

    local function MixplaceID(coords)
        return coords.x .. '_' .. coords.y .. '_' .. coords.z
    end

-- event pour battre un oeuf
RegisterNetEvent('qbx_Ab_CafetCraft:server:mixegg')
AddEventHandler('qbx_Ab_CafetCraft:server:mixegg', function(coords)
    local src = source
    local mixplace = MixplaceID(coords)

    exports.ox_inventory:RemoveItem(src, "oeuf", 1)
    exports.ox_inventory:AddItem(src, "oeuf_battu", 4)

    TriggerClientEvent('qbx_Ab_CafetCraft:client:mixAnimation', src) -- Lance l'animation 

end)


local function FriteuseID(coords)
    return coords.x .. '_' .. coords.y .. '_' .. coords.z
end

-- event pour faire des frites
RegisterNetEvent('qbx_Ab_CafetCraft:server:cookfrite')
AddEventHandler('qbx_Ab_CafetCraft:server:cookfrite', function(coords)
    local src = source
    local friteuse = FriteuseID(coords)
    local huilehere = exports.ox_inventory:GetItem(src, "huile_alimentaire")
    print (json.encode(huilehere))

    if huilehere.count > 0 then
        exports.ox_inventory:RemoveItem(src, "huile_alimentaire", 1)
        exports.ox_inventory:RemoveItem(src, "patate_decoupe", 1)
        exports.ox_inventory:AddItem(src, "frite", 5)
        TriggerClientEvent('qbx_Ab_CafetCraft:client:cookfriteAnimation', src) -- Lance l'animation 
    else
        exports.qbx_core:Notify(source, "il faut de l'huile alimentaire pour faire des frites", 'error', 7000)
        TriggerClientEvent('qbx_Ab_CafetCraft:client:isnotcooking', src)
    end

    

end)