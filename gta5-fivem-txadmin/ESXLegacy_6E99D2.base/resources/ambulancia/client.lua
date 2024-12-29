RegisterCommand("ambulancia", function()
    -- Obtener el Ped del jugador y su salud
    local ped = PlayerPedId()
    local health = GetEntityHealth(ped)

    -- Verificar si el jugador está muerto
    if health > 0 then
        -- Mostrar un mensaje en el chat indicando que no se puede usar el comando
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0}, -- Rojo
            multiline = true,
            args = {"Ambulancia", "¡No puedes llamar a la ambulancia si no estás muerto!"}
        })
        return -- Salir del comando si el jugador no está muerto
    end

    -- Obtener la posición del jugador
    local playerCoords = GetEntityCoords(ped)

    -- Modelo del NPC y del vehículo
    local npcModel = "s_m_m_paramedic_01" -- Modelo del paramédico
    local vehicleModel = "ambulance" -- Modelo de la ambulancia

    -- Cargar los modelos
    RequestModel(GetHashKey(npcModel))
    RequestModel(GetHashKey(vehicleModel))
    while not HasModelLoaded(GetHashKey(npcModel)) or not HasModelLoaded(GetHashKey(vehicleModel)) do
        Wait(500)
    end

    -- Generar la ambulancia a una distancia mucho mayor
    local spawnDistance = 50.0 -- Distancia mucho más lejana para la ambulancia
    local spawnCoords = GetOffsetFromEntityInWorldCoords(ped, spawnDistance, spawnDistance, 0.0)
    local _, groundZ = GetGroundZFor_3dCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z + 1.0, true)
    spawnCoords = vector3(spawnCoords.x, spawnCoords.y, groundZ)

    -- Crear la ambulancia en la posición segura
    local ambulance = CreateVehicle(GetHashKey(vehicleModel), spawnCoords.x, spawnCoords.y, spawnCoords.z, GetEntityHeading(ped), true, false)

    -- Crear el NPC en el asiento del conductor de la ambulancia
    local driver = CreatePedInsideVehicle(ambulance, 4, GetHashKey(npcModel), -1, true, false)

    -- Hacer que el NPC conduzca hacia el jugador
    TaskVehicleDriveToCoord(driver, ambulance, playerCoords.x, playerCoords.y, playerCoords.z, 15.0, 0, GetEntityModel(ambulance), 524863, 1.0, true)

    -- Esperar a que el NPC llegue
    Citizen.CreateThread(function()
        local arrived = false
        while not arrived do
            Citizen.Wait(1000)
            local distance = #(GetEntityCoords(driver) - playerCoords)
            if distance < 10.0 then -- Detenerse a una distancia segura
                arrived = true
            end
        end

        -- Detener el vehículo y bajar al NPC de manera segura
        TaskVehicleTempAction(driver, ambulance, 27, 3000) -- Detener el vehículo
        Wait(1000) -- Espera para asegurar que el vehículo se detenga
        TaskLeaveVehicle(driver, ambulance, 0) -- El NPC se baja de la ambulancia
        Wait(2000) -- Espera un momento para asegurar que el NPC no quede atrapado

        -- Animación de reanimación del NPC (CPR)
        local reviveAnimDict = "mini@cpr@char_b@cpr_str"
        local reviveAnimName = "cpr_pumpchest"
        RequestAnimDict(reviveAnimDict)
        while not HasAnimDictLoaded(reviveAnimDict) do
            Wait(100)
        end
        TaskPlayAnim(driver, reviveAnimDict, reviveAnimName, 8.0, 1.0, -1, 1, 0, false, false, false)

        -- Esperar unos segundos mientras el NPC hace la animación de CPR
        Wait(5000)

        -- Revivir al jugador después de la animación
        ResurrectPed(ped) -- Revive al jugador
        SetEntityHealth(ped, 200) -- Restaura la salud al máximo
        ClearPedTasksImmediately(ped) -- Elimina la animación de muerte
        SetEntityInvincible(ped, false) -- Asegura que el jugador ya no sea invencible

        -- Mostrar un mensaje en el chat
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"Ambulancia", "El paramédico te ha reanimado. ¡Cuida tu salud!"}
        })

        -- Eliminar NPC y vehículo después de completar la tarea
        Wait(5000)
        DeleteEntity(driver)
        DeleteEntity(ambulance)
    end)
end, false)
