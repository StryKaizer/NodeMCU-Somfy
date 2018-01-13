-- INIT DELAY TIMER
-- This timer delays commands when firing multiple requests simultaneously.
delay_count = 1;
delay_timer = tmr.create()
delay_timer:register(500, tmr.ALARM_AUTO, function() 
  if(delay_count > 1) then
    delay_count = delay_count - 500;
    if(delay_count < 2) then
      delay_count = 1;
    end
  end
end)
delay_timer:start()
-- START LISTENING FOR COMMANDS
-- Example code: https://github.com/nodemcu/nodemcu-firmware/blob/dev/lua_examples/somfy.lua
srv = net.createServer(net.TCP)
srv:listen(80, function(conn)
    conn:on("receive", function(client, request)
        local body = "";
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
        body = body .. "<!DOCTYPE html><html><head></head><body><strong>NodeMCU Somfy controller</strong> - uptime " .. tmr.time() .. " sec<hr>";
        body = body .. "<br><em>config.cfg</em><br><pre>" .. cjson.encode(config) .. "</pre>"
        body = body .. "<br><em>repeat count:</em><br><pre>" .. repeat_count .. "</pre>"
        body = body .. "<br><em>pin:</em><br><pre>" .. pin .. "</pre>"
        local _on, _off = "", ""
        if (_GET.name and _GET.command) then
            if (string.upper(_GET.command) == "ADD") then
              -- http://<ip>/?name=window1&command=ADD&address=123456
              if (_GET.address and not config[_GET.name]) then
                config[_GET.name] = { rc = 1, address = _GET.address }
                writeconfig()
                body = body .. "<br><em>Device has been ADDED:</em><br><pre>" .. _GET.name .. "</pre>"
              else
                body = body .. "<br><em>Address for device not specified or device already exists.</em>"
              end
            elseif not config[_GET.name] then
              body = body .. "<br><em>No device found with name '" .. _GET.name .. "'. You can add new devices using the ADD command.</em>"
            else
              if (string.upper(_GET.command) == "PROGRAM" and config[_GET.name].address) then
                -- http://<ip>/?name=window1&command=PROGRAM
                somfy.sendcommand(pin, tonumber(config[_GET.name].address), somfy.PROG, tonumber(config[_GET.name].rc), 1)
                -- Increase rolling code with 1
                config[_GET.name].rc = tonumber(config[_GET.name].rc) + 1
                writeconfig()
                body = body .. "<br><em>Triggered PROGRAM on device:</em><br><pre>" .. _GET.name .. "</pre>"
              elseif (string.upper(_GET.command) == "UP" and config[_GET.name].address) then
                -- http://<ip>/?name=window1&command=UP
                local remote_address = config[_GET.name].address
                local rolling_code = config[_GET.name].rc
                delay_tmr = tmr.create()
                delay_tmr:register(delay_count, tmr.ALARM_SINGLE, function() 
                    somfy.sendcommand(pin, remote_address, somfy.UP, rolling_code, repeat_count)
                end)
                delay_tmr:start()
                delay_count = delay_count + 1000;
                -- Increase rolling code with 1
                config[_GET.name].rc = config[_GET.name].rc + 1
                writeconfig()
                body = body .. "<br><em>Triggered UP on device:</em><br><pre>" .. _GET.name .. "</pre>"
              elseif (string.upper(_GET.command) == "DOWN" and config[_GET.name].address) then
                -- http://<ip>/?name=window1&command=DOWN
                local remote_address = config[_GET.name].address
                local rolling_code = config[_GET.name].rc
                delay_tmr = tmr.create()
                delay_tmr:register(delay_count, tmr.ALARM_SINGLE, function()
                    somfy.sendcommand(pin, remote_address, somfy.DOWN, rolling_code, repeat_count)
                end)
                delay_tmr:start()
                delay_count = delay_count + 1000;
                -- Increase rolling code with 1
                config[_GET.name].rc = config[_GET.name].rc + 1
                writeconfig()
                body = body .. "<br><em>Triggered DOWN on device:</em><br><pre>" .. _GET.name .. "</pre>"
              elseif (string.upper(_GET.command) == "STOP" and config[_GET.name].address) then
                -- http://<ip>/?name=window1&command=DOWN
                local remote_address = config[_GET.name].address
                local rolling_code = config[_GET.name].rc
                delay_tmr = tmr.create()
                delay_tmr:register(delay_count, tmr.ALARM_SINGLE, function()
                    somfy.sendcommand(pin, remote_address, somfy.STOP, rolling_code, repeat_count)
                end)
                delay_tmr:start()
                delay_count = delay_count + 1000;
                -- Increase rolling code with 1
                config[_GET.name].rc = config[_GET.name].rc + 1
                writeconfig()
                body = body .. "<br><em>Triggered STOP on device:</em><br><pre>" .. _GET.name .. "</pre>"
              elseif (string.upper(_GET.command) == "REMOVE") then
                config[_GET.name] = nil
                writeconfig()
                body = body .. "<br><em>Device has been REMOVED:</em><br><pre>" .. _GET.name .. "</pre>"
              else
                body = body .. "<br><em>Unsupported command</em>"
              end
            end
        end
        body = body .. "<br><hr>https://github.com/StryKaizer/NodeMCU-Somfy"
        body = body .. "</body></html>"
        client:send(table.concat ({"HTTP/1.1 200 OK", "Content-Type: text/html", "Content-length: " .. #body, "", body}, "\r\n"));
        client:close();
        collectgarbage();
    end)
end)
