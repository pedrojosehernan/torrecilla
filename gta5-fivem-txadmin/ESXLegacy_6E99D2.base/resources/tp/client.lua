local tpPoints = {}  -- Lista de puntos de teletransporte

-- Mostrar el panel cuando se usa el comando /teleport
RegisterCommand('teleport', function()
    SetNuiFocus(true, true)  -- Activar el foco en la interfaz NUI
    SendNUIMessage({ type = "showPanel", tpList = tpPoints })  -- Enviar la lista de TP al cliente
end, false)

-- Guardar el punto TP1
RegisterNUICallback('setTp1', function()
    local ped = PlayerPedId()
    local tp1Position = GetEntityCoords(ped)  -- Obtener la posición actual del jugador
    print("Punto TP1 guardado en: " .. tostring(tp1Position))  -- Imprimir la posición guardada en la consola
end)

-- Guardar el punto TP2 y añadirlo a la lista
RegisterNUICallback('setTp2', function(data)
    local ped = PlayerPedId()
    local tp2Position = GetEntityCoords(ped)  -- Obtener la posición actual del jugador
    local tpName = data.tpName or "Punto de Teletransporte"  -- Nombre predeterminado si no se ingresa

    -- Añadir el nuevo punto de TP a la lista
    table.insert(tpPoints, {name = tpName, position = tp2Position})

    -- Mensaje de confirmación
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        args = {"TP", "Punto '" .. tpName .. "' guardado en la posición: " .. tostring(tp2Position)}
    })
end)

-- Teletransportarse al punto seleccionado
RegisterNUICallback('goToTp', function(data)
    local tpName = data.tpName
    for _, tp in ipairs(tpPoints) do
        if tp.name == tpName then
            SetEntityCoordsNoOffset(PlayerPedId(), tp.position.x, tp.position.y, tp.position.z, false, false, false)
            print("Teletransportado a: " .. tpName)
            return
        end
    end
end)

-- Cerrar el panel NUI
RegisterNUICallback('closePanel', function()
    SetNuiFocus(false, false)  -- Desactivar el foco en la interfaz NUI
    SendNUIMessage({ type = "hidePanel" })  -- Ocultar el panel
end)
