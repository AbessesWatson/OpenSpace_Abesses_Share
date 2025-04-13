-- base poison
    -- mettre a jour dans la bdd
    RegisterNetEvent("qbx_Ab_SpecialRole:server:UpdatepoisonLvl")
    AddEventHandler("qbx_Ab_SpecialRole:server:UpdatepoisonLvl", function(poisonlvl)
        local src = source
        local player = exports.qbx_core:GetPlayer(src)

        if not player or not player.PlayerData then
            print("Erreur : impossible de récupérer les données du joueur pour l'ID source : " .. tostring(src))
            return
        end

        local citizenid = player.PlayerData.citizenid

        -- Mise à jour de la fatigue dans la base de données
        MySQL.Async.execute('UPDATE players SET poison = ? WHERE citizenid = ?', {poisonlvl, citizenid}, function(rowsChanged)
            if rowsChanged and rowsChanged > 0 then
                print("poisonlvl mise à jour de : " .. poisonlvl)

            else
                print("Erreur : mise à jour de poisonlvl a échouée")
            end
        end)    

    end)

    -- envoyé depuis la bdd vers le client le poisonlvl
    RegisterNetEvent("qbx_Ab_SpecialRole:server:GetpoisonLvl")
    AddEventHandler("qbx_Ab_SpecialRole:server:GetpoisonLvl", function(citizenid)
        local src = source
        local poisonlvl_get = nil

        if not citizenid then
            print("Erreur : citizenid est invalide.")
        else
            MySQL.Async.fetchScalar('SELECT poison FROM players WHERE citizenid = @citizenid', {
                ['@citizenid'] = citizenid
            }, function(poisonlvl_get)
                print (poisonlvl_get.. " poison lvl reçu")
                TriggerClientEvent('qbx_Ab_SpecialRole:client:updatepoison', src, poisonlvl_get)
            end)
        end

    end)

-- manger 

    -- event pour manger un burger
    RegisterNetEvent('qbx_Ab_SpecialRole:server:eatburgerPoison')
    AddEventHandler('qbx_Ab_SpecialRole:server:eatburgerPoison', function(coords, propName)
        local src = source
        coords = coords
        print (coords)
    
        getDirtLvlById(coords, function(dirtlvl)
            print(coords)
            if dirtlvl < 10 then 
                exports.ox_inventory:RemoveItem(src, "hamburger_poison", 1)
                TriggerEvent('qbx_Ab_CleanWipe:server:sharedUpDirtyTable', coords, propName)
                TriggerClientEvent('qbx_Ab_CafetCraft:client:eatburgerAnimation', src) -- Lance l'animation 
                TriggerClientEvent('qbx_Ab_SpecialRole:client:poisonActivated', src)
            else
                exports.qbx_core:Notify(src, 'La table est trop sale pour y manger!', 'error', 5000)
            end
        end)

    end)

    -- event pour manger une salade de tomate
    RegisterNetEvent('qbx_Ab_SpecialRole:server:eatsaladetomatePoison')
    AddEventHandler('qbx_Ab_SpecialRole:server:eatsaladetomatePoison', function(coords, propName)
        local src = source
        coords = coords
        print (coords)
    
        getDirtLvlById(coords, function(dirtlvl)
            print(coords)
            if dirtlvl < 10 then 
                exports.ox_inventory:RemoveItem(src, "salade_tomate_poison", 1)
                TriggerEvent('qbx_Ab_CleanWipe:server:sharedUpDirtyTable', coords, propName)
                TriggerClientEvent('qbx_Ab_CafetCraft:client:eatsaladetomateAnimation', src) -- Lance l'animation 
                TriggerClientEvent('qbx_Ab_SpecialRole:client:poisonActivated', src)
            else
                exports.qbx_core:Notify(src, 'La table est trop sale pour y manger!', 'error', 5000)
            end
        end)

    end)