config_file = "somfy."

local timer_write_delay = tmr.create()

function readconfig()
    local config_string
    if file.exists(config_file .. "cfg") then
        print("Reading config from " .. config_file .. "cfg")
        file.open(config_file .. "cfg", "r+")
        config_string = file.readline()
        file.close()
    else
        if file.exists(config_file .. "bak") then
            print("Reading config from " .. config_file .. "bak")
            file.open(config_file .. "bak", "r+")
            config_string = file.readline()
            file.close()
        end
    end
    if not config_string or config_string == "{}\n" then
        config_string = '{"demo":{"rc":1,"address":"123456"}}'
        print("When no devices are configured, the demo device will be shown.")
        print("You need to add your own device(s) before you can remove the demo item.")
    end
    print("Configuration: " .. config_string)
    config = cjson.decode(config_string)
end

function writeconfighard()
    print("Saving config to flash memory. Server will be offline for a few seconds!")
    file.remove(config_file .. "bak")
    file.rename(config_file .. "cfg", config_file .. "bak")
    file.open(config_file .. "cfg", "w+")
    local encoding_succeeded, config_string = pcall(cjson.encode, config)
    if encoding_succeeded then
        file.writeline(config_string)
    else
        print("Saving to flash memory failed.")
    end
    file.close()
end

-- Writing file to flash memory causes the device to be unresponsive for a few seconds.
-- Therefor, we delay these writes when the device is being used, until it is inactive again for 65 seconds.
function writeconfig()
    tmr.stop(timer_write_delay)
    print("Delay of 65 seconds triggered to save configuration to flash.")
    tmr.alarm(timer_write_delay, 65000, tmr.ALARM_SINGLE, writeconfighard)
end

if not config then readconfig() end
