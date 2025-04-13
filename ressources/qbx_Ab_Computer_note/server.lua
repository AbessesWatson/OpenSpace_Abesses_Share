RegisterNetEvent('qbx_Ab_Computer_note:server:savetext', function(text)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)

    if player then
        local citizenid = player.PlayerData.citizenid
        local texttosave = text

        --print ("Citizen ID : " .. citizenid .. " a enregistré la note : " .. texttosave)

        MySQL.Async.execute(
            [[
                INSERT INTO Ab_Computer_Note (citizenid, note_text)
                VALUES (?, ?)
                ON DUPLICATE KEY UPDATE
                    note_text = VALUES(note_text)
            ]], 
            { citizenid, texttosave },
            function()
                --print("Note enregistrée pour " .. citizenid)
            end
        )

    else
        print("Erreur : Le joueur n'a pas été trouvé.")
    end
end)

RegisterNetEvent('qbx_Ab_Computer_note:server:gettext', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)

    if player then
        local citizenid = player.PlayerData.citizenid

        MySQL.Async.fetchScalar(
            "SELECT note_text FROM Ab_Computer_Note WHERE citizenid = ?",
            { citizenid },
            function(note)
                if note then
                    -- Si la note existe, on l'envoie au client
                    TriggerClientEvent('qbx_Ab_Computer_note:client:receivetext', src, note)
                else
                    -- Si la ligne n'existe pas, on la crée avec un texte vide
                    MySQL.Async.execute(
                        "INSERT INTO Ab_Computer_Note (citizenid, note_text) VALUES (?, ?)",
                        { citizenid, "" },
                        function()
                            print("Nouvelle ligne créée pour " .. citizenid)
                            TriggerClientEvent('qbx_Ab_Computer_note:client:receivetext', src, "") -- Renvoie un texte vide au client
                        end
                    )
                end
            end
        )
    else
        print("Erreur : Le joueur n'a pas été trouvé.")
    end
end)
