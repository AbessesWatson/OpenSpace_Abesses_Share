local blackout = 'off'

-- Fonction pour désactiver les contrôles principaux
local function DisablePlayerActions()
    local controls = {
        24,  -- Attaque (clic gauche)
        25,  -- Visée (clic droit)
        30,  -- Déplacement gauche/droite
        31,  -- Déplacement avant/arrière
        36,  -- Accroupissement
        44,  -- Rechargement
        140, -- Attaque au corps à corps
        257, -- Attaque (contrôle secondaire)
        263  -- Visée (contrôle secondaire)
    }

    for _, control in ipairs(controls) do
        DisableControlAction(0, control, true)
    end
end

-- Fonction pour vérifier l'état d'un ordinateur
local function checkComputerState(computerID)
    -- Retourner l'état de l'ordinateur localement stocké
    return computer[computerID] and computer[computerID].state or 'active'
end

local isImageVisible = false -- Variable pour vérifier si l'image est affichée
local disabletargettoggle = false

CreateThread(function() -- utiliser le manuel
    while true do
        local interval = 2

        if isImageVisible then

            -- Appeler la fonction pour désactiver les actions
            DisablePlayerActions()
            if not disabletargettoggle then
                exports.ox_target:disableTargeting(true)
                disabletargettoggle = true
            end

            if IsControlJustPressed(1, 194) or IsControlJustPressed(0, 200) then -- Les choses se passent ici
                print('BACKSPACE or ECHAP PRESSED')
                isImageVisible = false
                SetNuiFocus(false, false) -- Désactive l'interface NUI
                SendNUIMessage({ action = 'hideImage' }) 
            end
        elseif disabletargettoggle then
            exports.ox_target:disableTargeting(false)
            disabletargettoggle = false
        end

        Citizen.Wait(interval)
    end
end)

exports.ox_target:addModel(
    Config.propscomputer, 
    {  
        {
        name = 'doc_soluce_location',
        icon = 'fas fa-search',
        label = 'Lire le guide pour les devis',
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
            if not isImageVisible then
                isImageVisible = true
                SetNuiFocus(false, false) -- Active le focus NUI pour capturer les entrées clavier
                SendNUIMessage({
                    action = 'showImage', -- Action pour afficher l'image
                })
            end
        end,
        }
    }
)

-- event blackout 

RegisterNetEvent('qbx_Ab_soluce_devis:client:blackout', function(isblackout)
    blackout = isblackout
end)