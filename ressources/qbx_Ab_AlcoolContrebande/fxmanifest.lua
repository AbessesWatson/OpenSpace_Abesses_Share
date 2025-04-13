fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Abesses'
description "effet de l'alcool et contrebande"
version '0.0.1'

shared_scripts {
    '@qbx_core/shared/locale.lua',
    '@ox_lib/init.lua',
	'@qbx_core/modules/lib.lua',
    'config.lua'

}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    '@ox_target/client/*.lua',
    'alcool/client.lua',
    'contrebande/client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'alcool/server.lua',
    'contrebande/server.lua',
}