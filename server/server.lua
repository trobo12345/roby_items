local resourceName = GetCurrentResourceName()

-- Discord webhook logging (leave empty to disable)
Roby.DiscordWebhook = ""
Roby.DiscordBotName = "Roby Items"

-- Current version – used for update checks
local CURRENT_VERSION = "2.0.0"
Roby.UpdateAvailable = false
Roby.LatestVersion    = nil

ESX = exports["es_extended"]:getSharedObject()

-- Version check against GitHub releases
AddEventHandler('onResourceStart', function(res)
    if res ~= resourceName then return end
    PerformHttpRequest(
        'https://api.github.com/repos/trobo12345/roby_items/releases/latest',
        function(statusCode, response)
            if statusCode == 200 and response then
                local ok, data = pcall(json.decode, response)
                if ok and data and data.tag_name then
                    local latest = data.tag_name:gsub('^v', '')
                    Roby.LatestVersion = latest
                    if latest ~= CURRENT_VERSION then
                        Roby.UpdateAvailable = true
                        print(string.format('^3[%s] UPDATE AVAILABLE — Current: v%s → Latest: v%s^7', resourceName, CURRENT_VERSION, latest))
                        print(string.format('^3[%s] Download: %s^7', resourceName, data.html_url or 'https://github.com/trobo12345/roby_items/releases'))
                    else
                        print(string.format('^2[%s] Up to date (v%s)^7', resourceName, CURRENT_VERSION))
                    end
                end
            elseif Roby.Debug then
                print(string.format('[%s] [DEBUG] Version check failed: HTTP %d', resourceName, statusCode or 0))
            end
        end,
        'GET', '', { ['User-Agent'] = 'roby_items-versioncheck' }
    )
end)

if Roby.Debug then
    print(string.format("[%s] [DEBUG] Server script loaded.", resourceName))
end

-- Callback so clients can retrieve update status for the UI
ESX.RegisterServerCallback(resourceName .. ':getUpdateInfo_s', function(source, cb)
    cb(Roby.UpdateAvailable, Roby.LatestVersion)
end)

Roby.HasPermission = function(src)
    if Roby.UseAcePermission then
        return IsPlayerAceAllowed(tostring(src), 'roby_items.use')
    end
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    return Roby.AllowedGroups[xPlayer.getGroup()] == true
end

ESX.RegisterServerCallback(resourceName .. ':checkPermission', function(source, cb)
    cb(Roby.HasPermission(source))
end)

local function DiscordLog(action, giverName, giverId, itemId, amount, targetName, targetId)
    if not Roby.DiscordWebhook or Roby.DiscordWebhook == "" then return end

    local color = action == "retrieve" and 3447003 or 15105570
    local description
    if action == "retrieve" then
        description = string.format("**%s** (ID: %s) retrieved: `%s` × **%d**", giverName, giverId, itemId, amount)
    else
        description = string.format("**%s** (ID: %s) gave **%s** (ID: %s): `%s` × **%d**",
            giverName, giverId, targetName or "?", targetId or "?", itemId, amount)
    end

    local payload = json.encode({
        username = Roby.DiscordBotName or "Roby Items",
        embeds = {{
            title = action == "retrieve" and "Item Retrieve" or "Item Give",
            description = description,
            color = color,
            footer = { text = "Roby Items • " .. os.date("%Y-%m-%d %H:%M:%S") }
        }}
    })

    PerformHttpRequest(Roby.DiscordWebhook, function(statusCode)
        if Roby.Debug then
            print(string.format("[%s] [DISCORD] Status: %d", resourceName, statusCode))
        end
    end, "POST", payload, { ["Content-Type"] = "application/json" })
end

local function IsBanned(itemId)
    if not Roby.BannedItems then return false end
    for _, v in ipairs(Roby.BannedItems) do
        if v == itemId then return true end
    end
    return false
end

RegisterNetEvent(resourceName .. ':retrieveItem_s', function(itemId, amount)
    local src = source
    amount = math.max(1, math.floor(tonumber(amount) or 1))

    if not Roby.HasPermission(src) then
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] Unauthorized retrieve by player %s", resourceName, src))
        end
        return
    end

    if IsBanned(itemId) then
        TriggerClientEvent(resourceName .. ':notification_c', src, "~r~This item is banned!")
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] Banned item '%s' blocked for player %s", resourceName, itemId, src))
        end
        return
    end

    if exports.ox_inventory:AddItem(src, itemId, amount) then
        local xPlayer = ESX.GetPlayerFromId(src)
        local playerName = xPlayer and xPlayer.getName() or tostring(src)
        DiscordLog("retrieve", playerName, src, itemId, amount, nil, nil)
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] %s retrieved %dx %s", resourceName, playerName, amount, itemId))
        end
    end
end)

RegisterNetEvent(resourceName .. ':giveItemToPlayer_s', function(itemId, targetPlayerId, amount)
    local src = source
    local targetSrc = tonumber(targetPlayerId)
    amount = math.max(1, math.floor(tonumber(amount) or 1))

    if not Roby.HasPermission(src) then
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] Player %s attempted to give item without permission", resourceName, src))
        end
        return
    end

    if IsBanned(itemId) then
        TriggerClientEvent(resourceName .. ':notification_c', src, "~r~This item is banned!")
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] Banned item '%s' give blocked for player %s", resourceName, itemId, src))
        end
        return
    end

    if not targetSrc or not GetPlayerName(targetSrc) then
        TriggerClientEvent(resourceName .. ':notification_c', src, "~r~Invalid player ID!")
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] Invalid target player ID: %s", resourceName, tostring(targetPlayerId)))
        end
        return
    end

    if exports.ox_inventory:AddItem(targetSrc, itemId, amount) then
        local xPlayer  = ESX.GetPlayerFromId(src)
        local xTarget  = ESX.GetPlayerFromId(targetSrc)
        local giverName  = xPlayer and xPlayer.getName() or tostring(src)
        local targetName = xTarget and xTarget.getName() or tostring(targetSrc)
        DiscordLog("give", giverName, src, itemId, amount, targetName, targetSrc)
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] %s gave %dx %s to %s", resourceName, giverName, amount, itemId, targetName))
        end
    end
end)

RegisterNetEvent(resourceName .. ':getItems_s', function()
    local src = source

    if not Roby.HasPermission(src) then
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] Player %s tried to get items without permission", resourceName, src))
        end
        return
    end

    local items = exports.ox_inventory:Items()
    local itemList = {}

    if type(items) == 'table' then
        for itemName, itemData in pairs(items) do
            table.insert(itemList, {
                id   = itemName,
                name = itemData.label or itemName,
            })
        end
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] Sending %d items to player %s", resourceName, #itemList, src))
        end
    end

    TriggerClientEvent(resourceName .. ':receiveItems_c', src, itemList)
end)

if Roby.Debug then
    print(string.format("[%s] [DEBUG] Server-side fully loaded. Debug is ON.", resourceName))
else
    print(string.format("[%s] Server-side loaded.", resourceName))
end
