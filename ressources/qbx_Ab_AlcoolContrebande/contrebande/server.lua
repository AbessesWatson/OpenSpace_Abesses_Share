local contrebande_state = 'need_item'
local item_to_recive = nil

-- envoie la maj coté client
RegisterNetEvent('qbx_Ab_AlcoolContrebande:server:contrebandeStatecheck')
AddEventHandler('qbx_Ab_AlcoolContrebande:server:contrebandeStatecheck', function()
    local src = source
    TriggerClientEvent("qbx_Ab_AlcoolContrebande:client:contrebandeState", src, contrebande_state)

end)

    -- Fonction pour démarrer le thread lorsque la porte de parking est active 
    local function startParkingCBThread()
        CreateThread(function()
            
            while contrebande_state == 'waiting' do
                print("waiting parking start")
                Wait(Config.parkingWait_time)  -- Attends le temps de prossess

                -- Une fois que le temps est écoulé, l'état change pour récéption
                contrebande_state = 'ready'
                print("Le parking est maintenant : " .. contrebande_state)

            end
        end)
    end

        -- event pour arroser
        RegisterNetEvent('qbx_Ab_AlcoolContrebande:server:giveItem')
        AddEventHandler('qbx_Ab_AlcoolContrebande:server:giveItem', function(item, itemReceived)
            local src = source
    
            exports.ox_inventory:RemoveItem(src, item, 1)
            contrebande_state = 'waiting'
            item_to_recive = itemReceived
    
    
            TriggerClientEvent('qbx_Ab_AlcoolContrebande:client:ItemAnimation', src) -- Lance l'animation
    
            -- Démarrer le thread uniquement lorsque l'état est 'waiting'
            exports.qbx_core:Notify(src, "Reviens dans un quart d'heure j'aurai quelque chose pour toi!", 'success', 10000)
            startParkingCBThread() 
    
        end)
    
        -- event pour récolter
        RegisterNetEvent('qbx_Ab_AlcoolContrebande:server:getItem')
        AddEventHandler('qbx_Ab_AlcoolContrebande:server:getItem', function()
            local src = source
    
            local allowGetItem = exports.ox_inventory:CanCarryItem(src, item_to_recive, 1)

            if allowGetItem then
                exports.ox_inventory:AddItem(src, item_to_recive, 1)
                contrebande_state = 'need_item'
                item_to_recive = nil
        
                TriggerClientEvent('qbx_Ab_AlcoolContrebande:client:ItemAnimation', src) -- Lance l'animation
            else
                exports.qbx_core:Notify(src, "Vous n'avez pas la place pour recevoir l'objet", 'error', 8000)
            end
    
        end)
    
        -- event pour checker la plant
        RegisterNetEvent('qbx_Ab_AlcoolContrebande:server:checkParking')
        AddEventHandler('qbx_Ab_AlcoolContrebande:server:checkParking', function()
            local src = source
            local durationotif = 8000
    
            if contrebande_state == 'need_item' then
                --print ('isok')
            elseif contrebande_state == 'waiting' then 
                exports.qbx_core:Notify(src, "Reviens plus tard!", 'inform', durationotif)
            elseif contrebande_state == 'ready' then 
                exports.qbx_core:Notify(src, "J'ai quelque chose pour toi!", 'success', durationotif)
            else
                exports.qbx_core:Notify(src, "Il y a un problème!", 'error', 10000)
            end
    
        end)