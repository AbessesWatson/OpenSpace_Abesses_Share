RegisterNetEvent('qbx_Ab_CleanWipe:server:sharedUpDirtyTable')
AddEventHandler('qbx_Ab_CleanWipe:server:sharedUpDirtyTable', function(coords, propName)

    TriggerEvent('qbx_Ab_CleanWipe:server:UpDirtyTable', coords, propName)
end)