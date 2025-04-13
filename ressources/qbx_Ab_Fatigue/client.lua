local fatigue = 0

local isResting = false

local doSport = false
local sportKind = nil
local shower_activated = false

local timeresting = nil
local timesportfatigue = nil
local timesportstress = nil

local destressKind = nil

-- Fonction pour initialiser la fatigue depuis le serveur lors de la connexion

    CreateThread(function() -- Pour charger le niveau d'alcool au dépar

        while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
            Wait(100)
            --print("En attente des données du joueur (citizenid)...")
        end

        local citizenid = QBX.PlayerData.citizenid
        TriggerServerEvent('qbx_Ab_Fatigue:server:getPlayerFatigue', citizenid)

    end)

    -- Événement pour mettre à jour la fatigue depuis le serveur
    RegisterNetEvent('qbx_Ab_Fatigue:client:updateFatigueDisplay')
    AddEventHandler('qbx_Ab_Fatigue:client:updateFatigueDisplay', function(newFatigue)
        fatigue = newFatigue
        -- Afficher la jauge de fatigue avec une UI personnalisée ou simple affichage console pour le test
        -- print("Niveau de fatigue mis à jour: " ..fatigue)
    end)

-- FUNCTION

    -- Fonction pour modifier la fatigue et envoyer au serveur
    function modifyFatigue(value)
        fatigue = fatigue + value
        if fatigue < 0 then fatigue = 0 end
        if fatigue > 100 then fatigue = 100 end

        -- Appel au serveur pour sauvegarder la modification
        local citizenid = QBX.PlayerData.citizenid
        if citizenid then
            TriggerServerEvent('qbx_Ab_Fatigue:server:setPlayerFatigue', citizenid, fatigue)
        end
        -- Vérifie les seuils et envoie les notifications appropriées
        if fatigue >= Config.veryhighfat then
            TriggerEvent('QBCore:Notify', "Vous êtes complètement épuisé.", "warning", Config.warningtime)
        elseif fatigue >= Config.highfat then
            TriggerEvent('QBCore:Notify', "Vous vous sentez fatigué.", "warning", Config.warningtime)
        elseif fatigue >= Config.midfat then
            TriggerEvent('QBCore:Notify', "Vous commencez à ressentir de la fatigue.", "warning", Config.warningtime)
        end
    end

--/// REGISTER COMMAND

    -- Commandes de test pour augmenter ou diminuer la fatigue
    RegisterCommand('increaseFatigue', function(source, args)
        local increaseBy = tonumber(args[1]) or 10
        modifyFatigue(increaseBy)
    end, false)

    RegisterCommand('decreaseFatigue', function(source, args)
        local decreaseBy = tonumber(args[1]) or 10
        modifyFatigue(-decreaseBy)
    end, false)

    -- Commande pour afficher la fatigue
    RegisterCommand('showFatigue', function(source, args)
        local citizenid = QBX.PlayerData.citizenid
        if citizenid then
            TriggerServerEvent('qbx_Ab_Fatigue:server:getPlayerFatigue', citizenid)  -- Demande la fatigue au serveur
        else
            print("CitizenID non trouvé !")
        end
    end, false)

-- EFFET PERMANANT

    -- Crée un thread pour surveiller le niveau de fatigue en continu
    Citizen.CreateThread(function()
        local wasFatigued = false -- Variable pour suivre si le joueur était fatigué au cycle précédent
        Citizen.Wait(1000)

        while true do
            Citizen.Wait(0) -- Vérification toutes les 100 ms

            local playerPed = PlayerPedId()

            while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
                Wait(100)
                --print("En attente des données du joueur (citizenid)...")
            end
            
            if fatigue >= Config.veryhighfat then
                --if not wasFatigued then
                    -- Applique l'emote de marche lente si la fatigue est maximale
                    RequestAnimSet("move_m@buzzed")
                    while not HasAnimSetLoaded("move_m@buzzed") do
                        Citizen.Wait(0)
                    end
                    SetPedMovementClipset(playerPed, "move_m@buzzed", 1.0)

                    -- Désactive la course
                    DisableControlAction(0, 21, true) -- 21 correspond au contrôle de course (shift par défaut)
                    
                    
                    wasFatigued = true -- Mettre à jour l'état
                --end
            else
                if wasFatigued then
                    -- Réinitialise les mouvements et réactive la course si la fatigue passe sous 100
                    ResetPedMovementClipset(playerPed, 0)
                    EnableControlAction(0, 21, true)
                    
                    wasFatigued = false -- Mettre à jour l'état
                end
            end

        end

    end)

    -- notif de fatigue
    Citizen.CreateThread(function()
        Wait(25*1000)
        while true do

            while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
                Wait(100)
                --print("En attente des données du joueur (citizenid)...")
            end

            local citizenid = QBX.PlayerData.citizenid
            if citizenid then
                -- Demande au serveur de récupérer la fatigue
                TriggerServerEvent('qbx_Ab_Fatigue:server:sendPlayerFatigue', citizenid)
                print("triggered sendPlayerFatigue")
            else
                print("CitizenID introuvable.")
            end
            if isResting then 
                Wait(Config.timeInfoFast*60*1000) -- TimeInfo en minute
            else
                Wait(Config.timeInfoSlow*60*1000) -- TimeInfo en minute
            end
        end
    end)

        -- récupération de fatigue ou perte par repos ou sport
        Citizen.CreateThread(function()
            local upNumberRest = 0
            local upNumberSport_fatigue = 0
            local upNumberSport_stress = 0
            local destress_secTic = 0

            while true do
                Wait(1000)
                if isResting then -- Pour la partie ou on se repose
                    
                    if timeresting then
                        upNumberRest = upNumberRest + 1
                        --print ('upNumberRest up to ' ..upNumberRest)
                        if upNumberRest == timeresting then
                            upNumberRest = 0
                            TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.downfatigue_resting)
                            --print('fatigue réduite de ' ..Config.downfatigue_resting.. 'new upNumberRest ' ..upNumberRest)
                        end

                        if destressKind then
                            destress_secTic = destress_secTic +1
                            if destress_secTic == Config.timedestress then
                                destress_secTic = 0
                                if destressKind == Config.downstress_resting_low then
                                    TriggerServerEvent('hud:server:RelieveStress',Config.downstress_resting_low)
                                elseif destressKind == Config.downstress_resting_high then
                                    TriggerServerEvent('hud:server:RelieveStress',Config.downstress_resting_high)
                                else
                                    print ("bad destressKind")
                                end
                            end
                        else 
                            print ("no destressKind")
                        end

                    else
                        print('timerestion is nil')
                    end

                elseif doSport then
                    if timesportfatigue then
                        upNumberSport_fatigue = upNumberSport_fatigue + 1
                        --print ('upNumberRest up to ' ..upNumberRest)
                        if upNumberSport_fatigue == timesportfatigue then
                            upNumberSport_fatigue = 0
                            if shower_activated then 
                                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue',  Config.downfatigue_douche)
                            else
                                TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.upfatigue_sport)
                            end
                            --print('fatigue réduite de ' ..Config.upfatigue_sport.. 'new upNumberSport_fatigue ' ..upNumberSport_fatigue)
                        end
                    else
                        print('timesportfatigue is nil')
                    end
                    if timesportstress then
                        upNumberSport_stress = upNumberSport_stress + 1
                        --print ('upNumberRest up to ' ..upNumberRest)
                        if upNumberSport_stress == timesportstress then
                            upNumberSport_stress = 0
                            TriggerServerEvent('hud:server:RelieveStress', Config.downstress_sport)
                            --print('stress réduite de ' ..Config.downstress_sport.. 'new upNumberSport_stress ' ..upNumberSport_stress)
                        end
                    else
                        print('timesportstress is nil')
                    end

                end
            end
        end)


-- EVENT BASE
    -- Réception de la fatigue depuis le serveur
    RegisterNetEvent('qbx_Ab_Fatigue:client:receivePlayerFatigue')
    AddEventHandler('qbx_Ab_Fatigue:client:receivePlayerFatigue', function(actualFatigue)
        --print("Fatigue reçue")

        if isResting then

            -- Vérifie les seuils et envoie les notifications appropriées
            if actualFatigue >= Config.veryhighfat then
                TriggerEvent('QBCore:Notify',"Vous êtes complètement épuisé.", "warning", Config.warningtime)
                Wait (500)
            elseif actualFatigue < Config.veryhighfat and actualFatigue >= Config.highfat then
                TriggerEvent('QBCore:Notify',"Vous vous sentez fatigué.", "warning", Config.warningtime)
                Wait (500)
            elseif actualFatigue < Config.highfat and actualFatigue >= Config.midfat then
                TriggerEvent('QBCore:Notify',"Vous vous sentez légèrement fatigué.", "warning", Config.warningtime)
                Wait (500)
            elseif actualFatigue < Config.midfat and actualFatigue > 0 then
                TriggerEvent('QBCore:Notify',"Vous vous sentez en forme.", "inform", Config.warningtime)
                Wait (500)
            elseif actualFatigue == 0 then
                TriggerEvent('QBCore:Notify',"Vous vous sentez en pleine forme.", "success", Config.warningtime)
                Wait (500)
            else
                TriggerEvent('QBCore:Notify',"Vous vous état de fatigue est indescriptible.", "success", Config.warningtime, 'Veuillez contacter un professionel de santé')
                Wait (500)
            end
        else

            -- Vérifie les seuils et envoie les notifications appropriées
            if actualFatigue >= Config.veryhighfat then
                TriggerEvent('QBCore:Notify',"Vous êtes complètement épuisé.", "warning", Config.warningtime)
                Wait (500)
            elseif actualFatigue < Config.veryhighfat and actualFatigue >= Config.highfat then
                TriggerEvent('QBCore:Notify',"Vous vous sentez fatigué.", "warning", Config.warningtime)
                Wait (500)
            elseif actualFatigue < Config.highfat and actualFatigue >= Config.midfat then
                TriggerEvent('QBCore:Notify',"Vous commencez à ressentir de la fatigue.", "warning", Config.warningtime)
                Wait (500)
            end
        end
    end)


    -- Réception de la fatigue de la cible
    RegisterNetEvent('qbx_Ab_Fatigue:client:showTargetFatigue')
    AddEventHandler('qbx_Ab_Fatigue:client:showTargetFatigue', function(fatigue)
        --print ("cette personne a pour fatigue " ..fatigue)
        if fatigue >= Config.veryhighfat then
            exports.qbx_core:Notify("Cette personne est complètement épuisé.", "warning", Config.warningtime)
            Wait (500)
        elseif fatigue < Config.veryhighfat and fatigue >= Config.highfat then
            exports.qbx_core:Notify("Cette personne est fatigué.", "warning", Config.warningtime)
            Wait (500)
        elseif fatigue < Config.highfat and fatigue >= Config.midfat then
            exports.qbx_core:Notify("Cette personne est un peu fatigué.", "warning", Config.warningtime)
            Wait (500)
        else
            exports.qbx_core:Notify("Cette personne est en pleine forme.", "success", Config.warningtime)
            Wait (500)
        end
    end)

-- TARGET 
    -- Cibler les joueurs pour voir leur niveau de fatigue
    exports.ox_target:addGlobalPlayer({

        {
            icon = 'fas fa-bed', -- Icône pour l'interaction
            label = 'Voir la fatigue',
            icon = 'fa-solid fa-eye',
            distance = 1.5, -- Distance pour interagir avec un autre joueur
            groups = Config.jobRequired,
            onSelect = function(data)
                local targetPlayerIndex = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                --print ('targetPlayerIndex : ' ..targetPlayerIndex)
                TriggerServerEvent('qbx_Ab_Fatigue:server:getTargetFatigue', targetPlayerIndex)
            end
        }

    })
    -- REPOS
        -- Cibler un lit medical
        exports.ox_target:addModel(
            Config.medicalbedprop, 
            {  
                -- Option se reposer
                {
                    name = "rest_medicalbed",
                    label = "Se reposer",
                    icon = 'fa-solid fa-bed',
                    canInteract = function(entity, distance, coords)
                        if not isResting  then
                            return true
                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        local bedcoords = GetEntityCoords(data.entity)
                        local bedheading = GetEntityHeading(data.entity) + 180
                        --print ('trigger anim and coords: ' ..json.encode(bedcoords))
                        TriggerEvent('qbx_Ab_Fatigue:client:AnimMedicalBed', bedcoords, bedheading)
                        Wait(10)
                    end,
                },
            }
        )

            -- Cibler un lit de qualité
            exports.ox_target:addModel(
                Config.goodbedprop, 
                {  
                    -- Option se reposer
                    {
                        name = "rest_goodbed",
                        label = "Se reposer",
                        icon = 'fa-solid fa-bed',
                        canInteract = function(entity, distance, coords)
                            if not isResting  then
                                return true
                            else
                                return false
                            end
                        end,
                        onSelect = function(data)
                            local bedcoords = GetEntityCoords(data.entity)
                            local bedheading = GetEntityHeading(data.entity) + 270
                            --print ('trigger anim and coords: ' ..json.encode(bedcoords))
                            TriggerEvent('qbx_Ab_Fatigue:client:AnimGoodBed', bedcoords, bedheading)
                            Wait(10)
                        end,
                    },
                }
            )

            -- Cibler un lit superposé
            exports.ox_target:addModel(
                Config.badbedprop, 
                {  
                    -- Option se reposer
                    {
                        name = "rest_badbed_wide",
                        label = "Se reposer",
                        icon = 'fa-solid fa-bed',
                        canInteract = function(entity, distance, coords)
                            if not isResting  then
                                return true
                            else
                                return false
                            end
                        end,
                        onSelect = function(data)
                            local bedcoords = GetEntityCoords(data.entity)
                            local bedheading = GetEntityHeading(data.entity) + 270
                            --print ('trigger anim and coords: ' ..json.encode(bedcoords))
                            TriggerEvent('qbx_Ab_Fatigue:client:AnimBadBed', bedcoords, bedheading)
                            Wait(10)
                        end,
                    },
                }
            )

            -- Cibler un transat
            exports.ox_target:addModel(
                Config.transatprop, 
                {  
                    -- Option se reposer
                    {
                        name = "rest_transat",
                        label = "Se détendre",
                        icon = 'fa-solid fa-couch',
                        canInteract = function(entity, distance, coords)
                            if not isResting  then
                                return true
                            else
                                return false
                            end
                        end,
                        onSelect = function(data)
                            local bedcoords = GetEntityCoords(data.entity)
                            local bedheading = GetEntityHeading(data.entity) + 180
                            --print ('trigger anim and coords: ' ..json.encode(bedcoords).. 'with heading : ' ..json.encode(bedheading))
                            TriggerEvent('qbx_Ab_Fatigue:client:AnimTransat', bedcoords, bedheading)
                            Wait(10)
                        end,
                    },
                }
            )

            -- Cibler un le siege de massage
            exports.ox_target:addModel(
                Config.massageprop, 
                {  
                    -- Option se reposer
                    {
                        name = "rest_massage",
                        label = "Se détendre",
                        icon = 'fa-solid fa-couch',
                        canInteract = function(entity, distance, coords)
                            if not isResting  then
                                return true
                            else
                                return false
                            end
                        end,
                        onSelect = function(data)
                            local bedcoords = GetEntityCoords(data.entity)
                            local bedheading = GetEntityHeading(data.entity) +4
                            --print ('trigger anim and coords: ' ..json.encode(bedcoords).. 'with heading : ' ..json.encode(bedheading))
                            TriggerEvent('qbx_Ab_Fatigue:client:AnimMassage', bedcoords, bedheading)
                            Wait(10)
                        end,
                    },
                }
            )

    -- SPORT

    -- Cibler un le siege de massage
    exports.ox_target:addModel(
        Config.tapisprop, 
        {  
            -- Option faire du yoga
            {
                name = "sport_yoga",
                label = "Faire du Yoga",
                icon = 'fa-solid fa-person-rays',
                canInteract = function(entity, distance, coords)
                    if not doSport  then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    local propscoords = GetEntityCoords(data.entity)
                    local propsheading = GetEntityHeading(data.entity) + 90
                    -- ('trigger anim and coords: ' ..json.encode(propscoords).. 'with heading : ' ..json.encode(propsheading))
                    TriggerEvent('qbx_Ab_Fatigue:client:AnimYoga', propscoords, propsheading)
                    Wait(10)
                end,
            },
            -- Option faire des pompes
            {
                name = "sport_pushup",
                label = "Faire des pompes",
                icon = 'fa-solid fa-weight-hanging',
                canInteract = function(entity, distance, coords)
                    if not doSport  then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    local propscoords = GetEntityCoords(data.entity)
                    local propsheading = GetEntityHeading(data.entity) + 90
                    --print ('trigger anim and coords: ' ..json.encode(propscoords).. 'with heading : ' ..json.encode(propsheading))
                    TriggerEvent('qbx_Ab_Fatigue:client:AnimPushup', propscoords, propsheading)
                    Wait(10)
                end,
            },
            -- Option faire des jumping jack
            {
                name = "sport_jumpinjack",
                label = "Faire des Jumping Jacks",
                icon = 'fa-solid fa-person-running',
                canInteract = function(entity, distance, coords)
                    if not doSport  then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    local propscoords = GetEntityCoords(data.entity)
                    local propsheading = GetEntityHeading(data.entity) + 180
                    -- ('trigger anim and coords: ' ..json.encode(propscoords).. 'with heading : ' ..json.encode(propsheading))
                    TriggerEvent('qbx_Ab_Fatigue:client:AnimJumpingJacks', propscoords, propsheading)
                    Wait(10)
                end,
            },
        }
    )

        -- Cibler un le siege de massage
    exports.ox_target:addModel(
        Config.doublealterprop, 
        {  
            -- Option faire des alter deux mains
            {
                name = "sport_alterdouble",
                label = "Faire de la musculation",
                icon = 'fa-solid fa-dumbbell',
                canInteract = function(entity, distance, coords)
                    if not doSport  then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    local propscoords = GetEntityCoords(data.entity)
                    local propsheading = GetEntityHeading(data.entity) 
                    -- ('trigger anim and coords: ' ..json.encode(propscoords).. 'with heading : ' ..json.encode(propsheading))
                    TriggerEvent('qbx_Ab_Fatigue:client:AnimAlterdouble', propscoords, propsheading)
                    Wait(10)
                end,
            },
        }
    )

    -- Cibler un les grosse alter simple
    exports.ox_target:addModel(
        Config.simplealterprop_big, 
        {  
            -- Option faire des alter simple
            {
                name = "sport_altersimple_big",
                label = "Faire de la musculation",
                icon = 'fa-solid fa-dumbbell',
                canInteract = function(entity, distance, coords)
                    if not doSport  then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    local propscoords = GetEntityCoords(data.entity)
                    local propsheading = GetEntityHeading(data.entity) 
                    -- ('trigger anim and coords: ' ..json.encode(propscoords).. 'with heading : ' ..json.encode(propsheading))
                    TriggerEvent('qbx_Ab_Fatigue:client:AnimAltersimple', propscoords, propsheading, Config.simplealtermodel_big, Config.timesporthigh, Config.timesportmedium)
                    Wait(10)
                end,
            },
        }
    )

    -- Cibler un les moyenne alter simple
    exports.ox_target:addModel(
        Config.simplealterprop_medium, 
        {  
            -- Option faire des alter simple
            {
                name = "sport_altersimple_medium",
                label = "Faire de la musculation",
                icon = 'fa-solid fa-dumbbell',
                canInteract = function(entity, distance, coords)
                    if not doSport  then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    local propscoords = GetEntityCoords(data.entity)
                    local propsheading = GetEntityHeading(data.entity) 
                    -- ('trigger anim and coords: ' ..json.encode(propscoords).. 'with heading : ' ..json.encode(propsheading))
                    TriggerEvent('qbx_Ab_Fatigue:client:AnimAltersimple', propscoords, propsheading, Config.simplealtermodel_medium, Config.timesportmedium, Config.timesportlow)
                    Wait(10)
                end,
            },
        }
    )

    -- Cibler un les moyenne alter simple
    exports.ox_target:addModel(
        Config.simplealterprop_small, 
        {  
            -- Option faire des alter simple
            {
                name = "sport_altersimple_small",
                label = "Faire de la musculation",
                icon = 'fa-solid fa-dumbbell',
                canInteract = function(entity, distance, coords)
                    if not doSport  then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    local propscoords = GetEntityCoords(data.entity)
                    local propsheading = GetEntityHeading(data.entity) 
                    -- ('trigger anim and coords: ' ..json.encode(propscoords).. 'with heading : ' ..json.encode(propsheading))
                    TriggerEvent('qbx_Ab_Fatigue:client:AnimAltersimple', propscoords, propsheading, Config.simplealtermodel_small, Config.timesportlow, Config.timesportlow)
                    Wait(10)
                end,
            },
        }
    )    

    -- Cibler un les moyenne alter simple
    exports.ox_target:addModel(
        Config.simplealtermodel_small_bis, 
        {  
            -- Option faire des alter simple
            {
                name = "sport_altersimple_small",
                label = "Faire de la musculation",
                icon = 'fa-solid fa-dumbbell',
                canInteract = function(entity, distance, coords)
                    if not doSport  then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    local propscoords = GetEntityCoords(data.entity)
                    local propsheading = GetEntityHeading(data.entity)
                    -- ('trigger anim and coords: ' ..json.encode(propscoords).. 'with heading : ' ..json.encode(propsheading))
                    TriggerEvent('qbx_Ab_Fatigue:client:AnimAltersimple', propscoords, propsheading, Config.simplealtermodel_small_bis, Config.timesportlow, Config.timesportlow)
                    Wait(10)
                end,
            },
        }
    )    

    -- Cibler le banc pour alter
    exports.ox_target:addModel(
        Config.layalterprop, 
        {  
            -- Option faire des alter couché
            {
                name = "sport_alterlay",
                label = "Faire de la musculation",
                icon = 'fa-solid fa-dumbbell',
                canInteract = function(entity, distance, coords)
                    if not doSport  then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    local propscoords = GetEntityCoords(data.entity)
                    local propsheading = GetEntityHeading(data.entity) + 180
                    -- ('trigger anim and coords: ' ..json.encode(propscoords).. 'with heading : ' ..json.encode(propsheading))
                    TriggerEvent('qbx_Ab_Fatigue:client:AnimAlterlay', propscoords, propsheading)
                    Wait(10)
                end,
            },
        }
    )  

    -- Cibler les bar de traction
    exports.ox_target:addModel(
        Config.tractionprop, 
        {  
            -- Option faire des tractions
            {
                name = "sport_traction",
                label = "Faire des Traction",
                icon = 'fa-solid fa-dumbbell',
                canInteract = function(entity, distance, coords)
                    if not doSport  then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    local propscoords = GetEntityCoords(data.entity)
                    local propsheading = GetEntityHeading(data.entity) + 180
                    -- ('trigger anim and coords: ' ..json.encode(propscoords).. 'with heading : ' ..json.encode(propsheading))
                    TriggerEvent('qbx_Ab_Fatigue:client:AnimTraction', propscoords, propsheading)
                    Wait(10)
                end,
            },
        }
    )     

    -- Cibler la douche
    exports.ox_target:addModel(
        Config.showerprops, 
        {  
            -- Option faire des tractions
            {
                name = "sport_shower",
                label = "Prendre une douche",
                icon = 'fa-solid fa-shower',
                canInteract = function(entity, distance, coords)
                    if not doSport  then
                        return true
                    else
                        return false
                    end
                end,
                onSelect = function(data)
                    local propscoords = GetEntityCoords(data.entity)
                    local propsheading = GetEntityHeading(data.entity) + 180
                    -- ('trigger anim and coords: ' ..json.encode(propscoords).. 'with heading : ' ..json.encode(propsheading))
                    TriggerEvent('qbx_Ab_Fatigue:client:AnimShower')
                    Wait(10)
                end,
            },
        }
    )    

-- SE COUCHER 

    function getup (playerPed, side)

        local dict = 'savem_default@'
        local name = nil
        local duration = 3000

        if side == 'left' then
            name = 'm_getout_l'
        elseif side == 'right' then 
            name = 'm_getout_r'
        else
            print('no side to getup')
        end

        FreezeEntityPosition(playerPed, false)
        SetEntityCollision(playerPed, true, true)

        TaskPlayAnim(playerPed, dict, name, 1.0, 1.0, duration, 64, 0, false, false, false)

        Wait(duration)

        --print('Se lever du lit')
        ClearPedTasks(playerPed)
        
    end

    function getupScenario (playerPed)

    
        -- Arrêter le scénario actuel
        ClearPedTasksImmediately(playerPed)
    
        -- Réactiver les mouvements et collisions
        FreezeEntityPosition(playerPed, false)
        SetEntityCollision(playerPed, true, true)

    end

    function bedResting (playerPed, animdict, anim_name, x, y, z, bedheading)

        -- Charger le dictionnaire d'animation
        RequestAnimDict(animdict)
        while not HasAnimDictLoaded(animdict) do
            Wait(100)
        end
    
        -- Désactiver la collision pour éviter les bugs
        SetEntityCollision(playerPed, false, false)
        FreezeEntityPosition(playerPed, true)
        
        -- Jouer l'animation
        TaskPlayAnimAdvanced(playerPed, animdict, anim_name, x, y, z, 0, 0, bedheading, 2.0, 2.0, -1, 1, 1.0, false, false)

    end

    -- Pour se reposé dans le lit médical
    RegisterNetEvent('qbx_Ab_Fatigue:client:AnimMedicalBed', function(bedcoords, bedheading)
        local playerPed = PlayerPedId()
        local animdict = 'savebighouse@'
        local anim_name = 'f_sleep_l_loop_bighouse'
        local x, y, z = bedcoords.x, bedcoords.y, bedcoords.z + 0.55 -- Ajustement de la hauteur du lit

        exports.qbx_core:Notify('Vous commencez à vous reposer, votre fatigue va réduire', 'success', 8000)    

        bedResting (playerPed, animdict, anim_name, x, y, z, bedheading)
        
        isResting = true
        timeresting = Config.timemedic
        destressKind = Config.downstress_resting_high
    
        -- Attendre qu'on appuie sur "X" ou "BACKSPACE" pour se lever
        CreateThread(function()
            while isResting do
                Wait(0)
                if IsControlJustReleased(0, 73) or IsControlJustReleased(0, 194) then -- 73 = X, 194 = BACKSPACE

                    getup (playerPed, 'right')
                    isResting = false
                    timeresting = nil
                    destressKind = nil
                end
            end
        end)
    end)

    -- Pour se reposé dans le good bed
    RegisterNetEvent('qbx_Ab_Fatigue:client:AnimGoodBed', function(bedcoords, bedheading)
        local playerPed = PlayerPedId()
        local animdict = 'savebighouse@'
        local anim_name = 'f_sleep_l_loop_bighouse'
        local x, y, z = bedcoords.x, bedcoords.y, bedcoords.z + 0.30 -- Ajustement de la hauteur du lit
        
        exports.qbx_core:Notify('Vous commencez à vous reposer, votre fatigue va réduire', 'success', 8000)   

        bedResting (playerPed, animdict, anim_name, x, y, z, bedheading)
            
        isResting = true
        timeresting = Config.timegood
        destressKind = Config.downstress_resting_low
        
        -- Attendre qu'on appuie sur "X" ou "BACKSPACE" pour se lever
           CreateThread(function()
            while isResting do
                Wait(0)
                if IsControlJustReleased(0, 73) or IsControlJustReleased(0, 194) then -- 73 = X, 194 = BACKSPACE
                    Wait(20)
                    getup (playerPed, 'left')
                    isResting = false
                    timeresting = nil
                    destressKind = nil
                end
            end
        end)
    end)

    -- Pour se reposé dans le bad bed 
    RegisterNetEvent('qbx_Ab_Fatigue:client:AnimBadBed', function(bedcoords, bedheading)
        local playerPed = PlayerPedId()
        local animdict = 'savebighouse@'
        local anim_name = 'f_sleep_l_loop_bighouse'
        local x, y, z = bedcoords.x, bedcoords.y, bedcoords.z  -- Ajustement de la hauteur du lit
        
        exports.qbx_core:Notify('Vous commencez à vous reposer, votre fatigue va réduire', 'success', 8000)   

        bedResting (playerPed, animdict, anim_name, x, y, z, bedheading)
                
        isResting = true
        timeresting = Config.timebad
        destressKind = nil
            
        -- Attendre qu'on appuie sur "X" ou "BACKSPACE" pour se lever
           CreateThread(function()
            while isResting do
                Wait(0)
                if IsControlJustReleased(0, 73) or IsControlJustReleased(0, 194) then -- 73 = X, 194 = BACKSPACE
                    Wait(20)
                    getup (playerPed, 'right')
                    isResting = false
                    timeresting = nil
                    destressKind = nil
                end
            end
        end)
    end)

        -- Pour se reposé dans le transat
    RegisterNetEvent('qbx_Ab_Fatigue:client:AnimTransat', function(bedcoords, bedheading)
        local playerPed = PlayerPedId()
        local scenario = 'PROP_HUMAN_SEAT_SUNLOUNGER'
        local x, y, z = bedcoords.x, bedcoords.y, bedcoords.z-0.98
        
        -- Désactiver la collision pour éviter les bugs
        SetEntityCoords(playerPed, x, y, z, false, false, false, true)
        SetEntityHeading(playerPed, bedheading)

        SetEntityCollision(playerPed, false, false)
        FreezeEntityPosition(playerPed, true)
        
        -- Lancer le scénario d'animation
        --TaskStartScenarioAtPosition(playerPed, scenario, x, y, z, bedheading, -1, false, true)
        TaskStartScenarioInPlace(playerPed, scenario, -1, false)

        FreezeEntityPosition(playerPed, true)
                
        isResting = true
        timeresting = Config.timetransat
        destressKind = Config.downstress_resting_high
            
        -- Attendre qu'on appuie sur "X" ou "BACKSPACE" pour se lever
           CreateThread(function()
            while isResting do
                Wait(0)
                if IsControlJustReleased(0, 73) or IsControlJustReleased(0, 194) then -- 73 = X, 194 = BACKSPACE
                    Wait(20)
                    getupScenario (playerPed)
                    isResting = false
                    timeresting = nil
                    destressKind = nil
                end
            end
        end)
    end)

    -- Pour se reposé dans le siege massant
    RegisterNetEvent('qbx_Ab_Fatigue:client:AnimMassage', function(bedcoords, bedheading)
        local playerPed = PlayerPedId()
        local animdict = 'misstattoo_parlour@shop_ig_4'
        local anim_name = 'customer_loop'
        local x, y, z = bedcoords.x+0.1, bedcoords.y+0.1, bedcoords.z+0.45 -- Ajustement de la hauteur du lit
        local massage_secTic = 0
        local massage_activated = true
        
        -- Charger le dictionnaire d'animation
            RequestAnimDict(animdict)
            while not HasAnimDictLoaded(animdict) do
               Wait(100)
            end
           
            -- Désactiver la collision pour éviter les bugs
            SetEntityCollision(playerPed, false, false)
            FreezeEntityPosition(playerPed, true)
               
            -- Jouer l'animation
            TaskPlayAnimAdvanced(playerPed, animdict, anim_name, x, y, z, 0, 0, bedheading, 2.0, 2.0, -1, 1, 1.0, false, false) -- mis ça et pas la fonction pour tenté rotation custom
            Wait(20)
            SetEntityRotation(playerPed, 10.0, 0.0, bedheading, 2, true)
                
        isResting = true
        timeresting = Config.timebad
        destressKind = Config.downstress_resting_veryhigh
            
        -- Attendre qu'on appuie sur "X" ou "BACKSPACE" pour se lever
           CreateThread(function()
                while massage_activated do
                    Wait(0)
                    if IsControlJustReleased(0, 73) or IsControlJustReleased(0, 194) then -- 73 = X, 194 = BACKSPACE
                        getup (playerPed, 'left')
                        isResting = false
                        timeresting = nil
                        destressKind = nil
                        massage_activated = false
                    end
                end
            end)

            CreateThread(function()
                Wait(100)
                while isResting do
                    massage_secTic = massage_secTic + 1
                    Wait(1000)
                    if massage_secTic == Config.timetotalmassage then 
                        massage_secTic = 0
                        exports.qbx_core:Notify("Le massage est terminé!", 'error', 7000)  
                        getup (playerPed, 'left')
                        isResting = false
                        timeresting = nil
                        destressKind = nil
                        massage_activated = false
                         
                    end
                end
            end)
            
    end)   

-- FAIRE DU SPORT

    local function stopExercise(playerPed, reason)
        FreezeEntityPosition(playerPed, false)
        SetEntityCollision(playerPed, true, true)
        ClearPedTasks(playerPed)
        doSport = false
        timesportfatigue = nil
        timesportstress = nil

        if reason == "fatigue" then
            exports.qbx_core:Notify('Vous êtes trop fatigué pour continuer.', 'warning', 7000)
        end
    end

    RegisterNetEvent('qbx_Ab_Fatigue:client:AnimYoga', function(propcoords, propheading)
        local playerPed = PlayerPedId()
        local scenario = 'WORLD_HUMAN_YOGA'
        local x, y, z = propcoords.x, propcoords.y, propcoords.z
        
        -- Désactiver la collision pour éviter les bugs
        SetEntityCoords(playerPed, x, y, z, false, false, false, true)
        SetEntityHeading(playerPed, propheading)

        SetEntityCollision(playerPed, false, false)
        FreezeEntityPosition(playerPed, true)
        
        -- Lancer le scénario d'animation
        --TaskStartScenarioAtPosition(playerPed, scenario, x, y, z, propheading, -1, false, true)
        TaskStartScenarioInPlace(playerPed, scenario, -1, false)

        FreezeEntityPosition(playerPed, true)
                
        doSport = true
        timesportfatigue = Config.timesportlow
        timesportstress = Config.timesportlow
            
        -- Attendre qu'on appuie sur "X" ou "BACKSPACE" pour se lever
        CreateThread(function()
            while doSport do
                Wait(0)
                if  fatigue >= Config.veryhighfat then
    
                    stopExercise(playerPed, "fatigue")

                elseif IsControlJustReleased(0, 73) or IsControlJustReleased(0, 194) then -- 73 = X, 194 = BACKSPACE

                    stopExercise(playerPed, "manual")

                end
            end
        end)
    end)

    RegisterNetEvent('qbx_Ab_Fatigue:client:AnimPushup', function(propcoords, propheading)
        local playerPed = PlayerPedId()
        local animdict = 'amb@world_human_push_ups@male@idle_a'
        local anim_name = 'idle_d'
        local x, y, z = propcoords.x, propcoords.y, propcoords.z+1
       
    
        -- Charger le dictionnaire d'animation
        RequestAnimDict(animdict)
        while not HasAnimDictLoaded(animdict) do
            Wait(100)
        end
        
            
        -- Jouer l'animation
        TaskPlayAnimAdvanced(playerPed, animdict, anim_name, x, y, z, 0, 0, propheading, 1.0, 1.0, -1, 1, 1.0, false, false)
        FreezeEntityPosition(playerPed, true)
        SetEntityCollision(playerPed, false, false)
            
        doSport = true
        timesportfatigue = Config.timesporthigh
        timesportstress = Config.timesportmedium
        
        -- Attendre qu'on appuie sur "X" ou "BACKSPACE" pour se lever
        CreateThread(function()
            while doSport do
                Wait(0)
                if  fatigue >= Config.veryhighfat then
    
                    stopExercise(playerPed, "fatigue")

                elseif IsControlJustReleased(0, 73) or IsControlJustReleased(0, 194) then -- 73 = X, 194 = BACKSPACE

                    stopExercise(playerPed, "manual")

                end
            end
        end)
    end)

    RegisterNetEvent('qbx_Ab_Fatigue:client:AnimJumpingJacks', function(propcoords, propheading)
        local playerPed = PlayerPedId()
        local animdict = 'timetable@reunited@ig_2'
        local anim_name = 'jimmy_getknocked'
        local x, y, z = propcoords.x, propcoords.y, propcoords.z+1
       
    
        -- Charger le dictionnaire d'animation
        RequestAnimDict(animdict)
        while not HasAnimDictLoaded(animdict) do
            Wait(100)
        end
        
            
        -- Jouer l'animation
        TaskPlayAnimAdvanced(playerPed, animdict, anim_name, x, y, z, 0, 0, propheading, 1.0, 1.0, -1, 1, 1.0, false, false)
        FreezeEntityPosition(playerPed, true)
        SetEntityCollision(playerPed, false, false)
            
        doSport = true
        timesportfatigue = Config.timesportmedium
        timesportstress = Config.timesportmedium
        
        -- Attendre qu'on appuie sur "X" ou "BACKSPACE" pour se lever
        CreateThread(function()
            while doSport do
                Wait(0)
                if  fatigue >= Config.veryhighfat then
    
                    stopExercise(playerPed, "fatigue")

                elseif IsControlJustReleased(0, 73) or IsControlJustReleased(0, 194) then -- 73 = X, 194 = BACKSPACE

                    stopExercise(playerPed, "manual")

                end
            end
        end)
    end)

    RegisterNetEvent('qbx_Ab_Fatigue:client:AnimAlterdouble', function(propcoords, propheading)
        local playerPed = PlayerPedId()
        local animdict = 'amb@world_human_muscle_free_weights@male@barbell@base'
        local anim_name = 'base'
        local propmodel = 'prop_curl_bar_01'
        local bone = 28422
        local x, y, z = propcoords.x, propcoords.y, propcoords.z+1
       
    
        -- Charger le dictionnaire d'animation
        RequestAnimDict(animdict)
        while not HasAnimDictLoaded(animdict) do
            Wait(100)
        end
        
            
        -- Jouer l'animation
        local prop = CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
        AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, bone), 0.00, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        --TaskPlayAnimAdvanced(playerPed, animdict, anim_name, x, y, z, 0, 0, propheading, 1.0, 1.0, -1, 1, 1.0, false, false)
        TaskPlayAnim(playerPed, animdict, anim_name, 1.0, 1.0, -1, 1, 0, false, false, false)
        FreezeEntityPosition(playerPed, true)
        SetEntityCollision(playerPed, false, false)
            
        doSport = true
        timesportfatigue = Config.timesporthigh
        timesportstress = Config.timesporthigh
        
        -- Attendre qu'on appuie sur "X" ou "BACKSPACE" pour se lever
        CreateThread(function()
            while doSport do
                Wait(0)
                if  fatigue >= Config.veryhighfat then
    
                    stopExercise(playerPed, "fatigue")
                    DeleteObject(prop)

                elseif IsControlJustReleased(0, 73) or IsControlJustReleased(0, 194) then -- 73 = X, 194 = BACKSPACE

                    stopExercise(playerPed, "manual")
                    DeleteObject(prop)

                end
            end
        end)
    end)

    RegisterNetEvent('qbx_Ab_Fatigue:client:AnimAltersimple', function(propcoords, propheading, kind, timefatigue, timestress)
        local playerPed = PlayerPedId()
        local animdict = 'amb@world_human_muscle_free_weights@male@barbell@base'
        local anim_name = 'base'
        local propmodel = kind
        local boneA = 57005
        local boneB = 18905
        local x, y, z = propcoords.x, propcoords.y, propcoords.z+1
       
    
        -- Charger le dictionnaire d'animation
        RequestAnimDict(animdict)
        while not HasAnimDictLoaded(animdict) do
            Wait(100)
        end
        
            
        -- Jouer l'animation
        local propA = CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
        local propB = CreateObject(GetHashKey(propmodel), 0, 0, 0, true, true, true)
        if kind == Config.simplealtermodel_small_bis then
            AttachEntityToEntity(propA, playerPed, GetPedBoneIndex(playerPed, boneA), 0.1, 0.0, -0.07, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
            AttachEntityToEntity(propB, playerPed, GetPedBoneIndex(playerPed, boneB), 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        else
            AttachEntityToEntity(propA, playerPed, GetPedBoneIndex(playerPed, boneA), 0.1, 0.0, 0.0, 0.0, 0.0, 90.0, true, true, false, true, 1, true)
            AttachEntityToEntity(propB, playerPed, GetPedBoneIndex(playerPed, boneB), 0.1, 0.0, 0.0, 0.0, 0.0, 90.0, true, true, false, true, 1, true)
        end
        --TaskPlayAnimAdvanced(playerPed, animdict, anim_name, x, y, z, 0, 0, propheading, 1.0, 1.0, -1, 1, 1.0, false, false)
        TaskPlayAnim(playerPed, animdict, anim_name, 1.0, 1.0, -1, 1, 0, false, false, false)
        FreezeEntityPosition(playerPed, true)
        SetEntityCollision(playerPed, false, false)
            
        doSport = true
        timesportfatigue = timefatigue
        timesportstress = timestress
        
        -- Attendre qu'on appuie sur "X" ou "BACKSPACE" pour se lever
        CreateThread(function()
            while doSport do
                Wait(0)
                if  fatigue >= Config.veryhighfat then
    
                    stopExercise(playerPed, "fatigue")
                    DeleteObject(propA)
                    DeleteObject(propB)

                elseif IsControlJustReleased(0, 73) or IsControlJustReleased(0, 194) then -- 73 = X, 194 = BACKSPACE

                    stopExercise(playerPed, "manual")
                    DeleteObject(propA)
                    DeleteObject(propB)

                end
            end
        end)
    end)
    
    RegisterNetEvent('qbx_Ab_Fatigue:client:AnimAlterlay', function(propcoords, propheading)
        local playerPed = PlayerPedId()
        local scenario = 'PROP_HUMAN_SEAT_MUSCLE_BENCH_PRESS'
        local x, y, z = propcoords.x, propcoords.y-0.15, propcoords.z - 1.3
        
        -- Désactiver la collision pour éviter les bugs
        SetEntityCollision(playerPed, false, false)

        SetEntityCoords(playerPed, x, y, z, false, false, false, true)
        SetEntityHeading(playerPed, propheading)

        
        FreezeEntityPosition(playerPed, true)
        
        -- Lancer le scénario d'animation
        --TaskStartScenarioAtPosition(playerPed, scenario, x, y, z, propheading, -1, false, true)
        TaskStartScenarioInPlace(playerPed, scenario, -1, false)

        FreezeEntityPosition(playerPed, true)
                
        doSport = true
        timesportfatigue = Config.timesportmedium
        timesportstress = Config.timesportmedium
            
        -- Attendre qu'on appuie sur "X" ou "BACKSPACE" pour se lever
        CreateThread(function()
            while doSport do
                Wait(0)
                if  fatigue >= Config.veryhighfat then
    
                    stopExercise(playerPed, "fatigue")

                elseif IsControlJustReleased(0, 73) or IsControlJustReleased(0, 194) then -- 73 = X, 194 = BACKSPACE

                    stopExercise(playerPed, "manual")

                end
            end
        end)
    end)
    
    RegisterNetEvent('qbx_Ab_Fatigue:client:AnimTraction', function(propcoords, propheading)
        local playerPed = PlayerPedId()
        local scenario = 'PROP_HUMAN_MUSCLE_CHIN_UPS'
        local x, y, z = propcoords.x, propcoords.y-0.8, propcoords.z-1.15
        
        -- Désactiver la collision pour éviter les bugs
        --SetEntityCollision(playerPed, false, false)

        SetEntityCoords(playerPed, x, y, z, false, false, false, true)
        SetEntityHeading(playerPed, propheading)

        
        --FreezeEntityPosition(playerPed, true)
        
        -- Lancer le scénario d'animation
        --TaskStartScenarioAtPosition(playerPed, scenario, x, y, z, propheading, -1, false, true)
        TaskStartScenarioInPlace(playerPed, scenario, -1, false)

        --FreezeEntityPosition(playerPed, true)
                
        doSport = true
        timesportfatigue = Config.timesportmedium
        timesportstress = Config.timesportlow
            
        -- Attendre qu'on appuie sur "X" ou "BACKSPACE" pour se lever
        CreateThread(function()
            while doSport do
                Wait(0)
                if  fatigue >= Config.veryhighfat then
    
                    stopExercise(playerPed, "fatigue")

                elseif IsControlJustReleased(0, 73) or IsControlJustReleased(0, 194) then -- 73 = X, 194 = BACKSPACE

                    stopExercise(playerPed, "manual")

                end
            end
        end)
    end)    

    -- Pour prendre une douche
    RegisterNetEvent('qbx_Ab_Fatigue:client:AnimShower', function()
        local playerPed = PlayerPedId()
        local animdict = 'mp_safehouseshower@male@'
        local anim_name = 'male_shower_idle_d'
        local shower_secTic = 0
        shower_activated = true
        
        -- Charger le dictionnaire d'animation
            RequestAnimDict(animdict)
            while not HasAnimDictLoaded(animdict) do
               Wait(100)
            end
           
            -- Désactiver la collision pour éviter les bugs
            SetEntityCollision(playerPed, false, false)
            FreezeEntityPosition(playerPed, true)
               
            -- Jouer l'animation
            TaskPlayAnim(playerPed, animdict, anim_name, 1.0, 1.0, -1, 1, 0, false, false, false)
                
            doSport = true
            timesportfatigue = Config.timesportlow
            timesportstress = Config.timesportlow
            
        -- Attendre qu'on appuie sur "X" ou "BACKSPACE" pour se lever
           CreateThread(function()
                while shower_activated do
                    Wait(0)
                    if IsControlJustReleased(0, 73) or IsControlJustReleased(0, 194) then -- 73 = X, 194 = BACKSPACE
                        stopExercise(playerPed, "manual")
                        doSport = false
                        timesportfatigue = nil
                        timesportstress = nil
                        shower_activated = false
                    end
                end
            end)

            CreateThread(function()
                Wait(100)
                while doSport do
                    shower_secTic = shower_secTic + 1
                    Wait(1000)
                    if shower_secTic == Config.timetotalshower then 
                        shower_secTic = 0
                        exports.qbx_core:Notify("La douche est terminé!", 'error', 7000)  
                        stopExercise(playerPed, "manual")
                        doSport = false
                        timesportfatigue = nil
                        timesportstress = nil
                        shower_activated = false
                         
                    end
                end
            end)
            
    end)