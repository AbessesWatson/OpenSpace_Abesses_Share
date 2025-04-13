local virus_spend = {
    a = false,
    b = false,
    c = false,
    d = false,
    e = false,
    f = false,
    g = false,
    h = false,
    i = false,
    j = false,
    k = false,
    l = false,
    m = false,
    n = false,
    o = false,
    p = false,
    q = false,
    r = false,
    s = false,
    sbis = false,
    t = false,
    u = false,
    v = false,
    x = false,
    twinL = false,
    twinG = false

}

local blackout = 'off'

-- Pour update les virus

    RegisterNetEvent ('qbx_Ab_It_base:Client:recievevirusSpending')
    AddEventHandler('qbx_Ab_It_base:Client:recievevirusSpending', function(dataspending)

        virus_spend = dataspending
        --print ('recievevirusSpending : ' ..json.encode(virus_spend))
    end)

    CreateThread(function() -- pour le lancement du jeu
        while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
            Wait(100)
            --print("En attente des données du joueur (citizenid)...")
        end

        Wait(500)
        TriggerServerEvent('qbx_Ab_It_base:Server:GetvirusSpending')
        --print('Client look for viruses')

    end)

-- FUNCTION

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

    local function checkVirus(bool)
        if bool then
            exports.qbx_core:Notify('Cet ordinateur est contaminé par un virus!', 'error', 8000)
        else
            exports.qbx_core:Notify("Cet ordinateur n'est pas contaminé", 'inform', 8000)
        end
    end

    -- pour retourne le nombre d'ordinateur avec un virus
    local function countActiveVirus()
        local count = 0
        for _, value in pairs(virus_spend) do
            if value == true then
                count = count + 1
            end
        end
        return count
    end
    
    -- retourne un ordinateur au haasard parmis les contaminées
    local function getRandomActiveVirus()
        local activeViruses = {}
        
        -- Remplit la liste des ordinateurs infectés
        for key, value in pairs(virus_spend) do
            if value then
                table.insert(activeViruses, key)
            end
        end
    
        -- Vérifie s'il y a au moins un virus actif
        if #activeViruses > 0 then
            local randomIndex = math.random(1, #activeViruses)
            --print('activeViruses random: ' ..activeViruses[randomIndex])
            return activeViruses[randomIndex] -- Retourne un ordinateur infecté au hasard
        else
            return nil -- Aucun virus actif
        end
    end

-- TARGET 

    exports.ox_target:addModel(
        Config.stashticketprop,  
        {  
            -- ouvrir la zone
            {
                name = "open_ticket_box",
                label = "Boite à tickets",
                icon = "fa-solid fa-box",
                distance = 1.5,
                onSelect = function(data)
                    exports.ox_inventory:openInventory(ticketstash, 'it_box')
                    --print('open drone_delivery')
                end,
            },
        }
    )

    -- Trigger sur ordi
    exports.ox_target:addModel(Config.propscomputer, {
        {    -- check nombre de virus
        name = 'check_virusnumber',
        label = 'Examiner le nombre de contamination',
        icon = 'fa-solid fa-square-virus',
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
            
            TriggerEvent('qbx_Ab_Accueil_InfoProd:client:brokeComputer', computerID)
            TriggerEvent('qbx_Ab_It_base:Client:GetActiveViruses')

        end 
        },
        {    -- cherche un ordinateur contaminé
        name = 'check_virus_random',
        label = 'Chercher un bureau contaminé',
        icon = 'fa-solid fa-virus',
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
            
            TriggerEvent('qbx_Ab_Accueil_InfoProd:client:brokeComputer', computerID)
            TriggerEvent('qbx_Ab_It_base:Client:randomVirusInfected')

        end 
        },
    })

    -- Polyzone de l'infini
        local areaTarget_a = { 
            coords = Config.coord_a,
            name = 'computer_bureau_a', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_a", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.a) 
                    end,
                },
                {
                    name = "fixVirus_a", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.a then
                            local iscontamined = true
                            virus_spend.a = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.a = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_b = { 
            coords = Config.coord_b,
            name = 'computer_bureau_b', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_b", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.b) 
                    end,
                },
                {
                    name = "fixVirus_b", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.b then
                            local iscontamined = true
                            virus_spend.b = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.b = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_c = { 
            coords = Config.coord_c,
            name = 'computer_bureau_c', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_c", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.c) 
                    end,
                },
                {
                    name = "fixVirus_c", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.c then
                            local iscontamined = true
                            virus_spend.c = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.c = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_d = { 
            coords = Config.coord_d,
            name = 'computer_bureau_d', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_d", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.d) 
                    end,
                },
                {
                    name = "fixVirus_b", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.d then
                            local iscontamined = true
                            virus_spend.d = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.d = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_e = { 
            coords = Config.coord_e,
            name = 'computer_bureau_e', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_e", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.e) 
                    end,
                },
                {
                    name = "fixVirus_e", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.e then
                            local iscontamined = true
                            virus_spend.e = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.e = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_f = { 
            coords = Config.coord_f,
            name = 'computer_bureau_f', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_f", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.f) 
                    end,
                },
                {
                    name = "fixVirus_f", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.f then
                            local iscontamined = true
                            virus_spend.f = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.f = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_g = { 
            coords = Config.coord_g,
            name = 'computer_bureau_g', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_g", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.g) 
                    end,
                },
                {
                    name = "fixVirus_g", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.g then
                            local iscontamined = true
                            virus_spend.g = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.g = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_h = { 
            coords = Config.coord_h,
            name = 'computer_bureau_h', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_h", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.h) 
                    end,
                },
                {
                    name = "fixVirus_h", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.h then
                            local iscontamined = true
                            virus_spend.h = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.h = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_i = { 
            coords = Config.coord_i,
            name = 'computer_bureau_i', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_i", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.i) 
                    end,
                },
                {
                    name = "fixVirus_i", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.i then
                            local iscontamined = true
                            virus_spend.i = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.i = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_j = { 
            coords = Config.coord_j,
            name = 'computer_bureau_j', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_j", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.g) 
                    end,
                },
                {
                    name = "fixVirus_j", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.j then
                            local iscontamined = true
                            virus_spend.j = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.j = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_k = { 
            coords = Config.coord_k,
            name = 'computer_bureau_k', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_k", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.k) 
                    end,
                },
                {
                    name = "fixVirus_k", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.k then
                            local iscontamined = true
                            virus_spend.k = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.k = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_l = { 
            coords = Config.coord_l,
            name = 'computer_bureau_l', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_l", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.g) 
                    end,
                },
                {
                    name = "fixVirus_l", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.l then
                            local iscontamined = true
                            virus_spend.l = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.l = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_m = { 
            coords = Config.coord_m,
            name = 'computer_bureau_g', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_m", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.m) 
                    end,
                },
                {
                    name = "fixVirus_m", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.m then
                            local iscontamined = true
                            virus_spend.m = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.m = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_n = { 
            coords = Config.coord_n,
            name = 'computer_bureau_n', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_n", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.n) 
                    end,
                },
                {
                    name = "fixVirus_n", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.n then
                            local iscontamined = true
                            virus_spend.n = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.n = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_o = { 
            coords = Config.coord_o,
            name = 'computer_bureau_o', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_o", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.o) 
                    end,
                },
                {
                    name = "fixVirus_o", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.o then
                            local iscontamined = true
                            virus_spend.o = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.o = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_p = { 
            coords = Config.coord_p,
            name = 'computer_bureau_p', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_p", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.p) 
                    end,
                },
                {
                    name = "fixVirus_p", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.p then
                            local iscontamined = true
                            virus_spend.p = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.p = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_q = { 
            coords = Config.coord_q,
            name = 'computer_bureau_q', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_q", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.q) 
                    end,
                },
                {
                    name = "fixVirus_q", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.q then
                            local iscontamined = true
                            virus_spend.q = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.q = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_r = { 
            coords = Config.coord_r,
            name = 'computer_bureau_r', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_r", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.r) 
                    end,
                },
                {
                    name = "fixVirus_r", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.r then
                            local iscontamined = true
                            virus_spend.r = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.r = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_s = { 
            coords = Config.coord_s,
            name = 'computer_bureau_s', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_s", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.s) 
                    end,
                },
                {
                    name = "fixVirus_s", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.s then
                            local iscontamined = true
                            virus_spend.s = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.s = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_sbis = { 
            coords = Config.coord_sbis,
            name = 'computer_bureau_sbis', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_sbis", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.sbis) 
                    end,
                },
                {
                    name = "fixVirus_sbis", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.sbis then
                            local iscontamined = true
                            virus_spend.sbis = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.sbis = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_t = { 
            coords = Config.coord_t,
            name = 'computer_bureau_t', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_t", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.t) 
                    end,
                },
                {
                    name = "fixVirus_t", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.t then
                            local iscontamined = true
                            virus_spend.t = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.t = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_u = { 
            coords = Config.coord_u,
            name = 'computer_bureau_u', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_u", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.u) 
                    end,
                },
                {
                    name = "fixVirus_u", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.u then
                            local iscontamined = true
                            virus_spend.u = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.u = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_v = { 
            coords = Config.coord_v,
            name = 'computer_bureau_v', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_v", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.v) 
                    end,
                },
                {
                    name = "fixVirus_v", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.v then
                            local iscontamined = true
                            virus_spend.v = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.v = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_x = { 
            coords = Config.coord_x,
            name = 'computer_bureau_x', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_x", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.x) 
                    end,
                },
                {
                    name = "fixVirus_x", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.x then
                            local iscontamined = true
                            virus_spend.x = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.x = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_twinL = { 
            coords = Config.coord_twinL,
            name = 'computer_bureau_twinL', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_twinL", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.twinL) 
                    end,
                },
                {
                    name = "fixVirus_twinL", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.twinL then
                            local iscontamined = true
                            virus_spend.twinL = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.twinL = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        local areaTarget_twinG = { 
            coords = Config.coord_twinG,
            name = 'computer_bureau_twinG', 
            radius = 0.5,
            debug = false,
            drawSprite = false,
            options = {  
                {
                    name = "checkVirus_twinG", 
                    label = "Verifier la présence de virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.diagitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        checkVirus(virus_spend.twinG) 
                    end,
                },
                {
                    name = "fixVirus_twinG", 
                    label = "Utiliser une disquette anti-virus",
                    icon = 'fa-solid fa-virus',
                    groups = Config.jobRequired,
                    items = Config.antivirusitem,
                    distance = 1,
                    canInteract = function(entity, distance, coords)
                        if blackout == 'off' then
                            return true

                        else
                            return false
                        end
                    end,
                    onSelect = function(data)
                        if virus_spend.twinG then
                            local iscontamined = true
                            virus_spend.twinG = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        else
                            local iscontamined = false
                            virus_spend.twinG = false 
                            TriggerEvent('qbx_Ab_It_base:Client:fixVirus_anim', iscontamined)
                        end             
                    end,
                },
            }
        }

        exports.ox_target:addSphereZone(areaTarget_a)
        exports.ox_target:addSphereZone(areaTarget_b)
        exports.ox_target:addSphereZone(areaTarget_c)
        exports.ox_target:addSphereZone(areaTarget_d)
        exports.ox_target:addSphereZone(areaTarget_e)
        exports.ox_target:addSphereZone(areaTarget_f)
        exports.ox_target:addSphereZone(areaTarget_g)
        exports.ox_target:addSphereZone(areaTarget_h)
        exports.ox_target:addSphereZone(areaTarget_i)
        exports.ox_target:addSphereZone(areaTarget_j)
        exports.ox_target:addSphereZone(areaTarget_k)
        exports.ox_target:addSphereZone(areaTarget_l)
        exports.ox_target:addSphereZone(areaTarget_m)
        exports.ox_target:addSphereZone(areaTarget_n)
        exports.ox_target:addSphereZone(areaTarget_o)
        exports.ox_target:addSphereZone(areaTarget_p)
        exports.ox_target:addSphereZone(areaTarget_q)
        exports.ox_target:addSphereZone(areaTarget_r)
        exports.ox_target:addSphereZone(areaTarget_s)
        exports.ox_target:addSphereZone(areaTarget_sbis)
        exports.ox_target:addSphereZone(areaTarget_t)
        exports.ox_target:addSphereZone(areaTarget_u)
        exports.ox_target:addSphereZone(areaTarget_v)
        exports.ox_target:addSphereZone(areaTarget_x)
        exports.ox_target:addSphereZone(areaTarget_twinL)
        exports.ox_target:addSphereZone(areaTarget_twinG)

-- EVENT

    -- Animation pour remplir la fontaine avec la bonbonne
    RegisterNetEvent('qbx_Ab_It_base:Client:fixVirus_anim')
    AddEventHandler('qbx_Ab_It_base:Client:fixVirus_anim', function(iscontamined)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local animdict = "anim@amb@warehouse@laptop@"  -- Exemple d'animation
        local animname = "idle_a"
        local duration = Config.duration_virusfix

        -- Charger et jouer l'animation
        RequestAnimDict(animdict)
        while not HasAnimDictLoaded(animdict) do
            Wait(100)
        end

        FreezeEntityPosition(playerPed, true)
        TaskPlayAnim(playerPed, animdict, animname, 3.0, 3.0, duration, 49, 0, false, false, false)

        Wait(duration)
        FreezeEntityPosition(playerPed, false)
        if iscontamined then 
            TriggerServerEvent('server:addProductivity', Config.prod_up) -- Event qui augmente la productivity de 1
            TriggerServerEvent('server:addJobProductivity', Config.jobtoprod, Config.prod_up) -- Augmente la productivité du job
            TriggerServerEvent("qbx_Ab_Archive_base:server:addDocToStash", "it") -- ajoute un doc a trier pour archive
            exports.qbx_core:Notify("Vous avez sacrifié cette disquette pour décontaminer cet ordinateur", 'inform', 10000)
        else
            exports.qbx_core:Notify("Vous avez sacrifié cette disquette pour rien", 'error', 10000)
        end
        TriggerServerEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue', Config.fatigue_up) 
        TriggerServerEvent('hud:server:GainStress',Config.stress_up)
        TriggerServerEvent('qbx_Ab_It_base:Server:updatevirusSpending', virus_spend)
        TriggerServerEvent('qbx_Ab_It_base:Server:brokeFloppyDisk')

        ClearPedTasks(playerPed) -- Arrêter l'animation
        RemoveAnimDict(animdict)
    end)

    -- Event pour avoir le nombre d'ordi infécté par un virus
    RegisterNetEvent('qbx_Ab_It_base:Client:GetActiveViruses')
    AddEventHandler('qbx_Ab_It_base:Client:GetActiveViruses', function()
        local activeViruses = countActiveVirus()
        exports.qbx_core:Notify("Nombre d'ordinateurs infectés à l'étage des bureaux est : " .. activeViruses, 'error', 10000)
    end)
    
    -- Event pour avoir un ordinateur infecté au hasard
    RegisterNetEvent('qbx_Ab_It_base:Client:randomVirusInfected')
    AddEventHandler('qbx_Ab_It_base:Client:randomVirusInfected', function()
        local randomVirus = getRandomActiveVirus()

        if randomVirus == 'a' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>15-A</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'b' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>9-B</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'c' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>17-C</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'd' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>8-D</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'e' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>3-E</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'f' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>12-F</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'g' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>13-G</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'h' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>6-H</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'i' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>11-I</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'j' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>22-J</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'k' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>4-K</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'l' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>19-L</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'm' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>2-M</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'n' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>18-N</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'o' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>1-O</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'p' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>5-P</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'q' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>20-Q</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'r' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>16-R</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 's' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>20-S</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'sbis' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>23-S</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 't' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>10-T</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'u' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>14-U</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'v' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>24-V</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'x' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>7-X</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'twinL' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>Jumeau Droite</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == 'twinG' then 
            exports.qbx_core:Notify("L'ordinateur du bureau <b>Jumeau Gauche</b> est contaminé par un virus!", 'error', 10000)
        elseif randomVirus == nil then
            exports.qbx_core:Notify("Aucun virus n'est detecté!", 'inform', 10000)
        end

    end)

    -- Event ordi

    RegisterNetEvent('qbx_Ab_It_base:client:brokeComputer', function(computerID)
        local proba_number = RandomizeNumber()

        --print ('brokeComputer with proba: ' ..proba_number)
        if proba_number < 21 then
            TriggerServerEvent('qbx_Ab_informatic:server:decreaseComputerHealth', computerID, Config.pcbighealth) -- Réduction santé du pc 
        elseif proba_number > 20 and proba_number < 60 then
            TriggerServerEvent('qbx_Ab_informatic:server:decreaseComputerHealth', computerID, Config.pcsmallhealth) -- Réduction santé du pc 
        end


    end)

    -- event blackout 

    RegisterNetEvent('qbx_Ab_It_base:client:blackout', function(isblackout)
        blackout = isblackout
    end)

-- COMMANDE 
    RegisterCommand("countvirus", function(source, args, rawCommand)
        TriggerEvent('qbx_Ab_It_base:Client:GetActiveViruses')
    end, false)
    
    RegisterCommand("randomvirus", function(source, args, rawCommand)
        TriggerEvent('qbx_Ab_It_base:Client:randomVirusInfected')
    end, false)