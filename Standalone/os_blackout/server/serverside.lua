local blackout = 'off'


RegisterNetEvent("os_blackout:updateCurrentEntity")
AddEventHandler("os_blackout:updateCurrentEntity", function( isblackout)
    blackout = isblackout

    Wait(5)
    TriggerEvent("os_blackout:server:sendBlackoutData")
    print ("blackout:" ..blackout)
end)

RegisterNetEvent("os_blackout:sendEntityInfos")
AddEventHandler("os_blackout:sendEntityInfos", function(isblackout)
    local src = source
    blackout = isblackout
    print ("blackout:" ..blackout)
    TriggerClientEvent("os_blackout:sendEntityToClient", -1, blackout)
end)

RegisterNetEvent("os_blackout:getCurrentEntitySet")
AddEventHandler("os_blackout:getCurrentEntitySet", function()
    local src = source
    TriggerClientEvent("os_blackout:receiveEntitySet", src, blackout)  
end)


-- pour envoyé a tout le monde que le blackout coupe les ordis lors du toggle
RegisterNetEvent("os_blackout:server:sendBlackoutData") 
AddEventHandler("os_blackout:server:sendBlackoutData", function()
    TriggerClientEvent('qbx_Ab_informatic:client:blackout', -1, blackout)
    Wait(5)
    TriggerClientEvent('qbx_Ab_soluce_devis:client:blackout', -1, blackout)
    Wait(5)
    TriggerClientEvent('qbx_Ab_minigame_labfile:client:blackout', -1, blackout)
    Wait(5)
    TriggerClientEvent('qbx_Ab_minigame_devis:client:blackout', -1, blackout)
    Wait(5)
    TriggerClientEvent('qbx_Ab_minigame_CSC:client:blackout', -1, blackout)
    Wait(5)
    TriggerClientEvent('qbx_Ab_minigame_bataille_naval:client:blackout', -1, blackout)
    Wait(5)
    TriggerClientEvent('qbx_Ab_Dorne_Delivery:client:blackout', -1, blackout)
    Wait(5)
    TriggerClientEvent('qbx_Ab_DiceyTroop:client:blackout', -1, blackout)
    Wait(5)
    TriggerClientEvent('qbx_Ab_Accueil_InfoProd:client:blackout', -1, blackout)
    Wait(5)
    TriggerClientEvent('qbx_Ab_Accueil_InfoList:client:blackout', -1, blackout)
    Wait(5)
    TriggerClientEvent('qbx_Ab_Accueil_InfoJobProd:client:blackout', -1, blackout)
    Wait(5)
    TriggerClientEvent('qbx_Ab_It_base:client:blackout', -1, blackout)
    Wait(5)
    TriggerClientEvent('qbx_Ab_Pharma:client:blackout', -1, blackout)
end)

