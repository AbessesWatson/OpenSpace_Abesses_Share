local MAX_FOV = 70.0
local MIN_FOV = 5.0 -- max zoom level (smaller fov is more zoom)
local ZOOM_SPEED = 10.0 -- camera zoom speed
local LR_SPEED = 8.0 -- speed by which the camera pans left-right
local UD_SPEED = 8.0 -- speed by which the camera pans up-down
local camera = false
local fov = (MAX_FOV + MIN_FOV) * 0.5

local function setEntityInvisibleForSelf(entity)
    
    -- Rendre l'entity invisible pour lui-même
    --SetEntityVisible(entity, false, false)  -- Masque l'entity pour lui-même
    
    -- S'assurer que le joueur est visible pour les autres
    --NetworkSetEntityInvisibleToNetwork(entity, false)
    
    -- Optionnel : Pour cacher le modèle de la caméra à travers la vue du joueur
    -- Cela empêchera le joueur de voir son modèle pendant que la caméra est active
    SetEntityAlpha(entity, 0, false)  -- On peut aussi manipuler l'alpha si nécessaire
end

local function resetEntityVisibilityentity(entity)
    
    -- Rendre le joueur visible pour lui-même
    --SetEntityVisible(entity, true, false)

    -- Rendre le joueur visible pour le réseau
    --NetworkSetEntityInvisibleToNetwork(entity, false)
    
    -- Rétablir l'alpha à sa valeur par défaut (enlever l'invisibilité)
    SetEntityAlpha(entity, 255, false)
end


local function checkInputRotation(cam, zoomValue)
    local rightAxisX = GetControlNormal(0, 220)
    local rightAxisY = GetControlNormal(0, 221)
    local rot = GetCamRot(cam, 2)
    if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
        local newZ = rot.z + rightAxisX * -1.0 * (UD_SPEED) * (zoomValue + 0.1)
        local newX = math.max(math.min(20.0, rot.x + rightAxisY * -1.0 * (LR_SPEED) * (zoomValue + 0.1)), -89.5)
        SetCamRot(cam, newX, 0.0, newZ, 2)
        SetEntityHeading(cache.ped, newZ)
    end
end

local function handleZoom(cam)
    local scrollUpControl = IsPedSittingInAnyVehicle(cache.ped) and 17 or 241
    local scrollDownControl = IsPedSittingInAnyVehicle(cache.ped) and 16 or 242

    if IsControlJustPressed(0, scrollUpControl) then
        fov = math.max(fov - ZOOM_SPEED, MIN_FOV)
    end

    if IsControlJustPressed(0, scrollDownControl) then
        fov = math.min(fov + ZOOM_SPEED, MAX_FOV)
    end

    local currentFov = GetCamFov(cam)
    local fovDifference = fov - currentFov

    if math.abs(fovDifference) > 0.01 then
        local newFov = currentFov + fovDifference * 0.05
        SetCamFov(cam, newFov)
    end
end

local function getOffsetPosition(entity)
    local distance = 0.1
    -- Obtenir les coordonnées du joueur
    local x, y, z = table.unpack(GetEntityCoords(entity))

    -- Obtenir le vecteur directionnel de l'entité (le joueur)
    local forwardVector = GetEntityForwardVector(entity)

    -- Calculer la nouvelle position de la caméra devant le joueur
    local offsetX = x + forwardVector.x * distance
    local offsetY = y + forwardVector.y * distance
    local offsetZ = z + 0.7 -- Positionner la caméra au niveau de la tête du joueur

    return vector3(offsetX, offsetY, offsetZ)
end



local cam = nil
local scaleform
local propcam = nil

local function closeCamera()
    ClearPedTasks(cache.ped)
    resetEntityVisibilityentity(propcam)
    Wait(500)
    RenderScriptCams(false, true, 500, false, false)
    SetScaleformMovieAsNoLongerNeeded(scaleform)
    DestroyCam(cam, false)
    --SetFollowPedCamViewMode(1)
    DeleteObject(propcam)
    propcam = nil
    cam = nil
    if propcam then
        DeleteObject(propcam)
        propcam = nil
    end
    -- Placer ici pour le cassage de camera
    TriggerServerEvent('qbx_Ab_Camera:server:brokeCamera')
end

local keybind = lib.addKeybind({
    name = 'closeCamera',
    description = 'Close Camera',
    defaultKey = 'BACK',
    onPressed = function()
        if not camera then return end
        camera = false
        closeCamera()
    end,
})


exports('camera', function(data, slot)
    local player = PlayerPedId()

    exports.ox_inventory:useItem(data, function(used)
        -- The server has verified the item can be used.
        if used then
            
            if cache.vehicle or IsPedSwimming(cache.ped) or QBX.PlayerData.metadata.isdead or QBX.PlayerData.metadata.ishandcuffed or QBX.PlayerData.metadata.inlaststand then return end
            camera = not camera
        
            if camera then
                local dict = 'missfinale_c2mcs_1'
                local animName = 'fin_c2_mcs_1_camman'
                local propModel = 'prop_v_cam_01'
                local flag = 49
                if propcam == nil then 
                    propcam = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                    SetEntityCollision(propcam, false, false)
                    AttachEntityToEntity(propcam, player, GetPedBoneIndex(player, 28422), 0.000000, 0.030000, 0.010000, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                end
                if not IsEntityPlayingAnim(player, dict, animName, 3) then
                    RequestAnimDict(dict)
                    while not HasAnimDictLoaded(dict) do
                        Wait(10) -- Attendre que l'animation soit chargée
                    end
                    TaskPlayAnim(player, dict, animName, 1.0, 1.0, -1, flag, 0, false, false, false)
                end
                cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
                Wait(1000)
                setEntityInvisibleForSelf(propcam)
                -- Position initiale devant le joueur
                SetCamRot(cam, 0.0, 0.0, GetEntityHeading(player), 2)
                local camPos = getOffsetPosition(player) -- Positionne la caméra devant le joueur
                SetCamCoord(cam, camPos.x, camPos.y, camPos.z)
                print ('Z = ' ..camPos.z)
                
                RenderScriptCams(true, false, 500, true, false)
                
                keybind:disable(false)
            else
                closeCamera()
                keybind:disable(true)
            end
        
            CreateThread(function()
                while camera do
                    local playerCoords = GetEntityCoords(player)

                    local camRot = GetCamRot(cam, 2) -- Récupère l'angle de la caméra
                    SetEntityHeading(player, camRot.z) -- Tourne le personnage vers la caméra

                    local camPos = getOffsetPosition(player)
                    SetCamCoord(cam, camPos.x, camPos.y, camPos.z) -- Déplace la caméra


                    --scaleform = lib.requestScaleformMovie('Camera')
                    --BeginScaleformMovieMethod(scaleform, 'SET_CAM_LOGO')
                    --ScaleformMovieMethodAddParamInt(0)
                    --EndScaleformMovieMethod()

                    
                    

                    local zoomValue = (1.0 / (MAX_FOV - MIN_FOV)) * (fov - MIN_FOV)
                    checkInputRotation(cam, zoomValue)
                    handleZoom(cam)

                    --DrawScaleformMovie(scaleform, 0.5, 0.5, 1.0, 1.0, 255, 255, 255, 255)
                    Wait(0)
                end
            end)

        end
      end)

end)
