-- Load settings
dofile("settings.lua")

-- Configure Wireless Internet
wifi.setmode(wifi.STATION)
print('set mode=STATION (mode=' .. wifi.getmode() .. ')\n')
print('MAC Address: ', wifi.sta.getmac())
print('Chip ID: ', node.chipid())
print('Heap Size: ', node.heap(), '\n')
wifi.sta.config(ssid, pass)
if static_ip ~= "" then
 wifi.sta.setip({ip=static_ip,netmask=netmask,gateway=gateway})
end

dofile("config.lua")

dofile("somfyserver.lua")
