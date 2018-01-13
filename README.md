# NodeMCU Somfy controller

Control your SOMFY blinds with http commands, using a cheap NodeMCU microcontroller and an RF transmitter. 

## Firmware

Firmware requires the following 9 modules: cjson file gpio net node somfy tmr uart wifi.
You can find a precompiled firmware in the /firmware folder or build your own.

# Setup

Copy default.settings.lua to settings.lua and adjust variables inside.

## Usage

To pair a somfy shutter with the nodemcu, use an already paired somfy remote and hold program for 2-3 seconds until the shutters move up and down. Then fire a "PROGRAM" command from the somfy.  You can now start controlling your somfy shutter using http commands to your nodemcu.

Add new device by sending ADD command.

    http://<ip>/?name=yourfirstdevice&command=ADD&address=123456

Add another device

    http://<ip>/?name=yourotherdevice&command=ADD&address=654321
    
Remove existing device

    http://<ip>/?name=yourfirstdevice&command=REMOVE

Send commands to existing somfy device.

    http://<ip>/?name=window1&command=UP
    http://<ip>/?name=window1&command=DOWN
    http://<ip>/?name=window1&command=STOP
    http://<ip>/?name=window1&command=PROGRAM
    

## Tip for homekit users

You can use this setup together with a homebridge server and the homebridge-blinds plugin to control your SOMFY devices with homekit and siri.