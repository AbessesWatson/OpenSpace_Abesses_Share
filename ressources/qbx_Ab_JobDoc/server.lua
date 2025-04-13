function addjobdoc (src, item)
    local cancarry = exports.ox_inventory:CanCarryItem(src, item, 1)
    if cancarry then
        exports.ox_inventory:AddItem(src, item, 1)
    else
        exports.qbx_core:Notify(src, "Vous n'avez pas la place pour porter ce document", 'error', 7000)
    end
end

RegisterNetEvent ("qbx_Ab_JobDoc:server:additemJobdoc", function(job)
    src = source

    if job == "it" then
        addjobdoc (src, Config.item_jobdoc_it)
    elseif job == "cafet" then
        addjobdoc (src, Config.item_jobdoc_cafet)
    elseif job == "archive" then
        addjobdoc (src, Config.item_jobdoc_archive)
    elseif job == "menage" then
        addjobdoc (src, Config.item_jobdoc_menage)
    elseif job == "compta" then
        addjobdoc (src, Config.item_jobdoc_compta)
    elseif job == "accueil" then
        addjobdoc (src, Config.item_jobdoc_accueil)
    elseif job == "infirmerie" then
        addjobdoc (src, Config.item_jobdoc_infirmerie)
    elseif job == "communication" then
        addjobdoc (src, Config.item_jobdoc_communication)
    else
        print("Erreur selection de job pour fiche de poste")
    end
end)