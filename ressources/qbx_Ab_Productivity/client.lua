-- local QBCore = exports['qb-core']:GetCoreObject() ancien

local isImageVisible = false

local Productivity_to_update = 0
local New_Productivity_to_update = 0

-- on start

CreateThread(function() -- Pour charger le niveau d'alcool au dépar

    while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
        Wait(100)
        --print("En attente des données du joueur (citizenid)...")
    end

    local citizenid = QBX.PlayerData.citizenid
    TriggerServerEvent('qbx_Ab_Productivity:server:initProdClient', citizenid)

end)

-- EVENT

    -- Event pour recevoir la nouvelle productivité
    RegisterNetEvent('qbx_Ab_Productivity:client:initProd', function (value)

        Productivity_to_update = value
        New_Productivity_to_update = Productivity_to_update
        print('Productivité initialisé') 

    end)

    -- Event pour recevoir la nouvelle productivité
    RegisterNetEvent('qbx_Ab_Productivity:Client:productivityToNotify', function (newProductivity)
        --print('update client prod to notify from :' ..New_Productivity_to_update.. 'to ' ..newProductivity)
        New_Productivity_to_update = newProductivity

    end)

    -- Événement client pour afficher l'UI de productivité
    RegisterNetEvent('client:showProductivityUI')
    AddEventHandler('client:showProductivityUI', function(name, productivity,namehigh, namelow, jobhigh)
        local playerPed = PlayerPedId() -- Récupère le Ped du joueur
        FreezeEntityPosition(playerPed, true) -- Fige le joueur

        SendNUIMessage({
            type = "show",
            name = name,
            productivity = productivity,
            namehigh = namehigh,
            namelow = namelow,
            jobhigh = jobhigh
        }) -- Active l'interface NUI
    end)

    -- Callback pour fermer l'interface NUI depuis le client
    RegisterNUICallback('close', function(data, cb)
        cb('ok')
    end)

-- THREAD

    CreateThread(function() -- Pour notifié lorsque la productivité augmente au baisse
        Wait (1000)

        while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
            Wait(100)
            --print("En attente des données du joueur (citizenid)...")
        end

        while true do

            if New_Productivity_to_update >= Productivity_to_update + 3 then
                exports.qbx_core:Notify('Votre productivité a grandement augmenté! ', 'success', 8000) 
                Wait (500)
                Productivity_to_update = New_Productivity_to_update
            elseif New_Productivity_to_update >= Productivity_to_update + 1 then
                exports.qbx_core:Notify('Votre productivité a augmenté! ', 'success', 8000) 
                Wait (500)
                Productivity_to_update = New_Productivity_to_update
            elseif New_Productivity_to_update <= Productivity_to_update - 3 then
                exports.qbx_core:Notify('Votre productivité a grandement baissé! ', 'warning', 8000)  
                Wait (500)
                Productivity_to_update = New_Productivity_to_update
            elseif New_Productivity_to_update <= Productivity_to_update - 1 then
                exports.qbx_core:Notify('Votre productivité a baissé! ', 'warning', 8000)
                Wait (500)
                Productivity_to_update = New_Productivity_to_update
                
            end 
            Wait (1000)
        end

    end)

    CreateThread(function() -- regarder le tableau
        while true do
            local interval = 2

            if  isImageVisible then
                if IsControlJustPressed(1,194) or IsControlJustPressed(0, 200) then -- Les choses se passe ici
                    isImageVisible = false
                    SetNuiFocus(false, false) -- Désactive l'interface NUI
                    SendNUIMessage({ type = 'hide' }) 

                    local playerPed = PlayerPedId() -- Récupère le Ped du joueur
                    FreezeEntityPosition(playerPed, false) -- Fige le joueur
                end
            end
        
            Citizen.Wait (interval)
            end
        end)

-- TARGET

    local areaBoardTarget = { -- tableau de prod
    coords = vec3(5.2, 211.7, -18.5),
    name = 'board_prod',
    radius = 0.8,
    debug = false,
    drawSprite = false,
    distance = 1,
    options = {
        -- Option pour regarder le tableau
        {
            name = "check_prodboard",
            label = "Regarder le tableau de productivité",
            icon = 'fas fa-user',
            canInteract = function(entity, distance, coords)
                if isImageVisible then
                    return false
                else
                    return true
                end
            end,
            onSelect = function(data)
                isImageVisible = true
                TriggerServerEvent('server:viewproductivity') 
            end,
        }

    }
    }
    exports.ox_target:addSphereZone(areaBoardTarget) 

    -- Cibler les joueurs pour réduir et augmenter la prod (admin)
    exports.ox_target:addGlobalPlayer({

        {
                
            label = '[admin] Productivité +1',
            icon = 'fa-solid fa-arrow-up',
            distance = 1.5, -- Distance pour interagir avec un autre joueur
            groups = "admin",
            onSelect = function(data)
                value = 1
                local targetPlayerIndex = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                --print ('targetPlayerIndex : ' ..targetPlayerIndex)
                TriggerEvent('qbx_Ab_Productivity:client:prodVariation', value, targetPlayerIndex)
                exports.qbx_core:Notify('Vous avez augmenter la productivité de cette personne de 1', 'inform', 8000)

            end
        },
        {
                
            label = '[admin] Productivité +3',
            icon = 'fa-solid fa-up-long',
            distance = 1.5, -- Distance pour interagir avec un autre joueur
            groups = "admin",
            onSelect = function(data)
                value = 3
                local targetPlayerIndex = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                --print ('targetPlayerIndex : ' ..targetPlayerIndex)
                TriggerEvent('qbx_Ab_Productivity:client:prodVariation', value, targetPlayerIndex)
                exports.qbx_core:Notify('Vous avez augmenter la productivité de cette personne de 3', 'inform', 8000)

            end
        },
        {
        
            label = '[admin] Productivité -1',
            icon = 'fa-solid fa-arrow-down',
            distance = 1.5, -- Distance pour interagir avec un autre joueur
            groups = "admin",
            onSelect = function(data)
                value = -1
                local targetPlayerIndex = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                --print ('targetPlayerIndex : ' ..targetPlayerIndex)
                TriggerEvent('qbx_Ab_Productivity:client:prodVariation', value, targetPlayerIndex)
                exports.qbx_core:Notify('Vous avez réduit la productivité de cette personne de 1', 'inform', 8000)

            end
        },
        {
        
            label = '[admin] Productivité -3',
            icon = 'fa-solid fa-down-long',
            distance = 1.5, -- Distance pour interagir avec un autre joueur
            groups = "admin",
            onSelect = function(data)
                value = -3
                local targetPlayerIndex = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                --print ('targetPlayerIndex : ' ..targetPlayerIndex)
                TriggerEvent('qbx_Ab_Productivity:client:prodVariation', value, targetPlayerIndex)
                exports.qbx_core:Notify('Vous avez réduit la productivité de cette personne de 3', 'inform', 8000)

            end
        },

    })

    -- Event pour trigger l'anim et le changement
    RegisterNetEvent('qbx_Ab_Productivity:client:prodVariation', function(value, target)
        local animduration = 2000

        TriggerEvent('qbx_Ab_Accueil_InfoProd:client:CheckbaseAnim', animduration)
        Wait (animduration)
        TriggerServerEvent('server:addProductivity', value, target)
    end)
