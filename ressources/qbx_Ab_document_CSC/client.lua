local isUIOpen = false

local function opendoc(text)
    print('fonction activé')
    if not isUIOpen then
        isUIOpen = true
        SetNuiFocus(true, true) -- Active la saisie utilisateur dans l'UI
        SetNuiFocusKeepInput(true)
        SendNUIMessage({
            action = 'openText',
            text = text
        })
    end
end

-- ICI C'est un long bordel pour tout les documents

-- Créez une fonction utilisable dans ox_inventory
exports("csc_doc_a", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_b", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_c", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_d", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_e", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_f", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_g", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_h", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_i", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_j", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_k", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_l", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_m", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_n", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_o", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_p", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_q", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_r", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_s", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

exports("csc_doc_t", function(data, slot)
    exports.ox_inventory:useItem(data, function(used)
        if used then
            local itemName = data.name -- Récupère le nom de l'item
            local text = Config.docTexts[itemName] or "Texte non défini pour ce document."
            
            opendoc(text)
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        if isUIOpen then
            Citizen.Wait(0)

            -- Désactiver toutes les entrées utilisateur
            DisableAllControlActions(0)

            -- Réactiver uniquement certaines touches
            EnableControlAction(0, 249, true) -- Push-to-Talk (N)
            EnableControlAction(0, 168, true) -- F7
        else
            Citizen.Wait(500)
        end
    end
end)


-- Fermer l'interface via un callback NUI
RegisterNUICallback('closeText', function(_, cb)
    SetNuiFocus(false, false)
    isUIOpen = false
    cb('ok')
end)