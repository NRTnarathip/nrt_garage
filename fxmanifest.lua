fx_version 'cerulean'
game 'gta5'

author 'NRTnarathip'
description 'Garage Vehicle'
version '0.1.0'

server_scripts {
    '@es_extended/locale.lua',
    'server/main.lua',
    'config.lua',
    'locales/en.lua',
    'locales/th.lua',
    'functions.lua',
	'@mysql-async/lib/MySQL.lua'
}

client_scripts {
    '@es_extended/locale.lua',  
    "@NativeUILua_Reloaded/src/NativeUIReloaded.lua",
    'client/main.lua',
    'config.lua',
    'locales/en.lua',
    'locales/th.lua',
    'functions.lua'
}

dependencies {
	'es_extended'
}
