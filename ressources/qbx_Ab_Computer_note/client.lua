local textsaved = ""

-- DEMARAGE DE RESSOURCE

CreateThread(function() -- Pour charger le niveau d'alcool au dépar

    while not QBX or not QBX.PlayerData or not QBX.PlayerData.citizenid do
        Wait(100)
        --print("En attente des données du joueur (citizenid)...")
    end

    TriggerServerEvent('qbx_Ab_Computer_note:server:gettext')

end)

-- EVENT

RegisterNetEvent('qbx_Ab_Computer_note:client:receivetext', function(text)
    textsaved = text
end)

-- target

exports.ox_target:addModel(
    Config.propcomputer, 
    { 
        -- Option pour écrire
        {
            name = "computer_text",
            label = "Utiliser le traitement de texte",
            icon = 'fa-solid fa-font',
            onSelect = function(data)
                ---@return { inputs: string[], isCancel: boolean }
                local Result = exports["office_ui"]:DisplayPrompt({
                    title = "Traitement de texte",
                    items = {
                        {
                            type = "textarea",
                            title = "Ceci est votre bloc-note personnel",
                            textArea = textsaved,
                            required = false
                        },
                    }
                })
                
                Wait(10)

                -- Vérifie si Result existe et contient bien 'inputs'
                if Result and Result[1] then
                    local result = Result[1] or ""
                    --print("Texte saisi:", result)

                    -- Envoyer le texte au serveur pour le sauvegarder
                    textsaved = result
                    TriggerServerEvent('qbx_Ab_Computer_note:server:savetext', result)
                else
                    print("Erreur : Aucune donnée entrée ou Result est nul.")
                end
            end,
        },            
    }
)