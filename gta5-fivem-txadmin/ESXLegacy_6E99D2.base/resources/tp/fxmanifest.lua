fx_version 'cerulean'  -- Usa la versión más reciente de FiveM (Cerulean es estable)
game 'gta5'           -- Indica que el recurso es para GTA V

author 'TuNombre'      -- Nombre del creador
description 'Sistema de teletransporte con puntos y listado' -- Descripción
version '1.0.0'        -- Versión del recurso

-- Archivos del cliente
client_scripts {
    'client.lua',       -- Archivo de cliente con la lógica
}

-- Página de la interfaz de usuario (NUI)
ui_page 'html/ui.html' -- Archivo HTML que contiene el panel NUI

files {
    'html/ui.html',     -- El archivo HTML para el panel
    'html/style.css',   -- Archivo CSS para el diseño del panel
    'html/script.js',   -- Archivo JS para interactuar con el panel
}
