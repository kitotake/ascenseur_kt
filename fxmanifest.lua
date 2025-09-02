fx_version 'adamant'

game 'gta5'
description 'Ascenseur'
version '1.0;0'
lua54 'yes'

client_scripts {
	'config.lua',
	'client/main.lua'
}

ui_page 'web/index.html'

server_scripts {
	'server/main.lua'
}

files {
	'web/index.html',
	'web/style.css',
	'web/server.js',
	'web/assets/*.png',
	'web/assets/*.svg',
}