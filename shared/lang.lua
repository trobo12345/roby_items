Lang = {
    ['hu'] = {
        roby_scripts_title = "Roby Scripts",
        search_placeholder = "Keresés...",
        close_button = "X",
        item_list_title = "ITEM LISTA",
        no_items_to_display = "Nincsenek megjeleníthető itemek.",
        copy_name_button = "Név másolása",
        retrieve_button = "Lehívás",
        give_button = "Adás",
        give_item_modal_title = "Item Átadása Játékosnak",
        retrieve_modal_title = "Item Lehívása",
        player_id_label = "Játékos ID:",
        player_id_placeholder = "Add meg a játékos ID-t",
        amount_label = "Mennyiség:",
        amount_placeholder = "1",
        cancel_button = "Mégse",
        confirm_give_button = "Átadás",
        confirm_retrieve_button = "Lehívás",
        notification_item_retrieved = "Item lehívva: %s",        
        notification_item_given_initiated = "Item átadása (%s) játékosnak (%s) kezdeményezve.",
        notification_invalid_player_id = "Érvénytelen játékos ID: %s",
        notification_missing_ids = "Item ID vagy Játékos ID hiányzik.",
        prev_page = "Előző",
        next_page = "Következő",
        page_info = "Oldal",
        no_permission = "Nincs jogosultságod ennek a parancsnak a használatához!"
    },
    ['en'] = {
        roby_scripts_title = "Roby Scripts",
        search_placeholder = "Search...",
        close_button = "X",
        item_list_title = "ITEM LIST",
        no_items_to_display = "No items to display.",
        copy_name_button = "Copy Name",
        retrieve_button = "Retrieve",
        give_button = "Give",
        give_item_modal_title = "Give Item to Player",
        retrieve_modal_title = "Retrieve Item",
        player_id_label = "Player ID:",
        player_id_placeholder = "Enter player ID",
        amount_label = "Amount:",
        amount_placeholder = "1",
        cancel_button = "Cancel",
        confirm_give_button = "Give",
        confirm_retrieve_button = "Retrieve",
        notification_item_retrieved = "Item retrieved: %s",        
        notification_item_given_initiated = "Giving item (%s) to player (%s) initiated.",
        notification_invalid_player_id = "Invalid player ID: %s",
        notification_missing_ids = "Missing Item ID or Player ID.",
        prev_page = "Previous",
        next_page = "Next",
        page_info = "Page",
        no_permission = "You don't have permission to use this command!"
    },
    ['de'] = {
        roby_scripts_title = "Roby Scripts",
        search_placeholder = "Suchen...",
        close_button = "X",
        item_list_title = "GEGENSTANDSLISTE",
        no_items_to_display = "Keine Gegenstände zum Anzeigen.",
        copy_name_button = "Namen kopieren",
        retrieve_button = "Abholen",
        give_button = "Geben",
        give_item_modal_title = "Gegenstand an Spieler geben",
        retrieve_modal_title = "Gegenstand abholen",
        player_id_label = "Spieler-ID:",
        player_id_placeholder = "Spieler-ID eingeben",
        amount_label = "Menge:",
        amount_placeholder = "1",
        cancel_button = "Abbrechen",
        confirm_give_button = "Geben",
        confirm_retrieve_button = "Abholen",
        notification_item_retrieved = "Gegenstand abgeholt: %s",        
        notification_item_given_initiated = "Gegenstand (%s) an Spieler (%s) übergeben.",
        notification_invalid_player_id = "Ungültige Spieler-ID: %s",
        notification_missing_ids = "Gegenstand-ID oder Spieler-ID fehlt.",
        prev_page = "Vorherige",
        next_page = "Nächste",
        page_info = "Seite",
        no_permission = "Du hast keine Berechtigung, diesen Befehl zu verwenden!"
    }
}

function _L(str, ...)
    if Lang[Roby.Language] and Lang[Roby.Language][str] then
        return string.format(Lang[Roby.Language][str], ...)
    elseif Lang['en'] and Lang['en'][str] then
        print(string.format('[Roby_Items] Missing translation for "%s" in language "%s", using English fallback.', str, Roby.Language))
        return string.format(Lang['en'][str], ...)
    else
        print(string.format('[Roby_Items] Missing translation for "%s" in language "%s" and no English fallback available.', str, Roby.Language))
        return str
    end
end
