

-- Fonction pour jouer un son en NUI
function PlayClientSound(volume)
    SendNUIMessage({
        action = "playSound",
        volume = volume or 1.0 -- Par défaut : volume à 100%
    })

    -- Thread pour surveiller la touche Backspace ou Échap
    CreateThread(function()
        while true do
            Wait(0) -- Vérifie à chaque frame
            if IsControlJustPressed(0, 177) or IsControlJustPressed(0, 200) then -- 177 = Backspace, 200 = Échap
                StopClientSound()
                break -- Sort de la boucle une fois que le son est stoppé
            end
        end
    end)
end

-- Fonction pour arrêter le son
function StopClientSound()
    SendNUIMessage({ action = "stopSound" })
end

RegisterNetEvent('qbx_Ab_CD:client:playsound')
AddEventHandler('qbx_Ab_CD:client:playsound', function()
 
    PlayClientSound(0.15)

end)