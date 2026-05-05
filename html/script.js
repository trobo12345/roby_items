'use strict';

// ─── SVG Icons ───────────────────────────────────────────────────────────────
const FALLBACK_SVG  = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 3l-4 4-4-4"/></svg>`;
const ICON_COPY     = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>`;
const ICON_RETRIEVE = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>`;
const ICON_GIVE     = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>`;

let currentResourceName   = 'roby_items';
let currentItemToGive     = null;
let currentItemToRetrieve = null;
let allItems      = [];
let filteredItems = [];
let currentPage   = 1;
const itemsPerPage = 10;
let translations  = {};

// ─── Helpers ──────────────────────────────────────────────────────────────────

function nuiFetch(endpoint, body) {
    return fetch(`https://${currentResourceName}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(body)
    }).catch(err => console.error(`[roby] fetch ${endpoint}:`, err));
}

function copyToClipboard(text) {
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.style.cssText = 'position:fixed;opacity:0';
    document.body.appendChild(textarea);
    textarea.select();
    try { document.execCommand('copy'); } catch (_) {}
    document.body.removeChild(textarea);
}

// ─── Filter & Pagination ──────────────────────────────────────────────────────

function filterItems(searchText) {
    if (!searchText || !searchText.trim()) {
        filteredItems = [...allItems];
    } else {
        const q = searchText.trim().toLowerCase();
        filteredItems = allItems.filter(item =>
            item.name.toLowerCase().includes(q) || item.id.toLowerCase().includes(q)
        );
    }
    currentPage = 1;
    updatePagination();
    displayCurrentPageItems();
}

function updatePagination() {
    const totalPages = Math.max(1, Math.ceil(filteredItems.length / itemsPerPage));
    document.getElementById('prevPage').disabled = currentPage <= 1;
    document.getElementById('nextPage').disabled = currentPage >= totalPages;
    document.getElementById('pageInfo').textContent =
        `${translations.page_info || 'Oldal'} ${currentPage}/${totalPages}`;
}

function displayCurrentPageItems() {
    const start = (currentPage - 1) * itemsPerPage;
    displayItems(filteredItems.slice(start, start + itemsPerPage));
}

// ─── Render Items ─────────────────────────────────────────────────────────────

function makeImgNode(itemId) {
    const img = document.createElement('img');
    img.className = 'item-img';
    img.alt = itemId;
    img.src = `nui://ox_inventory/web/images/${itemId}.png`;
    img.onerror = () => {
        const fallback = document.createElement('div');
        fallback.className = 'item-img-fallback';
        fallback.innerHTML = FALLBACK_SVG;
        img.replaceWith(fallback);
    };
    return img;
}

function makeBtn(cls, icon, label) {
    const btn = document.createElement('button');
    btn.className = cls;
    btn.innerHTML = icon + `<span>${label}</span>`;
    return btn;
}

function displayItems(items) {
    const list = document.getElementById('item-list');
    if (!list) return;
    list.innerHTML = '';

    if (!items || items.length === 0) {
        const p = document.createElement('p');
        p.className = 'no-items';
        p.textContent = translations.no_items_to_display || 'Nincsenek megjeleníthető itemek.';
        list.appendChild(p);
        return;
    }

    const fragment = document.createDocumentFragment();
    for (const item of items) {
        const card = document.createElement('div');
        card.className = 'item';

        card.appendChild(makeImgNode(item.id));

        const info = document.createElement('div');
        info.className = 'item-info';
        const nameEl = document.createElement('span');
        nameEl.className = 'item-name';
        nameEl.textContent = item.name;
        const idEl = document.createElement('span');
        idEl.className = 'item-id';
        idEl.textContent = item.id;
        info.appendChild(nameEl);
        info.appendChild(idEl);
        card.appendChild(info);

        const actions = document.createElement('div');
        actions.className = 'item-actions';

        const copyBtn = makeBtn('btn-copy', ICON_COPY, translations.copy_name_button || 'Másolás');
        copyBtn.onclick = () => nuiFetch('copyItemName', { itemName: item.id });

        const retrieveBtn = makeBtn('btn-retrieve', ICON_RETRIEVE, translations.retrieve_button || 'Lehívás');
        retrieveBtn.onclick = () => openRetrieveModal(item.id);

        const giveBtn = makeBtn('btn-give', ICON_GIVE, translations.give_button || 'Adás');
        giveBtn.onclick = () => openGiveModal(item.id);

        actions.appendChild(copyBtn);
        actions.appendChild(retrieveBtn);
        actions.appendChild(giveBtn);
        card.appendChild(actions);

        fragment.appendChild(card);
    }
    list.appendChild(fragment);
}

// ─── Modals ───────────────────────────────────────────────────────────────────

function openGiveModal(itemId) {
    currentItemToGive = itemId;
    document.getElementById('player-id-input').value = '';
    document.getElementById('give-amount-input').value = '1';
    document.getElementById('give-modal-title').textContent   = translations.give_item_modal_title || 'Item Átadása Játékosnak';
    document.getElementById('give-player-label').textContent  = translations.player_id_label || 'Játékos ID:';
    document.getElementById('give-amount-label').textContent  = translations.amount_label || 'Mennyiség:';
    document.getElementById('player-id-input').placeholder    = translations.player_id_placeholder || 'Játékos ID';
    document.getElementById('cancel-give-button').textContent  = translations.cancel_button || 'Mégse';
    document.getElementById('confirm-give-button').textContent = translations.confirm_give_button || 'Átadás';
    document.getElementById('give-item-modal').style.display = 'flex';
    document.getElementById('player-id-input').focus();
}

function closeGiveModal() {
    document.getElementById('give-item-modal').style.display = 'none';
    currentItemToGive = null;
}

function openRetrieveModal(itemId) {
    currentItemToRetrieve = itemId;
    document.getElementById('retrieve-amount-input').value = '1';
    document.getElementById('retrieve-modal-title').textContent    = translations.retrieve_modal_title || 'Item Lehívása';
    document.getElementById('retrieve-amount-label').textContent   = translations.amount_label || 'Mennyiség:';
    document.getElementById('retrieve-amount-input').placeholder   = translations.amount_placeholder || '1';
    document.getElementById('cancel-retrieve-button').textContent  = translations.cancel_button || 'Mégse';
    document.getElementById('confirm-retrieve-button').textContent = translations.confirm_retrieve_button || 'Lehívás';
    document.getElementById('retrieve-item-modal').style.display = 'flex';
    document.getElementById('retrieve-amount-input').focus();
}

function closeRetrieveModal() {
    document.getElementById('retrieve-item-modal').style.display = 'none';
    currentItemToRetrieve = null;
}

// ─── NUI Messages ─────────────────────────────────────────────────────────────

window.addEventListener('message', function(event) {
    const data   = event.data;
    const action = data.action;

    if (data.resourceName) currentResourceName = data.resourceName;

    if (data.translations) {
        translations = data.translations;
        const el = (id) => document.getElementById(id);
        if (el('title'))       el('title').textContent = translations.roby_scripts_title || 'Roby Scripts';
        if (el('searchInput')) el('searchInput').placeholder = translations.search_placeholder || 'Keresés...';
        const prevSpan = el('prevPage') && el('prevPage').querySelector('span');
        const nextSpan = el('nextPage') && el('nextPage').querySelector('span');
        if (prevSpan) prevSpan.textContent = translations.prev_page || 'Előző';
        if (nextSpan) nextSpan.textContent = translations.next_page || 'Következő';
    }

    const body      = document.body;
    const container = document.getElementById('ui-container');

    switch (action) {
        case 'openUi':
            body.style.display      = 'flex';
            container.style.display = 'flex';
            // Show update badge if a newer version is available
            {
                const badge = document.getElementById('update-badge');
                const badgeText = document.getElementById('update-badge-text');
                if (badge && data.updateAvailable && data.latestVersion) {
                    badgeText.textContent = `v${data.latestVersion} available`;
                    badge.style.display = 'flex';
                } else if (badge) {
                    badge.style.display = 'none';
                }
            }
            if (data.items) {
                allItems      = data.items;
                filteredItems = [...allItems];
                updatePagination();
                displayCurrentPageItems();
            }
            break;
        case 'closeUi':
            container.style.display = 'none';
            body.style.display      = 'none';
            closeGiveModal();
            closeRetrieveModal();
            break;
        case 'updateItems':
            if (data.items) {
                allItems      = data.items;
                filteredItems = [...allItems];
                const s = document.getElementById('searchInput');
                if (s && s.value.trim()) { filterItems(s.value); }
                else { updatePagination(); displayCurrentPageItems(); }
            }
            break;
        case 'copyToClipboard':
            if (data.text) copyToClipboard(data.text);
            break;
    }
});

// ─── DOM Events ───────────────────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', () => {

    document.getElementById('close-button').onclick = () => nuiFetch('closeUi', {});

    document.getElementById('searchInput').addEventListener('input', e => filterItems(e.target.value));

    document.getElementById('prevPage').addEventListener('click', () => {
        if (currentPage > 1) { currentPage--; updatePagination(); displayCurrentPageItems(); }
    });
    document.getElementById('nextPage').addEventListener('click', () => {
        const total = Math.max(1, Math.ceil(filteredItems.length / itemsPerPage));
        if (currentPage < total) { currentPage++; updatePagination(); displayCurrentPageItems(); }
    });

    document.getElementById('cancel-give-button').onclick = closeGiveModal;
    document.getElementById('confirm-give-button').onclick = () => {
        const targetId = document.getElementById('player-id-input').value.trim();
        const amount   = Math.max(1, parseInt(document.getElementById('give-amount-input').value, 10) || 1);
        if (currentItemToGive && targetId) {
            nuiFetch('giveItemToPlayer', { itemId: currentItemToGive, targetPlayerId: targetId, amount });
            closeGiveModal();
        }
    };
    document.getElementById('give-item-modal').addEventListener('keydown', e => {
        if (e.key === 'Escape') closeGiveModal();
        if (e.key === 'Enter')  document.getElementById('confirm-give-button').click();
    });
    document.getElementById('give-item-modal').addEventListener('click', e => {
        if (e.target === e.currentTarget) closeGiveModal();
    });

    document.getElementById('cancel-retrieve-button').onclick = closeRetrieveModal;
    document.getElementById('confirm-retrieve-button').onclick = () => {
        const amount = Math.max(1, parseInt(document.getElementById('retrieve-amount-input').value, 10) || 1);
        if (currentItemToRetrieve) {
            nuiFetch('retrieveItem', { itemId: currentItemToRetrieve, amount });
            closeRetrieveModal();
        }
    };
    document.getElementById('retrieve-item-modal').addEventListener('keydown', e => {
        if (e.key === 'Escape') closeRetrieveModal();
        if (e.key === 'Enter')  document.getElementById('confirm-retrieve-button').click();
    });
    document.getElementById('retrieve-item-modal').addEventListener('click', e => {
        if (e.target === e.currentTarget) closeRetrieveModal();
    });

    document.addEventListener('keydown', e => {
        if (e.key !== 'Escape') return;
        const giveOpen     = document.getElementById('give-item-modal').style.display === 'flex';
        const retrieveOpen = document.getElementById('retrieve-item-modal').style.display === 'flex';
        if (!giveOpen && !retrieveOpen) nuiFetch('closeUi', {});
    });
});

