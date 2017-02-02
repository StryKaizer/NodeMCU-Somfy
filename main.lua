-- main.lua --

--[[



--]]


-- https://github.com/nodemcu/nodemcu-firmware/blob/dev/lua_examples/somfy.lua


-- START LISTENING FOR COMMANDS
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        buf = buf.."<html><head></head><body><strong>Somfy controller</strong><br>";
        buf = buf .. "uptime: " .. tmr.time() .. " sec"
        buf = buf .. "</body></html>"
        local _on,_off = "",""
        --        if(_GET.pin and _GET.remote_address and command)
        --            somfy.sendcommand(pin, remote_address, command, rolling_code, repeat_count, call_back)
        --            -- pin, remote_address, command, rolling_code, repeat_coun
        --        end
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)