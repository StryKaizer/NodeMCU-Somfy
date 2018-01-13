# NodeMCU Somfy controller

Control your SOMFY blinds with http commands, using a cheap NodeMCU microcontroller and an RF transmitter. 

## Firmware

Firmware requires the following 9 modules: cjson file gpio net node somfy tmr uart wifi.
You can find a precompiled firmware in the /firmware folder or build your own.

# Setup

Copy default.settings.lua to settings.lua and adjust variables inside. Upload all code to NodeMcu.

## Usage

### Managing devices on NodeMCU

Add new device to NodeMCU by sending ADD command.

    http://<ip>/?name=window1&command=ADD&address=123456

Add another device.

    http://<ip>/?name=window2&command=ADD&address=654321
    
Remove existing device.

    http://<ip>/?name=window2&command=REMOVE
    
### Talking with Somfy
    
To pair a Somfy shutter with the NodeMCU, use an already paired Somfy remote and hold program for 2-3 seconds until the shutters move up and down. Then fire a "PROGRAM" command from the NodeMCU.  You can now start controlling your Somfy shutter using http commands to your NodeMCU.

Send commands to existing Somfy device.

    http://<ip>/?name=window1&command=UP
    http://<ip>/?name=window1&command=DOWN
    http://<ip>/?name=window1&command=STOP
    http://<ip>/?name=window1&command=PROGRAM
    

## Tip for homekit users

You can use this setup together with a homebridge server and the homebridge-blinds plugin to control your SOMFY devices with homekit and siri.