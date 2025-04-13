fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Abesses'
description 'script ambitieux informatique'
version '0.0.1'

shared_scripts {
    '@qbx_core/shared/locale.lua',
    '@ox_lib/init.lua',
	'@qbx_core/modules/lib.lua',
    'config.lua',

}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client.lua',
    'informatic_it/client.lua',
    'archive_strange_folder/client.lua',
    '@qbx_Ab_minigame_CSC/shared/client.lua',
    'informatic_accueil/client.lua',
    --'@qbx_Ab_DiceyTroop_byMugule/client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
    'shared/server.lua',
    'informatic_it/server.lua',
    'archive_strange_folder/server.lua',
    '@qbx_Ab_minigame_CSC/server.lua',
    'informatic_accueil/server.lua'
}

files {
    'archive_strange_folder/OS_minigame_file/*.*',
    'archive_strange_folder/OS_minigame_file/html5game/*.*',
    'archive_strange_folder/OS_minigame_file/html5game/builtinfonts/*.*',
    'archive_strange_folder/OS_minigame_file/html5game/particles/*.*',
    'archive_strange_folder/OS_minigame_file/html5game/sound/*.*'
}
ui_page {
    'archive_strange_folder/OS_minigame_file/index.html',
}