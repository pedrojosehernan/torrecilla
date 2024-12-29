RegisterCommand("pos", function()
    -- Obtener el Ped del jugador y su posición
    local ped = PlayerPedId() -- El Ped del jugador local
    local coords = GetEntityCoords(ped) -- Obtener las coordenadas (vector3)
    
    -- Formatear las coordenadas en un texto legible
    local coordsString = string.format("vector3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z)

    -- Copiar las coordenadas al portapapeles
    SendNUIMessage({
        action = "copy",
        text = coordsString
    })

    -- Mostrar un mensaje en el chat para confirmar
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0}, -- Verde
        multiline = true,
        args = {"Sistema", "Tu posición ha sido copiada: " .. coordsString}
    })
end, false) -- Comando accesible para todos