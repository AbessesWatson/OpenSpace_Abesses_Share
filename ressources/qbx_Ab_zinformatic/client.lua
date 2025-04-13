computer = {}

local blackout = 'off'

-- FUNCTION

-- Fonction pour vérifier l'état d'un ordinateur
local function checkComputerState(computerID)
    -- Retourner l'état de l'ordinateur localement stocké
    return computer[computerID] and computer[computerID].state or 'active'
end


-- EVENT

-- Synchroniser les données d'un prop


RegisterNetEvent('qbx_Ab_informatic:client:syncComputer', function(computerID, state, health)
    computer[computerID] = {state = state, health = health}
    --print("Synchronisation : ", computerID, json.encode(computer[computerID]))
end)

-- Récupérer et synchroniser l'état de tous les ordinateurs
RegisterNetEvent('qbx_Ab_informatic:client:syncAllComputers', function(computerData)
    for _, c in ipairs(computerData) do
        computer[c.id] = {state = c.state, health = c.health}
    end
end)

-- COMMANDE

-- Initialiser un prop
RegisterCommand('showComputers', function()
    print("Affichage de tous les ordinateurs :")
    for computerID, data in pairs(computer) do
        print(string.format("Ordinateur ID: %s, État: %s, Santé: %d", computerID, data.state, data.health))
    end
end, false)



-- Mettre à jour un prop IMPORTANT
exports.ox_target:addModel(Config.prop_computer, {
    {    -- ordinateur verrouillé car cassé
    name = 'show_broken_computer',
    label = "L'ordinateur est inutilisable",
    icon = 'fa-solid fa-screwdriver-wrench',
    distance = 1.5,
    canInteract = function(entity, distance, coords)
        local computerID = GetEntityCoords(entity)

        -- Vérifier l'état de l'ordinateur localement
        local state = checkComputerState(json.encode(computerID))

        -- Permettre l'interaction si l'état est 'broken'
        if blackout == 'off' then
            if state == 'broken' then
                return true
            else
                return false
            end
        else
            return false
        end
    end,

    onSelect = function(data)
        
    end
    },

    {    -- ordinateur verrouillé car fulllock
    name = 'show_full_lock_computer',
    label = "L'ordinateur est inutilisable",
    icon = 'fa-solid fa-screwdriver-wrench',
    distance = 1.5,
    canInteract = function(entity, distance, coords)
        local computerID = GetEntityCoords(entity)

        -- Vérifier l'état de l'ordinateur localement
        local state = checkComputerState(json.encode(computerID))

        -- Permettre l'interaction si l'état est 'broken'
        if blackout == 'off' then
            if state == 'full_lock' then
                return true
            else
                return false
            end
        else
            return false
        end
    end,

    onSelect = function(data)
        
    end
    },

    {    -- ordinateur verrouillé car lock
    name = 'show_lock_computer',
    label = "L'ordinateur est inutilisable",
    icon = 'fa-solid fa-screwdriver-wrench',
    distance = 1.5,
    canInteract = function(entity, distance, coords)
        local computerID = GetEntityCoords(entity)

        -- Vérifier l'état de l'ordinateur localement
        local state = checkComputerState(json.encode(computerID))

        -- Permettre l'interaction si l'état est 'broken'
        if blackout == 'off' then
            if state == 'lock' then
                return true
            else
                return false
            end
        else
            return false
        end
    end,

    onSelect = function(data)
        
    end
    },

    {    -- Réparer l'ordinateur
        name = 'fix_computer',
        label = 'Réparer',
        icon = 'fa-solid fa-screwdriver-wrench',
        groups = {"it", 'admin'},
        items = {"good_carte_mere", "repear_kit"},
        distance = 1.5,
        canInteract = function(entity, distance, coords)
            local computerID = GetEntityCoords(entity)

            -- Vérifier l'état de l'ordinateur localement
            local state = checkComputerState(json.encode(computerID))

            -- Permettre l'interaction si l'état est 'broken'
            if blackout == 'off' then
                if state == 'broken' then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end,

        onSelect = function(data)
            if isRepairInProgress then
                return
            end

            -- Verrouiller l'état de réparation
            isRepairInProgress = true

            local coords = GetEntityCoords(data.entity)
            TriggerServerEvent('qbx_Ab_informatic:server:attemptRepair', coords)

            Wait(Config.time.repair_time) -- Simulation de la durée de réparation (ajustez selon besoin)
            isRepairInProgress = false -- Réinitialiser l'état après la réparation
        end
    },

    {    -- casser l'ordinateur
        name = 'break_computer',
        label = 'Casser',
        icon = 'fa-solid fa-hammer',
        groups = {'tueur'},
        distance = 1.5,
        canInteract = function(entity, distance, coords)
            local computerID = GetEntityCoords(entity)

            -- Vérifier l'état de l'ordinateur localement
            local state = checkComputerState(json.encode(computerID))

            -- Permettre l'interaction si l'état est 'broken'
            if state == 'active' then
                return true
            else
                return false
            end
        end,
        onSelect = function(data)
            local coords = GetEntityCoords(data.entity)
            TriggerServerEvent('qbx_Ab_informatic:server:saveComputer', json.encode(coords), 'broken', 0)
        end
    },

    {    -- diagnostique de l'ordinateur
    name = 'diagnostic_computer',
    label = "Diagnostiquer l'ordinateur",
    icon = 'fa-regular fa-clipboard',
    groups = {"it","admin"},
    items = "diagnostic_kit",
    distance = 1.5,
    canInteract = function(entity, distance, coords)
        -- Permettre l'interaction si l'état est 'broken'
        if blackout == 'off' then
            return true
        else
            return false
        end
    end,
    onSelect = function(data)
        local computerID = GetEntityCoords(data.entity)
        local state = checkComputerState(json.encode(computerID))
        TriggerEvent('qbx_Ab_informatic:client:diagComputerAnimation')
        Wait(Config.time.diag_time)
        
        if state == 'broken' then
            TriggerEvent('QBCore:Notify', "L'ordinateur est cassé. Il faut changer la carte mère.", "error", 8000)
        elseif state == 'full_lock' then
            TriggerEvent('QBCore:Notify', "L'ordinateur fait un long calcule.", "warning", 8000)
            Wait (1000)
            TriggerEvent('QBCore:Notify', "Un.e Coordinateur.rice Fonctionnel peut y remédier.", "warning", 8000)
        elseif state == 'lock' then
            TriggerEvent('QBCore:Notify', "L'ordinateur fait un calcule court.", "inform", 8000)
            Wait (1000)
            TriggerEvent('QBCore:Notify', "Veuillez patienter.", "inform", 8000)
        elseif state == 'active' then
            TriggerEvent('QBCore:Notify', "L'ordinateur fonctionne.", "inform", 8000)
        else
            TriggerEvent('QBCore:Notify', "L'ordinateur a un gros problème.", "error", 8000)
            Wait (1000)
            TriggerEvent('QBCore:Notify', "Si le problème persiste.", "error", 8000)
            Wait (1000)
            TriggerEvent('QBCore:Notify', "Veuillez contacter un superieur.", "error", 8000)
        end
    end
    },

    {    -- Strange Folder
    name = 'strange_folder',
    label = 'Ranger les fichiers',
    icon = 'fa-solid fa-folder',
    groups = {"archive", "admin"},
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
        local isGameOpen = false

        if not isGameOpen then
            isGameOpen = true
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'openGame', -- pour ouvrir l'ui
                computerID = json.encode(GetEntityCoords(data.entity)) -- Inclure le computerID
            })
        end
    end 
    },
    
    {    -- unlock full lock ordinateur
    name = 'unlock_full_lock_computer',
    label = 'Réduire le temps de calcule',
    icon = 'fa-regular fa-clock', 
    groups = {"accueil", 'admin'},
    distance = 1.5,
    canInteract = function(entity, distance, coords)
        local computerID = GetEntityCoords(entity)

        -- Vérifier l'état de l'ordinateur localement
        local state = checkComputerState(json.encode(computerID))

        -- Permettre l'interaction si l'état est 'broken'
        if blackout == 'off' then
            if state == 'full_lock' then
                return true
            else
                return false
            end
        else
            return false
        end
    end,

    onSelect = function(data)
        local computerID = json.encode(GetEntityCoords(data.entity))
        print("pour unlock" .. computerID)
        TriggerEvent('qbx_Ab_informatic:client:unlock_computer', computerID)
    end
    },
})


CreateThread(function()
    TriggerServerEvent('qbx_Ab_informatic:server:getAllComputers')
    print('update computer')
end)

AddEventHandler('playerLoaded', function()
    -- Demander au serveur de récupérer tous les ordinateurs
    TriggerServerEvent('qbx_Ab_informatic:server:getAllComputers')
    print('PLayer Loaded')
end)

AddEventHandler('onClientGameTypeStart', function()
    TriggerServerEvent('qbx_Ab_informatic:server:getAllComputers')
    print('onClientGameTypeStart')
end)


-- Ordinateur inutilisable: 

-- Mettre à jour un prop IMPORTANT
exports.ox_target:addModel(Config.prop_uselesscomputer, {
    {    -- ordinateur verrouillé car cassé
    name = 'useless_computer',
    label = "L'accès à cette ordinateur est restreint",
    icon = 'fa-solid fa-ban',
    canInteract = function(entity, distance, coords)
        -- Permettre l'interaction si l'état est 'broken'
        if blackout == 'off' then
            return true
        else
            return false
        end
    end,
    onSelect = function(data)
        
    end
    },
})

-- event blackout 

RegisterNetEvent('qbx_Ab_informatic:client:blackout', function(isblackout)
    blackout = isblackout
end)