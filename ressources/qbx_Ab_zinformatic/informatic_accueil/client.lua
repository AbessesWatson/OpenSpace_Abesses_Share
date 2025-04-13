local function UnlockComputerAnimation()
    local playerPed = PlayerPedId()
    local anim = 'anim@amb@warehouse@laptop@'
    local anim_name = 'idle_a'

    -- On charge l'animation
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Wait(100)
    end

    -- Jouer l'animation
    TaskPlayAnim(playerPed, anim, anim_name, 1.0, 1.0, Config.time.unlock_time, 1, 0, false, false, false)
    Wait(Config.time.unlock_time) -- Temps de réparation (ajustez la durée si nécessaire)
    ClearPedTasks(playerPed) -- Arrête l'animation
    RemoveAnimDict(anim)
end

RegisterNetEvent('qbx_Ab_informatic:client:unlock_computer', function(computerID)
    print ('TRIGGER qbx_Ab_informatic:client:unlock_computer')
    UnlockComputerAnimation()
    Wait(Config.time.unlock_time)
    Wait(10)
    TriggerServerEvent("qbx_Ab_informatic:server:force_lock", computerID)

end)


