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
            if (string.upper(_GET.command) == "CONFIG") then
                -- http://<ip>/?name=window1&command=CONFIG&address=123456
                config[_GET.name] = { rc = 1, address = _GET.address }
                writeconfighard()
                buf = buf .. "<br><em>Configuration updated...</em>"
            elseif (string.upper(_GET.command) == "PROGRAM" and config[_GET.name].address) then
                -- http://<ip>/?name=window1&command=PROGRAM
                buf = buf .. "<br><em>Triggered PROGRAM on device:</em><br><pre>" .. config[_GET.name] .. "</pre>"
--                somfy.sendcommand(pin, tonumber(config[_GET.name].address), somfy.PROG, tonumber(config[_GET.name].rc), 1)
                -- Increase rolling code with 1
--                config[_GET.name].rc = tonumber(config[_GET.name].rc) + 1
            elseif (string.upper(_GET.command) == "UP" and config[_GET.name].address) then
                -- http://<ip>/?name=window1&command=UP
                local remote_address = config[_GET.name].address
                local rolling_code = config[_GET.name].rc
                buf = buf .. "<br><em>Triggered UP on device:</em><br><pre>" .. config[_GET.name] .. "</pre>"
--                somfy.sendcommand(pin, remote_address, somfy.UP, rolling_code, repeat_count)
                -- Increase rolling code with 1
                config[_GET.name].rc = config[_GET.name].rc + 1
            elseif (string.upper(_GET.command) == "DOWN" and config[_GET.name].address) then
                -- http://<ip>/?name=window1&command=DOWN
                local remote_address = config[_GET.name].address
                local rolling_code = config[_GET.name].rc
                buf = buf .. "<br><em>Triggered DOWN on device:</em><br><pre>" .. config[_GET.name] .. "</pre>"
--                somfy.sendcommand(pin, remote_address, somfy.DOWN, rolling_code, repeat_count)
                -- Increase rolling code with 1
                config[_GET.name].rc = config[_GET.name].rc + 1
            elseif (string.upper(_GET.command) == "STOP" and config[_GET.name].address) then
                -- http://<ip>/?name=window1&command=DOWN
                local remote_address = config[_GET.name].address
                local rolling_code = config[_GET.name].rc
                buf = buf .. "<br><em>Triggered STOP on device:</em><br><pre>" .. config[_GET.name] .. "</pre>"
--                somfy.sendcommand(pin, remote_address, somfy.STOP, rolling_code, repeat_count)
                -- Increase rolling code with 1
                config[_GET.name].rc = config[_GET.name].rc + 1
            else
                buf = buf .. "<br><em>Command 2 unsupported or missing configuration"
            end
            buf = buf .. "<br>https://github.com/StryKaizer/NodeMCU-Somfy"
        end
        buf = buf .. "</pre></body></html>"
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
