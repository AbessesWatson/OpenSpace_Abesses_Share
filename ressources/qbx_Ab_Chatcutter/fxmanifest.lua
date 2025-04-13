fx_version 'cerulean'
game 'gta5'

description 'couper le chat'
version '1.1.1'

shared_script '@ox_lib/init.lua'

client_scripts {
	'@qbx_core/modules/playerdata.lua',
    'client.lua'
}

server_script 'server.lua'

lua54 'yes'
use_experimental_fxv2_oal 'yes'
