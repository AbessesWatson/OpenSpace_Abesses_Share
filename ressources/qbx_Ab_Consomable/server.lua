
local function getDirtLvlById(id, cb)
    MySQL.Async.fetchScalar(
        'SELECT DirtLvl FROM Ab_PropToClean WHERE id = ?',
        {id},
        function(dirtlvl)
            if dirtlvl then
                cb(dirtlvl) -- Retourne le niveau de saleté via la fonction de rappel
            else
             print("Dirtlvl non trouvé") 
            end
        end
    )
end

-- EVENT SERVER POUR SE NOURRIR

    -- event pour manger un burger
    RegisterNetEvent('qbx_Ab_Consomable:server:eatburger')
    AddEventHandler('qbx_Ab_Consomable:server:eatburger', function(coords, propName)
        local src = source
        coords = coords
        print (coords)
    
        getDirtLvlById(coords, function(dirtlvl)
            print(coords)
            if dirtlvl < 10 then 
                exports.ox_inventory:RemoveItem(src, "hamburger", 1)
                TriggerEvent('qbx_Ab_CleanWipe:server:sharedUpDirtyTable', coords, propName)
                TriggerClientEvent('qbx_Ab_CafetCraft:client:eatburgerAnimation', src) -- Lance l'animation 
            else
                exports.qbx_core:Notify(src, 'La table est trop sale pour y manger!', 'error', 5000)
            end
        end)

    end)

    -- event pour manger un burger empoisonné
    RegisterNetEvent('qbx_Ab_Consomable:server:eatburgerPoison')
    AddEventHandler('qbx_Ab_Consomable:server:eatburgerPoison', function(coords, propName)
        local src = source
        coords = coords
        print (coords)
    
        getDirtLvlById(coords, function(dirtlvl)
            print(coords)
            if dirtlvl < 10 then 
                exports.ox_inventory:RemoveItem(src, "hamburger", 1)
                TriggerEvent('qbx_Ab_CleanWipe:server:sharedUpDirtyTable', coords, propName)
                TriggerClientEvent('qbx_Ab_CafetCraft:client:eatburgerAnimation', src) -- Lance l'animation 
                TriggerClientEvent('qbx_Ab_SpecialRole:client:poisonActivated', src) -- active l'empoisonement
            else
                exports.qbx_core:Notify(src, 'La table est trop sale pour y manger!', 'error', 5000)
            end
        end)

    end)

    -- event pour manger une salade de tomate
    RegisterNetEvent('qbx_Ab_Consomable:server:eatsaladetomate')
    AddEventHandler('qbx_Ab_Consomable:server:eatsaladetomate', function(coords, propName)
        local src = source
        coords = coords
        print (coords)
    
        getDirtLvlById(coords, function(dirtlvl)
            print(coords)
            if dirtlvl < 10 then 
                exports.ox_inventory:RemoveItem(src, "salade_tomate", 1)
                TriggerEvent('qbx_Ab_CleanWipe:server:sharedUpDirtyTable', coords, propName)
                TriggerClientEvent('qbx_Ab_CafetCraft:client:eatsaladetomateAnimation', src) -- Lance l'animation 
            else
                exports.qbx_core:Notify(src, 'La table est trop sale pour y manger!', 'error', 5000)
            end
        end)

    end)

    -- event pour manger une salade de tomate empoisonné
    RegisterNetEvent('qbx_Ab_Consomable:server:eatsaladetomatePoison')
    AddEventHandler('qbx_Ab_Consomable:server:eatsaladetomatePoison', function(coords, propName)
        local src = source
        coords = coords
        print (coords)
    
        getDirtLvlById(coords, function(dirtlvl)
            print(coords)
            if dirtlvl < 10 then 
                exports.ox_inventory:RemoveItem(src, "salade_tomate", 1)
                TriggerEvent('qbx_Ab_CleanWipe:server:sharedUpDirtyTable', coords, propName)
                TriggerClientEvent('qbx_Ab_CafetCraft:client:eatsaladetomateAnimation', src) -- Lance l'animation
                TriggerClientEvent('qbx_Ab_SpecialRole:client:poisonActivated', src) -- active l'empoisonement
            else
                exports.qbx_core:Notify(src, 'La table est trop sale pour y manger!', 'error', 5000)
            end
        end)

    end)

    -- event pour manger une omelette
    RegisterNetEvent('qbx_Ab_Consomable:server:eatomelette')
    AddEventHandler('qbx_Ab_Consomable:server:eatomelette', function(coords, propName)
        local src = source
        coords = coords
        print (coords)
    
        getDirtLvlById(coords, function(dirtlvl)
            print(coords)
            if dirtlvl < 10 then 
                exports.ox_inventory:RemoveItem(src, "omelette", 1)
                TriggerEvent('qbx_Ab_CleanWipe:server:sharedUpDirtyTable', coords, propName)
                TriggerClientEvent('qbx_Ab_CafetCraft:client:eatomeletteAnimation', src) -- Lance l'animation 
            else
                exports.qbx_core:Notify(src, 'La table est trop sale pour y manger!', 'error', 5000)
            end
        end)

    end)

    -- event pour manger des frites
    RegisterNetEvent('qbx_Ab_Consomable:server:eatfrite')
    AddEventHandler('qbx_Ab_Consomable:server:eatfrite', function(coords, propName)
        local src = source
        coords = coords
        print (coords)
    
        getDirtLvlById(coords, function(dirtlvl)
            print(coords)
            if dirtlvl < 10 then 
                exports.ox_inventory:RemoveItem(src, "frite", 1)
                TriggerEvent('qbx_Ab_CleanWipe:server:sharedUpDirtyTable', coords, propName)
                TriggerClientEvent('qbx_Ab_CafetCraft:client:eatfriteAnimation', src) -- Lance l'animation 
                Wait(4000)
            else
                exports.qbx_core:Notify(src, 'La table est trop sale pour y manger!', 'error', 5000)
            end
        end)
    
    end)

    -- event pour manger un candy
    RegisterNetEvent('qbx_Ab_Consomable:server:eatcandy')
    AddEventHandler('qbx_Ab_Consomable:server:eatcandy', function()
        local src = source
    
        exports.ox_inventory:RemoveItem(src, "jeton", 1)

        TriggerClientEvent('qbx_Ab_CafetCraft:client:eatcandyAnimation', src) -- Lance l'animation 

    end)

    -- event pour manger un pizza
    RegisterNetEvent('qbx_Ab_Consomable:server:eatpizza')
    AddEventHandler('qbx_Ab_Consomable:server:eatpizza', function(coords, propName)
        local src = source
        coords = coords
        print (coords)
    
        getDirtLvlById(coords, function(dirtlvl)
            print(coords)
            if dirtlvl < 10 then 
                exports.ox_inventory:RemoveItem(src, "pizza", 1)
                TriggerEvent('qbx_Ab_CleanWipe:server:sharedUpDirtyTable', coords, propName)
                TriggerClientEvent('qbx_Ab_CafetCraft:client:eatpizzaAnimation', src) -- Lance l'animation 
            else
                exports.qbx_core:Notify(src, 'La table est trop sale pour y manger!', 'error', 5000)
            end
        end)

    end)

-- EVENT ADMIN

    -- event pour recupéré un bonpoint
    RegisterNetEvent('qbx_Ab_Consomable:server:printJeton')
    AddEventHandler('qbx_Ab_Consomable:server:printJeton', function()
        local src = source
    
        exports.ox_inventory:AddItem(src, "jeton", 1)

    end)