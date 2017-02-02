# NodeMCU Somfy controller

## firmware

Firmware requires the following 9 modules: cjson file gpio net node somfy tmr uart wifi.

    esptool.py --port /dev/tty.wchusbserial1410 write_flash -fm qio 0x00000 path/to/firmware/nodemcu-master-9-modules-2017-02-01-21-28-47-integer.bin

# setup

Copy default.settings.lua to settings.lua and adjust variables inside.

## Usage

Add new device by sending programming command.

    http://<ip>/?name=window1&command=PROGRAM&remote_address=123456&rolling_code=1&repeat_count=2

Add another device

    http://<ip>/?name=window2&command=PROGRAM&remote_address=654321&rolling_code=1&repeat_count=2

Send command to existing device.

    http://<ip>/?name=window1&command=UP
    http://<ip>/?name=window1&command=DOWN
    http://<ip>/?name=window1&command=STOP
    http://<ip>/?name=window1&command=PROGRAM