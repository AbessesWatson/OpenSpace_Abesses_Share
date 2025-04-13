math.randomseed(os.time())

function porbaRandom()

    local randomNumber = math.random(1, 100) -- Génère un nombre entre 1 et 100
    return randomNumber
end

RegisterNetEvent('qbx_Ab_Camera:server:brokeCamera')
AddEventHandler('qbx_Ab_Camera:server:brokeCamera', function()
    local src = source
    local percent = 10
    local randomnumber = porbaRandom()

    if randomnumber <= percent then
        --print("broke camera with number " ..randomnumber)
        exports.ox_inventory:RemoveItem(src, 'camera', 1)
        exports.ox_inventory:AddItem(src, 'camera_broken', 1)
        exports.qbx_core:Notify(src, "La caméra a un problème!", 'error', 10000)
    else
        --print("all good with number " ..randomnumber)
    end
    
end)