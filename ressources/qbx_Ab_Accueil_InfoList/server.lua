RegisterNetEvent('qbx_Ab_Accueil_InfoList:server:CheckJobList', function(job)

    local src = source
    local foundName = {}
    local empty = true

    print ('CheckJobList triggered with ' ..job)

    -- Requête SQL pour récupérer la raison du coma
    MySQL.Async.fetchAll("SELECT citizenid FROM players WHERE JSON_EXTRACT(job, '$.grade.name') = @job", { 
    ['@job'] = job
    }, function(citizenids)
        if citizenids and #citizenids > 0 then
            local pendingQueries = #citizenids -- Pour gérer les requêtes asynchrones

            for _, row in ipairs(citizenids) do
                local citizenid = row.citizenid

                -- Requête SQL pour récupérer la raison du coma
                MySQL.Async.fetchScalar('SELECT charinfo FROM players WHERE citizenid = @citizenid', { 
                    ['@citizenid'] = citizenid

                }, function(charinfo)
                    if charinfo then
                        local resultcharinfo = json.decode(charinfo)
                        local resultFirstName = resultcharinfo.firstname
                        local resultLastName = resultcharinfo.lastname
                        local fullname = resultcharinfo.firstname.. " " ..resultcharinfo.lastname
                        print (fullname.. " a le job " ..job)

                        table.insert(foundName, fullname)
                        empty = false
                            
                    end

                    -- Vérifie si toutes les requêtes sont terminées avant d'envoyer les données
                    pendingQueries = pendingQueries - 1
                    if pendingQueries == 0 then
                        -- Envoi des données au client une fois toutes les requêtes terminées
                        
                        TriggerClientEvent('qbx_Ab_Accueil_InfoList:client:showList', src, foundName, empty)
                    end
                end)
            end
        else
            TriggerClientEvent('qbx_Ab_Accueil_InfoList:client:showList', src, foundName, empty)
        end
    end)
    
end)