fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Abesses'
description 'Les fontaines à eau'
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
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}
