local QBCore = exports['qb-core']:GetCoreObject()

local BlipsFile = LoadResourceFile(GetCurrentResourceName(), "blips.json")
local ServerBlips = {}
if BlipsFile then ServerBlips = json.decode(BlipsFile) else SaveResourceFile(GetCurrentResourceName(), "blips.json", "[]", -1) ServerBlips = {} end

local function IsAuthorized(src)
    if type(src) == 'string' or src == 0 or src == nil then return true end
    if QBCore.Functions.HasPermission(src, "admin") or QBCore.Functions.HasPermission(src, "god") then return true end
    return false
end

local function IsRealPlayer(src)
    if type(src) == 'number' and src > 0 then return true end
    return false
end

QBCore.Functions.CreateCallback('Restlibadmin:Server:CheckPerms', function(source, cb) if IsAuthorized(source) then cb(true) else cb(false) end end)
QBCore.Functions.CreateCallback('Restlibadmin:Server:GetPlayers', function(source, cb)
    local players = {}
    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local target = QBCore.Functions.GetPlayer(v)
        if target then table.insert(players, { id = v, name = target.PlayerData.charinfo.firstname .. " " .. target.PlayerData.charinfo.lastname .. " (" .. target.PlayerData.name .. ")" }) end
    end
    cb(players, #players)
end)
QBCore.Functions.CreateCallback('Restlibadmin:Server:GetBlipData', function(source, cb) cb(ServerBlips) end)

QBCore.Commands.Add('duyuru', 'Sunucu genelinde duyuru yap', {{name='mesaj', help='Duyurulacak mesaj'}}, true, function(source, args)
    local msg = table.concat(args, ' ')
    if msg == '' then return end
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 0, 0},
        multiline = true,
        args = {"SİSTEM DUYURUSU", msg}
    })
    TriggerClientEvent('Restlibadmin:Client:ShowGlobalAnnounce', -1, msg)
end, 'admin')

QBCore.Commands.Add('kisiselduyuru', 'Belirli bir oyuncuya özel bildirim gönder', {{name='id', help='Oyuncu ID'}, {name='mesaj', help='Mesaj'}}, true, function(source, args)
    local playerId = tonumber(args[1])
    table.remove(args, 1)
    local msg = table.concat(args, ' ')
    if playerId and msg ~= '' then
        local targetPlayer = QBCore.Functions.GetPlayer(playerId)
        if targetPlayer then
            TriggerClientEvent('QBCore:Notify', playerId, 'YÖNETİM DUYURUSU: ' .. msg, 'error', 15000)
            TriggerClientEvent('Restlibadmin:Client:ShowPrivateAnnounce', playerId, msg)
            TriggerClientEvent('QBCore:Notify', source, 'Mesaj iletildi.', 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, 'Oyuncu bulunamadı!', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, 'Eksik bilgi! (/kisiselduyuru ID Mesaj)', 'error')
    end
end, 'admin')

RegisterNetEvent('Restlibadmin:Server:GiveItem', function(targetId, item, amount)
    local src = source
    if not IsAuthorized(src) then return end 
    local Player = QBCore.Functions.GetPlayer(tonumber(targetId))
    if Player then
        Player.Functions.AddItem(item, tonumber(amount))
        TriggerClientEvent('inventory:client:ItemBox', tonumber(targetId), QBCore.Shared.Items[item], "add")
        if IsRealPlayer(src) then
            TriggerClientEvent('QBCore:Notify', src, item .. " verildi.", "success")
        else
            print("^2[Bot]^7 Oyuncuya item verildi: " .. item)
        end
    else
        if IsRealPlayer(src) then TriggerClientEvent('QBCore:Notify', src, "Oyuncu bulunamadı!", "error") end
    end
end)

RegisterNetEvent('Restlibadmin:Server:SetJob', function(targetId, job, grade)
    local src = source
    if not IsAuthorized(src) then return end
    local Player = QBCore.Functions.GetPlayer(tonumber(targetId))
    if Player then
        Player.Functions.SetJob(job, tonumber(grade))
        if IsRealPlayer(src) then
            TriggerClientEvent('QBCore:Notify', src, "Meslek ayarlandı: " .. job, "success")
        else
            print("^2[Bot]^7 Meslek ayarlandı: " .. job)
        end
    end
end)

RegisterNetEvent('Restlibadmin:Server:SetWeather', function(weather)
    local src = source
    if not IsAuthorized(src) then return end
    if GetResourceState('qb-weathersync') == 'started' then
        exports['qb-weathersync']:setWeather(weather)
    else
        ExecuteCommand("weather " .. weather)
    end
    if IsRealPlayer(src) then
        TriggerClientEvent('QBCore:Notify', src, "Hava durumu güncellendi: " .. weather, "success")
    else
        print("^2[Bot]^7 Hava durumu değişti: " .. weather)
    end
end)

RegisterNetEvent('Restlibadmin:Server:SendAnnounce', function(data)
    local src = source
    if not IsAuthorized(src) then return end
    if data.type == "global" then
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"YÖNETİM DUYURUSU", data.msg}
        })
        TriggerClientEvent('Restlibadmin:Client:ShowGlobalAnnounce', -1, data.msg)
    elseif data.type == "personal" then
        TriggerClientEvent('QBCore:Notify', tonumber(data.targetId), 'YÖNETİM MESAJI: ' .. data.msg, 'error', 15000)
        TriggerClientEvent('Restlibadmin:Client:ShowPrivateAnnounce', tonumber(data.targetId), data.msg)
    end
end)

RegisterNetEvent('Restlibadmin:Server:DiscordPersonalWarn', function(targetId, msg)
    TriggerClientEvent('QBCore:Notify', tonumber(targetId), 'YÖNETİMDEN UYARI: ' .. msg, 'error', 20000)
    TriggerClientEvent('Restlibadmin:Client:ShowPrivateAnnounce', tonumber(targetId), msg)
end)

RegisterNetEvent('Restlibadmin:Server:OpenClothing', function(targetId)
    local src = source
    if not IsAuthorized(src) then return end
    local tPlayer = QBCore.Functions.GetPlayer(tonumber(targetId))
    if tPlayer then
        TriggerClientEvent('Restlibadmin:Client:OpenClothingMenu', tPlayer.PlayerData.source)
        if IsRealPlayer(src) then
            TriggerClientEvent('QBCore:Notify', src, "Kıyafet menüsü verildi.", "success")
        else
            print("^2[Bot]^7 Kıyafet menüsü verildi ID: " .. targetId)
        end
    else
        if IsRealPlayer(src) then TriggerClientEvent('QBCore:Notify', src, "Oyuncu bulunamadı!", "error") end
    end
end)

RegisterNetEvent('Restlibadmin:Server:CheckInventory', function(targetId)
    local src = source
    if not IsAuthorized(src) then return end
    local Player = QBCore.Functions.GetPlayer(tonumber(targetId))
    if Player then
        local items = Player.PlayerData.items
        if IsRealPlayer(src) then TriggerClientEvent('Restlibadmin:Client:ReceiveInventory', src, items) end
    end
end)

RegisterNetEvent('Restlibadmin:Server:SaveBlip', function(data)
    local src = source
    if not IsAuthorized(src) then return end
    table.insert(ServerBlips, data)
    SaveResourceFile(GetCurrentResourceName(), "blips.json", json.encode(ServerBlips), -1)
    TriggerClientEvent('Restlibadmin:Client:UpdateBlips', -1, ServerBlips)
end)

RegisterNetEvent('Restlibadmin:Server:DeleteBlip', function(index)
    local src = source
    if not IsAuthorized(src) then return end
    if ServerBlips[index] then
        table.remove(ServerBlips, index)
        SaveResourceFile(GetCurrentResourceName(), "blips.json", json.encode(ServerBlips), -1)
        TriggerClientEvent('Restlibadmin:Client:UpdateBlips', -1, ServerBlips)
    end
end)

RegisterNetEvent('Restlibadmin:Server:DiscordCheckBank', function(targetId)
    local tPlayer = QBCore.Functions.GetPlayer(tonumber(targetId))
    if tPlayer then
        local cash = tPlayer.PlayerData.money.cash
        local bank = tPlayer.PlayerData.money.bank
        local name = tPlayer.PlayerData.charinfo.firstname .. " " .. tPlayer.PlayerData.charinfo.lastname
        print("^4[Banka]^7 Oyuncu: "..name.." | Nakit: $"..cash.." | Banka: $"..bank)
        TriggerEvent('Restlibadmin:Bot:ReceiveBankData', targetId, name, cash, bank)
    else
        TriggerEvent('Restlibadmin:Bot:ReceiveBankData', targetId, nil, 0, 0)
    end
end)

RegisterNetEvent('Restlibadmin:Server:DiscordClearInv', function(targetId, adminName)
    local tPlayer = QBCore.Functions.GetPlayer(tonumber(targetId))
    if tPlayer then tPlayer.Functions.ClearInventory() print("^2[Bot]^7 Envanter silindi ID: "..targetId) end
end)

RegisterNetEvent('Restlibadmin:Server:DiscordRevive', function(targetId, adminName)
    local src = tonumber(targetId)
    local tPlayer = QBCore.Functions.GetPlayer(src)
    if tPlayer then
        TriggerClientEvent('hospital:client:Revive', src)
        TriggerClientEvent('qb-ambulancejob:revive', src)
        TriggerClientEvent('ars_ambulancejob:client:revive', src)
        TriggerClientEvent('wasabi_ambulance:revive', src)
        tPlayer.Functions.SetMetaData('health', 200)
        tPlayer.Functions.SetMetaData('isdead', false)
        tPlayer.Functions.SetMetaData('inlaststand', false)
        tPlayer.Functions.SetMetaData('thirst', 100)
        tPlayer.Functions.SetMetaData('hunger', 100)
        TriggerClientEvent('QBCore:Client:SetDuty', src) 
        print("^2[Bot]^7 Canlandırma yapıldı ID: "..src)
    end
end)

RegisterNetEvent('Restlibadmin:Server:RevivePlayer', function(targetId)
    local src = source
    if not IsAuthorized(src) then return end 
    TriggerEvent('Restlibadmin:Server:DiscordRevive', targetId, "Panel")
end)

RegisterNetEvent('Restlibadmin:Server:PlayerAction', function(targetId, action)
    local src = source
    if not IsAuthorized(src) then return end
    local tPlayer = QBCore.Functions.GetPlayer(tonumber(targetId))
    if not tPlayer then return end
    if action == 'revive' then TriggerEvent('Restlibadmin:Server:DiscordRevive', targetId, "Panel")
    elseif action == 'kick' then DropPlayer(tonumber(targetId), 'Yönetim tarafından atıldınız.')
    elseif action == 'goto' then
        local coords = GetEntityCoords(GetPlayerPed(tonumber(targetId)))
        TriggerClientEvent('QBCore:Command:TeleportToCoords', src, coords.x, coords.y, coords.z)
    elseif action == 'bring' then
        local coords = GetEntityCoords(GetPlayerPed(src))
        TriggerClientEvent('QBCore:Command:TeleportToCoords', tonumber(targetId), coords.x, coords.y, coords.z)
    end
end)

RegisterNetEvent('Restlibadmin:Server:TrollPlayer', function(targetId, type)
    local src = source
    if src == 0 or src == nil or IsAuthorized(src) then
        TriggerClientEvent('Restlibadmin:Client:TrollEffect', tonumber(targetId), type)
    end
end)

RegisterNetEvent('Restlibadmin:Server:DiscordGetInventory', function(targetId)
    local targetId = tonumber(targetId)
    local tPlayer = QBCore.Functions.GetPlayer(targetId)
    if tPlayer then
        local items = {}
        if GetResourceState('ox_inventory') == 'started' then
            items = exports.ox_inventory:GetInventoryItems(targetId)
        else
            items = tPlayer.PlayerData.items
        end
        local inventoryList = {}
        local isEmpty = true
        if items then
            for _, item in pairs(items) do
                if item and (item.name or item.label) then
                    local quantity = item.count or item.amount or 0
                    if quantity > 0 then
                        isEmpty = false
                        local label = item.label or item.name or "Bilinmeyen Eşya"
                        table.insert(inventoryList, label .. " (x" .. tostring(quantity) .. ")")
                    end
                end
            end
        end
        local charName = tPlayer.PlayerData.charinfo.firstname .. " " .. tPlayer.PlayerData.charinfo.lastname
        local resultString = isEmpty and "Envanter Boş." or table.concat(inventoryList, ", ")
        print("^2[Bot]^7 Envanter sorgulandı ID: " .. targetId)
        TriggerEvent('Restlibadmin:Bot:ReceiveInventoryData', targetId, charName, resultString)
    else
        TriggerEvent('Restlibadmin:Bot:ReceiveInventoryData', targetId, nil, nil)
    end
end)

RegisterNetEvent('Restlibadmin:Server:DiscordGetStatus', function()
    local players = QBCore.Functions.GetPlayers()
    local totalPlayers = #players
    local policeCount = 0
    local emsCount = 0
    local mechCount = 0
    for _, v in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player then
            local job = Player.PlayerData.job.name
            if job == "police" then policeCount = policeCount + 1
            elseif job == "ambulance" then emsCount = emsCount + 1
            elseif job == "mechanic" then mechCount = mechCount + 1 end
        end
    end
    TriggerEvent('Restlibadmin:Bot:ReceiveStatusData', totalPlayers, policeCount, emsCount, mechCount)
end)

QBCore.Commands.Add('report', 'Yönetime yardım talebi gönderir', {{name='mesaj', help='Sorununuz'}}, true, function(source, args)
    local msg = table.concat(args, ' ')
    if msg == '' then 
        TriggerClientEvent('QBCore:Notify', source, 'Lütfen bir mesaj yazın!', 'error')
        return 
    end
    local Player = QBCore.Functions.GetPlayer(source)
    local name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)
    TriggerEvent('Restlibadmin:Bot:SendReportToDiscord', source, name, msg, coords.x, coords.y, coords.z)
    TriggerClientEvent('QBCore:Notify', source, 'Talebiniz yönetime iletildi.', 'success')
end)

RegisterNetEvent('Restlibadmin:Server:DiscordTakeScreenshot', function(targetId)
    local src = source
    local tPlayer = QBCore.Functions.GetPlayer(tonumber(targetId))
    if tPlayer then
        TriggerClientEvent('Restlibadmin:Client:CaptureScreenshot', tPlayer.PlayerData.source)
        print("^2[Bot]^7 Ekran görüntüsü talebi gönderildi ID: " .. targetId)
    else
        TriggerEvent('Restlibadmin:Bot:ReceiveScreenshot', targetId, nil)
    end
end)

RegisterNetEvent('Restlibadmin:Server:ScreenshotResult', function(url)
    local src = source
    local tPlayer = QBCore.Functions.GetPlayer(src)
    local name = tPlayer.PlayerData.charinfo.firstname .. " " .. tPlayer.PlayerData.charinfo.lastname
    TriggerEvent('Restlibadmin:Bot:ReceiveScreenshot', src, name, url)
end)