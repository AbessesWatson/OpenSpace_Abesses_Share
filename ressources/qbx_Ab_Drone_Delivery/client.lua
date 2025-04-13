local blackout = 'off'
local isUIOpen = false

-- Fonction pour vérifier l'état d'un ordinateur
local function checkComputerState(computerID)
    -- Retourner l'état de l'ordinateur localement stocké
    return computer[computerID] and computer[computerID].state or 'active'
end

exports.ox_target:addModel(
    'office_drone_main',  -- zone de livraison drone
    {  
        -- ouvrir la zone
        {
            name = "open delivery zone",
            label = "Zone de livraison",
            icon = "fa-solid fa-box", 
            onSelect = function(data)
                exports.ox_inventory:openInventory(deliverystash, 'drone_delivery')
                --print('open drone_delivery')
            end,
        },
    })

-- ordi classic
exports.ox_target:addModel('prop_monitor_03b', {
    {    -- Delivery Device classic
    name = 'Delivery_Device',
    label = 'Commander du materiel',
    icon = 'fa-solid fa-dolly', 
    groups = Config.jobRequired,
    distance = 1.5,
    canInteract = function(entity, distance, coords)
        local computerID = GetEntityCoords(entity)

        -- Vérifier l'état de l'ordinateur localement
        local state = checkComputerState(json.encode(computerID))

        -- Permettre l'interaction si l'état est 'active'
        if blackout == 'off' then
            if state == 'active' then
                return true
            else
                return false
            end
        else
            return false
        end
    end,
    
        onSelect = function(data)
            local listkind = 'classic'
            TriggerEvent('qbx_Ab_Drone_Delivery:client:openInterface', listkind)
            Wait(10)
        end 
        },
        {    -- Delivery Device medical
        name = 'Delivery_Device_medical',
        label = 'Commander du materiel médical',
        icon = 'fa-solid fa-dolly', 
        groups = Config.jobRequired_medical,
        distance = 1.5,
        canInteract = function(entity, distance, coords)
            local computerID = GetEntityCoords(entity)
    
            -- Vérifier l'état de l'ordinateur localement
            local state = checkComputerState(json.encode(computerID))
    
            -- Permettre l'interaction si l'état est 'active'
            if blackout == 'off' then
                if state == 'active' then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end,
        
            onSelect = function(data)
                local listkind = 'medical'
                TriggerEvent('qbx_Ab_Drone_Delivery:client:openInterface', listkind)
                Wait(10)
            end 
            },
        {    -- Delivery Device Black Market cd
            name = 'Delivery_Device_black_market',
            label = 'Commander sur le Black Market',
            icon = 'fa-solid fa-shop-lock',
            items = Config.blackmarket_item,
            distance = 1.5,
            canInteract = function(entity, distance, coords)
                local computerID = GetEntityCoords(entity)
        
                -- Vérifier l'état de l'ordinateur localement
                local state = checkComputerState(json.encode(computerID))
        
                -- Permettre l'interaction si l'état est 'active'
                if blackout == 'off' then
                    if state == 'active' then
                        return true
                    else
                        return false
                    end
                else
                    return false
                end
            end,
        
            onSelect = function(data)
                local listkind = 'black_market'
                TriggerEvent('qbx_Ab_Drone_Delivery:client:openInterface', listkind)
                TriggerServerEvent('qbx_Ab_Drone_Delivery:server:blackMarketItemRandomize')
                Wait(10)
            end 
        },  
})

-- ordi admin 

exports.ox_target:addModel('v_ind_dc_desk01', {
    {    -- Delivery Device Black Market admin
        name = 'Delivery_Device_blackmarket_admin',
        label = 'Commander sur le Black Market (admin)',
        icon = 'fa-solid fa-shop-lock',
        groups = 'admin',
        canInteract = function(entity, distance, coords)
            local computerID = GetEntityCoords(entity)

            -- Vérifier l'état de l'ordinateur localement
            local state = checkComputerState(json.encode(computerID))

            -- Permettre l'interaction si l'état est 'active'
            if state == 'active' then
                return true
            else
                return false
            end
        end,

        onSelect = function(data)
            local listkind = 'black_market'
            TriggerEvent('qbx_Ab_Drone_Delivery:client:openInterface', listkind)
            Wait(10)
        end 
    },
})

-- Ouverture de l'interface
RegisterNetEvent("qbx_Ab_Drone_Delivery:client:openInterface", function(kind)
    Wait(10)
    local listkind = kind
    TriggerServerEvent("qbx_Ab_Drone_Delivery:server:fetchItems", listkind)
    print("fetch items trigger")
end)

-- Réception des objets disponibles et ouverture de l'interface NUI
RegisterNetEvent("qbx_Ab_Drone_Delivery:client:setItems", function(items)
    if not isUIOpen then
        isUIOpen = true
        SetNuiFocus(true, true) -- Active la saisie utilisateur dans l'UI
        SetNuiFocusKeepInput(true)
        SendNUIMessage({
            action = "openDeliveryInterface",
            items = items
        })
    end
    --print("interface delivery open")
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

-- Gestion des données envoyées par l'interface
RegisterNUICallback("submitData", function(data, cb)
    if data.name and data.count then
        TriggerServerEvent("qbx_Ab_Drone_Delivery:server:addToStash", data)
    else
        TriggerEvent("QBCore:Notify", "Données invalides.", "error")
    end

    -- Fermer l'interface
    SetNuiFocus(false, false)
    isUIOpen = false
    cb("ok")
end)

-- Fermer l'interface avec le bouton annuler
RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    isUIOpen = false
    cb("ok")
end)

-- event blackout 

RegisterNetEvent('qbx_Ab_Dorne_Delivery:client:blackout', function(isblackout)
    blackout = isblackout
end)