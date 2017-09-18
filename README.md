# NodeMCU Somfy controller

## firmware

Firmware requires the following 9 modules: cjson file gpio net node somfy tmr uart wifi.

    esptool.py --port /dev/tty.wchusbserial1410 write_flash -fm qio 0x00000 path/to/firmware/nodemcu-master-9-modules-2017-02-01-21-28-47-integer.bin

# setup

Copy default.settings.lua to settings.lua and adjust variables inside.

## Usage

Add new device by sending CONFIG command.

    http://<ip>/?name=yourfirstdevice&command=CONFIG&address=123456

Add another device

    http://<ip>/?name=yourotherdevice&command=CONFIG&address=654321
    
Update config for existing device

    http://<ip>/?name=yourfirstdevice&command=CONFIG&address=123457

Send somfy commands to existing device.

    http://<ip>/?name=window1&command=UP
    http://<ip>/?name=window1&command=DOWN
    http://<ip>/?name=window1&command=STOP
    http://<ip>/?name=window1&command=PROGRAM