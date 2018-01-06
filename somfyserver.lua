-- START LISTENING FOR COMMANDS
-- Example code: https://github.com/nodemcu/nodemcu-firmware/blob/dev/lua_examples/somfy.lua
srv = net.createServer(net.TCP)
srv:listen(80, function(conn)
    conn:on("receive", function(client, request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if (method == nil) then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil) then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        buf = buf .. "<html><head></head><body><strong>NodeMCU Somfy controller</strong> - uptime " .. tmr.time() .. " sec<hr>";
        buf = buf .. "<br><em>config.cfg</em><br><pre>" .. cjson.encode(config) .. "</pre>"
        buf = buf .. "<br><em>repeat count:</em><br><pre>" .. repeat_count .. "</pre>"
        buf = buf .. "<br><em>pin:</em><br><pre>" .. pin .. "</pre>"
        local _on, _off = "", ""
        if (_GET.name and _GET.command) then
            if (string.upper(_GET.command) == "ADD") then
              -- http://<ip>/?name=window1&command=ADD&address=123456
              if (_GET.address and not config[_GET.name]) then
                config[_GET.name] = { rc = 1, address = _GET.address }
                writeconfig()
                buf = buf .. "<br><em>Device has been ADDED:</em><br><pre>" .. _GET.name .. "</pre>"
              else
                buf = buf .. "<br><em>Address for device not specified or device already exists.</em>"
              end
            elseif not config[_GET.name] then
              buf = buf .. "<br><em>No device found with name '" .. _GET.name .. "'. You can add new devices using the ADD command.</em>"
            else
              if (string.upper(_GET.command) == "PROGRAM" and config[_GET.name].address) then
                -- http://<ip>/?name=window1&command=PROGRAM
                somfy.sendcommand(pin, tonumber(config[_GET.name].address), somfy.PROG, tonumber(config[_GET.name].rc), 1)
                -- Increase rolling code with 1
                config[_GET.name].rc = tonumber(config[_GET.name].rc) + 1
                writeconfig()
                buf = buf .. "<br><em>Triggered PROGRAM on device:</em><br><pre>" .. _GET.name .. "</pre>"
              elseif (string.upper(_GET.command) == "UP" and config[_GET.name].address) then
                -- http://<ip>/?name=window1&command=UP
                local remote_address = config[_GET.name].address
                local rolling_code = config[_GET.name].rc
                somfy.sendcommand(pin, remote_address, somfy.UP, rolling_code, repeat_count)
                -- Increase rolling code with 1
                config[_GET.name].rc = config[_GET.name].rc + 1
                writeconfig()
                buf = buf .. "<br><em>Triggered UP on device:</em><br><pre>" .. _GET.name .. "</pre>"
              elseif (string.upper(_GET.command) == "DOWN" and config[_GET.name].address) then
                -- http://<ip>/?name=window1&command=DOWN
                local remote_address = config[_GET.name].address
                local rolling_code = config[_GET.name].rc
                somfy.sendcommand(pin, remote_address, somfy.DOWN, rolling_code, repeat_count)
                -- Increase rolling code with 1
                config[_GET.name].rc = config[_GET.name].rc + 1
                writeconfig()
                buf = buf .. "<br><em>Triggered DOWN on device:</em><br><pre>" .. _GET.name .. "</pre>"
              elseif (string.upper(_GET.command) == "STOP" and config[_GET.name].address) then
                -- http://<ip>/?name=window1&command=DOWN
                local remote_address = config[_GET.name].address
                local rolling_code = config[_GET.name].rc
                somfy.sendcommand(pin, remote_address, somfy.STOP, rolling_code, repeat_count)
                -- Increase rolling code with 1
                config[_GET.name].rc = config[_GET.name].rc + 1
                writeconfig()
                buf = buf .. "<br><em>Triggered STOP on device:</em><br><pre>" .. _GET.name .. "</pre>"
              elseif (string.upper(_GET.command) == "REMOVE") then
                config[_GET.name] = nil
                writeconfig()
                buf = buf .. "<br><em>Device has been REMOVED:</em><br><pre>" .. _GET.name .. "</pre>"
              else
                buf = buf .. "<br><em>Unsupported command</em>"
              end
            end
        end
        buf = buf .. "<br><hr>https://github.com/StryKaizer/NodeMCU-Somfy"
        buf = buf .. "</body></html>"
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
