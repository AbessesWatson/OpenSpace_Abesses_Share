local OS_Jobs = {
    { job_id = 'menage', productivity = 0 },
    { job_id = 'compta', productivity = 0 },
    { job_id = 'accueil', productivity = 0 },
    { job_id = 'archive', productivity = 0 },
    { job_id = 'cafet', productivity = 0 },
    { job_id = 'it', productivity = 0 },
    { job_id = 'communication', productivity = 0 },
    { job_id = 'infirmerie', productivity = 0 },
}


-- FUNCTION

    -- Initialiser la base de donné
    local function initJobProd()
        
        for _, job in ipairs(OS_Jobs) do
             -- Vérification si job_id est bien présent
            if job.job_id == nil then
                print(" Erreur: job_id est NIL pour un des jobs !")
            end
            
            Wait(20)

            MySQL.Async.execute([[
                INSERT INTO Ab_JobProd (job_id, productivity) 
                VALUES (@job_id, @productivity) 
                ON DUPLICATE KEY UPDATE productivity = productivity
            ]], {
                ['@job_id'] = job.job_id,
                ['@productivity'] = job.productivity
            }, function(rowsChanged)
                if rowsChanged then
                    print("Job " .. job.job_id .. " a sa productivité initialisé")
                else
                    print("Erreur lors de l'initialisation du job " .. job.job_id)
                end
            end)
        end
    end

    -- Fonction pour mettre à jour la productivité d'un joueur
        function SetPlayerProductivity(citizenid, productivityValue)
            MySQL.Async.execute('UPDATE players SET productivity = @productivity WHERE citizenid = @citizenid', {
                ['@productivity'] = productivityValue,
                ['@citizenid'] = citizenid
            }, function(affectedRows)
                if affectedRows > 0 then
                    print("Productivité mise à jour pour le joueur avec CitizenID: " .. citizenid)
                else
                    print("Erreur : La mise à jour a échoué ou le joueur n'a pas été trouvé.")
                end
            end)
        end

        
    -- Fonction pour mettre à jour la productivité d'un job
        function SetJobProductivity(job, productivityValue)

            --print ('SetJobProductivity job : ' ..job.. ' value ' ..productivityValue)
            MySQL.Async.execute('UPDATE Ab_JobProd SET productivity = @productivity WHERE job_id = @job_id', {
                ['@productivity'] = productivityValue,
                ['@job_id'] = job
            }, function(affectedRows)
                if affectedRows > 0 then
                    print("Productivité mise à jour pour le job : " ..job)
                else
                    print("Erreur : La mise à jour a échoué ou le job n'a pas été trouvé.")
                end
            end)
        end

    -- Fonction pour récupérer le joueur avec la plus grande valeur de productivity
        function GetPlayerWithHighestProductivity(callback)
            MySQL.Async.fetchAll(
                [[
                SELECT 
                    JSON_EXTRACT(charinfo, "$.firstname") AS firstname, 
                    JSON_EXTRACT(charinfo, "$.lastname") AS lastname, 
                    productivity 
                FROM 
                    players 
                WHERE 
                    JSON_UNQUOTE(JSON_EXTRACT(job, "$.name")) != "admin"
                ORDER BY 
                    productivity DESC 
                LIMIT 1
                ]],
                {}, 
                function(resulthigh)
                if resulthigh[1] then
                    local player = resulthigh[1]
                    --print (json.encode(player))
                    local namehigh = player.firstname:gsub('"', '') .. " " .. player.lastname:gsub('"', '') -- gsub permet de viré les guillemet en trop dans la base de donné
                    --print("Le joueur le plus productif est: " .. namehigh .. " avec " .. player.productivity .. " de productivité")
                    if callback then
                        callback(namehigh)
                    end
                else
                    print("HighestProductivity Aucun joueur trouvé.")
                    callback(nil)
                end
            end)
        end

    -- Fonction pour récupérer le joueur avec la plus faible valeur de productivity
        function GetPlayerWithLowerProductivity(callback)
            MySQL.Async.fetchAll(
                [[
                SELECT 
                    JSON_EXTRACT(charinfo, "$.firstname") AS firstname, 
                    JSON_EXTRACT(charinfo, "$.lastname") AS lastname, 
                    productivity 
                FROM 
                    players 
                WHERE 
                    JSON_EXTRACT(job, "$.name") != "admin"
                ORDER BY 
                    productivity ASC 
                LIMIT 1
                ]],
                {},
                function(resultlow)
                if resultlow[1] then
                    local player = resultlow[1]
                    local namelow = player.firstname:gsub('"', '') .. " " .. player.lastname:gsub('"', '') -- gsub permet de viré les guillemet en trop dans la base de donné
                    --print("Le joueur le moins productif est: " .. namelow .. " avec " .. player.productivity .. " de productivité")
                    if callback then
                        callback(namelow)
                    end
                else
                    print("LowerProductivity Aucun joueur trouvé.")
                end
            end)
        end

    -- Fonction pour obtenir le job avec la productivité la plus élevée
    function GetJobWithHighestProductivity(callback)
        MySQL.Async.fetchScalar('SELECT job_id FROM Ab_JobProd ORDER BY productivity DESC LIMIT 1', {}, function(job_id)
            if job_id then
                --print("Le job avec la productivité la plus élevée est : " .. job_id)
                local job_name = 'Poste Inconnu'

                if job_id == 'menage' then
                    job_name = 'Exécutant.e Sanitaires'
                elseif job_id == 'compta' then
                    job_name = 'Conservateur.ice budgétaires'
                elseif job_id == 'accueil' then
                    job_name = 'Coordinateur.rice Fonctionnel'
                elseif job_id == 'archive' then
                    job_name = 'Garant.e de consignations et dépôts'
                elseif job_id == 'cafet' then
                    job_name = 'Artisant.e Culinaires'
                elseif job_id == 'it' then
                    job_name = 'Chargé.e de télégestion'
                elseif job_id == 'communication' then
                    job_name = 'Auxiliaire transmitionnel'
                elseif job_id == 'infirmerie' then
                    job_name = 'Agent.e thérapeutique'
                end
                    
                if callback then
                    callback(job_name)
                end
            else
                print("Aucun job trouvé.")
            end
        end)
    end

    -- Fonction pour lire la productivité d'un joueur
        function ViewPlayerProductivity(citizenid, callback)
            MySQL.Async.fetchScalar('SELECT productivity FROM players WHERE citizenid = @citizenid', {
                ['@citizenid'] = citizenid
            }, function(productivity)
                if callback then
                    callback(productivity)
                end
            end)
        end

    -- Fonction pour ajouter de la productivité a un joueur
        function AddPlayerProductivity(value, src)
            src = src or source
            local player = exports.qbx_core:GetPlayer(src)
            local value = value

            if player then
                local citizenid = player.PlayerData.citizenid
                MySQL.Async.fetchScalar('SELECT productivity FROM players WHERE citizenid = @citizenid', {
                    ['@citizenid'] = citizenid
                }, function(Productivity)
                    if Productivity then
                        -- Incrémenter la productivité de [value]
                        local newProductivity = Productivity + value
                        SetPlayerProductivity(citizenid, newProductivity)
                        TriggerClientEvent('qbx_Ab_Productivity:Client:productivityToNotify', src, newProductivity)
                        --print("La productivité du joueur " ..citizenid.. " a été augmentée de "..value.. " elle est maintenant de " .. newProductivity)
                    else
                        print("Erreur : Impossible de lire la productivité actuelle pour le joueur.")
                    end
                end)
            else
                print("Erreur : Le joueur n'a pas été trouvé.")
            end
        end

    -- Fonction pour ajouter de la productivité a un job
    function AddJobProductivity(job, value)

        local addvalue = value

        --print(' AddJobProductivity ' ..job)

        MySQL.Async.fetchScalar('SELECT productivity FROM Ab_JobProd WHERE job_id = @job_id', {
            ['@job_id'] = job
        }, function(Productivity)
            if Productivity then
                -- Incrémenter la productivité de [addvalue]
                local newProductivity = Productivity + addvalue
                Wait(10)
                SetJobProductivity(job, newProductivity)
                --print("La productivité du job " ..job.. " a été augmentée de "..addvalue.. " elle est maintenant de " .. newProductivity)
            else
                print("Erreur : Impossible de lire la productivité actuelle pour le job.")
            end
        end)

    end    



-- Commande console //////////////////

    -- Definir la productivité
    RegisterCommand('setproductivity', function(source, args, rawCommand)
        local src = source
        local player = exports.qbx_core:GetPlayer(src)

        if player then
            local citizenid = player.PlayerData.citizenid
            local newProductivity = args[1] or 'default_value' -- Récupérer la valeur de productivité depuis les arguments de la commande
            SetPlayerProductivity(citizenid, newProductivity)
            --print(newProductivity.." de productivité a été défini au joueur")
        else
            print("Erreur : Le joueur n'a pas été trouvé.")
        end
    end, false)

    -- lire la productivité
    RegisterCommand('viewproductivity', function(source, args, rawCommand)
        local src = tonumber(args[1]) or source
        local player = exports.qbx_core:GetPlayer(src)

        if player then
            local citizenid = player.PlayerData.citizenid
            ViewPlayerProductivity(citizenid, function(productivity)
                local roundedvalue = math.floor(productivity * 10 + 0.5) / 10 
                exports.qbx_core:Notify(source, 'Cette personne à ' ..roundedvalue.. ' de productivité', notifyType, 8000)
            end)
        else
            print("Erreur : Le joueur n'a pas été trouvé.")
        end
    end, false)


    -- Commande pour ajouter la productivité
    RegisterCommand('addproductivity', function(source, args, rawCommand)
        local src = tonumber(args[1])


        local value = tonumber(args[2]) or 1 -- Récupérer la valeur de productivité depuis les arguments de la commande
        AddPlayerProductivity(value, src)

    end, false)

    RegisterCommand('GetPlayerWithHighestProductivity',function(source, args, rawCommand)
        GetPlayerWithHighestProductivity()
    end,false)


    RegisterCommand('GetPlayerWithLowerProductivity',function(source, args, rawCommand)
        GetPlayerWithLowerProductivity()
    end,false)

-- Événement serveur //////////////////

    AddEventHandler('onResourceStart', function(resourceName)
        if (GetCurrentResourceName() ~= resourceName) then
            return
        end
        initJobProd()
    end)

    -- Événement serveur pour montrer le tableau de productivité
        RegisterNetEvent('server:viewproductivity')
        AddEventHandler('server:viewproductivity', function()
            local src = source
            local player = exports.qbx_core:GetPlayer(src)

            if player then
                local name = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
                local citizenid = player.PlayerData.citizenid
                ViewPlayerProductivity(citizenid, function(productivity)
                    GetPlayerWithHighestProductivity(function(namehigh)
                        --print (namehigh .. ' high')
                        GetPlayerWithLowerProductivity(function(namelow)
                            --print (namelow .. ' low')
                            GetJobWithHighestProductivity(function(highjob)
                                TriggerClientEvent('client:showProductivityUI', src, name, productivity, namehigh, namelow, highjob)
                            end)
                        end)
                    end)
                end)

                --TriggerClientEvent('client:showProductivityUI', src, name, productivity, namehigh, namelow)
            else
                print("Erreur : les données du joueur ne sont pas accessibles.")
            end
        end)

    -- pour initialisé la prod coté client
    RegisterNetEvent('qbx_Ab_Productivity:server:initProdClient')
    AddEventHandler('qbx_Ab_Productivity:server:initProdClient', function(citizenid)
        local src = source
        local player = exports.qbx_core:GetPlayer(src)

        if player then
            ViewPlayerProductivity(citizenid, function(productivity)
                local prodvalue = tonumber(productivity)
                TriggerClientEvent('qbx_Ab_Productivity:client:initProd', src, prodvalue)
            end)
        else
            print("Erreur initProdClient: les données du joueur ne sont pas accessibles.")
        end
    end)        

