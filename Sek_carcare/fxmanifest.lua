fx_version 'adamant'

game 'gta5'
description 'Sek_carcare' 
author 'SEK'
version '1.0.0'

client_script {
  'config.lua',
  'client/main.lua'
}

server_script {
  'config.lua',
  'server/main.lua'
}


ui_page 'html/index.html'

files {
	'html/index.html',
	'html/style.css',
	'html/app.js',
	'html/click.mp3',
  'html/open.mp3',
  'html/close.mp3',
  "html/img/*.png",
}
