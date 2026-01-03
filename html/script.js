const resName = GetParentResourceName();
var selectedId = null;
var activeStates = {
    GodMode: false,
    Noclip: false,
    Invisible: false,
    ShowNames: false,
    SuperSpeed: false,
    SuperJump: false
};

$(document).ready(function() {
    window.addEventListener('message', function(event) {
        var data = event.data;

        if (data.action === "open") {
            $("body").css("display", "flex").hide().fadeIn(300);
            $("#total-players").text(data.playerCount);
            loadPlayers(data.players);
            if (data.blips) loadBlips(data.blips);
            
            showIslandNotification("Admin Paneli Aktif", "fa-shield-halved");
        } 
        else if (data.action === "showInventory") {
            renderInventory(data.inventory);
        }
    });

    $(document).keyup(function(e) {
        if (e.key === "Escape") closeMenu();
    });

    setInterval(() => {
        const d = new Date();
        const timeStr = d.getHours() + ":" + (d.getMinutes() < 10 ? '0' : '') + d.getMinutes();
        $("#tablet-time").text(timeStr);
    }, 1000);
});

function post(endpoint, data) {
    $.post(`https://${resName}/${endpoint}`, JSON.stringify(data));
}

function showIslandNotification(message, icon) {
    const island = $("#dynamicIsland");
    const islandMsg = island.find(".island-msg");
    const islandIcon = island.find(".island-icon");

    if (icon) {
        islandIcon.attr('class', `fa-solid ${icon} island-icon`);
    }

    islandMsg.text(message);
    island.addClass("active");

    setTimeout(() => {
        island.removeClass("active");
    }, 3000);
}

function closeMenu() {
    $("body").fadeOut(300, function() { $(this).css("display", "none"); });
    post('closeMenu', {});
}

function openApp(id) {
    $(".app-window").removeClass("active");
    $("#" + id).addClass("active");
    
}

function loadPlayers(players) {
    $("#player-list").empty();
    players.forEach(p => {
        $("#player-list").append(`
            <div class="player-item" onclick="selectPlayer(${p.id}, '${p.name}', this)">
                <div class="avatar-circle-sm"><i class="fa-solid fa-user"></i></div>
                <div class="player-info">
                    <strong>${p.name}</strong>
                    <small>ID: ${p.id}</small>
                </div>
            </div>
        `);
    });
}

function selectPlayer(id, name, el) {
    selectedId = id;
    $(".player-item").removeClass("selected");
    $(el).addClass("selected");
    $("#selected-name").text(name);
    $("#player-details").fadeIn();
    
    showIslandNotification(name + " Seçildi", "fa-user-check");
}

function toggleSelf(option) {
    activeStates[option] = !activeStates[option];
    
    const btn = $(`button[onclick="toggleSelf('${option}')"]`);
    btn.attr("data-active", activeStates[option]);

    const statusText = activeStates[option] ? "Açıldı" : "Kapatıldı";
    showIslandNotification(option + " " + statusText, activeStates[option] ? "fa-check-circle" : "fa-circle-xmark");

    post('toggleSelfOption', { 
        option: option, 
        state: activeStates[option] 
    });
}

function giveItem() {
    let item = $("#item-input").val();
    let amount = $("#amount-input").val();
    if(selectedId && item) {
        post('giveItem', { targetId: selectedId, item: item, amount: amount });
        showIslandNotification("Eşya Verildi: " + item, "fa-box");
    }
}

function setJob() {
    let job = $("#job-input").val();
    let grade = $("#grade-input").val();
    if(selectedId && job) {
        post('setJob', { targetId: selectedId, job: job, grade: grade });
        showIslandNotification("Meslek Ayarlandı: " + job, "fa-briefcase");
    }
}

function revivePlayer() { 
    if(selectedId) {
        post('revive', { targetId: selectedId });
        showIslandNotification("Oyuncu Canlandırıldı", "fa-heart-pulse");
    }
}

function checkInventory() { 
    if(selectedId) {
        post('checkInventory', { targetId: selectedId });
        showIslandNotification("Envanter Sorgulanıyor...", "fa-magnifying-glass");
    }
}

function pAction(act) { 
    if(selectedId) {
        post('playerAction', { targetId: selectedId, action: act });
        showIslandNotification("İşlem: " + act, "fa-bolt");
    }
}

function spawnCar() {
    let m = $("#veh-model").val();
    if(m) {
        post('spawnVehicle', { model: m });
        showIslandNotification("Araç Çıkarılıyor: " + m, "fa-car");
        closeMenu(); 
    }
}

function vehAction(act) { 
    post('vehicleAction', { action: act });
    showIslandNotification("Araç İşlemi: " + act, "fa-wrench");
}

function saveCurrentPosBlip() {
    let name = $("#blip-name").val();
    if(!name) return;
    post('saveBlipAtCurrentPos', {
        name: name,
        sprite: $("#blip-sprite").val(),
        color: $("#blip-color").val()
    });
    showIslandNotification("Blip Kaydedildi: " + name, "fa-map-location-dot");
    $("#blip-name").val("");
}

function renderInventory(items) {
    let h = "";
    $.each(items, (k, v) => {
        if(v) h += `<div class="inv-item"><span>${v.label}</span><small>x${v.amount}</small></div>`;
    });
    $("#inventory-list").html(h || "Boş");
    $("#inventory-modal").fadeIn();
}
