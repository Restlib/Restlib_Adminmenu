local QBCore = exports['qb-core']:GetCoreObject()
local menuOpen = false
local CreatedBlips = {} 

local AdminOptions = {
    GodMode = false,
    Invisible = false,
    SuperJump = false,
    SuperSpeed = false,
    Noclip = false,
    ShowNames = false,
    SuperPunch = false,
    InfiniteStamina = false,
    FreeAim = false
}

local noClipSpeed = 1.0
local speeds = {
    [1] = 0.5,
    [2] = 1.0,
    [3] = 2.0,
    [4] = 5.0,
    [5] = 10.0,
}

local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px, py, pz) - vector3(x, y, z))
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    if onScreen then
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function SetVehicleMaxMods(veh)
    SetVehicleModKit(veh, 0)
    SetVehicleMod(veh, 11, GetNumVehicleMods(veh, 11) - 1, false)
    SetVehicleMod(veh, 12, GetNumVehicleMods(veh, 12) - 1, false)
    SetVehicleMod(veh, 13, GetNumVehicleMods(veh, 13) - 1, false)
    SetVehicleMod(veh, 15, GetNumVehicleMods(veh, 15) - 1, false)
    SetVehicleMod(veh, 16, GetNumVehicleMods(veh, 16) - 1, false)
    ToggleVehicleMod(veh, 18, true)
    SetVehicleWindowTint(veh, 1)
    SetVehicleTyresCanBurst(veh, false)
end

local function RotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return vector3(direction.x, direction.y, direction.z)
end

local function RaycastFromCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = cameraCoord + direction * distance
    local rayHandle = StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0)
    local _, hit, endCoords, _, entityHit = GetShapeTestResult(rayHandle)
    return hit, endCoords, entityHit
end

local function GetCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    local x = -math.sin(heading * math.pi / 180.0)
    local y = math.cos(heading * math.pi / 180.0)
    local z = math.sin(pitch * math.pi / 180.0)
    local len = math.sqrt(x * x + y * y + z * z)
    if len ~= 0 then
        x = x / len
        y = y / len
        z = z / len
    end
    return x, y, z
end

local function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1], colour[2], colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end

RegisterCommand('noclip', function()
    QBCore.Functions.TriggerCallback('Restlibadmin:Server:CheckPerms', function(hasPerms)
        if hasPerms then
            AdminOptions.Noclip = not AdminOptions.Noclip
            if not AdminOptions.Noclip then
                SetEntityInvincible(PlayerPedId(), false)
                SetEntityVisible(PlayerPedId(), true)
                SetEntityCollision(PlayerPedId(), true, true)
            end
            local status = AdminOptions.Noclip and "Aktif" or "Pasif"
            QBCore.Functions.Notify('Noclip: ' .. status, AdminOptions.Noclip and 'success' or 'error')
        else
            QBCore.Functions.Notify('Yetkiniz yok!', 'error')
        end
    end)
end)

RegisterCommand('godmode', function()
    QBCore.Functions.TriggerCallback('Restlibadmin:Server:CheckPerms', function(hasPerms)
        if hasPerms then
            AdminOptions.GodMode = not AdminOptions.GodMode
            if not AdminOptions.GodMode then
                SetEntityInvincible(PlayerPedId(), false)
            end
            local status = AdminOptions.GodMode and "Aktif" or "Pasif"
            QBCore.Functions.Notify('God Mode: ' .. status, AdminOptions.GodMode and 'success' or 'error')
        else
            QBCore.Functions.Notify('Yetkiniz yok!', 'error')
        end
    end)
end)

RegisterCommand('names', function()
    QBCore.Functions.TriggerCallback('Restlibadmin:Server:CheckPerms', function(hasPerms)
        if hasPerms then
            AdminOptions.ShowNames = not AdminOptions.ShowNames
            local status = AdminOptions.ShowNames and "Aktif" or "Pasif"
            QBCore.Functions.Notify('İsimler: ' .. status, AdminOptions.ShowNames and 'success' or 'error')
        else
            QBCore.Functions.Notify('Yetkiniz yok!', 'error')
        end
    end)
end)

RegisterCommand('superpunch', function()
    QBCore.Functions.TriggerCallback('Restlibadmin:Server:CheckPerms', function(hasPerms)
        if hasPerms then
            AdminOptions.SuperPunch = not AdminOptions.SuperPunch
            local status = AdminOptions.SuperPunch and "Aktif" or "Pasif"
            QBCore.Functions.Notify('Süper Yumruk: ' .. status, AdminOptions.SuperPunch and 'success' or 'error')
        else
            QBCore.Functions.Notify('Yetkiniz yok!', 'error')
        end
    end)
end)

RegisterCommand('stamina', function()
    QBCore.Functions.TriggerCallback('Restlibadmin:Server:CheckPerms', function(hasPerms)
        if hasPerms then
            AdminOptions.InfiniteStamina = not AdminOptions.InfiniteStamina
            local status = AdminOptions.InfiniteStamina and "Aktif" or "Pasif"
            QBCore.Functions.Notify('Sınırsız Kondisyon: ' .. status, AdminOptions.InfiniteStamina and 'success' or 'error')
        else
            QBCore.Functions.Notify('Yetkiniz yok!', 'error')
        end
    end)
end)

CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local playerId = PlayerId()

        if AdminOptions.FreeAim then
            wait = 0
            local hit, coords, entity = RaycastFromCamera(100.0)
            local camCoords = GetGameplayCamCoord()
            DrawLine(camCoords.x, camCoords.y, camCoords.z, coords.x, coords.y, coords.z, 255, 0, 0, 255)
            Draw2DText(".", 4, {255, 255, 255}, 0.5, 0.495, 0.495)

            if hit and entity ~= 0 and IsEntityAnEntity(entity) then
                local entityCoords = GetEntityCoords(entity)
                local entityHeading = GetEntityHeading(entity)
                local entityModel = GetEntityModel(entity)
                local entityHealth = GetEntityHealth(entity)
                local entityMaxHealth = GetEntityMaxHealth(entity)
                
                local min, max = GetModelDimensions(entityModel)
                local points = {
                    GetOffsetFromEntityInWorldCoords(entity, min.x, min.y, min.z),
                    GetOffsetFromEntityInWorldCoords(entity, max.x, min.y, min.z),
                    GetOffsetFromEntityInWorldCoords(entity, max.x, max.y, min.z),
                    GetOffsetFromEntityInWorldCoords(entity, min.x, max.y, min.z),
                    GetOffsetFromEntityInWorldCoords(entity, min.x, min.y, max.z),
                    GetOffsetFromEntityInWorldCoords(entity, max.x, min.y, max.z),
                    GetOffsetFromEntityInWorldCoords(entity, max.x, max.y, max.z),
                    GetOffsetFromEntityInWorldCoords(entity, min.x, max.y, max.z)
                }

                local edges = {{1,2}, {2,3}, {3,4}, {4,1}, {5,6}, {6,7}, {7,8}, {8,5}, {1,5}, {2,6}, {3,7}, {4,8}}
                for _, edge in ipairs(edges) do
                    local p1, p2 = points[edge[1]], points[edge[2]]
                    DrawLine(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, 0, 255, 0, 255)
                end

                local entInfo = string.format("Model: %s\nID: %s\nHealth: %d/%d\nDist: %.2f", entityModel, entity, entityHealth, entityMaxHealth, #(GetEntityCoords(ped) - entityCoords))
                Draw2DText(entInfo, 4, {255, 255, 255}, 0.4, 0.75, 0.15)

                if IsControlJustPressed(0, 38) then
                    SetEntityAsMissionEntity(entity, true, true)
                    DeleteEntity(entity)
                elseif IsControlJustPressed(0, 47) then
                    FreezeEntityPosition(entity, not IsEntityPositionFrozen(entity))
                elseif IsControlJustPressed(0, 74) then
                    print(string.format("vector4(%.2f, %.2f, %.2f, %.2f)", entityCoords.x, entityCoords.y, entityCoords.z, entityHeading))
                end
            end
        end

        if AdminOptions.ShowNames then
            wait = 0
            local pCoords = GetEntityCoords(ped)
            for _, player in ipairs(GetActivePlayers()) do
                local targetPed = GetPlayerPed(player)
                if targetPed ~= ped then
                    local tCoords = GetEntityCoords(targetPed)
                    local dist = #(pCoords - tCoords)
                    if dist < 80.0 then
                        local targetId = GetPlayerServerId(player)
                        local targetName = GetPlayerName(player)
                        local health = GetEntityHealth(targetPed) - 100
                        local armor = GetPedArmour(targetPed)
                        local hColor = health > 50 and "~g~" or "~r~"
                        local text = string.format("ID: %d | %s\n%sCan: %d%% ~w~| Zırh: %d%%", targetId, targetName, hColor, health, armor)
                        DrawText3D(tCoords.x, tCoords.y, tCoords.z + 1.2, text)
                    end
                end
            end
        end

        if AdminOptions.GodMode then
            wait = 5
            SetEntityInvincible(ped, true)
            SetPlayerInvincible(playerId, true)
            SetPedCanRagdoll(ped, false)
            ClearPedBloodDamage(ped)
            ResetPedVisibleDamage(ped)
            SetEntityProofs(ped, true, true, true, true, true, true, true, true)
        else
            if not AdminOptions.Noclip then
                SetEntityInvincible(ped, false)
                SetPlayerInvincible(playerId, false)
                SetPedCanRagdoll(ped, true)
                SetEntityProofs(ped, false, false, false, false, false, false, false, false)
            end
        end

        if AdminOptions.Noclip then
            wait = 0
            SetEntityInvincible(ped, true)
            SetEntityVisible(ped, false, false) 
            SetEntityAlpha(ped, 150, false) 
            SetEntityCollision(ped, false, false)
            local coords = GetEntityCoords(ped)
            local camRot = GetGameplayCamRot(2)
            local dx, dy, dz = GetCamDirection()
            local currentSpeed = noClipSpeed
            if IsControlPressed(0, 21) then currentSpeed = noClipSpeed * 4.0 end
            if IsControlPressed(0, 36) then currentSpeed = noClipSpeed * 0.2 end
            SetEntityVelocity(ped, 0.0, 0.0, 0.0)
            if IsControlPressed(0, 32) then
                coords = coords + vector3(dx, dy, dz) * currentSpeed
            elseif IsControlPressed(0, 269) then
                coords = coords - vector3(dx, dy, dz) * currentSpeed
            end
            local heading = camRot.z * math.pi / 180.0
            local rdx = math.cos(heading)
            local rdy = math.sin(heading)
            if IsControlPressed(0, 34) then
                coords = coords - vector3(rdx, rdy, 0.0) * currentSpeed
            elseif IsControlPressed(0, 9) then
                coords = coords + vector3(rdx, rdy, 0.0) * currentSpeed
            end
            if IsControlPressed(0, 44) then
                coords = coords + vector3(0, 0, currentSpeed)
            elseif IsControlPressed(0, 38) then
                coords = coords - vector3(0, 0, currentSpeed)
            end
            SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, true, true, true)
            SetEntityHeading(ped, camRot.z)
        else
            if not AdminOptions.Invisible then
                ResetEntityAlpha(ped)
                SetEntityVisible(ped, true, false)
                SetEntityCollision(ped, true, true)
                SetEntityInvincible(ped, false)
            end
        end

        if AdminOptions.SuperPunch then
            wait = 0
            if IsPedInMeleeCombat(ped) then
                local target = GetMeleeTargetForPed(ped)
                if target ~= 0 and IsControlJustPressed(0, 24) then
                    ApplyForceToEntity(target, 1, 0.0, 50.0, 10.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                    local tCoords = GetEntityCoords(target)
                    AddExplosion(tCoords.x, tCoords.y, tCoords.z, 1, 0.0, true, false, 0.0)
                end
            end
        end

        if AdminOptions.InfiniteStamina then
            wait = 5
            RestorePlayerStamina(playerId, 1.0)
        end

        if AdminOptions.Invisible then
            wait = 5
            SetEntityVisible(ped, false, false)
        elseif not AdminOptions.Invisible and not AdminOptions.Noclip then
            if not IsEntityVisible(ped) then SetEntityVisible(ped, true, false) end
        end

        if AdminOptions.SuperJump then
            wait = 5
            SetSuperJumpThisFrame(playerId)
        end

        if AdminOptions.SuperSpeed then
            wait = 5
            SetRunSprintMultiplierForPlayer(playerId, 1.49)
        else
            SetRunSprintMultiplierForPlayer(playerId, 1.0)
        end
        Wait(wait)
    end
end)

RegisterCommand('adminmenu', function()
    QBCore.Functions.TriggerCallback('Restlibadmin:Server:CheckPerms', function(hasPerms)
        if hasPerms then
            menuOpen = true
            SetNuiFocus(true, true)
            QBCore.Functions.TriggerCallback('Restlibadmin:Server:GetPlayers', function(players, count)
                QBCore.Functions.TriggerCallback('Restlibadmin:Server:GetBlipData', function(blips)
                    SendNUIMessage({
                        action = "open",
                        players = players,
                        playerCount = count,
                        blips = blips
                    })
                end)
            end)
        else
            QBCore.Functions.Notify('Yetkiniz yok!', 'error')
        end
    end)
end)

RegisterNUICallback('closeMenu', function(data, cb)
    menuOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    TriggerEvent('QBCore:Command:SpawnVehicle', data.model)
    SetTimeout(1000, function()
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= 0 then
            SetVehicleMaxMods(vehicle)
            QBCore.Functions.Notify(data.model .. ' oluşturuldu ve fullendi.', 'success')
        end
    end)
    cb('ok')
end)

RegisterNUICallback('toggleSelfOption', function(data, cb)
    local option = data.option
    if AdminOptions[option] ~= nil then
        AdminOptions[option] = not AdminOptions[option]
        if option == "GodMode" and not AdminOptions.GodMode then
            SetEntityInvincible(PlayerPedId(), false)
        elseif option == "Noclip" and not AdminOptions.Noclip then
            SetEntityInvincible(PlayerPedId(), false)
            SetEntityVisible(PlayerPedId(), true)
        end
        local status = AdminOptions[option] and "Açık" or "Kapalı"
        QBCore.Functions.Notify(option .. ': ' .. status, AdminOptions[option] and 'success' or 'error')
    end
    cb('ok')
end)

RegisterNUICallback('vehicleAction', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if data.action == 'delete' then
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
            SetTimeout(1000, function() DeleteVehicle(vehicle) end)
        else
            local closeVeh = QBCore.Functions.GetClosestVehicle()
            if closeVeh then DeleteVehicle(closeVeh) end
        end
    elseif data.action == 'repair' then
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            SetVehicleFixed(vehicle)
            SetVehicleDirtLevel(vehicle, 0)
            SetVehicleDeformationFixed(vehicle)
            SetVehicleMaxMods(vehicle)
        end
    end
    cb('ok')
end)

RegisterNUICallback('playerAction', function(data, cb)
    if data.targetId then
        TriggerServerEvent('Restlibadmin:Server:PlayerAction', data.targetId, data.action)
    end
    cb('ok')
end)

RegisterNUICallback('giveItem', function(data, cb)
    TriggerServerEvent('Restlibadmin:Server:GiveItem', data.targetId, data.item, data.amount)
    cb('ok')
end)

RegisterNUICallback('setJob', function(data, cb)
    TriggerServerEvent('Restlibadmin:Server:SetJob', data.targetId, data.job, data.grade)
    cb('ok')
end)

RegisterNUICallback('setWeather', function(data, cb)
    TriggerServerEvent('Restlibadmin:Server:SetWeather', data.weather)
    cb('ok')
end)

RegisterNUICallback('revive', function(data, cb)
    TriggerServerEvent('Restlibadmin:Server:RevivePlayer', data.targetId)
    cb('ok')
end)

RegisterNUICallback('openClothing', function(data, cb)
    TriggerServerEvent('Restlibadmin:Server:OpenClothing', data.targetId)
    cb('ok')
end)

RegisterNUICallback('checkInventory', function(data, cb)
    TriggerServerEvent('Restlibadmin:Server:CheckInventory', data.targetId)
    cb('ok')
end)

RegisterNUICallback('sendAnnounce', function(data, cb)
    TriggerServerEvent('Restlibadmin:Server:SendAnnounce', data)
    cb('ok')
end)

RegisterNUICallback('saveBlipAtCurrentPos', function(data, cb)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    TriggerServerEvent('Restlibadmin:Server:SaveBlip', {
        name = data.name,
        sprite = tonumber(data.sprite) or 1,
        color = tonumber(data.color) or 1,
        coords = coords
    })
    QBCore.Functions.Notify('Blip kaydedildi.', 'success')
    cb('ok')
end)

RegisterNUICallback('deleteBlip', function(data, cb)
    TriggerServerEvent('Restlibadmin:Server:DeleteBlip', data.index)
    QBCore.Functions.Notify('Blip silindi.', 'success')
    cb('ok')
end)

RegisterNetEvent('Restlibadmin:Client:ReceiveInventory', function(inventoryData)
    SendNUIMessage({
        action = "showInventory",
        inventory = inventoryData
    })
end)

RegisterNetEvent('Restlibadmin:Client:OpenClothingMenu', function()
    TriggerEvent('qb-clothing:client:openMenu')
end)

RegisterNetEvent('Restlibadmin:Client:UpdateBlips', function(blipData)
    for k, v in pairs(CreatedBlips) do RemoveBlip(v) end
    CreatedBlips = {}
    for i, data in ipairs(blipData) do
        local coords = data.coords
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, tonumber(data.sprite) or 1)
        SetBlipColour(blip, tonumber(data.color) or 1)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.name)
        EndTextCommandSetBlipName(blip)
        table.insert(CreatedBlips, blip)
    end
    if menuOpen then
        SendNUIMessage({
            action = "open", 
            blips = blipData
        })
    end
end)

RegisterNetEvent('Restlibadmin:Client:ShowGlobalAnnounce', function(msg)
    SendNUIMessage({
        action = "announce_global",
        message = msg, 
        msg = msg
    })
end)

RegisterNetEvent('Restlibadmin:Client:CaptureScreenshot', function()
    local webhook = "https://discord.com/api/webhooks/1456823823004471570/wtZcDOnka4TPuvcxeH5eVKJir0WsyzwSm1Tqhd5wZ50TgHG8AEKXoWmzw52nawut3m5J"
    exports['screenshot-basic']:requestScreenshotUpload(webhook, "files[]", function(data)
        local resp = json.decode(data)
        if resp and resp.attachments and resp.attachments[1] then
            TriggerServerEvent('Restlibadmin:Server:ScreenshotResult', resp.attachments[1].proxy_url)
        else
            TriggerServerEvent('Restlibadmin:Server:ScreenshotResult', nil)
        end
    end)
end)

TriggerEvent('chat:addSuggestion', '/report', 'Yönetime yardım talebi gönderir', {
    { name="mesaj", help="Sorununuz" }
})