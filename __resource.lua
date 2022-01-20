resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page "nui/mtb.html"

client_scripts {
	"@vrp/lib/utils.lua",
    'mtb_client.lua',
    'mtb_config.lua'
}

server_scripts {
    "@vrp/lib/utils.lua",
    "mtb_server.lua"
}

files {
    "nui/*",
    "nui/images/*",
}