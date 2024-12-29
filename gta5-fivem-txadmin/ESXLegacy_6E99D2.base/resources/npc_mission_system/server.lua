--------------------------------------------------------------------------------
-- SERVER.LUA
--------------------------------------------------------------------------------

local npcList = {}
local npcCount = 0

-- Modelos random (para crear NPC)
local npcModels = {
    "a_m_m_farmer_01",
    "a_m_m_hillbilly_02",
    "u_m_m_promourn_01",
    "ig_abigail",
    "ig_cletus",
    "ig_russiandrunk",
    "cs_milton"
}
math.randomseed(os.time())

--------------------------------------------------------------------------------
-- setNpcLocation -> crear un NPC con modelo aleatorio
--------------------------------------------------------------------------------
RegisterNetEvent('npc_mission:setNpcLocation')
AddEventHandler('npc_mission:setNpcLocation', function(coords)
    npcCount = npcCount + 1

    local rndIndex   = math.random(#npcModels)
    local chosenModel= npcModels[rndIndex]

    npcList[npcCount] = {
        id       = npcCount,
        coords   = coords,
        model    = chosenModel,
        message  = "Hola, necesito ayuda.",
        reqItem  = "item_x",
        rewItem  = "item_y"
    }

    print(("[SERVER] Creando NPC #%d en (%.2f, %.2f, %.2f) modelo '%s'")
        :format(npcCount, coords.x, coords.y, coords.z, chosenModel))

    -- Notificar a TODOS los clientes -> createNpc
    TriggerClientEvent('npc_mission:createNpc', -1,
        npcCount,
        coords,
        chosenModel,
        npcList[npcCount].message,
        npcList[npcCount].reqItem,
        npcList[npcCount].rewItem
    )
end)

--------------------------------------------------------------------------------
-- saveNpcData -> actualizar info (mensaje, items) del NPC
--------------------------------------------------------------------------------
RegisterNetEvent('npc_mission:saveNpcData')
AddEventHandler('npc_mission:saveNpcData', function(data)
    local idx = npcCount  -- Modo simple: siempre el último NPC
    if npcList[idx] then
        npcList[idx].message = data.message   or npcList[idx].message
        npcList[idx].reqItem = data.requiredItem or npcList[idx].reqItem
        npcList[idx].rewItem = data.rewardItem   or npcList[idx].rewItem

        print(("[SERVER] NPC #%d -> message='%s', req='%s', rew='%s'")
            :format(idx, npcList[idx].message, npcList[idx].reqItem, npcList[idx].rewItem))

        -- Actualizar a todos
        TriggerClientEvent('npc_mission:createNpc', -1,
            idx,
            npcList[idx].coords,
            npcList[idx].model,
            npcList[idx].message,
            npcList[idx].reqItem,
            npcList[idx].rewItem
        )
    end
end)
