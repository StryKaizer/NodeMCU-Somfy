-- Wifi settings
ssid = "YOUR_WIFI_NETWORK"
pass = "YOUR_WIFI_PASSWORD"
-- Leave static ip empty if you do not want to set a static ip.
static_ip = ""
gateway = "192.168.1.1"
netmask = "255.255.255.0"

-- Pin connected to RF data.
pin = 1

-- How many times a command is repeated. 5 is a good default here. 
-- If you are experiencing blinds not going entirely up/down, try to lower this value (e.g. 2)
repeat_count = 5
