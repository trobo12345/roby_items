Roby = {}
Roby.Debug = false
Roby.Language = "en"

-- Permission system
-- UseAcePermission = true  → checks ACE node "roby_items.use"
--   add_ace identifier.license:XXXX roby_items.use allow
-- UseAcePermission = false → ESX group-based check (AllowedGroups)
Roby.UseAcePermission = false

Roby.AllowedGroups = {
    ['admin'] = true,
    ['superadmin'] = true,
    ['mod'] = true
}

-- Banned items – these cannot be given to self or others
Roby.BannedItems = {
    -- 'money',
    -- 'black_money',
    -- 'markedbills',
}
