local blackout = "off" -- "off" / "on" / "broken"

local areaCoords = vector3(1.1, 1.1, -18.9999) -- Coordonnees de la zone a definir si proche du props
local areaRadius = 2.0 -- Radius de la zone de trigger
local currentEntitySet_0 = "bo0set1"
local currentEntitySet = "boset1"
local currentEntitySet_1 = "bo1set1"
local currentEntitySet_2 = "bo2set1"
local currentEntitySet_3 = "bo3set1"
local currentEntitySet_4 = "bo4set1"
local currentEntitySet_5 = "bo5set1"
local currentEntitySet_st = "bostset1"

local interiorId = nil
local isPlayerInArea = false

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

-- Fonction pour update le blackout dans tout les scripts pour le client seul (utilisé à la connexion)
local function sendBlackoutData()
    Wait(5)
    TriggerEvent('qbx_Ab_informatic:client:blackout', blackout)
    Wait(5)
    TriggerEvent('qbx_Ab_soluce_devis:client:blackout', blackout)
    Wait(5)
    TriggerEvent('qbx_Ab_minigame_labfile:client:blackout', blackout)
    Wait(5)
    TriggerEvent('qbx_Ab_minigame_devis:client:blackout', blackout)
    Wait(5)
    TriggerEvent('qbx_Ab_minigame_CSC:client:blackout', blackout)
    Wait(5)
    TriggerEvent('qbx_Ab_minigame_bataille_naval:client:blackout', blackout)
    Wait(5)
    TriggerEvent('qbx_Ab_Dorne_Delivery:client:blackout', blackout)
    Wait(5)
    TriggerEvent('qbx_Ab_DiceyTroop:client:blackout', blackout)
    Wait(5)
    TriggerEvent('qbx_Ab_Accueil_InfoProd:client:blackout', blackout)
    Wait(5)
    TriggerEvent('qbx_Ab_Accueil_InfoList:client:blackout', blackout)
    Wait(5)
    TriggerEvent('qbx_Ab_Accueil_InfoJobProd:client:blackout', blackout)
    Wait(5)
    TriggerEvent('qbx_Ab_It_base:client:blackout', blackout)
    Wait(5)
    TriggerEvent('qbx_Ab_Pharma:client:blackout', blackout)
end

-- les switch d'entity set
    local function setEntity_1to2()
        print ('setEntity_1to2 activate')
        local id_0 = GetInteriorAtCoords(-97.87, 42.01, -23.0)
        local id_rdc =GetInteriorAtCoords(-2.57, 18.55, -19.0)
        local id_1 = GetInteriorAtCoords(-0.19, 110.08, -19.0)
        local id_2 = GetInteriorAtCoords(-5.74, 210.55, -19.0)
        local id_3 = GetInteriorAtCoords(100.04, 110.12, -19.0)
        local id_4 = GetInteriorAtCoords(100.47, 5.44, -19.0)
        local id_5 = GetInteriorAtCoords(40.0, 0.0, 240.0)
        local id_st = GetInteriorAtCoords(1.86, 0.54, 216.8)

        if not interiorId or interiorId == 0 then
            print("Failed to fetch valid interior ID!")
            return
        else
            print("interiorId: " ..json.encode(interiorId))
        end

        -- 0
        DeactivateInteriorEntitySet(id_0, "bo0set1")
        ActivateInteriorEntitySet(id_0, "bo0set2")
        print("interiorId 0: " ..json.encode(id_0))
        RefreshInterior(id_0)
        Wait(5)
        -- 
        DeactivateInteriorEntitySet(id_rdc, "boset1")
        ActivateInteriorEntitySet(id_rdc, "boset2")
        print("interiorId: " ..json.encode(id_rdc))
        RefreshInterior(id_rdc)
        Wait(5)
        -- 1
        DeactivateInteriorEntitySet(id_1, "bo1set1")
        ActivateInteriorEntitySet(id_1, "bo1set2")
        print("interiorId 1: " ..json.encode(id_1))
        RefreshInterior(id_1)
        Wait(5)
        -- 2
        DeactivateInteriorEntitySet(id_2, "bo2set1")
        ActivateInteriorEntitySet(id_2, "bo2set2")
        RefreshInterior(id_2)
        Wait(5)
        -- 3
        DeactivateInteriorEntitySet(id_3, "bo3set1")
        ActivateInteriorEntitySet(id_3, "bo3set2")
        RefreshInterior(id_3)
        Wait(5)
        -- 4
        DeactivateInteriorEntitySet(id_4, "bo4set1")
        ActivateInteriorEntitySet(id_4, "bo4set2")
        RefreshInterior(id_4)
        Wait(5)
        -- 5
        DeactivateInteriorEntitySet(id_5, "bo5set1")
        ActivateInteriorEntitySet(id_5, "bo5set2")
        RefreshInterior(id_5)
        Wait(5)
        -- t
        DeactivateInteriorEntitySet(id_st, "bostset1")
        ActivateInteriorEntitySet(id_st, "bostset2")
        RefreshInterior(id_st)
        Wait(5)

        currentEntitySet_0 = "bo0set2"
        currentEntitySet = "boset2"
        currentEntitySet_1 = "bo1set2"
        currentEntitySet_2 = "bo2set2"
        currentEntitySet_3 = "bo3set2"
        currentEntitySet_4 = "bo4set2"
        currentEntitySet_5 = "bo5set2"
        currentEntitySet_st = "bostset2"
    end

    local function setEntity_2to1()
        print ('setEntity_2to1 activate')
        local id_0 = GetInteriorAtCoords(-97.87, 42.01, -23.0)
        local id_rdc =GetInteriorAtCoords(-2.57, 18.55, -19.0)
        local id_1 = GetInteriorAtCoords(-0.19, 110.08, -19.0)
        local id_2 = GetInteriorAtCoords(-5.74, 210.55, -19.0)
        local id_3 = GetInteriorAtCoords(100.04, 110.12, -19.0)
        local id_4 = GetInteriorAtCoords(100.47, 5.44, -19.0)
        local id_5 = GetInteriorAtCoords(40.0, 0.0, 240.0)
        local id_st = GetInteriorAtCoords(1.86, 0.54, 216.8)

        if not interiorId or interiorId == 0 then
            print("Failed to fetch valid interior ID!")
            return
        else
            print("interiorId: " ..json.encode(interiorId))
        end

        -- 0
        DeactivateInteriorEntitySet(id_0, "bo0set2")
        ActivateInteriorEntitySet(id_0, "bo0set1")
        RefreshInterior(id_0)
        Wait(5)
        -- 
        DeactivateInteriorEntitySet(id_rdc, "boset2")
        ActivateInteriorEntitySet(id_rdc, "boset1")
        RefreshInterior(id_rdc)
        Wait(5)
        -- 1
        DeactivateInteriorEntitySet(id_1, "bo1set2")
        ActivateInteriorEntitySet(id_1, "bo1set1")
        RefreshInterior(id_1)
        Wait(5)
        -- 2
        DeactivateInteriorEntitySet(id_2, "bo2set2")
        ActivateInteriorEntitySet(id_2, "bo2set1")
        RefreshInterior(id_2)
        Wait(5)
        -- 3
        DeactivateInteriorEntitySet(id_3, "bo3set2")
        ActivateInteriorEntitySet(id_3, "bo3set1")
        RefreshInterior(id_3)
        Wait(5)
        -- 4
        DeactivateInteriorEntitySet(id_4, "bo4set2")
        ActivateInteriorEntitySet(id_4, "bo4set1")
        RefreshInterior(id_4)
        Wait(5)
        -- 5
        DeactivateInteriorEntitySet(id_5, "bo5set2")
        ActivateInteriorEntitySet(id_5, "bo5set1")
        RefreshInterior(id_5)
        Wait(5)
        -- t
        DeactivateInteriorEntitySet(id_st, "bostset2")
        ActivateInteriorEntitySet(id_st, "bostset1")
        RefreshInterior(id_st)
        Wait(5)

        currentEntitySet_0 = "bo0set1"
        currentEntitySet = "boset1"
        currentEntitySet_1 = "bo1set1"
        currentEntitySet_2 = "bo2set1"
        currentEntitySet_3 = "bo3set1"
        currentEntitySet_4 = "bo4set1"
        currentEntitySet_5 = "bo5set1"
        currentEntitySet_st = "bostset1"
    end

-- Fonction toggle des EntitySet
local function toggleEntitySet()
    if not interiorId then
        print("Interior ID not found!")
        return
    end

    -- Désactive le set numero 1 (blackout off)
    if blackout == "on" or blackout == "broken" then
        
        SetArtificialLightsState(true)
        PlaySoundFrontend(-1, "Power_Down", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
        SetArtificialLightsStateAffectsVehicles(false)

        setEntity_1to2()
    else -- blackout on
        
        SetArtificialLightsState(false)
        PlaySoundFrontend(-1, "Zoom_In", "DLC_HEIST_PLANNING_BOARD_SOUNDS", 1)
        SetArtificialLightsStateAffectsVehicles(true)

        setEntity_2to1()
    end

    -- Refresh interieur
    
    TriggerServerEvent("os_blackout:updateCurrentEntity", blackout)

    --print("Entity set toggled to: " .. currentEntitySet)
end

-- Fontion recuperation ID intérieur
local function fetchInteriorId()
    interiorId = GetInteriorAtCoords(areaCoords)
    if interiorId and interiorId ~= 0 then
        --print("Interior ID fetched: " .. interiorId)

        -- Active le premier set par defaut
        RefreshInterior(interiorId)
        if blackout == "on" or blackout == "broken" then
            SetArtificialLightsState(true)
            SetArtificialLightsStateAffectsVehicles(false)
            setEntity_1to2()
            sendBlackoutData()
        else
            SetArtificialLightsState(false)
            SetArtificialLightsStateAffectsVehicles(true)
            setEntity_2to1()
        end
        --print("current entityset activated.")
    else
        print("Failed to fetch Interior ID!")
    end
end

-- Check si player est dans la zone
local function isPlayerNearArea()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    return #(playerCoords - areaCoords) <= areaRadius
end


-- Détection input
CreateThread(function()
    -- Recupere ID intérieur & active le premier set au demarrage
    TriggerServerEvent("os_blackout:getCurrentEntitySet")
    print("Initialization EntitySet bo complete.")
end)

RegisterNetEvent("os_blackout:sendEntityToClient")
AddEventHandler("os_blackout:sendEntityToClient", function(isblackout)
    blackout = isblackout
    --print ("blackout:" ..blackout)
    toggleEntitySet()
end)

RegisterNetEvent("os_blackout:receiveEntitySet")
AddEventHandler("os_blackout:receiveEntitySet", function(isblackout)
    blackout = isblackout
    --print ("blackout:" ..blackout)
    Wait(50)
    fetchInteriorId()
end)

-- target

    local areaBlackoutTarget = { 
    coords = vec3(51.56, 22.52, 238.65),
    name = 'electric_blackout',
    radius = 0.8,
    debug = false,
    drawSprite = false,
    distance = 1,
    options = {
        {    -- Fonction affichage
            name = 'blackout_switch_on',
            label = 'Couper le courant',
            icon = 'fa-solid fa-retweet',
            --groups = 'admin',
            canInteract = function(entity, distance, coords)
                -- Permettre l'interaction en fonction du blackout
                if blackout == "off" then
                    return true
                else
                    return false
                end
            end,
            onSelect = function(data)
                TriggerServerEvent("os_blackout:sendEntityInfos", 'on')
                exports.qbx_core:Notify('Vous avez coupez le courant, seul le système de sécurité est opérationnel', 'error', 10000)
            end
        },
        {    -- Fonction affichage
            name = 'blackout_switch_off',
            label = 'Remettre le courant',
            icon = 'fa-solid fa-retweet',
            --groups = 'admin',
            canInteract = function(entity, distance, coords)
                -- Permettre l'interaction en fonction du blackout
                if blackout == "on" then
                    return true
                else
                    return false
                end
            end,
            onSelect = function(data)
                TriggerServerEvent("os_blackout:sendEntityInfos", 'off')
                exports.qbx_core:Notify('Le courant est rétablie!', 'inform', 10000)
            end
        },
        {
            name = "sabot_blackout",
            label = "Saboter le système électrique",
            icon = 'fa-regular fa-hand',
            groups = 'tueur',
            items = 'kit_sabotage',
            canInteract = function(entity, distance, coords)
                if blackout == 'off' then
                    return true
                else
                    return false
                end
            end,
            onSelect = function(data)
                TriggerEvent("os_blackout:client:animBrokeBlackout")
            end,
        },
        -- Option pour verifier la plant
        {
            name = "fix_blackout",
            label = "Réparer le courant",
            icon = 'fas fa-screwdriver-wrench',
            groups = {'it','admin'},
            items = 'repear_kit',
            canInteract = function(entity, distance, coords)
                if blackout == 'broken' then
                    return true
                else
                    return false
                end
            end,
            onSelect = function(data)
                TriggerEvent("os_blackout:client:animFixBlackout")
            end,
        },
        {
            name = "check_blackout",
            label = "Analyser le compteur",
            icon = 'fas fa-search',
            groups = {'it','admin'},
            items = 'diagnostic_kit',
            onSelect = function(data)
                if blackout == 'off' then
                    exports.qbx_core:Notify("Pas d'anomalies", 'inform', 8000)
                elseif blackout == 'on' then
                    exports.qbx_core:Notify("Le courant a sauté ou a été coupé.", 'inform', 8000)
                elseif blackout == 'broken' then
                    exports.qbx_core:Notify("Le boitier électrique a été saboté!", 'error', 8000)
                else
                    exports.qbx_core:Notify("Impossible d'analyser, veuillez contacter un superieur!", 'error', 8000)
                end

            end,
        }

    }
    }
    exports.ox_target:addSphereZone(areaBlackoutTarget)  


-- anim
    RegisterNetEvent("os_blackout:client:animFixBlackout")
    AddEventHandler("os_blackout:client:animFixBlackout", function()
        local duration = 15000

        PlayAnimation('missmechanic', 'work_base', duration, 1)

        TriggerServerEvent("os_blackout:sendEntityInfos", 'off')
        exports.qbx_core:Notify('Le courant est rétablie!', 'inform', 10000)
        
    end)

    RegisterNetEvent("os_blackout:client:animBrokeBlackout")
    AddEventHandler("os_blackout:client:animBrokeBlackout", function()
        local duration = 6000
        local playerPed = PlayerPedId() 

        FreezeEntityPosition(playerPed, true)
        PlayAnimation('melee@unarmed@streamed_core', 'walking_punch_no_target', duration, 1) 
        FreezeEntityPosition(playerPed, false)

        TriggerServerEvent("os_blackout:sendEntityInfos", 'broken')
        TriggerServerEvent("0r_cctv:server:removeitem", 'kit_sabotage')
        exports.qbx_core:Notify('Vous avez coupez le courant, seul le système de sécurité est opérationnel', 'error', 10000)
        
    end)