// Escuchamos mensajes del client.lua
window.addEventListener("message", function (event) {
    const data = event.data;

    // Panel de Config
    if (data.type === "showConfigPanel") {
        document.getElementById("configPanel").style.display = "block";
    } else if (data.type === "hideConfigPanel") {
        document.getElementById("configPanel").style.display = "none";
    }

    // Panel de Interacción
    if (data.type === "showNpcInteraction") {
        document.getElementById("npcInteractionPanel").style.display = "block";
        document.getElementById("npcMessageText").textContent  = data.message || "";
        document.getElementById("npcRequiredText").textContent = data.reqItem || "";
        document.getElementById("npcRewardText").textContent   = data.rewItem || "";
    } else if (data.type === "hideNpcInteraction") {
        document.getElementById("npcInteractionPanel").style.display = "none";
    }
});

// Botones del Panel de Config
document.getElementById("setLocation").addEventListener("click", function() {
    fetch(`https://${GetParentResourceName()}/setNpcLocation`, {
        method: "POST"
    });
});

document.getElementById("saveNpc").addEventListener("click", function() {
    const npcMessage = document.getElementById("npcMessage").value || "";
    const npcRequiredItem = document.getElementById("npcRequiredItem").value || "";
    const npcRewardItem = document.getElementById("npcRewardItem").value || "";

    fetch(`https://${GetParentResourceName()}/saveNpcData`, {
        method: "POST",
        body: JSON.stringify({
            message: npcMessage,
            requiredItem: npcRequiredItem,
            rewardItem: npcRewardItem
        })
    });
});

document.getElementById("closeConfigBtn").addEventListener("click", function() {
    fetch(`https://${GetParentResourceName()}/closeConfigPanel`, {
        method: "POST"
    });
});

// Botón: cerrar panel de interacción
document.getElementById("closeNpcInteractionBtn").addEventListener("click", function() {
    fetch(`https://${GetParentResourceName()}/closeNpcInteraction`, {
        method: "POST"
    });
});
