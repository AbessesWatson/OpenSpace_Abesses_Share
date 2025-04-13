-- //// FUNCTION
    local function PlayAnimation(dict, name, duration,flag)
        local playerPed = PlayerPedId()

        -- Charger le dictionnaire d'animation
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(100)
        end

        -- Jouer l'animation
        TaskPlayAnim(playerPed, dict, name, 1.0, 1.0, duration, flag, 0, false, false, false)

        -- Attendre la durée de l'animation
        Wait(duration)

        -- Arrêter l'animation
        ClearPedTasks(playerPed)
        RemoveAnimDict(animdict)
    end

    function ReviveAndHealPlayer(src, playerPed)
        -- Vérifie si le ped existe
        if DoesEntityExist(playerPed) then
            print('playerPed: ' .. playerPed)

            -- Réinitialiser la santé et les états du joueur
            SetEntityMaxHealth(playerPed, 200)
            SetEntityHealth(playerPed, 200)
            ClearPedBloodDamage(playerPed)
            ResetPedMovementClipset(playerPed, 0.0)

            -- Gestion spécifique pour les admins
            local playerjob = QBX.PlayerData.job.name

            if playerjob == 'admin' then
                TriggerServerEvent('hud:server:RelieveStress', 100) 
                TriggerServerEvent('consumables:server:addThirst', 80) 
                TriggerServerEvent('consumables:server:addHunger', 80)
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', -100)
                print("Pour l'Admin : stress réduit de 20, soif et faim remontés de 20, fatigue réduite de 100")
            else
                TriggerServerEvent('consumables:server:addThirst', 20) 
                TriggerServerEvent('consumables:server:addHunger', 20)
            end

            -- autre trigger pour tous
            TriggerEvent ('qbx_Ab_AlcoolContrebande:client:setDrunk', 0)

            -- Supprime l'animation de mort si active
            if IsPedDeadOrDying(playerPed, true) then
                --ResurrectPed(playerPed) -- Fait revivre le ped s'il est mort
                local playerPed = PlayerPedId()

                local playerCoords = GetEntityCoords(playerPed)
                local playerHeading = GetEntityHeading(playerPed)
                SetEntityInvincible(playerPed, false)            
                NetworkResurrectLocalPlayer(playerCoords.x, playerCoords.y, playerCoords.z, playerHeading, false, false)
            end

            -- Réanimer le joueur et le remettre debout
            local coords = GetEntityCoords(playerPed)
            SetEntityCoords(playerPed, coords.x, coords.y, coords.z, true, false, false, false)

            

        else
            print("Erreur : Le joueur ciblé n'existe pas.")
        end
    end

    function FullHealPlayer (playerPedid, playerCurrentHealth, playerMaxHealth)
        if DoesEntityExist(playerPedid) then

            if IsPedDeadOrDying(playerPedid, true) then
                print ("Inconscient: Il faut d'abord réanimer")
            else
                print('playerPed: ' .. playerPedid.. ' avait en hp: ' ..playerCurrentHealth)

                SetEntityHealth(playerPedid, playerMaxHealth)
                ClearPedBloodDamage(playerPedid)

                print('playerPed: ' .. playerPedid.. ' a en hp: ' ..playerMaxHealth)
            end
        else
            print("Erreur : Le joueur ciblé n'existe pas.")
        end
    end

    function SmallHealPlayer (playerPedid, playerCurrentHealth, playerMaxHealth)
        if DoesEntityExist(playerPedid) then

            if IsPedDeadOrDying(playerPedid, true) then
                print ("Inconscient: Il faut d'abord réanimer")
            else
                print('playerPed: ' .. playerPedid.. ' avait en hp: ' ..playerCurrentHealth)

                local HealthToAdd = Config.small_heal
                print ('HealthToAdd : ' ..HealthToAdd)
                local playerNewHealth = playerCurrentHealth + HealthToAdd
                print ('playerNewHealth : ' ..playerNewHealth)
                local playerFinalHealth = nil

                Wait(10)

                if playerNewHealth > playerMaxHealth then 
                    SetEntityHealth(playerPedid, playerMaxHealth)
                    playerFinalHealth = GetEntityHealth(playerPedid)
                else
                    SetEntityHealth(playerPedid, playerNewHealth)
                    playerFinalHealth = GetEntityHealth(playerPedid)
                end
                ClearPedBloodDamage(playerPedid)

                Wait(10)
                print('playerPed: ' .. playerPedid.. ' a en hp: ' ..playerFinalHealth)
            end
        else
            print("Erreur : Le joueur ciblé n'existe pas.")
        end
    end





-- THREAD POUR INCONSCIENT

    local isDead = false
    local nuiActive = false

    -- Crée un thread pour surveiller l'état du joueur
    CreateThread(function()
        while true do
            Wait(50) -- Vérification toutes les 500 ms pour éviter d'impacter les performances
            
            local playerPed = PlayerPedId()
            local playerindex = PlayerId()
            local playerServerId = GetPlayerServerId(playerindex)

            -- Vérifie si le joueur est mort ou inconscient
            if IsPedDeadOrDying(playerPed, true) and not isDead then
                isDead = true

                -- Appliquer l'écran opaque et afficher le message
                StartScreenEffect("DeathFailOut", 0, true)

                -- On set isDead a true
                LocalPlayer.state:set( "isDead", true, true )

                -- On active le mute micro
                TriggerServerEvent( 'UI:Server:SetMute', playerServerId, true )

                if Config.office_ui then
                        ---@return { inputs: string[], isCancel: boolean }
                        local Result = exports["office_ui"]:DisplayPrompt({
                            title = "Inconscient",
                            items = {
                                {
                                    type = "textarea",
                                    title = "Expliquez en HRP pourquoi vous êtes inconscient",
                                    placeholder = "Entrez votre raison ici...",
                                    required = true
                                }
                            }
                        } )

                        local Raison = Result[1] or "Les données n'ont pas été entrées"

                        print("Raison de l'inconscience : " .. Raison) -- Traite la raison côté client
                        TriggerServerEvent('qbx_Ab_Medic:server:saveReason', Raison) -- Envoie la raison au serveur
                else
                    -- Active l'interface NUI pour saisir la raison
                    SetNuiFocus(true, true)
                    nuiActive = true
                    SendNUIMessage({
                        type = "open"
                    })
                end
            elseif not IsPedDeadOrDying(playerPed, true) and isDead then

                -- Si le joueur revient à la vie, désactive les effets
                isDead = false
                StopScreenEffect("DeathFailOut")

                -- On set isDead a false
                LocalPlayer.state:set( "isDead", false, true )

                -- on désactive le mute micro
                TriggerServerEvent( 'UI:Server:SetMute', playerServerId, false )
                if Config.office_ui then

                else
                    if nuiActive then
                        -- Ferme l'interface NUI s'il est ouvert
                        SetNuiFocus(false, false)
                        nuiActive = false
                        SendNUIMessage({
                            type = "close"
                        })
                    end
                end
            end
            
        end
    end)

    -- NUI Callback pour gérer l'envoi des données
    RegisterNUICallback('submitReason', function(data, cb)
        print("Raison de l'inconscience : " .. data.reason) -- Traite la raison côté client
        TriggerServerEvent('qbx_Ab_Medic:server:saveReason', data.reason) -- Envoie la raison au serveur
        cb('ok')

        -- Fermer la fenêtre NUI
        SetNuiFocus(false, false)
        nuiActive = false
        SendNUIMessage({
            type = "close"
        })
    end)

-- THREAD POUR ANNULER LA REGEN et autre parametre 

-- Désactiver la régénération automatique de la vie
    Citizen.CreateThread(function()
        while true do
            playerPed = PlayerPedId()
            -- Désactiver la régénération automatique de la vie
            SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
            SetEntityMaxHealth(playerPed, 200)

            -- Permet de contrôler la fréquence de vérification (en millisecondes)
            Citizen.Wait(100)
        end
    end)

-- THREAD DE LANCEMENT POUR SAVE LE MEDLOGS

    Citizen.CreateThread(function()
        while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
            Wait(100)
            --print("En attente des données du joueur (citizenid)...")
        end

        TriggerServerEvent('qbx_Ab_Medic:server:saveReasonIfNew')

    end)

    RegisterNetEvent('qbx_Ab_Medic:client:initPlayer', function()
        -- ajout pour les pv
        Wait(500)
        local playerPed = PlayerPedId()
        local health = QBX.PlayerData.metadata.health
        print('Health spawn: ' .. health)
        SetEntityHealth(playerPed, health) -- Appliquer la santé une seule fois après le spawn
    end)


-- EVENT BASIQUE

    -- event pour tuer un joueur
    RegisterNetEvent('qbx_Ab_Medic:client:KillPlayer', function()

        local playerPed = PlayerPedId()

        if DoesEntityExist(playerPed) then
            -- Réduire la santé du joueur à 0 pour le "tuer"
            SetEntityHealth(playerPed, 0)
        end
    end)


    --event pour qu'un joueur revive un autre
    RegisterNetEvent('qbx_Ab_Medic:client:RevivePlayer', function(playerSrc, command)
        print(source)
        local playerPedid = GetPlayerPed(GetPlayerFromServerId(source)) -- Obtenir le ped du joueur local
        local playerSrc = playerSrc -- Référence au joueur exécutant

        print ("to revive playerSrc: " ..playerSrc.. " playerPedid: " ..playerPedid)

        if command == true then
            -- Appeler la fonction générique pour réanimer et soigner
            ReviveAndHealPlayer(playerSrc, playerPedid)
            
        elseif IsPedDeadOrDying(playerPedid, true) then
            ReviveAndHealPlayer(playerSrc, playerPedid)
            TriggerServerEvent('qbx_Ab_Medic:server:ItemUseMedKit')
            
        else
            TriggerServerEvent('qbx_Ab_Medic:server:notifyNotDead', playerSrc)
        end
    end)

    -- event pour qu'un joueur soigne entierement un autre
    RegisterNetEvent('qbx_Ab_Medic:client:useMedKit', function(playerSrc)
        print(source)
        local playerPedid = GetPlayerPed(GetPlayerFromServerId(source)) -- Obtenir le ped du joueur local
        local playerSrc = playerSrc -- Référence au joueur exécutant
        local playerCurrentHealth = GetEntityHealth(playerPedid)
        local playerMaxHealth = Config.max_health

        print ("Le joueur: " ..playerSrc.. " actif sur le playerPedid: " ..playerPedid.. " qui a pour pv : " ..playerCurrentHealth.. " le max est : " ..playerMaxHealth)

        if playerCurrentHealth < playerMaxHealth then
            -- Appeler la fonction générique soigner
            FullHealPlayer(playerPedid, playerCurrentHealth, playerMaxHealth)
            TriggerServerEvent('qbx_Ab_Medic:server:ItemUseMedKit')
        else
            TriggerServerEvent('qbx_Ab_Medic:server:notifyNoNeedHeal', playerSrc)
        end
    end)

        -- event pour qu'un joueur soigne un autre avec un bandage
        RegisterNetEvent('qbx_Ab_Medic:client:useBandage', function(playerSrc)
            print(source)
            local playerPedid = GetPlayerPed(GetPlayerFromServerId(source)) -- Obtenir le ped du joueur local
            local playerSrc = playerSrc -- Référence au joueur exécutant
            local playerCurrentHealth = GetEntityHealth(playerPedid)
            local playerMaxHealth = Config.max_health
            local PlayerMinimumHealth = Config.mini_health_bandage
    
            print ("Le joueur: " ..playerSrc.. " actif sur le playerPedid: " ..playerPedid.. " qui a pour pv : " ..playerCurrentHealth.. " et doit avoir au moins : " ..PlayerMinimumHealth.. " le max est : " ..playerMaxHealth)
    
            if playerCurrentHealth < playerMaxHealth then
                if playerCurrentHealth > PlayerMinimumHealth then
                    -- Appeler la fonction générique pour soigner un peu
                    SmallHealPlayer(playerPedid, playerCurrentHealth, playerMaxHealth)
                    TriggerServerEvent('qbx_Ab_Medic:server:ItemUseBandage', playerSrc)
                else
                    TriggerServerEvent('qbx_Ab_Medic:server:notifyToMuchHeart', playerSrc)
                end
            else
                TriggerServerEvent('qbx_Ab_Medic:server:notifyNoNeedHeal', playerSrc)
            end
        end)

-- EVENT ANIM 

    -- Animation pour réanimer un autre
    RegisterNetEvent('qbx_Ab_Medic:client:AnimReviveOtherPlayer')
    AddEventHandler('qbx_Ab_Medic:client:AnimReviveOtherPlayer', function()

        
        -- fonction perso d'animation (fonction a changer si on veut coller un props à la main)
        PlayAnimation("amb@medic@standing@tendtodead@idle_a", "idle_a", 8000, 1) 

        --DeleteObject(prop) -- Supprimer la bonbonne après l'animation

        -- Si il se passe des chose
        local fatigue_up = 10
        local stress_up = 3

        TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_up) -- augmente la fatigue
        TriggerServerEvent('hud:server:GainStress',stress_up)

    end)

        -- Animation pour être reanimé
        RegisterNetEvent('qbx_Ab_Medic:client:AnimReviveself')
        AddEventHandler('qbx_Ab_Medic:client:AnimReviveself', function()


            PlayAnimation("mini@cpr@char_b@cpr_str", "cpr_success", -1, 64)
    
            --DeleteObject(prop) -- Supprimer la bonbonne après l'animation
    
            -- Si il se passe des chose
            local fatigue_up = 25
            local stress_up = 6
    
            TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_up) -- augmente la fatigue
            TriggerServerEvent('hud:server:GainStress',stress_up)
    
        end)

        -- Animation pour être reanimé
        RegisterNetEvent('qbx_Ab_Medic:client:AnimHealPlayer')
        AddEventHandler('qbx_Ab_Medic:client:AnimHealPlayer', function()


            -- fonction perso d'animation (fonction a changer si on veut coller un props à la main)
            PlayAnimation("anim@amb@business@cfm@cfm_drying_notes@", "base_worker", 5000, 1) 
    
            --DeleteObject(prop) -- Supprimer la bonbonne après l'animation
    
            -- Si il se passe des chose
            local fatigue_up = 5
            local stress_up = 1
    
            TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_up) -- augmente la fatigue
            TriggerServerEvent('hud:server:GainStress',stress_up)
    
        end)

        -- Animation pour verifier l'état de santé
        RegisterNetEvent('qbx_Ab_Medic:client:AnimCheck')
        AddEventHandler('qbx_Ab_Medic:client:AnimCheck', function(duration)
            local playerPed = PlayerPedId()
            local anim = "amb@medic@standing@timeofdeath@base"
            local anim_name = 'base'
            local propModel = 'p_amb_clipboard_01'
            local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
            AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 36029), 0.16, 0.08, 0.1,-130.0, -50.0, 0.0, true, true, false, true, 1, true)

            PlayAnimation(anim, anim_name, duration, 1) 
            
            Wait(duration) -- Temps de réparation (ajustez la durée si nécessaire)
            DeleteObject(prop)
            
            -- Si il se passe des chose
            
        end)

-- //Cibler les joueurs pour des action
    exports.ox_target:addGlobalPlayer({

        {
            name = 'player_revive',
            icon = 'fa-solid fa-square-plus',
            label = 'Réanimer',
            distance = 1.5, -- Distance pour interagir avec un autre joueur
            groups = Config.jobRequired,
            items = 'medical_kit',
            onSelect = function(data)
                local targetPlayerIndex = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)) 
                TriggerServerEvent('qbx_Ab_Medic:server:RevivePlayer', targetPlayerIndex, false)
            end
        },
        {
            name = 'use_MedKit',
            icon = 'fa-solid fa-suitcase-medical', 
            label = 'Utiliser un Kit Médical',
            distance = 1.5, -- Distance pour interagir avec un autre joueur
            groups = Config.jobRequired,
            items = 'medical_kit',
            onSelect = function(data)
                local targetPlayerIndex = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)) 
                TriggerServerEvent('qbx_Ab_Medic:server:useMedKit', targetPlayerIndex)
            end
        },
        {
            name = 'use_Bandage',
            icon = 'fa-solid fa-hand-holding-medical',
            label = 'Utiliser un bandage',
            distance = 1.5, -- Distance pour interagir avec un autre joueur
            items = 'bandage',
            onSelect = function(data)
                local targetPlayerIndex = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)) 
                TriggerServerEvent('qbx_Ab_Medic:server:useBandage', targetPlayerIndex)
            end
        },
        {
            name = 'check_health',
            icon = 'fa-solid fa-stethoscope',
            label = 'Examiner la santé du patient',
            distance = 1.5, -- Distance pour interagir avec un autre joueur
            items = 'stethoscope',
            onSelect = function(data)
                local targetPlayerIndex = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                local targethealth = GetEntityHealth(data.entity) 
                TriggerServerEvent('qbx_Ab_Medic:server:checkHealth', targetPlayerIndex, targethealth)
            end
        },
        {
            name = 'check_stress',
            icon = 'fa-solid fa-weight-scale',
            label = 'Examiner la tension du patient',
            distance = 1.5, -- Distance pour interagir avec un autre joueur
            items = 'tensiometre',
            onSelect = function(data)
                local targetPlayerIndex = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                TriggerServerEvent('qbx_Ab_Medic:server:checkStress', targetPlayerIndex)
            end
        },

        
    })



-- Small stuff


exports('medical_kit', function(data, slot)

    -- Triggers internal-code to correctly use items.
    -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
    exports.ox_inventory:useItem(data, function(used)
        -- The server has verified the item can be used.
        if used then
            TriggerEvent('scully_emotemenu:playEmoteByCommand', 'medbag')
        end
    end)

end)

TriggerEvent('scully_emotemenu:playEmoteByCommand', 'beachring')

    RegisterCommand("pv", function()
        local playerPed = PlayerPedId() -- Récupère le joueur
        local health = GetEntityHealth(playerPed) -- Obtient les PV du joueur
    
        print ('health command: ' ..health)
    end, false)