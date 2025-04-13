local plantstate = nil
local plantpoisonstate = nil

local handprotected = false
local timeprotected = 0

local damaging = false
local notifdone_damaging = false

local isdreaming = false
local lastpos = nil
local timetrip = nil

local pickedpos = nil

local playerClonedPed = nil

-- FONCTION


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
        RemoveAnimDict(dict)
    end

    RegisterNetEvent("qbx_Ab_SpecialPlant:client:updateCurrentPlace")
    AddEventHandler("qbx_Ab_SpecialPlant:client:updateCurrentPlace", function(position)
        pickedpos = position
        --print ("position de trip : " ..json.encode(pickedpos))
    end)

    RegisterNetEvent("qbx_Ab_SpecialPlant:client:sendClientpos")
    AddEventHandler("qbx_Ab_SpecialPlant:client:sendClientpos", function(dreamstate, position)
        -- Vérification que dreamstate est un booléen
        if type(dreamstate) == "boolean" then
            isdreaming = dreamstate
            lastpos = position
            --print("LOAD reve t on : " .. tostring(isdreaming) .. " au position: " .. json.encode(lastpos))

            if isdreaming == true then
                timetrip = Config.timetrip_veryshort
                TriggerEvent('qbx_Ab_SpecialPlant:client:startDreaming')
            end
        else
            print("Erreur: dreamstate n'est pas un booléen !")
        end
    end)

-- PLANTE GESTION

    -- Écoute la réception de la variable plantstate
    RegisterNetEvent("qbx_Ab_SpecialPlant:client:PlantState")
    AddEventHandler("qbx_Ab_SpecialPlant:client:PlantState", function(plantkind, state)
        --print ('recived : ' ..plantkind.. ' state : ' ..state)
        if plantkind == "special" then
            plantstate = state

        elseif plantkind == "poison" then
            plantpoisonstate = state

        end
        
    end)


    local areaPlantTarget = { -- plant special
        coords = vec3(-9.36, 93.78, -19.0),
        name = 'plant_halu',
        radius = 0.8,
        debug = false,
        drawSprite = false,
        distance = 1,
        options = {-- Option pour récolter
            {
                name = "harvest_plant_spe",
                label = "Récolter",
                icon = 'fa-regular fa-hand',
                distance = 1.5,
                canInteract = function(entity, distance, coords)
                    TriggerServerEvent('qbx_Ab_SpecialPlant:server:PlantStatecheck', 'special')
                    Wait (2)
                        if plantstate == 'ready' then
                            return true
                        else
                            return false
                        end
                end,
                onSelect = function(data)
                    --print (json.encode(handprotected))
                    if handprotected then 
                        TriggerEvent('qbx_Ab_SpecialPlant:client:harvestPlant', 'special') 
                    else
                        damaging = true 
                        notifdone_damaging = true
                    end
                end,
            },
            -- Option pour verifier la plant
            {
                name = "check_plant_spe",
                label = "Regarder l'état de la plante",
                icon = 'fas fa-search', 
                distance = 1.5,
                onSelect = function(data)
                    TriggerServerEvent('qbx_Ab_SpecialPlant:server:checkPlant', 'special') 
                end,
            }

        }
    }
    exports.ox_target:addSphereZone(areaPlantTarget)  

    local areaPlantPoisonTarget = { -- Plante poison
        coords = vec3(20.38, 162.04, -19.0),
        name = 'plant_poison',
        radius = 0.8,
        debug = false,
        drawSprite = false,
        distance = 1,
        options = {-- Option pour récolter
            {
                name = "harvest_plant_p",
                label = "Récolter",
                icon = 'fa-regular fa-hand',
                distance = 1.5,
                canInteract = function(entity, distance, coords)
                    TriggerServerEvent('qbx_Ab_SpecialPlant:server:PlantStatecheck', 'poison')
                    Wait (2)
                        if plantpoisonstate == 'ready' then
                            return true
                        else
                            return false
                        end
                end,
                onSelect = function(data)
                    --print (json.encode(handprotected))
                    if handprotected then 
                        TriggerEvent('qbx_Ab_SpecialPlant:client:harvestPlant', 'poison') 
                    else
                        damaging = true 
                        notifdone_damaging = true
                    end
                end,
            },
            -- Option pour verifier la plant
            {
                name = "check_plant_p",
                label = "Regarder l'état de la plante",
                icon = 'fas fa-search', 
                distance = 1.5,
                onSelect = function(data)
                    TriggerServerEvent('qbx_Ab_SpecialPlant:server:checkPlant', 'poison') 
                end,
            }

        }
    }
    exports.ox_target:addSphereZone(areaPlantPoisonTarget)  

    -- Animation pour récolter la plante
    RegisterNetEvent('qbx_Ab_SpecialPlant:client:harvestPlant')
    AddEventHandler('qbx_Ab_SpecialPlant:client:harvestPlant', function(kindplant)

            TriggerServerEvent('qbx_Ab_SpecialPlant:server:harvestPlant', kindplant) 
            --print ('trigger harvestPlant with kindplant : ' ..kindplant)


    end)    

-- THREAD et démarage

        Citizen.CreateThread(function()

            Wait(1500)

            while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
                Wait(100)
                --print("En attente des données du joueur (citizenid)...")
            end

            TriggerServerEvent('qbx_Ab_SpecialPlant:server:updateClientPos')
            Wait (100)
            print(" Mise à jour de la position du client.")

            TriggerServerEvent('qbx_Ab_SpecialPlant:server:loadClientpos')

        end)

        -- action de la plante
        Citizen.CreateThread(function()
            Wait(5000)

            while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
                Wait(100)
                --print("En attente des données du joueur (citizenid)...")
            end
            

            while true do
                Wait(500)

                Wait(500)

                if handprotected then
                    if timeprotected < Config.total_timeprotected then
                        handprotected = true
                        timeprotected = timeprotected + 1
                        --print ("timeprotected " ..timeprotected)
                    elseif timeprotected >= Config.total_timeprotected then
                        handprotected = false
                        timeprotected = 0
                    else
                        print('Il y a un problème de protection des mains')
                    end
                end

                if damaging then 

                    local playerPedid = PlayerPedId()
                    local playerCurrentHealth = GetEntityHealth(playerPedid)
                    local healthReduction = playerCurrentHealth -25
                    --print (" is damaging")

                    if IsPedDeadOrDying(playerPedid, true) then 
                        damaging = false 
                        notifdone_damaging = false 
                    else
                        playerCurrentHealth = GetEntityHealth(playerPedid)
                        healthReduction = playerCurrentHealth -15
                        SetEntityHealth(playerPedid,healthReduction)
                        if notifdone_damaging then 
                            exports.qbx_core:Notify("Vous recentez un forte douleur provenant des mains", 'warning', 7000)
                            notifdone_damaging = false
                        end
                        
                    end

                end

            end
        end)

    -- vérifier si isdreaming et revenir à lastpos après timetrip
    RegisterNetEvent("qbx_Ab_SpecialPlant:client:startDreaming")
    AddEventHandler("qbx_Ab_SpecialPlant:client:startDreaming", function()
        if isdreaming and timetrip and pickedpos then
            --print("Début du rêve pour " .. timetrip .. " minute(s).")
    
            CreateThread(function()
                local tripDuration = timetrip * 60 * 1000  
                local higheffect_duration = tripDuration * 0.5
                local player = PlayerPedId()
                local playercoords = GetEntityCoords(player)

                TriggerServerEvent('qbx_Ab_SpecialPlant:server:saveClientPos', isdreaming, playercoords)

                TriggerEvent("qbx_Ab_Weed:client:highEffect", higheffect_duration)
                Wait(tripDuration)
    
                local playerPed = PlayerPedId()
                DoScreenFadeOut(1000)
                Wait(1000)
    
                SetEntityCoords(playerPed, lastpos.x, lastpos.y, lastpos.z, false, false, false, true)
                SetEntityHeading(playerPed, GetEntityHeading(playerPed))


                TriggerEvent('qbx_Ab_SpecialPlant:client:WakeupAnimation')
                Wait(500)
                --TriggerEvent('qbx_Ab_SpecialPlant:client:Deleteped')
                
                Wait(500)
                DoScreenFadeIn(1000)
    
                --print("Retour à la réalité effectué.")
    
                -- Réinitialisation des variables
                isdreaming = false
                timetrip = nil
                Wait(10)
                TriggerServerEvent('qbx_Ab_SpecialPlant:server:saveClientPos', isdreaming, lastpos)
            end)
        else
            print ("erreur isdreaming and timetrip and pickedpos")
        end
    end)


-- Export

    exports('desinfectos', function(data, slot)
        local player = PlayerPedId()
        local animduration = 6000

        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                
                PlayAnimation("missheist_agency3aig_23", "urinal_sink_loop", animduration, 49)

                handprotected = true

                exports.qbx_core:Notify("Vous mains sont protégé pour la prochaine minutes", 'warning', 7000)
                
                -- Appliquer un effet de défoncé temporaire
                        
            end
        end)

    end)

    exports('joint_special', function(data, slot)
        local player = PlayerPedId()
        local playercoords = GetEntityCoords(player)
        local duration = Config.highduration
        local propmodel = 'p_cs_joint_02'        
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then

                -- Créer et attacher le prop
                local prop = CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

                PlayAnimation("amb@world_human_leaning@female@smoke@base", "base", 5000, 49)

                DeleteObject(prop) -- Supprimer le prop après l'animation

                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'joint_butt')    
                
                if not isdreaming then
                    -- Je vais trigger ici le voyage
                    lastpos = playercoords
                    isdreaming = true
                    timetrip = Config.timetrip_short 
                    
                    Wait(10)
                    --print('timetrip defini a' ..timetrip)
                    TriggerEvent ('qbx_Ab_SpecialPlant:client:effect_Tp')
                    

                else
                    print ('déjà en rêve'..json.encode(isdreaming))
                end

            end
        end)

    end)
    
    exports('tea_special', function(data, slot)
        local player = PlayerPedId()
        local playercoords = GetEntityCoords(player)
        local soif_up = 50
        local fatigue_down = -5
        local stress_down = 5
        local downdrunk = 10
        local duration = 5000
    
        -- Triggers internal-code to correctly use items.
        -- This adds security, removes the item on use, adds progressbar support, and is necessary for server callbacks.
        exports.ox_inventory:useItem(data, function(used)
            -- The server has verified the item can be used.
            if used then
                
                PlayAnimation("amb@prop_human_seat_chair_drink@female@generic@base", "base", duration, 49)

                TriggerServerEvent('consumables:server:addThirst',soif_up)
                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', fatigue_down)
                TriggerServerEvent('hud:server:RelieveStress',stress_down)
                TriggerServerEvent('qbx_Ab_Garbages:server:addTrash', 'goblet')
                TriggerEvent ('qbx_Ab_AlcoolContrebande:client:decreaseDrunk', downdrunk)

                if not isdreaming then 
                    -- ajout du voyage
                    lastpos = playercoords
                    isdreaming = true
                    timetrip = Config.timetrip_long
                    Wait(10)
                    TriggerEvent ('qbx_Ab_SpecialPlant:client:effect_Tp')

                else
                    print ('déjà en rêve '..json.encode(isdreaming))
                end

            end
        end)

    end)

-- EVENT

        -- Animation pour se lever
    RegisterNetEvent('qbx_Ab_SpecialPlant:client:WakeupAnimation')
    AddEventHandler('qbx_Ab_SpecialPlant:client:WakeupAnimation', function()

        local playerPed = PlayerPedId()
        local dict = "safe@trevor@ig_8"
        local name = "ig_8_wake_up_front_player"
        local duration = 5000
        local flag = 0

        -- Charger le dictionnaire d'animation
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(100)
        end

        Wait (800)
        -- Jouer l'animation
        TaskPlayAnim(playerPed, dict, name, 5.0, 1.0, duration, flag, 0, false, false, false)

        -- Attendre la durée de l'animation
        Wait(duration)

        -- Arrêter l'animation
        ClearPedTasks(playerPed)
        RemoveAnimDict(dict)

    end)

    RegisterNetEvent("qbx_Ab_SpecialPlant:client:effect_Tp")
    AddEventHandler("qbx_Ab_SpecialPlant:client:effect_Tp", function()
        local playerPed = PlayerPedId()
    
        TriggerServerEvent('qbx_Ab_SpecialPlant:server:updateClientPos')

        while not pickedpos do
            Wait(100)  -- Attendre 100ms et vérifier de nouveau
        end
    
        if pickedpos then
            --print('Voyage activé à ' .. json.encode(pickedpos))
    
            DoScreenFadeOut(1000)
            
            Wait(500)

            --TriggerEvent('qbx_Ab_SpecialPlant:client:Createped', source)

            Wait(1000)

            SetEntityCoords(playerPed, pickedpos.x, pickedpos.y, pickedpos.z, false, false, false, true)
            SetEntityHeading(playerPed, pickedpos.w)

            TriggerEvent ('qbx_Ab_SpecialPlant:client:startDreaming')
    
            TriggerEvent('qbx_Ab_SpecialPlant:client:WakeupAnimation')
            Wait(1000)
            DoScreenFadeIn(1000)
        else
            print("Erreur : Rêve non définie.")
        end
    end)
    

    -- Animation pour récolter la plante
    RegisterNetEvent('qbx_Ab_SpecialPlant:client:harvestPlantAnimation')
    AddEventHandler('qbx_Ab_SpecialPlant:client:harvestPlantAnimation', function()

    
        PlayAnimation("anim@move_m@trash", "pickup", 15000, 1)

        -- Si il se passe des chose


    end)

    -- Commande pour connaitre
    RegisterCommand('dreamlocation', function(source, args, rawCommand)

        TriggerServerEvent('qbx_Ab_SpecialPlant:server:showdreamlocation')

    end, false)
        

-- Creation de ped lors de voyage PAS  UP



    -- RegisterNetEvent('qbx_Ab_SpecialPlant:client:Createped')
    -- AddEventHandler('qbx_Ab_SpecialPlant:client:Createped', function(targetId)
    --     local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
    --     if not DoesEntityExist(targetPed) then return end
    
    --     local model = GetEntityModel(targetPed)
    --     RequestModel(model)
    --     while not HasModelLoaded(model) do
    --         Wait(10)
    --     end
    
    --     local coords = GetEntityCoords(targetPed)
    --     local heading = GetEntityHeading(targetPed)
    
    --     -- Supprimer l'ancien PED si déjà existant
    --     if playerClonedPed and DoesEntityExist(playerClonedPed) then
    --         DeleteEntity(playerClonedPed)
    --     end
    
    --     -- Création du PED cloné
    --     local clonedPed = CreatePed(4, model, coords.x, coords.y, coords.z-1.7, heading, true, false)
        
    
    --     -- Copie des vêtements
    --     for i = 0, 12 do
    --         SetPedComponentVariation(clonedPed, i, GetPedDrawableVariation(targetPed, i), GetPedTextureVariation(targetPed, i), 0)
    --     end
    
    --     -- Correction de la couleur des cheveux
    --     local hairColor = GetPedHairColor(targetPed)
    --     local hairHighlightColor = GetPedHairHighlightColor(targetPed)
    --     SetPedHairColor(clonedPed, hairColor, hairHighlightColor)
    
    --     -- Freeze le PED
    --     FreezeEntityPosition(clonedPed, true)
    --     SetEntityInvincible(clonedPed, true) -- Facultatif si tu veux éviter qu'il meure
    --     SetBlockingOfNonTemporaryEvents(clonedPed, true) -- Empêche les réactions automatiques
    --     SetPedCanRagdoll(clonedPed, false) 
    --     SetEntityProofs(clonedPed, true, true, true, true, true, true, true, true)
    
    --     SetEntityAsMissionEntity(clonedPed, true, true)

    --     -- Animation : PED couché au sol
    --     RequestAnimDict("savebighouse@")
    --     while not HasAnimDictLoaded("savebighouse@") do
    --         Wait(10)
    --     end
    --     TaskPlayAnim(clonedPed, "savebighouse@", "f_sleep_l_loop_bighouse", 8.0, -8.0, -1, 1, 0, false, false, false)
    
    --     -- forcer l'animation en continu
    --     CreateThread(function()
    --         while DoesEntityExist(clonedPed) do
    --             if not IsEntityPlayingAnim(clonedPed, "savebighouse@", "f_sleep_l_loop_bighouse", 3) then
    --                 TaskPlayAnim(clonedPed, "savebighouse@", "f_sleep_l_loop_bighouse", 8.0, -8.0, -1, 1, 0, false, false, false)
    --             end
    --             Wait(1000) -- Vérifie toutes les secondes
    --         end
    --     end)

    --     -- Stockage du PED pour ce joueur
    --     playerClonedPed = clonedPed

    --     print('PED cloné avec ID : ' .. clonedPed)
    -- end)

    -- RegisterNetEvent('qbx_Ab_SpecialPlant:client:Deleteped')
    -- AddEventHandler('qbx_Ab_SpecialPlant:client:Deleteped', function()
    --     if playerClonedPed then
    --             if DoesEntityExist(playerClonedPed) then
    --             DeleteEntity(playerClonedPed)
    --             playerClonedPed = nil
    --             print('PED supprimé avec succès.')
    --         else
    --             print('PED Entity dont Exist.')
    --         end
    --     else
    --         print('Aucun PED à supprimer.')
    --     end
    -- end)



