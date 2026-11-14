fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name 'cobalt_addons'
author 'Project Cobalt'
description 'Consumables, player actions, vehicle features and world tweaks'
version '1.0.0'

dependencies {
    'ox_lib',
    'cobalt_core',
    'cobalt_inventory',
    'cobalt_hud',
}

ox_libs { 'locale' }

shared_script '@ox_lib/init.lua'

client_script 'client/init.lua'

server_script 'server/init.lua'

data_file 'AMBIENT_PED_MODEL_SET_FILE' 'popgroups.ymt'
data_file 'EVENTS_OVERRIDE_FILE' 'events.meta'

files {
    'config.lua',
    'client/**/*.lua',
    'locales/*.json',
    'events.meta',
    'popgroups.ymt',
}
