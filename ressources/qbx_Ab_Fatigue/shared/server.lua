

-- Fonction pour modifier la fatigue d'un joueur
RegisterNetEvent('qbx_Ab_Fatigue:server:modifyPlayerFatigue')
AddEventHandler('qbx_Ab_Fatigue:server:modifyPlayerFatigue', function(value, src)
    local src = src or source -- Utilise source si src n'est pas défini
    TriggerEvent('qbx_Ab_Fatigue:server:local_modifyPlayerFatigue',value, src)
end)