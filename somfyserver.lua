
-- START LISTENING FOR COMMANDS
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
        local _on, _off = "", ""
        if (_GET.name and _GET.command) then
            if(string.upper(_GET.command) == "PROGRAM") then
                buf = buf .. "<br><em>program time:</em><br><pre>" .. _GET.command .. "</pre>"
            end
            buf = buf .. "<br><em>received:</em><br><pre>" .. _GET.command .. "</pre>"
            --            somfy.sendcommand(pin, remote_address, command, rolling_code, repeat_count, call_back)
        end
        buf = buf .. "</pre></body></html>"
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
