    local contrebande_state = nil
    local iswaiting = false

    local function PlayAnimation(dict, name, duration,flag)
        local playerPed = PlayerPedId()
    
        -- Charger le dictionnaire d'animation
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(100)
        end
    
        -- Jouer l'animation
        TaskPlayAnim(playerPed, dict, name, 1.0, 1.0, duration, flag, 0, false, false, false)
    
        -- Attendre la durée de l'animation
        Wait(duration)
    
        -- Arrêter l'animation
        ClearPedTasks(playerPed)
        RemoveAnimDict(dict)
    end
    
    -- Écoute la réception de la variable plantstate
    RegisterNetEvent("qbx_Ab_AlcoolContrebande:client:contrebandeState")
    AddEventHandler("qbx_Ab_AlcoolContrebande:client:contrebandeState", function(state)
        contrebande_state = state
    end)

-- TARGET
    local function GiveParkingEvent(nameEvent, giveitem_name, giveitem, receiveitem)
        return {
            name = nameEvent,
            label = "Glisser " .. giveitem_name .. " sous la porte de garage",
            icon = 'fa-solid fa-handshake-simple',
            items = giveitem,
            distance = 1,
            canInteract = function(entity, distance, coords)
                TriggerServerEvent('qbx_Ab_AlcoolContrebande:server:contrebandeStatecheck')
                Wait (10)
                    
                if iswaiting == false then
                    if contrebande_state == 'need_item' then
                        return true
                    else
                        return false
                    end
                else
                    return false
                end
            end,
            onSelect = function(data)
                TriggerServerEvent('qbx_Ab_AlcoolContrebande:server:giveItem', giveitem, receiveitem)
                iswaiting = true
            end,
        }
    end

    local areaTarget = {
        coords = vec3(84.75, -693.29, 31.66),
        name = 'parking_contrebande',
        radius = 1,
        debug = false,
        drawSprite = false,
        options = {  
            {
                name = "checkParking",
                label = "Frapper à la porte de parking",
                icon = 'fa-solid fa-hand-back-fist',
                distance = 1,
                canInteract = function(entity, distance, coords)
                    TriggerServerEvent('qbx_Ab_AlcoolContrebande:server:contrebandeStatecheck')
                    Wait (10)
                        
                    if contrebande_state == 'waiting' or contrebande_state == 'ready' then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    TriggerServerEvent('qbx_Ab_AlcoolContrebande:server:checkParking')  
                end,
            },
            GiveParkingEvent("giveParking_1", Config.giveitem_1_name, Config.giveitem_1, Config.receiveitem_1),
            GiveParkingEvent("giveParking_2", Config.giveitem_2_name, Config.giveitem_2, Config.receiveitem_2),
            GiveParkingEvent("giveParking_3", Config.giveitem_3_name, Config.giveitem_3, Config.receiveitem_3),
            GiveParkingEvent("giveParking_4", Config.giveitem_4_name, Config.giveitem_4, Config.receiveitem_4),
            GiveParkingEvent("giveParking_5", Config.giveitem_5_name, Config.giveitem_5, Config.receiveitem_5),
            GiveParkingEvent("giveParking_6", Config.giveitem_6_name, Config.giveitem_6, Config.receiveitem_6),
            GiveParkingEvent("giveParking_7", Config.giveitem_7_name, Config.giveitem_7, Config.receiveitem_7),
            GiveParkingEvent("giveParking_8", Config.giveitem_8_name, Config.giveitem_8, Config.receiveitem_8),

            {
                name = "pickupParking",
                label = "Récupéré un objet" ,
                icon = 'fa-solid fa-handshake-simple',
                distance = 1,
                canInteract = function(entity, distance, coords)
                    TriggerServerEvent('qbx_Ab_AlcoolContrebande:server:contrebandeStatecheck')
                    Wait (10)
                        
                    if contrebande_state == 'ready' then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    TriggerServerEvent('qbx_Ab_AlcoolContrebande:server:getItem')  
                end,
            },
            {
                name = "askParking",
                label = "Demander l'objet" ,
                icon = 'fa-solid fa-handshake-simple',
                distance = 1,
                canInteract = function(entity, distance, coords)
                    TriggerServerEvent('qbx_Ab_AlcoolContrebande:server:contrebandeStatecheck')
                    Wait (10)
                        
                    if contrebande_state == 'need_item' then
                        if iswaiting then
                            return true
                        else
                            return false
                        end
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    exports.qbx_core:Notify("J'ai déjà donner l'objet c'était pas à toi?", 'inform', 80000)
                    Wait(500)
                    exports.qbx_core:Notify("Tu as quelque chose d'autre pour moi?", 'inform', 80000)
                    iswaiting = false
                end,
            },
        }

    }

    exports.ox_target:addSphereZone(areaTarget)

-- ANIMATION

    RegisterNetEvent("qbx_Ab_AlcoolContrebande:client:ItemAnimation")
    AddEventHandler("qbx_Ab_AlcoolContrebande:client:ItemAnimation", function()

        PlayAnimation("anim@mp_snowball", "pickup_snowball", -1, 64)
        Wait(1000)
        
    end)