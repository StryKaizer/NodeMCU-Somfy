-- init.lua --

-- LOAD SETTINGS
dofile("settings.lua")

-- Configure Wireless Internet
wifi.setmode(wifi.STATION)
print('set mode=STATION (mode=' .. wifi.getmode() .. ')\n')
print('MAC Address: ', wifi.sta.getmac())
print('Chip ID: ', node.chipid())
print('Heap Size: ', node.heap(), '\n')
wifi.sta.config(ssid, pass)


dofile("config.lua")

dofile("somfyserver.lua")


