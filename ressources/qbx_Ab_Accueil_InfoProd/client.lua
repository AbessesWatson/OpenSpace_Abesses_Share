local isUIOpen = false

local blackout = 'off'

-- Fonction pour vérifier l'état d'un ordinateur
    local function checkComputerState(computerID)
        -- Retourner l'état de l'ordinateur localement stocké
        return computer[computerID] and computer[computerID].state or 'active'
    end

    function RandomizeNumber()
        math.randomseed(GetGameTimer()) -- Réinitialise la graine du générateur
        local randomNumber = math.random(1, 100)
        return randomNumber
    end

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

-- Trigger sur ordi
    exports.ox_target:addModel(Config.propscomputer, {
        {    -- check productivité
        name = 'check_productivity',
        label = 'Verifier la productivité',
        icon = 'fa-solid fa-address-card',
        groups = Config.jobRequired,
        distance = 1.5,
        canInteract = function(entity, distance, coords)
            local computerID = GetEntityCoords(entity)
    
            -- Vérifier l'état de l'ordinateur localement
            local state = checkComputerState(json.encode(computerID))
    
            -- Permettre l'interaction si l'état est 'active'
            if blackout == 'off' then
                if state == 'active' then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end,

        onSelect = function(data)
            computerID = json.encode(GetEntityCoords(data.entity)) -- Inclure le computerID
            if not isUIOpen then
                isUIOpen = true
                SetNuiFocus(true, true) -- Active la saisie utilisateur dans l'UI
                --SetNuiFocusKeepInput(true)
                SendNUIMessage({
                    type = "open",
                    kindinfo = "productivity"
                })
                TriggerEvent ('qbx_Ab_Accueil_InfoProd:client:brokeComputer', computerID)
            end

        end 
        },
        {    -- check job
        name = 'check_job',
        label = 'Verifier le poste',
        icon = 'fa-solid fa-id-badge',
        groups = Config.jobRequired,
        distance = 1.5,
        canInteract = function(entity, distance, coords)
            local computerID = GetEntityCoords(entity)
    
            -- Vérifier l'état de l'ordinateur localement
            local state = checkComputerState(json.encode(computerID))
    
            -- Permettre l'interaction si l'état est 'active'
            if blackout == 'off' then
                if state == 'active' then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end,

        onSelect = function(data)
            computerID = json.encode(GetEntityCoords(data.entity)) -- Inclure le computerID
            if not isUIOpen then
                isUIOpen = true
                SetNuiFocus(true, true) -- Active la saisie utilisateur dans l'UI
                --SetNuiFocusKeepInput(true)
                SendNUIMessage({
                    type = "open",
                    kindinfo = "job"
                })
                TriggerEvent ('qbx_Ab_Accueil_InfoProd:client:brokeComputer', computerID)
            end

        end 
        },
    })

-- Event ordi

    RegisterNetEvent('qbx_Ab_Accueil_InfoProd:client:brokeComputer', function(computerID)
        local proba_number = RandomizeNumber()

        --print ('brokeComputer with proba: ' ..proba_number)
        if proba_number < 6 then
            TriggerServerEvent('qbx_Ab_informatic:server:decreaseComputerHealth', computerID, Config.pcbighealth) -- Réduction santé du pc 
        elseif proba_number > 5 and proba_number < 20 then
            TriggerServerEvent('qbx_Ab_informatic:server:decreaseComputerHealth', computerID, Config.pcsmallhealth) -- Réduction santé du pc 
        end


    end)

-- interface stuff

   -- Callback NUI pour recevoir les données
    RegisterNUICallback('submitForm', function(data, cb)
        local firstname = data.firstname
        local lastname = data.lastname
        local kind = data.kind

        -- Envoyer au serveur si nécessaire
        if kind == "productivity" then
            TriggerServerEvent('qbx_Ab_Accueil_InfoProd:server:CheckProductivity', firstname, lastname)
        elseif kind == "job" then
            TriggerServerEvent('qbx_Ab_Accueil_InfoProd:server:CheckJob', firstname, lastname)
        else
            print ('erreur de type de data recherché')
        end

        -- Fermer l'UI
        SetNuiFocus(false, false)
        isUIOpen = false

        cb('ok') -- Répond au NUI que tout est traité
    end)

    -- Fermer l'UI via la touche Échap
    RegisterNUICallback('closeUI', function(data, cb)
        SetNuiFocus(false, false)
        isUIOpen = false

        cb('ok')
    end) 

-- Trigger sur joueur

-- //Cibler les joueurs pour des action
exports.ox_target:addGlobalPlayer({
    {
        name = 'check_name_player',
        icon = 'fa-solid fa-spell-check',
        label = "Verifier l'identité",
        distance = 1.5, -- Distance pour interagir avec un autre joueur
        groups = Config.jobRequired,
        canInteract = function(entity, distance, coords)
    
            -- Permettre l'interaction si l'état est 'active'
            if Config.allow_checkName == true then
                return true
            else
                return false
            end
        end,
        onSelect = function(data)
            local targetPlayerIndex = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
            TriggerServerEvent('qbx_Ab_Accueil_InfoProd:server:CheckName', targetPlayerIndex)
        end
    },
    {
        name = 'check_job_player',
        icon = 'fa-solid fa-user-check',
        label = "Verifier le poste",
        distance = 1.5, -- Distance pour interagir avec un autre joueur
        groups = Config.jobRequired,
        onSelect = function(data)
            local targetPlayerIndex = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
            TriggerServerEvent('qbx_Ab_Accueil_InfoProd:server:CheckJobPlayer', targetPlayerIndex)
        end
    },

})

-- anim 

    RegisterNetEvent('qbx_Ab_Accueil_InfoProd:client:CheckbaseAnim', function(duration)

        local player = PlayerPedId()
        local propmodel_a = 'prop_notepad_01'
        local propmodel_b = 'prop_pencil_01'

        local prop_a = CreateObject(GetHashKey(propmodel_a), 0, 0, 0, true, true, true)
        local prop_b = CreateObject(GetHashKey(propmodel_b), 0, 0, 0, true, true, true)
        AttachEntityToEntity(prop_a, player, GetPedBoneIndex(player, 18905), 0.1, 0.02, 0.05, 10.0, 0.0, 0.0, true, true, false, true, 1, true)
        AttachEntityToEntity(prop_b, player, GetPedBoneIndex(player, 58866), 0.11, -0.02, 0.001, -120.0, 0.0, 0.0, true, true, false, true, 1, true)
        PlayAnimation("missheistdockssetup1clipboard@base", "base", duration, 49)
        DeleteObject(prop_a)
        DeleteObject(prop_b)

    end)

    RegisterNetEvent('qbx_Ab_Accueil_InfoProd:client:CheckJobAnim', function(job)
        local checkduration = 4000

        TriggerEvent('qbx_Ab_Accueil_InfoProd:client:CheckbaseAnim', checkduration)

        Wait(checkduration)

        exports.qbx_core:Notify("Le poste de cette personne est : " ..job, 'inform', 12000)
    
    end)

    RegisterNetEvent('qbx_Ab_Accueil_InfoProd:client:CheckNameAnim', function(name)
        local checkduration = 4000

        TriggerEvent('qbx_Ab_Accueil_InfoProd:client:CheckbaseAnim', checkduration)

        Wait(checkduration)

        exports.qbx_core:Notify("Cette personne s'appelle : " ..name, 'inform', 12000)
    
    end)

    -- Citizen.CreateThread(function()
    --     while true do
    --         if isUIOpen then
    --             Citizen.Wait(0)
    
    --             -- Désactiver toutes les entrées utilisateur
    --             DisableAllControlActions(0)
    
    --             -- Réactiver uniquement certaines touches
    --             EnableControlAction(0, 249, true) -- Push-to-Talk (N)
    --             EnableControlAction(0, 168, true) -- F7
    --         else
    --             Citizen.Wait(500)
    --         end
    --     end
    -- end)

-- event blackout 

    RegisterNetEvent('qbx_Ab_Accueil_InfoProd:client:blackout', function(isblackout)
        blackout = isblackout
    end)

