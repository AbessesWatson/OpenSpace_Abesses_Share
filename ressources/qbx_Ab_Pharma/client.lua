local blackout = 'off'

--FUNCTION

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

    -- Fonction pour vérifier l'état d'un ordinateur
    local function checkComputerState(computerID)
        -- Retourner l'état de l'ordinateur localement stocké
        return computer[computerID] and computer[computerID].state or 'active'
    end

-- EVENT

RegisterNetEvent('qbx_Ab_Pharma:client:deliveryAnimReward')
AddEventHandler('qbx_Ab_Pharma:client:deliveryAnimReward', function(isreward)

    local playerPed = PlayerPedId()
    local animdict = "move_mop"  -- Exemple d'animation
    local animname = "idle_scrub_small_player"
    local duration = 1000

    PlayAnimation("anim@move_m@trash", "pickup", duration, 49)

    if isreward then
        TriggerServerEvent('server:addProductivity', Config.prod_up) -- Event qui augmente la productivity
        TriggerServerEvent('server:addJobProductivity', Config.jobtoprod, Config.prod_up) -- Augmente la productivité du job
        TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.fatigue_up) -- augmente la fatigue
        TriggerServerEvent('hud:server:GainStress',Config.stress_up_low) -- auigment le stress
    else
        TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.fatigue_up) -- augmente la fatigue
        TriggerServerEvent('hud:server:GainStress',Config.stress_up_high) -- auigment le stress
    end


end)

-- Target

    exports.ox_target:addModel(
        Config.delivery_props, 
        { 
            {
                name = "deliver_anxiolytique_box",
                label = "Livrer une boite d'anxiolytique",
                icon = 'fa-solid fa-truck-medical',
                items = Config.box_item.anxiolytique_box,
                groups = Config.jobRequired,
                distance = 1.5,
                onSelect = function(data)
                    TriggerServerEvent('qbx_Ab_Pharma:server:delivery', Config.box_item.anxiolytique_box)
                end,
            },
            {
                name = "deliver_beta_bloquant_box",
                label = "Livrer une boite de bêta-bloquant",
                icon = 'fa-solid fa-truck-medical',
                items = Config.box_item.beta_bloquant_box,
                groups = Config.jobRequired,
                distance = 1.5,
                onSelect = function(data)
                    TriggerServerEvent('qbx_Ab_Pharma:server:delivery', Config.box_item.beta_bloquant_box)
                end,
            },
            {
                name = "deliver_vitamines_box",
                label = "Livrer une boite de vitamines",
                icon = 'fa-solid fa-truck-medical',
                items = Config.box_item.vitamines_box,
                groups = Config.jobRequired,
                distance = 1.5,
                onSelect = function(data)
                    TriggerServerEvent('qbx_Ab_Pharma:server:delivery', Config.box_item.vitamines_box)
                end,
            },
            {
                name = "deliver_modafinil_box",
                label = "Livrer une boite de modafinils",
                icon = 'fa-solid fa-truck-medical',
                items = Config.box_item.modafinil_box,
                groups = Config.jobRequired,
                distance = 1.5,
                onSelect = function(data)
                    TriggerServerEvent('qbx_Ab_Pharma:server:delivery', Config.box_item.modafinil_box)
                end,
            },
            {
                name = "deliver_medicament_box",
                label = "Livrer une boite de médicaments",
                icon = 'fa-solid fa-truck-medical',
                items = Config.box_item.medicament_box,
                groups = Config.jobRequired,
                distance = 1.5,
                onSelect = function(data)
                    TriggerServerEvent('qbx_Ab_Pharma:server:delivery', Config.box_item.medicament_box)
                end,
            },
                
        }
    )

        -- Trigger sur ordi
        exports.ox_target:addModel(Config.propscomputer, {
            {    -- check la commande
            name = 'check_pharma_command',
            label = 'Regarder la commande pharmaceutique',
            icon = 'fa-solid fa-comment-medical',
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
                
                TriggerServerEvent('qbx_Ab_Pharma:server:deliveryCheck')
    
            end 
            },
        })

-- event blackout 

    RegisterNetEvent('qbx_Ab_Pharma:client:blackout', function(isblackout)
        blackout = isblackout
    end)