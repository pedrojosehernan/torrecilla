--------------------------------------------------------------------------------
-- CLIENT.LUA
--------------------------------------------------------------------------------

local isConfigPanelVisible = false
local previewMarker = nil
local npcList = {}           -- Aquí guardamos info local de los NPC creados
local closeRange = 2.0       -- Distancia para interactuar con el NPC

--------------------------------------------------------------------------------
-- Lista de modelos NPC (aleatorio)
--------------------------------------------------------------------------------
local npcModels = {
    "a_m_m_farmer_01",
    "a_m_m_hillbilly_02",
    "u_m_m_promourn_01",
    "ig_abigail",
    "ig_cletus",
    "ig_russiandrunk",
    "cs_milton"
}

--------------------------------------------------------------------------------
-- Función auxiliar para debug
--------------------------------------------------------------------------------
local function debugPrint(msg)
    print("^3[CLIENT DEBUG]^7 "..msg)
end

--------------------------------------------------------------------------------
-- COMANDO /mision -> mostrar panel de configuración
--------------------------------------------------------------------------------
RegisterCommand('mision', function()
    debugPrint("Comando /mision usado -> abrir panel config.")
    if not isConfigPanelVisible then
        SetNuiFocus(true, true)
        SendNUIMessage({ type = "showConfigPanel" })
        isConfigPanelVisible = true
    end
end)

--------------------------------------------------------------------------------
-- Cerrar el panel de configuración (NUICallback)
--------------------------------------------------------------------------------
RegisterNUICallback('closeConfigPanel', function(_, cb)
    debugPrint("closeConfigPanel -> ocultando panel de config.")
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "hideConfigPanel" })
    isConfigPanelVisible = false
    if cb then cb({}) end
end)

--------------------------------------------------------------------------------
-- Botón: "Establecer ubicación" -> Creamos un marker, E = confirmar, X = cancelar
--------------------------------------------------------------------------------
RegisterNUICallback('setNpcLocation', function(_, cb)
    debugPrint("setNpcLocation: ocultamos panel y creamos marker de preview.")
    -- Cerrar panel
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "hideConfigPanel" })
    isConfigPanelVisible = false

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    -- Creamos la variable previewMarker
    previewMarker = {
        coords = coords,
        color  = {255, 0, 0},
        size   = 1.0
    }

    --------------------------------------------------------------------------
    -- UN SOLO BUCLE para dibujar el marker y chequear E / X
    --------------------------------------------------------------------------
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            -- Si previewMarker es nil, rompemos
            if not previewMarker then
                debugPrint("previewMarker == nil -> salimos del bucle marker.")
                break
            end

            -- Dibujar el marker
            DrawMarker(
                1,
                previewMarker.coords.x,
                previewMarker.coords.y,
                previewMarker.coords.z - 1.0,
                0,0,0,0,0,0,
                previewMarker.size,
                previewMarker.size,
                previewMarker.size,
                previewMarker.color[1],
                previewMarker.color[2],
                previewMarker.color[3],
                200,
                false,true,2,false,nil,nil,false
            )

            -- Revisar si pulsa E para confirmar
            if IsControlJustPressed(0, 38) then  -- E
                debugPrint("Has pulsado E -> confirmar ubicación.")
                local groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 200.0, 0)
                local finalCoords = vector3(coords.x, coords.y, groundZ)

                TriggerServerEvent('npc_mission:setNpcLocation', finalCoords)
                debugPrint("Evento setNpcLocation enviado al servidor.")

                -- Volvemos a mostrar el panel
                SetNuiFocus(true, true)
                SendNUIMessage({ type = "showConfigPanel" })
                isConfigPanelVisible = true

                previewMarker = nil  -- Rompemos el marker
            end

            -- Revisar si pulsa X para cancelar
            if IsControlJustPressed(0, 73) then  -- X
                debugPrint("Has pulsado X -> cancelar ubicación.")
                -- Reabrir panel
                SetNuiFocus(true, true)
                SendNUIMessage({ type = "showConfigPanel" })
                isConfigPanelVisible = true

                previewMarker = nil
            end
        end
    end)

    if cb then cb({}) end
end)

--------------------------------------------------------------------------------
-- Botón: "Guardar NPC" -> (mensaje, objetos, etc.)
--------------------------------------------------------------------------------
RegisterNUICallback('saveNpcData', function(data, cb)
    debugPrint("saveNpcData -> Mensaje: "..(data.message or "nil"))
    TriggerServerEvent('npc_mission:saveNpcData', data)
    if cb then cb({}) end
end)

--------------------------------------------------------------------------------
-- Evento createNpc (desde server) -> crear Ped con modelo aleatorio
--------------------------------------------------------------------------------
RegisterNetEvent('npc_mission:createNpc')
AddEventHandler('npc_mission:createNpc', function(npcId, coords, npcModel, msg, reqItem, rewItem)
    debugPrint(("createNpc -> ID=%d, coords=(%.2f,%.2f,%.2f), modelo=%s")
        :format(npcId, coords.x, coords.y, coords.z, npcModel))

    local modelHash = GetHashKey(npcModel)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(0)
    end

    local npcPed = CreatePed(4, modelHash, coords.x, coords.y, coords.z, 0.0, false, true)
    debugPrint("NPC creado. handle="..npcPed)

    SetEntityAsMissionEntity(npcPed, true, true)
    FreezeEntityPosition(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    SetEntityInvincible(npcPed, true)
    SetPedCanRagdoll(npcPed, false)

    npcList[npcId] = {
        ped     = npcPed,
        coords  = coords,
        message = msg,
        reqItem = reqItem,
        rewItem = rewItem
    }
end)

--------------------------------------------------------------------------------
-- Bucle: detectar si el player está cerca de un NPC -> Pulsa E para interactuar
--------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local pPed = PlayerPedId()
        local pCoords = GetEntityCoords(pPed)

        for npcId, npcData in pairs(npcList) do
            local dist = #(pCoords - npcData.coords)
            if dist < closeRange then
                -- Texto "Pulsa E"
                DisplayHelpText("Pulsa ~INPUT_CONTEXT~ para hablar con el NPC")
                if IsControlJustPressed(0, 38) then
                    debugPrint("Interactuando con NPC #"..npcId)
                    -- Abrir el panel de interacción
                    SendNUIMessage({
                        type    = "showNpcInteraction",
                        npcId   = npcId,
                        message = npcData.message,
                        reqItem = npcData.reqItem,
                        rewItem = npcData.rewItem
                    })
                end
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- Cerrar panel de interacción (abajo derecha)
--------------------------------------------------------------------------------
RegisterNUICallback('closeNpcInteraction', function(_, cb)
    debugPrint("closeNpcInteraction -> ocultamos panel de interacción.")
    SendNUIMessage({ type = "hideNpcInteraction" })
    if cb then cb({}) end
end)

--------------------------------------------------------------------------------
-- Función auxiliar: DisplayHelpText
--------------------------------------------------------------------------------
function DisplayHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

--------------------------------------------------------------------------------
-- Al iniciar el recurso -> ocultar paneles y quitar foco
--------------------------------------------------------------------------------
AddEventHandler('onClientResourceStart', function(resName)
    if resName == GetCurrentResourceName() then
        debugPrint("ResourceStart -> ocultar paneles, quitar foco.")
        SetNuiFocus(false, false)
        SendNUIMessage({ type = "hideConfigPanel" })
        SendNUIMessage({ type = "hideNpcInteraction" })
        isConfigPanelVisible = false
    end
end)
