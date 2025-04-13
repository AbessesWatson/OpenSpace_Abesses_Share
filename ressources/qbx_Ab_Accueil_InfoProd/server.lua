-- Fonction pour arrondir à une décimale
function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Event pour check ordi

    RegisterNetEvent ('qbx_Ab_Accueil_InfoProd:server:CheckProductivity', function(firstname, lastname)
        local src = source
        local firstname = firstname
        local lastname = lastname
        local fullname = firstname.. " " ..lastname

        MySQL.Async.fetchAll('SELECT citizenid, charinfo FROM players', {}, function(result)
            if result and #result > 0 then
                for _, row in ipairs(result) do
                    local charinfo = json.decode(row.charinfo)  -- Décodage du JSON dans charinfo
                    if charinfo.firstname == firstname and charinfo.lastname == lastname then
                        found = true
                        --print("Citizen ID trouvé : " .. row.citizenid)

                        local citizenid = row.citizenid
                    
                        -- Requête SQL pour récupérer la raison du coma
                        MySQL.Async.fetchScalar('SELECT productivity FROM players WHERE citizenid = @citizenid', { 
                            ['@citizenid'] = citizenid
                        }, function(resultProd)
                            if resultProd then
                                local roundedReason = round(resultProd, 1)
                                exports.qbx_core:Notify(src, fullname.. " a pour producitivité : " ..roundedReason, 'inform', 12000)
                            end
                        end)
                        
                        break  -- On s'arrête dès qu'on trouve le premier match
                    end
                end
            end

            if not found then
                exports.qbx_core:Notify(src, "Informations indisponibles ou Prénom&Nom erronés", 'error', 7000)
            end
            
        end)

    end)

    RegisterNetEvent ('qbx_Ab_Accueil_InfoProd:server:CheckJob', function(firstname, lastname)
        local src = source
        local firstname = firstname
        local lastname = lastname
        local fullname = firstname.. " " ..lastname
        local found = false

        MySQL.Async.fetchAll('SELECT citizenid, charinfo FROM players', {}, function(result)
            if result and #result > 0 then
                for _, row in ipairs(result) do
                    local charinfo = json.decode(row.charinfo)  -- Décodage du JSON dans charinfo
                    if charinfo.firstname == firstname and charinfo.lastname == lastname then
                        found = true
                        --print("Citizen ID trouvé : " .. row.citizenid)

                        local citizenid = row.citizenid
                    
                        -- Requête SQL pour récupérer la raison du coma
                        MySQL.Async.fetchScalar('SELECT job FROM players WHERE citizenid = @citizenid', { 
                            ['@citizenid'] = citizenid
                        }, function(resultJob)
                            if resultJob then
                                local jobData = json.decode(resultJob)
                                local resultJobName = jobData.grade.name
                                exports.qbx_core:Notify(src, "Le poste de " ..fullname.. " est : " ..resultJobName, 'inform', 12000)
                            end
                        end)
                        
                        break  -- On s'arrête dès qu'on trouve le premier match
                    end
                end
            end

            if not found then
                exports.qbx_core:Notify(src, "Informations indisponibles ou Prénom&Nom erronés", 'error', 7000)
            end

        end)

    end)

-- Event pour check personnage

    -- check name
    RegisterNetEvent('qbx_Ab_Accueil_InfoProd:server:CheckName', function(target)
        local src = source
        local targetPlayer = exports.qbx_core:GetPlayer(target)
        local firstname = targetPlayer.PlayerData.charinfo.firstname
        local lastname = targetPlayer.PlayerData.charinfo.lastname
        local fullname = firstname.. " " ..lastname


        TriggerClientEvent('qbx_Ab_Accueil_InfoProd:client:CheckNameAnim', src, fullname)
 
    end)

    -- check job
    RegisterNetEvent('qbx_Ab_Accueil_InfoProd:server:CheckJobPlayer', function(target)
        local src = source
        local targetPlayer = exports.qbx_core:GetPlayer(target)
        local job = targetPlayer.PlayerData.job.grade.name

        TriggerClientEvent('qbx_Ab_Accueil_InfoProd:client:CheckJobAnim', src, job)
     
    end)