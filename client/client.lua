local nuiOpen = false
local resourceName = GetCurrentResourceName()
local currentItems = {}

CreateThread(function()
ESX = exports["es_extended"]:getSharedObject()

      if Roby.Debug then
        print(string.format("[%s] [DEBUG] ESX loaded successfully", resourceName))
    end

    TriggerServerEvent(resourceName .. ':getItems_s')
end)

Roby.ShowNotification = function(message)
    if ESX then
        ESX.ShowNotification(message)
    end
    if Roby.Debug then
        print(string.format("[%s] [DEBUG] Notification: %s", resourceName, message))
    end
end

RegisterCommand('items', function(source, args, rawCommand)
    ESX.TriggerServerCallback(resourceName .. ':checkPermission', function(hasPermission)        if not hasPermission then
            Roby.ShowNotification(_L('no_permission'))
            return
        end
        
        if Roby.Debug then
            print(string.format("[%s] [DEBUG] 'items' command executed. NUI current state: %s. currentItems count: %d", resourceName, nuiOpen, #currentItems))
        end
        
        if not nuiOpen then            if #currentItems == 0 then 
                if Roby.Debug then
                    print(string.format("[%s] [DEBUG] Requesting items from server as currentItems is empty.", resourceName))
                end
                TriggerServerEvent(resourceName .. ':getItems_s')
            else
                if Roby.Debug then
                    print(string.format("[%s] [DEBUG] Not requesting items from server, using %d cached items.", resourceName, #currentItems))
                end
            end
        end
        
        Roby.ToggleNuiFrame(not nuiOpen)
    end)
end, false)

Roby.PrepareTranslations = function()
    local translations = {
        roby_scripts_title = _L('roby_scripts_title'),
        search_placeholder = _L('search_placeholder'),
        close_button = _L('close_button'),
        item_list_title = _L('item_list_title'),
        no_items_to_display = _L('no_items_to_display'),
        copy_name_button = _L('copy_name_button'),
        retrieve_button = _L('retrieve_button'),
        give_button = _L('give_button'),
        give_item_modal_title = _L('give_item_modal_title'),
        player_id_label = _L('player_id_label'),
        player_id_placeholder = _L('player_id_placeholder'),
        cancel_button = _L('cancel_button'),
        confirm_give_button = _L('confirm_give_button'),
        prev_page = _L('prev_page'),
        next_page = _L('next_page'),
        page_info = _L('page_info')
    }
    return translations
end

Roby.ToggleNuiFrame = function(state)
    if Roby.Debug then
        print(string.format("[%s] [DEBUG] ToggleNuiFrame called. New state: %s", resourceName, state))
    end
    nuiOpen = state
    SetNuiFocus(state, state) 
    local message = {
        action = state and 'openUi' or 'closeUi',
        resourceName = resourceName,
        translations = state and Roby.PrepareTranslations() or nil
    }
    if state and #currentItems > 0 then
        if Config.Debug then
            print(string.format("[%s] [DEBUG] Sending %d items to NUI on open.", resourceName, #currentItems))
        end
        message.items = currentItems 
    end
    SendNUIMessage(message)    if Roby.Debug then
        print(string.format("[%s] [DEBUG] Sent NUI message with action: %s", resourceName, message.action))
    end
end

RegisterNetEvent(resourceName .. ':receiveItems_c', function(itemsFromServer)
    if Roby.Debug then
        print(string.format("[%s] [DEBUG] Received %d items from server.", resourceName, #itemsFromServer))
    end
    currentItems = itemsFromServer
    if nuiOpen then 
        if Config.Debug then
            print(string.format("[%s] [DEBUG] NUI is open, sending updated items list (%d items).", resourceName, #currentItems))
        end
        SendNUIMessage({
            action = 'updateItems',
            items = currentItems,
            resourceName = resourceName
        })
    end
end)

RegisterNUICallback('closeUi', function(data, cb)
    if Roby.Debug then
        print(string.format("[%s] [DEBUG] NUI callback 'closeUi' received.", resourceName))
    end
    Roby.ToggleNuiFrame(false)
    cb({ ok = true })
end)

RegisterNUICallback('retrieveItem', function(data, cb)
    if Roby.Debug then
        print(string.format("[%s] [DEBUG] NUI callback 'retrieveItem' received. Item ID: %s", resourceName, data.itemId))
    end
    if data.itemId then
        TriggerServerEvent(resourceName .. ':retrieveItem_s', data.itemId)
        local notificationMsg = string.format(_L('notification_item_retrieved'), data.itemId)
        ShowNotification(notificationMsg)
        SendNUIMessage({ 
            action = 'showNotification', 
            message = notificationMsg
        })
    end
    cb({ ok = true })
end)

RegisterNUICallback('copyItemName', function(data, cb)
    if Roby.Debug then
        print(string.format("[%s] [DEBUG] NUI callback 'copyItemName' received. Item Name: %s", resourceName, data.itemName))
    end
    if data.itemName then
        SendNUIMessage({ action = 'copyToClipboard', text = data.itemName })
    end
    cb({ ok = true })
end)

RegisterNUICallback('giveItemToPlayer', function(data, cb)
    if Roby.Debug then
        print(string.format("[%s] [DEBUG] NUI callback 'giveItemToPlayer' received. Item ID: %s, Target Player ID: %s", resourceName, data.itemId, data.targetPlayerId))
    end
    if data.itemId and data.targetPlayerId then
        local targetPlayer = tonumber(data.targetPlayerId)
        if targetPlayer then
            TriggerServerEvent(resourceName .. ':giveItemToPlayer_s', data.itemId, targetPlayer)
            local notificationMsg = string.format(_L('notification_item_given_initiated'), data.itemId, targetPlayer)
            ShowNotification(notificationMsg)
            SendNUIMessage({ 
                action = 'showNotification', 
                message = notificationMsg
            })
        else
            local notificationMsg = string.format(_L('notification_invalid_player_id'), data.targetPlayerId)
            ShowNotification(notificationMsg)
            SendNUIMessage({ 
                action = 'showNotification', 
                message = notificationMsg
            })
            if Config.Debug then
                print(string.format("[%s] [DEBUG] Invalid target player ID: %s", resourceName, data.targetPlayerId))
            end
        end
    else
        local notificationMsg = _L('notification_missing_ids')
        ShowNotification(notificationMsg)
        SendNUIMessage({ 
            action = 'showNotification', 
            message = notificationMsg
        })
        if Config.Debug then
            print(string.format("[%s] [DEBUG] Missing itemId or targetPlayerId in 'giveItemToPlayer' callback.", resourceName))
        end
    end
    cb({ ok = true })
end)

