fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Roby'
description 'Roby Items - Item list with UI'
version '1.0.4'

shared_scripts {
    'shared/*.lua',
    '@es_extended/imports.lua'

}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

client_scripts {'client/*.lua'}
server_scripts {'server/*.lua' }
