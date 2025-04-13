local function repairComputerAnimation()
    local playerPed = PlayerPedId()
    local anim = 'mini@repair'
    local anim_name = 'fixing_a_ped'

    -- On charge l'animation
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Wait(100)
    end

    -- Jouer l'animation
    TaskPlayAnim(playerPed, anim, anim_name, 1.0, 1.0, Config.time.repair_time, 1, 0, false, false, false)
    --Wait(Config.time.repair_time) -- Temps de réparation (ajustez la durée si nécessaire)
    ClearPedTasks(playerPed) -- Arrête l'animation
    RemoveAnimDict(animDict)
end



RegisterNetEvent('qbx_Ab_informatic:client:repairComputerAnimation', function()
    repairComputerAnimation()
    Wait(Config.time.repair_time)

end)

-- Événement déclenché en cas de réussite
RegisterNetEvent('qbx_Ab_informatic:client:repairSuccess', function(coords)
    TriggerServerEvent('server:addProductivity', Config.upprod.repairComputer) -- Event qui augmente la productivity de 1 
    TriggerServerEvent('server:addJobProductivity', 'it', Config.upprod.repairComputer) -- Augmente la productivité du job
    TriggerServerEvent("qbx_Ab_Archive_base:server:addDocToStash", "it") -- ajoute un doc a trier pour archive
    TriggerServerEvent('qbx_Ab_informatic:server:saveComputer', json.encode(coords), 'active', 100)
end)


-- diag
local function diagComputerAnimation()
    local playerPed = PlayerPedId()
    local anim = 'missfam4'
    local anim_name = 'base'
    local propModel = 'p_amb_clipboard_01'

    -- On charge l'animation
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Wait(100)
    end

    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 36029), 0.16, 0.08, 0.1,-130.0, -50.0, 0.0, true, true, false, true, 1, true)
    -- Jouer l'animation
    TaskPlayAnim(playerPed, anim, anim_name, 1.0, 1.0, Config.time.diag_time, 1, 0, false, false, false)
    Wait(Config.time.diag_time) -- Temps de réparation (ajustez la durée si nécessaire)
    DeleteObject(prop)
    ClearPedTasks(playerPed) -- Arrête l'animation
    RemoveAnimDict(anim)
end



RegisterNetEvent('qbx_Ab_informatic:client:diagComputerAnimation', function()
    diagComputerAnimation()
    Wait(Config.time.diag_time)

end)
