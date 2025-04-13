-- PARTIE PLANTE
    local plantstate = 'needW'

    RegisterNetEvent('qbx_Ab_Weed:server:PlantStatecheck')
    AddEventHandler('qbx_Ab_Weed:server:PlantStatecheck', function()
        local src = source
        TriggerClientEvent("qbx_Ab_Weed:client:PlantState", src, plantstate)

    end)

    -- Fonction pour démarrer le thread lorsque la plante devient "growing"
    local function startGrowingThread()
        CreateThread(function()
            -- Vérifie que la plante est en train de pousser (c'est-à-dire l'état est "growing")
            while plantstate == 'growing' do
                print("growing start")
                Wait(Config.plantgrow_time)  -- Attends le temps de pousse

                -- Une fois que le temps est écoulé, la plante est prête
                plantstate = 'ready'
                print("La plante est maintenant : " .. plantstate)

            end
        end)
    end


    -- event pour arroser
    RegisterNetEvent('qbx_Ab_Weed:server:waterPlant')
    AddEventHandler('qbx_Ab_Weed:server:waterPlant', function(item)
        local src = source

        exports.ox_inventory:RemoveItem(src, item, 1)
        plantstate = 'growing'

        if  item == Config.wateritem_menage then
            exports.ox_inventory:AddItem(src, 'bucket', 1)
        end
        if  item == Config.wateritem_classic then
            exports.ox_inventory:AddItem(src, Config.wateritem_classic_empty, 1)
        end

        TriggerClientEvent('qbx_Ab_Weed:client:waterPlantAnimation', src) -- Lance l'animation

        -- Démarrer le thread uniquement lorsque l'état est 'growing'
        startGrowingThread() 

    end)

    -- event pour récolter
    RegisterNetEvent('qbx_Ab_Weed:server:harvestPlant')
    AddEventHandler('qbx_Ab_Weed:server:harvestPlant', function()
        local src = source

        exports.ox_inventory:AddItem(src, Config.harvesteditem, 4)
        plantstate = 'needW'

        TriggerClientEvent('qbx_Ab_Weed:client:harvestPlantAnimation', src) -- Lance l'animation 

    end)

    -- event pour checker la plant
    RegisterNetEvent('qbx_Ab_Weed:server:checkPlant')
    AddEventHandler('qbx_Ab_Weed:server:checkPlant', function()
        local src = source
        local durationotif = 6000

        if plantstate == 'needW' then
            exports.qbx_core:Notify(src, "La plante à besoin d'eau", 'inform', durationotif)
        elseif plantstate == 'growing' then 
            exports.qbx_core:Notify(src, "La plante est en train de pousser", 'inform', durationotif)
        elseif plantstate == 'ready' then 
            exports.qbx_core:Notify(src, "La plante est prête à être récolter", 'success', durationotif)
        else
            exports.qbx_core:Notify(src, "La plante a un problème", 'error', 10000, "Veuillez avertir son propriétaire!")
        end

    end)

-- FAIRE DES JOINS

    RegisterNetEvent('qbx_Ab_Weed:craftJoin', function(slot)
        local src = source
        -- Vérifie si l'utilisateur a les items nécessaires
        local paperhere = exports.ox_inventory:GetItemCount(src, "os_rollpaper")
        local weedhere = exports.ox_inventory:GetItemCount(src, "os_weed")
        local cighere = exports.ox_inventory:GetItemCount(src, "cigarette")
        local duration = 8000
        
        if paperhere > 0 and weedhere > 0 and cighere > 0 then
            -- Retirer un papier à rouler et une weed
            exports.ox_inventory:RemoveItem(src, "os_rollpaper", 1)
            exports.ox_inventory:RemoveItem(src, "os_weed", 1)
            exports.ox_inventory:RemoveItem(src, "cigarette", 1)
            -- Ajouter un joint
            exports.ox_inventory:AddItem(src, "os_joint", 3)
            TriggerClientEvent('qbx_core:Notify', src, "Tu as roulé un joint !", 'success', duration)
        else
            TriggerClientEvent('qbx_core:Notify', src, "Il te manque des éléments pour rouler un joint", 'error', 8000)
        end
    end)

    

-- ouvrir paquet de cig

    RegisterNetEvent('qbx_Ab_Weed:openCigPack', function(slot)
        local src = source

        exports.ox_inventory:RemoveItem(src, "cig_pack", 1)
        exports.ox_inventory:AddItem(src, "cigarette", 20)

    end)

-- Prendre un cigare

    RegisterNetEvent('qbx_Ab_Weed:server:TakeCigare', function()
        local src = source

        exports.ox_inventory:AddItem(src, Config.item_cigare, 1)

    end)

-- PARTIE POUR L'arrosoir

    RegisterNetEvent('qbx_Ab_Weed:Server:full_can')
    AddEventHandler('qbx_Ab_Weed:Server:full_can', function()
        local src = source

        local allowfill = exports.ox_inventory:CanCarryItem(src, Config.wateritem_classic, 1)

        if allowfill then

            exports.ox_inventory:RemoveItem(src, Config.wateritem_classic_empty, 1)
            exports.ox_inventory:AddItem(src, Config.wateritem_classic, 1)
            TriggerClientEvent('qbx_Ab_Weed:Client:full_canAnim', src)

        else
            exports.qbx_core:Notify(src, "Un arrosoir rempli d'eau serait trop lourd à porter", 'error', 7000)
        end

    end)

    RegisterNetEvent('qbx_Ab_Weed:Server:empty_can')
    AddEventHandler('qbx_Ab_Weed:Server:empty_can', function()
        local src = source

        exports.ox_inventory:RemoveItem(src, Config.wateritem_classic, 1)
        exports.ox_inventory:AddItem(src, Config.wateritem_classic_empty, 1)
        TriggerClientEvent('qbx_Ab_Weed:Client:empty_canAnim', src)

    end)

