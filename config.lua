config_file = "somfy."

local tmr_cache = tmr.create()

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function readconfig()
    local cfg, ok, ln
    if file.exists(config_file .. "cfg") then
        print("Reading config from " .. config_file .. "cfg")
        file.open(config_file .. "cfg", "r+")
        ln = file.readline()
        file.close()
    else
        if file.exists(config_file .. "bak") then
            print("Reading config from " .. config_file .. "bak")
            file.open(config_file .. "bak", "r+")
            ln = file.readline()
            file.close()
        end
    end
    if not ln then ln = "{}" end
    print("Configuration: " .. ln)
    config = cjson.decode(ln)
    config_saved = deepcopy(config)
end

function writeconfighard()
    print("Saving config now!")
    file.remove(config_file .. "bak")
    file.rename(config_file .. "cfg", config_file .. "bak")
    file.open(config_file .. "cfg", "w+")
    local ok, cfg = pcall(cjson.encode, config)
    if ok then
        file.writeline(cfg)
    else
        print("Config not saved!")
    end
    file.close()

    config_saved = deepcopy(config)
end

function writeconfig()
    print("Requested save config...")
    tmr.stop(tmr_cache)
    local savenow = false
    local savelater = false

    --print("Config: "..cjson.encode(config))
    --print("Config saved: "..cjson.encode(config))

    local count = 0
    for _ in pairs(config_saved) do count = count + 1 end
    if count == 0 then
        config_saved = readconfig()
    end
    for remote, cfg in pairs(config_saved) do
        savelater = savelater or not config[remote] or config[remote].rc > cfg.rc
        savenow = savenow or not config[remote] or config[remote].rc > cfg.rc + 10
    end
    savelater = savelater and not savenow
    if savenow then
        print("Saving config immediately!")
        writeconfighard()
    end
    if savelater then
        print("Delay triggered to save config")
        tmr.alarm(tmr_cache, 65000, tmr.ALARM_SINGLE, writeconfighard)
    end
end



if not config then readconfig() end
if config == 0 then -- somfy.cfg does not exist
    config = cjson.decode([[{"dummyitem1":{"rc":1,"address":123},"dummyitem2":{"rc":1,"address":124}}]])
    config_saved = deepcopy(config)
end