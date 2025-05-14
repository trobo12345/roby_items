let currentResourceName = 'roby_items';
let currentItemToGive = null;
let allItems = [];
let filteredItems = [];
let currentPage = 1;
let itemsPerPage = 10;
let translations = {};

function copyToClipboard(text) {
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';
    document.body.appendChild(textarea);
    textarea.select();
    try {
        const successful = document.execCommand('copy');
        const msg = successful ? 'sikeres' : 'sikertelen';
        console.log('Másolás ' + msg + ' szöveghez: ' + text);
    } catch (err) {
        console.error('Hiba a másoláskor: ', err);
    }
    document.body.removeChild(textarea);
}

function filterItems(searchText) {
    if (!searchText || searchText.trim() === '') {
        filteredItems = [...allItems];
    } else {
        const lowerSearchText = searchText.toLowerCase();
        filteredItems = allItems.filter(item => 
            item.name.toLowerCase().includes(lowerSearchText) || 
            item.id.toLowerCase().includes(lowerSearchText)
        );
    }
    currentPage = 1;
    updatePagination();
    displayCurrentPageItems();
}

function updatePagination() {
    const totalPages = Math.ceil(filteredItems.length / itemsPerPage) || 1;
    const prevPageBtn = document.getElementById('prevPage');
    const nextPageBtn = document.getElementById('nextPage');
    const pageInfoSpan = document.getElementById('pageInfo');
    
    if (prevPageBtn) prevPageBtn.disabled = currentPage <= 1;
    if (nextPageBtn) nextPageBtn.disabled = currentPage >= totalPages;
    if (pageInfoSpan) pageInfoSpan.textContent = `${translations.page_info || 'Page'} ${currentPage}/${totalPages}`;
}

function displayCurrentPageItems() {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = Math.min(startIndex + itemsPerPage, filteredItems.length);
    const pageItems = filteredItems.slice(startIndex, endIndex);
    displayItems(pageItems);
}

function displayItems(items) {
    const itemList = document.getElementById('item-list'); 
    if (!itemList) return;
    itemList.innerHTML = '';

    if (!items || items.length === 0) {
        itemList.innerHTML = `<p class="no-items">${translations.no_items_to_display || 'No items to display'}</p>`;
        return;
    }

    items.forEach(item => {
        const itemElement = document.createElement('div');
        itemElement.className = 'item';

        const itemNameLabel = document.createElement('span');
        itemNameLabel.textContent = item.name;
        itemNameLabel.className = 'item-name';

        const buttonsContainer = document.createElement('div');
        buttonsContainer.className = 'item-actions';

        const copyButton = document.createElement('button');
        copyButton.textContent = translations.copy_name_button || 'Copy Name';
        copyButton.onclick = () => {
            fetch(`https://${currentResourceName}/copyItemName`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({ itemName: item.id })
            }).catch(err => console.error("Hiba a copyItemName küldésekor:", err));
        };
        
        const retrieveButton = document.createElement('button');
        retrieveButton.textContent = translations.retrieve_button || 'Retrieve';
        retrieveButton.onclick = () => {
            fetch(`https://${currentResourceName}/retrieveItem`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({ itemId: item.id })
            }).catch(err => console.error("Hiba a retrieveItem küldésekor:", err));
        };

        const giveButton = document.createElement('button');
        giveButton.textContent = translations.give_button || 'Give';
        giveButton.onclick = () => {
            currentItemToGive = item.id;
            const giveModal = document.getElementById('give-item-modal');
            if (giveModal) {
                giveModal.style.display = 'flex';
                
                const modalTitle = giveModal.querySelector('h2');
                if (modalTitle) modalTitle.textContent = translations.give_item_modal_title || 'Give Item to Player';
                
                const playerLabel = giveModal.querySelector('label');
                if (playerLabel) playerLabel.textContent = translations.player_id_label || 'Player ID:';
                
                const playerInput = document.getElementById('player-id-input');
                if (playerInput) playerInput.placeholder = translations.player_id_placeholder || 'Enter player ID';
                
                const cancelBtn = document.getElementById('cancel-give-button');
                if (cancelBtn) cancelBtn.textContent = translations.cancel_button || 'Cancel';
                
                const confirmBtn = document.getElementById('confirm-give-button');
                if (confirmBtn) confirmBtn.textContent = translations.confirm_give_button || 'Give';
            }
        };

        buttonsContainer.appendChild(copyButton);
        buttonsContainer.appendChild(retrieveButton);
        buttonsContainer.appendChild(giveButton);
        itemElement.appendChild(itemNameLabel);
        itemElement.appendChild(buttonsContainer);
        itemList.appendChild(itemElement);
    });
}

window.addEventListener('message', function(event) {
    const action = event.data.action;
    const data = event.data;

    if (data.resourceName) {
        currentResourceName = data.resourceName;
    }

    if (data.translations) {
        translations = data.translations;
        
        const title = document.getElementById('title');
        if (title) title.textContent = translations.roby_scripts_title || 'Roby Scriptss';
        
        const searchInput = document.getElementById('searchInput');
        if (searchInput) searchInput.placeholder = translations.search_placeholder || 'Search...';
        
        const closeButton = document.getElementById('close-button');
        if (closeButton) closeButton.textContent = translations.close_button || 'Close';
        
        const prevButton = document.getElementById('prevPage');
        if (prevButton) prevButton.textContent = translations.prev_page || 'Previous';
        
        const nextButton = document.getElementById('nextPage');
        if (nextButton) nextButton.textContent = translations.next_page || 'Next';
    }

    const uiContainer = document.getElementById('ui-container');
    const bodyElement = document.body;

    switch (action) {
        case 'openUi':
            bodyElement.style.display = 'flex';
            uiContainer.style.display = 'flex';
            if (data.items) {
                allItems = data.items;
                filteredItems = [...allItems];
                updatePagination();
                displayCurrentPageItems();
            }
            break;
        case 'closeUi':
            uiContainer.style.display = 'none';
            bodyElement.style.display = 'none';
            document.getElementById('give-item-modal').style.display = 'none';
            break;
        case 'updateItems':
            if (data.items) {
                allItems = data.items;
                filteredItems = [...allItems];
                updatePagination();
                displayCurrentPageItems();
            }
            break;
        case 'copyToClipboard':
            if (data.text) {
                copyToClipboard(data.text);
            }
            break;
        case 'showNotification':
            console.log(data.message);
            break;
    }
});

document.addEventListener('DOMContentLoaded', () => {
    const closeButton = document.getElementById('close-button');
    const giveItemModal = document.getElementById('give-item-modal');
    const cancelGiveButton = document.getElementById('cancel-give-button');
    const confirmGiveButton = document.getElementById('confirm-give-button');
    const playerIdInput = document.getElementById('player-id-input');
    const searchInput = document.getElementById('searchInput');
    const prevPageBtn = document.getElementById('prevPage');
    const nextPageBtn = document.getElementById('nextPage');

    if (closeButton) {
        closeButton.onclick = () => {
            fetch(`https://${currentResourceName}/closeUi`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({})
            }).catch(err => console.error("Hiba a closeUi küldésekor:", err));
        };
    }

    if (cancelGiveButton) {
        cancelGiveButton.onclick = () => {
            giveItemModal.style.display = 'none';
            currentItemToGive = null;
            playerIdInput.value = '';
        };
    }

    if (confirmGiveButton) {
        confirmGiveButton.onclick = () => {
            const targetPlayerId = playerIdInput.value.trim();
            if (currentItemToGive && targetPlayerId) {
                fetch(`https://${currentResourceName}/giveItemToPlayer`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                    body: JSON.stringify({ itemId: currentItemToGive, targetPlayerId: targetPlayerId })
                }).catch(err => console.error("Hiba a giveItemToPlayer küldésekor:", err));
                
                giveItemModal.style.display = 'none';
                currentItemToGive = null;
                playerIdInput.value = '';
            } else {
                console.error('Item ID vagy Player ID hiányzik.');
            }
        };
    }

    if (searchInput) {
        searchInput.addEventListener('input', (e) => {
            filterItems(e.target.value);
        });
    }

    if (prevPageBtn) {
        prevPageBtn.addEventListener('click', () => {
            if (currentPage > 1) {
                currentPage--;
                updatePagination();
                displayCurrentPageItems();
            }
        });
    }

    if (nextPageBtn) {
        nextPageBtn.addEventListener('click', () => {
            const totalPages = Math.ceil(filteredItems.length / itemsPerPage) || 1;
            if (currentPage < totalPages) {
                currentPage++;
                updatePagination();
                displayCurrentPageItems();
            }
        });
    }
});
