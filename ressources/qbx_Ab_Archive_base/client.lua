local issearching = false

local cd_sreach = 0

-- fonctions 

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

    local function updateRandom_cd_sreach()

        cd_sreach = math.random(Config.cd_searchmini, Config.cd_searchmaxi) -- Génère une nouvelle valeur aléatoire
        --print ('new cd_sreach =' ..cd_sreach)

    end

-- THREAD

    CreateThread(function() -- Pour charger le niveau d'alcool au dépar

        Wait(1000)

        while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
            Wait(100)
            --print("En attente des données du joueur (citizenid)...")
        end

        while true do 
            Wait(1000)
            if cd_sreach > 0 then
                cd_sreach = cd_sreach - 1
                if cd_sreach < 0 then
                    cd_sreach = 0
                end
                --print ('cd_sreach ' ..cd_sreach)
            end

            

        end

    end)

-- FOUILLE DANS LES ARCHIVES 
    exports.ox_target:addModel(
        Config.archivesearch_props, 
        { 
            -- Option pour fouiller dans les archive
            {
                name = "search_archive",
                label = "Fouiller dans les archives",
                icon = 'fa-solid fa-magnifying-glass',
                canInteract = function(entity, distance, coords)
                    if issearching then
                        return false
                    else
                        return true
                    end
                end,
                onSelect = function(data)
                    if cd_sreach <= 0 then 
                        TriggerEvent('qbx_Ab_Archive_base:client:searchArchiveAnimation')
                        issearching = true
                        Wait(10)
                    else
                        exports.qbx_core:Notify('Vous avez déjà fouiller récemment!', 'error', 8000)
                    end
                end,
            },            
        }
    )

    -- Anim pour fouiller dans les archive
    RegisterNetEvent('qbx_Ab_Archive_base:client:searchArchiveAnimation')
    AddEventHandler('qbx_Ab_Archive_base:client:searchArchiveAnimation', function()

        -- fonction perso d'animation (fonction a changer si on veut coller un props à la main)
        PlayAnimation("anim@move_m@trash", "pickup", Config.search_duration, 1)  

        --DeleteObject(prop) -- Supprimer la bonbonne après l'animation
        -- Si il se passe des chose
        TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.search_fatigue_up) -- augmente la fatigue
        TriggerServerEvent('hud:server:GainStress',Config.search_stress_up)

        TriggerServerEvent('qbx_Ab_Archive_base:server:searchArchive')
        issearching = false
        updateRandom_cd_sreach()
    end)

-- TRI DE DOCUMMENT
    -- Target zone de récéption des doc a trier
    local targetdebug = false

    local ReceiptTarget = {
        coords = vec3(98.13, 8.03, -19.8),
        name = 'area_receiptdocstash',
        radius = 1,
        debug = false,
        drawSprite = false,
        options = {  
            {
                name = "open_receiptdocstash",
                label = "Récupérer un document à tirer",
                icon = 'fa-solid fa-file-arrow-up',
                distance = 1,
                onSelect = function(data)
                    exports.ox_inventory:openInventory(receiptdocstash, 'doc_receipt')
                end,
            },
        }
    }

    local function PlaceDocArchive (nameEvent, item_name, item, docneed, dockind)
        return  {   
            name = nameEvent,
            label = "Déposer un " ..item_name,
            icon = 'fa-solid fa-file-arrow-down',
            distance = 1,
            items = item,
            onSelect = function(data)
                TriggerServerEvent('qbx_Ab_Archive_base:server:placedoc', docneed, dockind, item)
                PlayAnimation("anim@heists@narcotics@trash", "drop_front", Config.dropfile_duration, 1)  
            end,
        }
    end

    -- Target zone de déposer doc it
        
        local placeitTarget = {
            coords = Config.telegestion_pos,
            name = 'area_placeit',
            radius = 1,
            debug = targetdebug,
            drawSprite = targetdebug,
            options = {
                -- si dessous : nom / nom d'item / item / item nécéssaire / item choisi
                PlaceDocArchive ("place_it_itdoc", Config.it_doc_name, Config.it_doc, 'it', 'it'),
                PlaceDocArchive ("place_it_cafet_doc", Config.cafet_doc_name, Config.cafet_doc, 'it', 'cafet'),
                PlaceDocArchive ("place_it_archive_doc", Config.archive_doc_name, Config.archive_doc, 'it', 'archive'),
                PlaceDocArchive ("place_it_menage_doc", Config.menage_doc_name, Config.menage_doc, 'it', 'menage'),
                PlaceDocArchive ("place_it_compta_doc", Config.compta_doc_name, Config.compta_doc, 'it', 'compta'),
                PlaceDocArchive ("place_it_accueil_doc", Config.accueil_doc_name, Config.accueil_doc, 'it', 'accueil'),
                PlaceDocArchive ("place_it_communication_doc", Config.communication_doc_name, Config.communication_doc, 'it', 'communication'),
                PlaceDocArchive ("place_it_infirmerie_doc", Config.infirmerie_doc_name, Config.infirmerie_doc, 'it', 'infirmerie'),
            }
        }

        local placecafetTarget = {
            coords = Config.culinaire_pos,
            name = 'area_placecafet',
            radius = 1,
            debug = targetdebug,
            drawSprite = targetdebug,
            options = {
                -- si dessous : nom / nom d'item / item / item nécéssaire / item choisi
                PlaceDocArchive ("place_cafet_itdoc", Config.it_doc_name, Config.it_doc, 'cafet', 'it'),
                PlaceDocArchive ("place_cafet_cafet_doc", Config.cafet_doc_name, Config.cafet_doc, 'cafet', 'cafet'),
                PlaceDocArchive ("place_cafet_archive_doc", Config.archive_doc_name, Config.archive_doc, 'cafet', 'archive'),
                PlaceDocArchive ("place_cafet_menage_doc", Config.menage_doc_name, Config.menage_doc, 'cafet', 'menage'),
                PlaceDocArchive ("place_cafet_compta_doc", Config.compta_doc_name, Config.compta_doc, 'cafet', 'compta'),
                PlaceDocArchive ("place_cafet_accueil_doc", Config.accueil_doc_name, Config.accueil_doc, 'cafet', 'accueil'),
                PlaceDocArchive ("place_cafet_communication_doc", Config.communication_doc_name, Config.communication_doc, 'it', 'communication'),
                PlaceDocArchive ("place_cafet_infirmerie_doc", Config.infirmerie_doc_name, Config.infirmerie_doc, 'cafet', 'infirmerie'),
            }
        }

        local placearchiveTarget = {
            coords = Config.consignation_pos,
            name = 'area_placearchive',
            radius = 1,
            debug = targetdebug,
            drawSprite = targetdebug,
            options = {
                -- si dessous : nom / nom d'item / item / item nécéssaire / item choisi
                PlaceDocArchive ("place_archive_itdoc", Config.it_doc_name, Config.it_doc, 'archive', 'it'),
                PlaceDocArchive ("place_archive_cafet_doc", Config.cafet_doc_name, Config.cafet_doc, 'archive', 'cafet'),
                PlaceDocArchive ("place_archive_archive_doc", Config.archive_doc_name, Config.archive_doc, 'archive', 'archive'),
                PlaceDocArchive ("place_archive_menage_doc", Config.menage_doc_name, Config.menage_doc, 'archive', 'menage'),
                PlaceDocArchive ("place_archive_compta_doc", Config.compta_doc_name, Config.compta_doc, 'archive', 'compta'),
                PlaceDocArchive ("place_archive_accueil_doc", Config.accueil_doc_name, Config.accueil_doc, 'archive', 'accueil'),
                PlaceDocArchive ("place_archive_communication_doc", Config.communication_doc_name, Config.communication_doc, 'archive', 'communication'),
                PlaceDocArchive ("place_archive_infirmerie_doc", Config.infirmerie_doc_name, Config.infirmerie_doc, 'archive', 'infirmerie'),
            }
        } 
        
        local placemenageTarget = {
            coords = Config.sanitaire_pos,
            name = 'area_placemenage',
            radius = 1,
            debug = targetdebug,
            drawSprite = targetdebug,
            options = {
                -- si dessous : nom / nom d'item / item / item nécéssaire / item choisi
                PlaceDocArchive ("place_menage_itdoc", Config.it_doc_name, Config.it_doc, 'menage', 'it'),
                PlaceDocArchive ("place_menage_cafet_doc", Config.cafet_doc_name, Config.cafet_doc, 'menage', 'cafet'),
                PlaceDocArchive ("place_menage_archive_doc", Config.archive_doc_name, Config.archive_doc, 'menage', 'archive'),
                PlaceDocArchive ("place_menage_menage_doc", Config.menage_doc_name, Config.menage_doc, 'menage', 'menage'),
                PlaceDocArchive ("place_menage_compta_doc", Config.compta_doc_name, Config.compta_doc, 'menage', 'compta'),
                PlaceDocArchive ("place_menage_accueil_doc", Config.accueil_doc_name, Config.accueil_doc, 'menage', 'accueil'),
                PlaceDocArchive ("place_menage_communication_doc", Config.communication_doc_name, Config.communication_doc, 'menage', 'communication'),
                PlaceDocArchive ("place_menage_infirmerie_doc", Config.infirmerie_doc_name, Config.infirmerie_doc, 'menage', 'infirmerie'),
            }
        }  
        
        local placecomptaTarget = {
            coords = Config.budget_pos,
            name = 'area_placecompta',
            radius = 1,
            debug = targetdebug,
            drawSprite = targetdebug,
            options = {
                -- si dessous : nom / nom d'item / item / item nécéssaire / item choisi
                PlaceDocArchive ("place_compta_itdoc", Config.it_doc_name, Config.it_doc, 'compta', 'it'),
                PlaceDocArchive ("place_compta_cafet_doc", Config.cafet_doc_name, Config.cafet_doc, 'compta', 'cafet'),
                PlaceDocArchive ("place_compta_archive_doc", Config.archive_doc_name, Config.archive_doc, 'compta', 'archive'),
                PlaceDocArchive ("place_compta_menage_doc", Config.menage_doc_name, Config.menage_doc, 'compta', 'menage'),
                PlaceDocArchive ("place_compta_compta_doc", Config.compta_doc_name, Config.compta_doc, 'compta', 'compta'),
                PlaceDocArchive ("place_compta_accueil_doc", Config.accueil_doc_name, Config.accueil_doc, 'compta', 'accueil'),
                PlaceDocArchive ("place_compta_communication_doc", Config.communication_doc_name, Config.communication_doc, 'compta', 'communication'),
                PlaceDocArchive ("place_compta_infirmerie_doc", Config.infirmerie_doc_name, Config.infirmerie_doc, 'compta', 'infirmerie'),
            }
        }  
        
        local placeaccueilTarget = {
            coords = Config.coordination_pos,
            name = 'area_placeaccueil',
            radius = 1,
            debug = targetdebug,
            drawSprite = targetdebug,
            options = {
                -- si dessous : nom / nom d'item / item / item nécéssaire / item choisi
                PlaceDocArchive ("place_accueil_itdoc", Config.it_doc_name, Config.it_doc, 'accueil', 'it'),
                PlaceDocArchive ("place_accueil_cafet_doc", Config.cafet_doc_name, Config.cafet_doc, 'accueil', 'cafet'),
                PlaceDocArchive ("place_accueil_archive_doc", Config.archive_doc_name, Config.archive_doc, 'accueil', 'archive'),
                PlaceDocArchive ("place_accueil_menage_doc", Config.menage_doc_name, Config.menage_doc, 'accueil', 'menage'),
                PlaceDocArchive ("place_accueil_compta_doc", Config.compta_doc_name, Config.compta_doc, 'accueil', 'compta'),
                PlaceDocArchive ("place_accueil_accueil_doc", Config.accueil_doc_name, Config.accueil_doc, 'accueil', 'accueil'),
                PlaceDocArchive ("place_accueil_communication_doc", Config.communication_doc_name, Config.communication_doc, 'accueil', 'communication'),
                PlaceDocArchive ("place_accueil_infirmerie_doc", Config.infirmerie_doc_name, Config.infirmerie_doc, 'accueil', 'infirmerie'),
            }
        } 
        
        local placecommunicationTarget = {
            coords = Config.transmission_pos,
            name = 'area_placecommunication',
            radius = 1,
            debug = targetdebug,
            drawSprite = targetdebug,
            options = {
                -- si dessous : nom / nom d'item / item / item nécéssaire / item choisi
                PlaceDocArchive ("place_communication_itdoc", Config.it_doc_name, Config.it_doc, 'communication', 'it'),
                PlaceDocArchive ("place_communication_cafet_doc", Config.cafet_doc_name, Config.cafet_doc, 'communication', 'cafet'),
                PlaceDocArchive ("place_communication_archive_doc", Config.archive_doc_name, Config.archive_doc, 'communication', 'archive'),
                PlaceDocArchive ("place_communication_menage_doc", Config.menage_doc_name, Config.menage_doc, 'communication', 'menage'),
                PlaceDocArchive ("place_communication_compta_doc", Config.compta_doc_name, Config.compta_doc, 'communication', 'compta'),
                PlaceDocArchive ("place_communication_accueil_doc", Config.accueil_doc_name, Config.accueil_doc, 'communication', 'accueil'),
                PlaceDocArchive ("place_communication_communication_doc", Config.communication_doc_name, Config.communication_doc, 'communication', 'communication'),
                PlaceDocArchive ("place_communication_infirmerie_doc", Config.infirmerie_doc_name, Config.infirmerie_doc, 'communication', 'infirmerie'),
            }
        } 
        
        local placeinfirmerieTarget = {
            coords = Config.therapeutique_pos,
            name = 'area_placeinfirmerie',
            radius = 1,
            debug = targetdebug,
            drawSprite = targetdebug,
            options = {
                -- si dessous : nom / nom d'item / item / item nécéssaire / item choisi
                PlaceDocArchive ("place_infirmerie_itdoc", Config.it_doc_name, Config.it_doc, 'infirmerie', 'it'),
                PlaceDocArchive ("place_infirmerie_cafet_doc", Config.cafet_doc_name, Config.cafet_doc, 'infirmerie', 'cafet'),
                PlaceDocArchive ("place_infirmerie_archive_doc", Config.archive_doc_name, Config.archive_doc, 'infirmerie', 'archive'),
                PlaceDocArchive ("place_infirmerie_menage_doc", Config.menage_doc_name, Config.menage_doc, 'infirmerie', 'menage'),
                PlaceDocArchive ("place_infirmerie_compta_doc", Config.compta_doc_name, Config.compta_doc, 'infirmerie', 'compta'),
                PlaceDocArchive ("place_infirmerie_accueil_doc", Config.accueil_doc_name, Config.accueil_doc, 'infirmerie', 'accueil'),
                PlaceDocArchive ("place_infirmerie_communication_doc", Config.communication_doc_name, Config.communication_doc, 'infirmerie', 'communication'),
                PlaceDocArchive ("place_infirmerie_infirmerie_doc", Config.infirmerie_doc_name, Config.infirmerie_doc, 'infirmerie', 'infirmerie'),
            }
        }          

    exports.ox_target:addSphereZone(ReceiptTarget)
    exports.ox_target:addSphereZone(placeitTarget)
    exports.ox_target:addSphereZone(placecafetTarget)
    exports.ox_target:addSphereZone(placearchiveTarget)
    exports.ox_target:addSphereZone(placemenageTarget)
    exports.ox_target:addSphereZone(placecomptaTarget)
    exports.ox_target:addSphereZone(placeaccueilTarget)
    exports.ox_target:addSphereZone(placecommunicationTarget)
    exports.ox_target:addSphereZone(placeinfirmerieTarget)

-- ///// Pour admin

    exports.ox_target:addModel(
    Config.adminprops,  -- zone de livraison drone
    {  
         -- déposer un doc random
         {
            name = "drop_random_doc",
            label = "déposer un document au archive",
            icon = "fa-solid fa-file-arrow-down",
            groups = "admin",
            onSelect = function(data)
                TriggerServerEvent("qbx_Ab_Archive_base:server:addRandomDoc")
                exports.qbx_core:Notify("Un document à trier à été livré aux archives.", 'inform', 5000)
            end,
            },
    })    