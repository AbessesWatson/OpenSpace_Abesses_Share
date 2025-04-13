fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Abesses'
description 'script pour mini game graph compta'
version '0.0.1'

shared_scripts {
    '@qbx_core/shared/locale.lua',
    '@ox_lib/init.lua',
	'@qbx_core/modules/lib.lua',
    'config.lua',

}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    '@qbx_Ab_zinformatic/client.lua',
    'shared/client.lua',
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

files {
    'OS_Minigame_Graph/*.*',
    'OS_Minigame_Graph/html5game/*.*',
    'OS_Minigame_Graph/html5game/builtinfonts/*.*',
    'OS_Minigame_Graph/html5game/particles/*.*',
    'OS_Minigame_Graph/html5game/sound/*.*',
}
ui_page {
    'OS_Minigame_Graph/index.html'
}
dependencies {
    'qbx_Ab_zinformatic',
    'qbx_AB_search_CSC',
    'qbx_Ab_document_CSC,

}
