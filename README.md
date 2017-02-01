## firmware
Firmware requires the following 9 modules: cjson file gpio net node somfy tmr uart wifi.


esptool.py --port /dev/tty.wchusbserial1410 write_flash -fm qio 0x00000 ~/Projects/NodeMCUSomfy/firmware/nodemcu-master-9-modules-2017-02-01-21-28-47-integer.bin