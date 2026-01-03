fx_version 'cerulean'
game 'gta5'

author 'SeninIsmin'
description 'Restlibadmin - iOS Style Admin Menu & Discord Bot'
version '1.0.0'

-- QBCore bağımlılığı
shared_script '@qb-core/shared/locale.lua'

-- HTML dosyaları (İleride dolduracağız)
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/*.png'
}

-- Client Scriptleri
client_scripts {
    'client/main.lua',
    'client/functions.lua'
}

-- Server Scriptleri (LUA)
server_scripts {
    'server/main.lua'
}

-- Server Scriptleri (Node.js / Bot)
server_script 'server/bot.js'