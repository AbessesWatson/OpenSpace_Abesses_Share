-- Événement serveur pour gérer l'ajout de productivité
RegisterServerEvent('server:addProductivity')
AddEventHandler('server:addProductivity', function(value, src)
    AddPlayerProductivity(value,src)
end)

-- Événement serveur pour gérer l'ajout de productivité à un job
RegisterServerEvent('server:addJobProductivity')
AddEventHandler('server:addJobProductivity', function(job, value)
    AddJobProductivity(job, value)
    print('fonction AddJobProductivity triggered')
end)