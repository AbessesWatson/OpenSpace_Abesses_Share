RegisterNetEvent ('qbx_Ab_Medic_readlog:server:CheckComaReason', function(firstname, lastname)
    local src = source
    local firstname = firstname
    local lastname = lastname
    local fullname = firstname.. " " ..lastname

    print (fullname.. " reçu pour sql")

    -- Requête SQL pour récupérer la raison du coma
    MySQL.Async.fetchScalar('SELECT last_coma_reason FROM Ab_MedicLog WHERE name = @name', { 
        ['@name'] = fullname
    }, function(resultReason)
        if resultReason then
            local comaReason = (json.encode(resultReason))

            -- Requête SQL pour récupérer la date du dernier coma
            MySQL.Async.fetchScalar('SELECT date FROM Ab_MedicLog WHERE name = @name', { 
                ['@name'] = fullname
            }, function(ResultDate)
                if ResultDate then
                    local timestamp = tonumber(ResultDate) / 1000 -- Diviser par 1000 pour passer en secondes
                    local comaDate = os.date("%Y-%m-%d %H:%M:%S", timestamp) -- Format : Année-Mois-Jour Heure:Minute:Seconde

                    exports.qbx_core:Notify(src, "Raison HRP du Coma:", 'inform', 12000, fullname.. ' : ' ..comaReason.. '. Date et heure: ' ..comaDate)
                else 
                    print("resultReason and ResultDate C NON")
                end
            end)

        else
            -- Si aucune donnée n'est trouvée, informez le client
            exports.qbx_core:Notify(src, "Informations indisponibles ou Prénom&Nom erronés", 'error', 7000)
        end
    end)

end)