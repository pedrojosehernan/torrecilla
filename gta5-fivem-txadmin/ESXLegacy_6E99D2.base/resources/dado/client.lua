RegisterCommand("dado", function(source, args, rawCommand)
    -- Generar un numero aleatorio entre 1 y 100
    local numeroAleatorio = math.random(1, 100)
    
    -- Mostrar el resultado en el chat del jugador
    TriggerEvent('chat:addMessage', {
        color = {255, 255, 0}, -- Color amarillo
        multiline = true,
        args = {"Dado", "Has lanzado un dado y salió: " .. numeroAleatorio}
    })
end, false) -- El 'false' indica que el comando puede ser usado por cualquier jugador