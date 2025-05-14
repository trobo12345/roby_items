local resourceName = GetCurrentResourceName()

ESX = exports["es_extended"]:getSharedObject()

if Roby.Debug then
    print(string.format("[%s] [DEBUG] Server script loaded. Resource Name: %s", resourceName, resourceName))
end

ESX.RegisterServerCallback(resourceName .. ':checkPermission', function(source, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
      if not xPlayer then
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] Player not found for ID %s in permission check", resourceName, src))
        end
        cb(false)
        return
    end
    
    local playerGroup = xPlayer.getGroup()
    local hasPermission = false
      if Roby.AllowedGroups[playerGroup] then
        hasPermission = true
    end
    
    if Roby.EnableAdminDutySupport and not hasPermission then
        local playerState = Player(src).state
        if playerState and playerState.asdasd_adminduty then
            hasPermission = true
        end
    end
      if Roby.Debug then
        print(string.format("[%s] [DEBUG] Permission check for player %s (Group: %s): %s", 
            resourceName, src, playerGroup, hasPermission and "Granted" or "Denied"))
    end
    
    cb(hasPermission)
end)

Roby.HasPermission = function(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    
    local playerGroup = xPlayer.getGroup()
      if Roby.AllowedGroups[playerGroup] then 
        return true 
    end
    
    if Roby.EnableAdminDutySupport then
        local playerState = Player(src).state
        if playerState and playerState.asdasd_adminduty then
            return true
        end
    end
    
    return false
end

RegisterNetEvent(resourceName .. ':retrieveItem_s', function(itemId)
    local src = source
      if not Roby.HasPermission(src) then
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] Unauthorized retrieval attempt by player %s for item %s", resourceName, src, itemId))
        end
        return
    end
    
    if Roby.Debug then
        print(string.format("[%s] [DEBUG] Event '%s:retrieveItem_s' triggered by player %s for item %s", resourceName, resourceName, src, itemId))
    end
      if exports.ox_inventory:AddItem(src, itemId, 1) then
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] OX_INVENTORY: Item %s successfully given to player %s", resourceName, itemId, src))
        end
    else
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] OX_INVENTORY: Failed to give item %s to player %s", resourceName, itemId, src))
        end
    end
end)

RegisterNetEvent(resourceName .. ':giveItemToPlayer_s', function(itemId, targetPlayerId)
    local src = source
    local targetSrc = tonumber(targetPlayerId)
      if not Roby.HasPermission(src) then
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] Player %s attempted to give item without permission", resourceName, src))
        end
        return
    end
    
    if Roby.Debug then
        print(string.format("[%s] [DEBUG] Event '%s:giveItemToPlayer_s' triggered by player %s for item %s to target %s", 
            resourceName, resourceName, src, itemId, targetPlayerId))
    end
      if targetSrc and GetPlayerName(targetSrc) then
        if exports.ox_inventory:AddItem(targetSrc, itemId, 1) then
            if Roby.Debug then
                print(string.format("[%s] [DEBUG] OX_INVENTORY: Item %s successfully given to target player %s by player %s", 
                    resourceName, itemId, targetSrc, src))
            end
        else
            if Roby.Debug then
                print(string.format("[%s] [DEBUG] OX_INVENTORY: Failed to give item %s to target player %s", 
                    resourceName, itemId, targetSrc))
            end
        end
    else
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] Invalid target player ID: %s (requested by player %s)", 
                resourceName, targetPlayerId, src))
        end
    end
end)

RegisterNetEvent(resourceName .. ':getItems_s', function()
    local src = source
    
    if not Roby.HasPermission(src) then
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] Player %s attempted to get items without permission", resourceName, src))
        end
        return
    end
    
    if Roby.Debug then
        print(string.format("[%s] [DEBUG] Event '%s:getItems_s' triggered by player %s. Fetching items from ox_inventory.", resourceName, resourceName, src))
    end
    
    local items = exports.ox_inventory:Items()
    local itemList = {}
    
    if type(items) == 'table' then
        for itemName, itemData in pairs(items) do
            table.insert(itemList, { id = itemName, name = itemData.label or itemName })
        end
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] Fetched %d items from ox_inventory. Sending to player %s.", resourceName, #itemList, src))
        end
    else
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] Failed to fetch items or no items found in ox_inventory. 'items' type: %s", resourceName, type(items)))
        end
    end
    
    TriggerClientEvent(resourceName .. ':receiveItems_c', src, itemList)
end)

if Roby.Debug then
    print(string.format("[%s] [DEBUG] Server-side script fully loaded and configured to use ox_inventory. Debug is ON.", resourceName))
else
    print(string.format("[%s] Server-side script loaded. Debug is OFF.", resourceName))
end
