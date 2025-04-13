-- Fonction pour gérer l'état `full_lock`
RegisterNetEvent('qbx_Ab_informatic:server:handleComputerfull_lock', function(computerID)
    local src = source
    TriggerEvent('qbx_Ab_informatic:server:local_handleComputerfull_lock',computerID)

end)

-- Fonction pour gérer l'état `lock`
RegisterNetEvent('qbx_Ab_informatic:server:handleComputerlock', function(computerID)
    local src = source

    TriggerEvent('qbx_Ab_informatic:server:local_handleComputerlock',computerID)
end)

-- baisse la santé de l'ordi
RegisterNetEvent('qbx_Ab_informatic:server:decreaseComputerHealth', function(computerID, amount)
    local src = source
    print("decreaseComputerHealth activated")

    TriggerEvent('qbx_Ab_informatic:server:local_decreaseComputerHealth',computerID, amount)
end)