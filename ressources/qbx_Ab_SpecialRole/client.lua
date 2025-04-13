local killer = false

local playerOutfits = {}


--EVENT

    RegisterNetEvent('qbx_Ab_SpecialRole:client:killermode')
    AddEventHandler('qbx_Ab_SpecialRole:client:killermode', function()
        local playerPed = PlayerPedId()
        local playerId = GetPlayerServerId(PlayerId())
        local isMale = GetEntityModel(playerPed) == `mp_m_freemode_01`

        if playerOutfits[playerId] then -- desactive le mode tueur
            -- Restaurer la tenue d'origine
            local outfit = playerOutfits[playerId]
            for k, v in pairs(outfit.components) do
                SetPedComponentVariation(playerPed, k, v[1], v[2], v[3])
            end
            for k, v in pairs(outfit.props) do
                SetPedPropIndex(playerPed, k, v[1], v[2], true)
            end

            playerOutfits[playerId] = nil -- Supprime la sauvegarde

            -- ici se qu'il se passe en desactivant
            killer = false
            TriggerServerEvent('qbx_Ab_SpecialRole:server:notifykiller', killer)
            exports.qbx_core:Notify("Vous n'êtes plus en tenue pour faire vos méfaits", 'warning', 10000)


        else -- active le mode tueur
            -- Sauvegarder la tenue actuelle
            playerOutfits[playerId] = { components = {}, props = {} }
            for i = 0, 11 do
                local drawable = GetPedDrawableVariation(playerPed, i)
                local texture = GetPedTextureVariation(playerPed, i)
                local palette = GetPedPaletteVariation(playerPed, i)
                playerOutfits[playerId].components[i] = { drawable, texture, palette }
            end
            for i = 0, 7 do
                local propIndex = GetPedPropIndex(playerPed, i)
                local propTexture = GetPedPropTextureIndex(playerPed, i)
                if propIndex ~= -1 then
                    playerOutfits[playerId].props[i] = { propIndex, propTexture }
                end
            end

            -- Appliquer la tenue prédéfinie
            if isMale then
                -- 🏃‍♂️ Tenue pour homme
                SetPedComponentVariation(playerPed, 1, 28, 0, 0) -- masque
                SetPedComponentVariation(playerPed, 3, 31, 0, 0) -- Torse gant en vrai
                SetPedComponentVariation(playerPed, 4, 33, 0, 0) -- Pantalon
                SetPedComponentVariation(playerPed, 5, 0, 0, 0) -- sac a dos
                SetPedComponentVariation(playerPed, 6, 24, 0, 0) -- Chaussures
                SetPedComponentVariation(playerPed, 7, 112, 2, 0) -- accessoire
                SetPedComponentVariation(playerPed, 8, 15, 0, 0) -- undershirt
                SetPedComponentVariation(playerPed, 11, 187, 0, 0) -- Veste

                -- Accessoires homme
                --SetPedPropIndex(playerPed, 0, 5, 0, true) -- Chapeau
                --SetPedPropIndex(playerPed, 1, 0, 0, true) -- Lunettes
            else
                -- 👩 Tenue pour femme
                SetPedComponentVariation(playerPed, 1, 28, 0, 0) -- masque
                SetPedComponentVariation(playerPed, 3, 34, 0, 0) -- Torse gant en vrai
                SetPedComponentVariation(playerPed, 4, 32, 0, 0) -- Pantalon
                SetPedComponentVariation(playerPed, 5, 0, 0, 0) -- sac a dos
                SetPedComponentVariation(playerPed, 6, 24, 0, 0) -- Chaussures
                SetPedComponentVariation(playerPed, 7, 83, 2, 0) -- accessoire
                SetPedComponentVariation(playerPed, 8, 49, 0, 0) -- undershirt
                SetPedComponentVariation(playerPed, 11, 189, 0, 0) -- Veste
                -- Accessoires femme
                --SetPedPropIndex(playerPed, 0, 6, 0, true) -- Chapeau
                --SetPedPropIndex(playerPed, 1, 1, 0, true) -- Lunettes
            end

            --ici ce qu'il se passe en activant
            killer = true
            TriggerServerEvent('qbx_Ab_SpecialRole:server:notifykiller', killer)
            exports.qbx_core:Notify("Vous êtes en tenue pour faire vos méfaits", 'warning', 10000)

        end
    end)

    RegisterNetEvent('qbx_Ab_SpecialRole:client:notifykiller')
    AddEventHandler('qbx_Ab_SpecialRole:client:notifykiller', function(onoff)

        local Playerjob = QBX.PlayerData.job.name

        if Playerjob == 'admin' then
            if onoff == true then
                exports.qbx_core:Notify("Quelqu'un a mis la tenue spécial", 'warning', 10000)
            elseif onoff == false then
                exports.qbx_core:Notify("Quelqu'un a retiré la tenue spécial", 'warning', 10000)
            end
        end

    end)

-- TARGET

    exports.ox_target:addModel(
        Config.changingprops,  
        {  
            -- Option pour se changer
            {
                name = "killermodetoggle",
                label = "Mettre la tenue spécial",
                icon = 'fa-solid fa-vest-patches',
                groups = Config.group,
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('qbx_Ab_SpecialRole:client:killermode')
                end,
            },
        }
    )
