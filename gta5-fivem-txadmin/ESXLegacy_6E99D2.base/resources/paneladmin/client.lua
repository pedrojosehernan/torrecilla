local isPanelVisible = false

-- Función para verificar si el jugador es admin
function isPlayerAdmin()
    -- Usamos un ejemplo con vMenu (si lo tienes instalado)
    local playerPed = PlayerPedId()
    local playerId = PlayerId()
    -- Verifica si el jugador tiene el permiso de noclip
    if IsPlayerAceAllowed(playerId, "command.noclip") then
        return true
    else
        return false
    end
end

-- Crear el comando /adminsuper
RegisterCommand('adminsuper', function()
    if isPlayerAdmin() then
        isPanelVisible = not isPanelVisible

        -- Enviar mensaje para mostrar u ocultar el panel
        if isPanelVisible then
            SetNuiFocus(true, true) -- Activar el foco en el NUI (HTML)
            SendNUIMessage({ type = "showPanel" })
        else
            SetNuiFocus(false, false) -- Desactivar el foco en el NUI
            SendNUIMessage({ type = "hidePanel" })
        end
    else
        -- Mensaje en el chat si el jugador no tiene permisos
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {"Noclip", "¡No tienes permiso para ejecutar este comando!"}
        })
    end
end)

-- Activar el noclip al recibir un evento desde el HTML
RegisterNUICallback('noclip', function()
    -- Activar o desactivar el noclip
    local ped = PlayerPedId()
    local isInVehicle = IsPedInAnyVehicle(ped, false)

    if not isInVehicle then
        -- Cambiar el estado del noclip
        local currentNoclip = GetEntityInvincible(ped)
        SetEntityInvincible(ped, not currentNoclip) -- Activar/desactivar noclip
        SetEntityVisible(ped, not currentNoclip, false) -- Hacer visible o invisible al jugador
        SetLocalPlayerVisibleLocally(not currentNoclip) -- Cambiar visibilidad local

        -- Mostrar un mensaje en el chat
        local status = currentNoclip and "desactivado" or "activado"
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            args = {"Noclip", "Noclip " .. status}
        })
    end
end)
