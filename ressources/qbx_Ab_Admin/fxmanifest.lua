fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Abesses'
description "Pour des actions admin"
version '0.0.1'

shared_scripts {
    '@qbx_core/shared/locale.lua',
    '@ox_lib/init.lua',
	'@qbx_core/modules/lib.lua',
    'config.lua'
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', 
    '@qbx_core/modules/playerdata.lua',
    'server.lua'
}

files {
    'index.html',

}
ui_page {
    'index.html'
}