-- Event d'action medical
    -- revive
    RegisterNetEvent('qbx_Ab_Medic:server:RevivePlayer', function(target, command)
        local src = source

        TriggerClientEvent('qbx_Ab_Medic:client:RevivePlayer', target, src, command)
        TriggerClientEvent('qbx_Ab_Medic:client:AnimReviveOtherPlayer', src)
        TriggerClientEvent('qbx_Ab_Medic:client:AnimReviveself', target)

    end)
    -- big heal
    RegisterNetEvent('qbx_Ab_Medic:server:useMedKit', function(target)
        local src = source

        print(target.. " pour medkit")
        TriggerClientEvent('qbx_Ab_Medic:client:useMedKit', target, src)
        TriggerClientEvent('qbx_Ab_Medic:client:AnimHealPlayer', src)

    end)
    
    RegisterNetEvent('qbx_Ab_Medic:server:ItemUseMedKit', function()
        local src = source

        exports.ox_inventory:RemoveItem(src, "medical_kit", 1)

    end)
    --small heal
    RegisterNetEvent('qbx_Ab_Medic:server:useBandage', function(target)
        local src = source

        print(target.. " pour bandage")
        TriggerClientEvent('qbx_Ab_Medic:client:useBandage', target, src)
        TriggerClientEvent('qbx_Ab_Medic:client:AnimHealPlayer', src)

    end)

    RegisterNetEvent('qbx_Ab_Medic:server:ItemUseBandage', function(playerSrc)
        local src = source

        exports.ox_inventory:RemoveItem(playerSrc, "bandage", 1)

    end)
    -- check
    RegisterNetEvent('qbx_Ab_Medic:server:checkHealth', function(target, targethealth)
        local src = source
        local checkduration = 4000

        print(target.. " a pour health : " ..targethealth)
        TriggerClientEvent('qbx_Ab_Medic:client:AnimCheck', src, checkduration)

        Wait(checkduration)

        if targethealth == 200 then
            exports.qbx_core:Notify(src, "Cette personne est en pleine santé!", 'inform', 7000)
        elseif targethealth < 200 and targethealth > Config.mini_health_bandage then
            exports.qbx_core:Notify(src, "Cette personne est légèrement blessé!", 'inform', 7000)
        elseif targethealth < Config.mini_health_bandage and targethealth > 0 then
            exports.qbx_core:Notify(src, "Cette personne est blessé!", 'warning', 7000)
        elseif targethealth <= 0 then
            exports.qbx_core:Notify(src, "Cette personne est inconsciente!", 'warning', 7000)
        else
            exports.qbx_core:Notify(src, "Il n'est pas possible de définir l'état de cette personne!", 'error', 7000)
        end
 
    end)

    RegisterNetEvent('qbx_Ab_Medic:server:checkStress', function(target)
        local src = source
        local checkduration = 4000
        local target_stress = exports.qbx_core:GetMetadata(target, 'stress')

        print(target.. " a pour stress : " ..target_stress)
        TriggerClientEvent('qbx_Ab_Medic:client:AnimCheck', src, checkduration)

        Wait(checkduration)

        if  target_stress == 90 or target_stress > 90 then
            exports.qbx_core:Notify(src, "Cette personne a une tension extrêmement élevé!", 'warning', 7000)
        elseif target_stress < 90 and target_stress > 70 then
            exports.qbx_core:Notify(src, "Cette personne a une tension élevé!", 'warning', 7000)
        elseif target_stress < 70 and target_stress > 40 then
            exports.qbx_core:Notify(src, "Cette personne a une tension un peu haute!", 'inform', 7000)
        elseif target_stress < 40 then
            exports.qbx_core:Notify(src, "Cette personne a une tension normale!", 'inform', 7000)
        else
            exports.qbx_core:Notify(src, "Il n'est pas possible de définir la tension de cette personne!", 'error', 7000)
        end
 
    end)


-- // notif part

    RegisterNetEvent('qbx_Ab_Medic:server:notifyNotDead', function(playerSrc)

        exports.qbx_core:Notify(playerSrc, "Cette personne est consciente!", 'error', 7000)

    end)

    RegisterNetEvent('qbx_Ab_Medic:server:notifyNoNeedHeal', function(playerSrc)

        exports.qbx_core:Notify(playerSrc, "Cette personne est déjà en pleine santé!", 'error', 7000)

    end)

    RegisterNetEvent('qbx_Ab_Medic:server:notifyToMuchHeart', function(playerSrc)

        exports.qbx_core:Notify(playerSrc, "Cette personne est trop blessé pour être soigné ainsi!", 'error', 7000)

    end)


-- Pour la save de la raison en sql

    RegisterNetEvent('qbx_Ab_Medic:server:saveReason', function(reason)
        local src = source
        local player = exports.qbx_core:GetPlayer(src)
        local date = os.date('%Y-%m-%d %H:%M:%S')

        local reasontosave = reason

        if player then
            local citizenid = player.PlayerData.citizenid
            local firstname = player.PlayerData.charinfo.firstname
            local lastname = player.PlayerData.charinfo.lastname
            local fullname = firstname.. " " ..lastname

            print ("Citizen ID : " ..citizenid.. " qui s'appel : " ..fullname.. " est tombé inconscient pour cette raison : " ..reasontosave.. " le : " ..date)

            MySQL.Async.execute(
                [[
                    INSERT INTO Ab_MedicLog (citizenid, name, last_coma_reason, date)
                    VALUES (?, ?, ?, ?)
                    ON DUPLICATE KEY UPDATE
                        last_coma_reason = VALUES(last_coma_reason),
                        date = VALUES(date)
                ]], 
                    { citizenid, fullname, reasontosave, date},
                    function()
                        print("MedicLog send pour " ..citizenid)
                    end
            )

        else
            print("Erreur : Le joueur n'a pas été trouvé.")
        end

    end)

    RegisterNetEvent('qbx_Ab_Medic:server:saveReasonIfNew', function()
        local src = source
        local player = exports.qbx_core:GetPlayer(src)
        local date = os.date('%Y-%m-%d %H:%M:%S')
    
        if player then
            local citizenid = player.PlayerData.citizenid
            local firstname = player.PlayerData.charinfo.firstname
            local lastname = player.PlayerData.charinfo.lastname
            local fullname = firstname.. " " ..lastname
            local reason = "Cette personne ne présente aucun antécédent médical."
    
            --print("Vérification de l'existence de Citizen ID :", citizenid)
    
            MySQL.Async.fetchScalar(
                "SELECT COUNT(*) FROM Ab_MedicLog WHERE citizenid = ?", 
                { citizenid },
                function(count)
                    if count == 0 then
                        --print("Ajout du Citizen ID :", citizenid)
    
                        MySQL.Async.execute(
                            "INSERT INTO Ab_MedicLog (citizenid, name, last_coma_reason, date) VALUES (?, ?, ?, ?)",
                            { citizenid, fullname, reason, date },
                            function(rowsChanged)
                                if rowsChanged > 0 then
                                    print("Nouveau MedicLog ajouté pour", citizenid)
                                else
                                    print("Échec de l'ajout du MedicLog pour", citizenid)
                                end
                            end
                        )
                    else
                        --print("Citizen ID :", citizenid, "existe déjà. Aucune insertion au medic logs.")
                    end
                end
            )
        else
            print("Erreur Medlog save: Le joueur n'a pas été trouvé.")
        end
    end)
    

-- COMMANDES

    -- Commande pour réanimer
    RegisterCommand('revive', function(source, args)
        -- Récupère l'ID serveur du joueur cible
        local targetId = tonumber(args[1])
        local src = source

        if not targetId or targetId <= 0 then
            targetId = src -- Si aucun argument, réanime le joueur exécutant la commande
        end

        TriggerClientEvent('qbx_Ab_Medic:client:RevivePlayer', targetId, src, true)
        print (src.. " a réanimé par commande " ..targetId)
    end)

    RegisterCommand('kill', function(source, args)
        -- Récupère l'ID serveur du joueur cible
        local targetId = tonumber(args[1])
        local src = source

        if not targetId or targetId <= 0 then
            targetId = source -- Si aucun argument, tue le joueur exécutant la commande
        end

        TriggerClientEvent('qbx_Ab_Medic:client:KillPlayer', targetId)
        print (src.. " a tuer par commande " ..targetId)
    end)