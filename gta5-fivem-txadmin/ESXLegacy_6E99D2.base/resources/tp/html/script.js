// Escuchar eventos enviados desde client.lua
window.addEventListener('message', function(event) {
    if (event.data.type === 'showPanel') {
        document.getElementById('panel').style.display = 'block';
        updateTPList(event.data.tpList);
    } else if (event.data.type === 'hidePanel') {
        document.getElementById('panel').style.display = 'none';
    }
});

// Función para actualizar la lista de teletransportes
function updateTPList(tpList) {
    const listDiv = document.getElementById('tpList');
    listDiv.innerHTML = '';  // Limpiar la lista actual
    tpList.forEach(tp => {
        let button = document.createElement('button');
        button.textContent = tp.name;
        button.onclick = () => goToTp(tp.name);
        listDiv.appendChild(button);
    });
}

// Función para teletransportarse a un punto
function goToTp(tpName) {
    fetch(`https://${GetParentResourceName()}/goToTp`, {
        method: 'POST',
        body: JSON.stringify({ tpName: tpName })
    });
}

// Cerrar el panel al hacer clic en el botón
document.getElementById('closeButton').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closePanel`, {
        method: 'POST'
    });
});
