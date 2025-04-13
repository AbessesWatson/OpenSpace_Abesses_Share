RegisterNetEvent('qbx_Ab_Medicaments:server:openFlacon', function(slot, itembase, itemresult)
    local src = source

    exports.ox_inventory:RemoveItem(src, itembase, 1)
    exports.ox_inventory:AddItem(src, itemresult, 10)
    exports.ox_inventory:AddItem(src, "empty_flacon", 1)

end)