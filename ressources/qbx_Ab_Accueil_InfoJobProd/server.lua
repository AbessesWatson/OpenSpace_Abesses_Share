 
    RegisterServerEvent('qbx_Ab_Accueil_InfoJobProd:server:ProdJobSelected')
    AddEventHandler('qbx_Ab_Accueil_InfoJobProd:server:ProdJobSelected', function(job)
        local src = source

        MySQL.Async.fetchAll('SELECT productivity, last_updated FROM Ab_JobProd WHERE job_id = @job_id', {
            ['@job_id'] = job
        }, function(result)
            if result and #result > 0 then
                local productivity = result[1].productivity or 0.0
                local lastUpdatedTimestamp = result[1].last_updated or 0  -- Récupère le timestamp UNIX

                -- Convertir timestamp en date/heure formatée
                local formattedDate = "Inconnu"
                if lastUpdatedTimestamp > 0 then
                    timestamp = tonumber(lastUpdatedTimestamp) / 1000
                    formattedDate = os.date("%d-%m-%y à %H:%M:%S", timestamp) -- Format : Année-Mois-Jour Heure:Minute:Seconde
                end

                -- Construire le message final

                -- Envoyer au client
                exports.qbx_core:Notify(src, 'La productivité de se poste est de ' ..productivity.. ' \nla dernière évolution a eu lieu le : \n' ..formattedDate, 'inform', 12000)
            else
                exports.qbx_core:Notify(src, "Aucune donnée trouvée, veuillez contacter un superieur", 'inform', 12000)
            end
        end)
    end)
