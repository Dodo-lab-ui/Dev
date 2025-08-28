fx_version 'cerulean'
games { 'gta5' }

client_scripts {
    "config.lua",
    "client/functions.lua",
    "client/main.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
    "config.lua",
    "server/main.lua"
}

shared_scripts {
    "config.lua"
}