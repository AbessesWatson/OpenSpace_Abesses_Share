local statereception = 'wait' -- wait / ready

local itemtoreceive = nil 

-- Function 

    function getRandomBoxItem()
        local items = Config.box_item
        local itemKeys = {}

        -- Récupérer les clés des items dans un tableau
        for key, _ in pairs(items) do
            table.insert(itemKeys, key)
        end

        -- Sélectionner une clé aléatoire
        local randomKey = itemKeys[math.random(#itemKeys)]
        
        -- Retourner l'élément correspondant à la clé aléatoire
        return items[randomKey]
    end

    local function startwaiting()
        CreateThread(function()
            -- Vérifie que la plante est en train de pousser (c'est-à-dire l'état est "growing")
            if statereception == 'wait' then
                itemtoreceive = nil
                Wait (Config.durationwait * 60 * 1000)

                itemtoreceive = getRandomBoxItem()

                if itemtoreceive then
                    statereception = 'ready'
                    print ('itemtoreceive = ' ..itemtoreceive)
                end
            end
        end)
    end

-- thread de départ

CreateThread(function()
    -- Vérifie que la plante est en train de pousser (c'est-à-dire l'état est "growing")
    startwaiting()

end)

-- Event 

RegisterNetEvent('qbx_Ab_Pharma:server:delivery')
AddEventHandler('qbx_Ab_Pharma:server:delivery', function(item)
    local src = source

    if statereception == 'ready' then
        exports.ox_inventory:RemoveItem(src, item, 1)
        if item == itemtoreceive then
            statereception = 'wait'
            startwaiting()
            exports.qbx_core:Notify(src, "Vous avez envoyé la bonne boite !", 'error', 10000)

            TriggerClientEvent('qbx_Ab_Pharma:client:deliveryAnimReward', src, true)

        else
            exports.qbx_core:Notify(src, "Vous n'avez pas envoyé la boite attendu !", 'error', 10000)
            TriggerClientEvent('qbx_Ab_Pharma:client:deliveryAnimReward', src, false)
        end
    elseif statereception == 'wait' then
        exports.ox_inventory:RemoveItem(src, item, 1)
        exports.qbx_core:Notify(src, "Aucune boite n'était attendu mais un cadeau reste bienvenue !", 'error', 10000)
        TriggerClientEvent('qbx_Ab_Pharma:client:deliveryAnimReward', src, false)
    else
        print('erreur avec pharma delivery state')
    end

end)

RegisterNetEvent('qbx_Ab_Pharma:server:deliveryCheck')
AddEventHandler('qbx_Ab_Pharma:server:deliveryCheck', function()
    local src = source
    if statereception == 'ready' then
        if itemtoreceive == 'anxiolytique_box' then
            exports.qbx_core:Notify(src, "Un envoi par drône <b>d'une boite d'anxiolytiques</b> est attendu à l'étage du CEO", 'inform', 12000)
        elseif itemtoreceive == 'beta_bloquant_box' then
            exports.qbx_core:Notify(src, "Un envoi par drône <b>d'une boite de bêta-bloquants</b> est attendu à l'étage du CEO", 'inform', 12000)
        elseif itemtoreceive == 'vitamines_box' then
            exports.qbx_core:Notify(src, "Un envoi par drône <b>d'une boite de vitamines</b> est attendu à l'étage du CEO", 'inform', 12000)
        elseif itemtoreceive == 'modafinil_box' then
            exports.qbx_core:Notify(src, "Un envoi par drône <b>d'une boite de modafinils</b> est attendu à l'étage du CEO", 'inform', 12000)
        elseif itemtoreceive == 'medicament_box' then
            exports.qbx_core:Notify(src, "Un envoi par drône <b>d'une boite de médicaments</b> est attendu à l'étage du CEO", 'inform', 12000)
        else
            exports.qbx_core:Notify(src, "Il ya un problème dans les livraison de produit pharmaceutique!", 'error', 10000)
            Wait(100)
            exports.qbx_core:Notify(src, "Veuillez contacter un superieur!", 'error', 10000)
        end
    elseif statereception == 'wait' then
        exports.qbx_core:Notify(src, "Aucun envoie de produit pharmaceutique n'est attendu!", 'inform', 10000)
    else
        exports.qbx_core:Notify(src, "Il ya un problème dans les livraison de produit pharmaceutique!", 'error', 10000)
        Wait(100)
        exports.qbx_core:Notify(src, "Veuillez contacter un superieur!", 'error', 10000)
    end
end)