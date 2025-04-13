local function getJobLabel(jobName)
    for _, job in ipairs(Config.jobs) do
        if job.name == jobName then
            return job.label
        end
    end
    return nil -- Retourne nil si aucun job ne correspond
end

-- EVENT 
    RegisterNetEvent('qbx_Ab_Admin:server:deleteItem', function(item)
        local src = source

        exports.ox_inventory:RemoveItem(src, item, 1)

    end) 

    RegisterNetEvent('qbx_Ab_Admin:server:GetItem', function(item)
        local src = source

        exports.ox_inventory:AddItem(src, item, 1)

    end) 

    RegisterNetEvent('qbx_Ab_Admin:server:setnewjob', function(target , job)
        local src = source
        local joblabel = getJobLabel(job)

        exports.qbx_core:SetJob(target, job, 0)

        exports.qbx_core:Notify(src, 'Le poste de <b>' ..joblabel.. '</b> a été attribué à cette personne', 'inform', 7000)
        exports.qbx_core:Notify(target, 'Vous faites désormais partie des <b>' ..joblabel.. '</b> ', 'inform', 10000)     

    end) 


    -- TRUC POUR LINV


    RegisterNetEvent("qbx_Ab_Admin:server:getPlayerFullName", function(targetId)
        local src = source
        local Player = exports.qbx_core:GetPlayer(targetId) -- Récupère les données du joueur

    
        if Player then
            local firstName = Player.PlayerData.charinfo.firstname
            local lastName = Player.PlayerData.charinfo.lastname
            --print (firstName.. ' ' ..lastName)
            TriggerClientEvent("ox_inventory:receivePlayerFullName", src, targetId, firstName, lastName)
        else
            TriggerClientEvent("ox_inventory:receivePlayerFullName", src, targetId, 'inconnu', '')
        end
    end)
    