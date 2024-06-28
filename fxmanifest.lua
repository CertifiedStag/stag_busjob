fx_version 'cerulean'
games {'gta5'}

author 'CertifiedStag'
Description 'Bus Job'
version '1.0.0'

server_scripts {
    'config.lua',
    'sv_busjob.lua'
    
}

client_scripts {
    'config.lua',
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'cl_busjob.lua'
    
}

lua54 'yes'
