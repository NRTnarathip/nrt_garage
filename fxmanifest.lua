fx_version 'cerulean'
game 'gta5'

author 'An awesome dude'
description 'An awesome, but short, description'
version '1.0.0'

server_scripts {
    '@es_extended/locale.lua',
    'server/main.lua',
    'config.lua',
	'@mysql-async/lib/MySQL.lua',
    'vehicleListlua'
}
client_scripts {
    '@es_extended/locale.lua',
    "@NativeUILua_Reloaded/src/NativeUIReloaded.lua",
    'client/main.lua',
    'config.lua',
    'vehicleListlua'
}
dependencies {
	'es_extended'
}