math.randomseed(GetGameTimer()) -- Réinitialise la graine du générateur

local allowsearch = true

receiptdocstash = {
    id = 'doc_receipt',
    label = 'Document à trier',
    slots = Config.receiptslots,
    weight = 0, 

}

function RandomizeNumber(max)
    local randomNumber = math.random(1, max)
    return randomNumber
end

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
        exports.ox_inventory:RegisterStash(receiptdocstash.id, receiptdocstash.label, receiptdocstash.slots, receiptdocstash.weight)
    end
end)

-- FOUILLE DANS LES ARCHIVES
    RegisterNetEvent('qbx_Ab_Archive_base:server:searchArchive')
    AddEventHandler('qbx_Ab_Archive_base:server:searchArchive', function()
        local src = source
        local probakind = math.random(1, 10)
        local loot = nil
        if allowsearch then
            print ('searchArchive activated with proba ' ..probakind)
            if probakind < 4 then
                loot = Config.gooddoc_wh[math.random(#Config.gooddoc_wh)]
                exports.ox_inventory:AddItem(src, loot, 1)
            else
                loot = Config.baddoc_wh[math.random(#Config.baddoc_wh)]
                exports.ox_inventory:AddItem(src, loot, 1)
            end
        else
            exports.qbx_core:Notify(src, "Il est trop tard pour fouiller!", "error", 10000)
        end
    end)

-- TRI DES ARCHIVES 

    -- Ajout au stash de récéption
    RegisterNetEvent("qbx_Ab_Archive_base:server:addDocToStash", function(dockind)
        local src = source

        local stashId = "doc_receipt" -- Stash fixe
        itemkind = dockind

        if itemkind == "it" then
            itemName = Config.it_doc
        elseif itemkind == "cafet" then
            itemName = Config.cafet_doc
        elseif itemkind == "archive" then
            itemName = Config.archive_doc
        elseif itemkind == "menage" then
            itemName = Config.menage_doc
        elseif itemkind == "compta" then
            itemName = Config.compta_doc
        elseif itemkind == "accueil" then
            itemName = Config.accueil_doc
        elseif itemkind == "communication" then
            itemName = Config.communication_doc
        elseif itemkind == "infirmerie" then
            itemName = Config.infirmerie_doc
        else
            print ("Erreur de définition d'item kind")
        end

        -- Validation des données
        if itemkind then
            local success = exports.ox_inventory:AddItem(stashId, itemName, 1)
            if success then
                
            else
                exports.qbx_core:Notify(src, "Impossible de déliverer un document aux Garant.es de consignations et dépots", "error", 10000)
            end
        end
    end)

    RegisterNetEvent("qbx_Ab_Archive_base:server:addRandomDoc", function()
        local docNumber = RandomizeNumber(8)
        local itemnumber = docNumber

        if itemnumber == 1 then
            itemKind = "it"
        elseif itemnumber == 2 then
            itemKind = "cafet"
        elseif itemnumber == 3 then
            itemKind = "archive"
        elseif itemnumber == 4 then
            itemKind = "menage"
        elseif itemnumber == 5 then
            itemKind = "compta"
        elseif itemnumber == 6 then
            itemKind = "accueil"
        elseif itemnumber == 7 then
            itemKind = "communication"
        elseif itemnumber == 8 then
            itemKind = "infirmerie"
        else
            print ("Erreur de définition d'item kind", itemKind)
        end

        TriggerEvent("qbx_Ab_Archive_base:server:addDocToStash", itemKind)
        
    end)

    RegisterNetEvent("qbx_Ab_Archive_base:server:placedoc", function(docneed, dockind, item)
        local src = source

        exports.ox_inventory:RemoveItem(src, item, 1)
        print ('kind : ' ..dockind.. " need : " ..docneed)

        if dockind == docneed then
            exports.qbx_core:Notify(src, "Ce document à était déposé au bon endroit.", "success", 7000)
            TriggerEvent('server:addProductivity', Config.upprod, src) -- Augmente la productivité
            TriggerEvent('server:addJobProductivity', Config.jobtoprod, Config.upprod) -- Augmente la productivité du job
            TriggerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue',Config.upfatigue, src) -- augmente la fatigue 
        else
            exports.qbx_core:Notify(src, "Ce document à était déposé au mauvais endroit.", "error", 7000)
            TriggerEvent('hud:server:GainStress',Config.upstress, src) -- Augmente le stress 
            TriggerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue',Config.upfatigue, src) -- augmente la fatigue 
        end

    end)

    

-- commande allow search    
    RegisterCommand("toggleallowsearch", function()
        allowsearch = not allowsearch -- Inverse la valeur (true <-> false)
        local state = allowsearch and "activé" or "désactivé"
        print("allowsearch est maintenant " .. state) -- Affiche dans la console
    end, false)