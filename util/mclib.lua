--MC Utility Library

local util = {}

--setup is true by default so always start with a clean monitor state. Flase used if monitor settings must be retained (unlikely)
local setup = true
function util.findMonitors(setup)
    local setDefaults = true
    if setup == false then
        setDefaults = false
    end
    local monitors = {}
    local connectedPeripherals = peripheral.getNames()

    for _, side in ipairs(connectedPeripherals) do
        if peripheral.getType(side) == "monitor" then
            local monitor = peripheral.wrap(side)
            monitors[side] = monitor
            monitors[side].maxX, monitors[side].maxY = monitor.getSize()
            print("Monitor on Side: "..side.." wrapped")
        end
        if setDefaults == true then
            monitors[side].clear()
            monitors[side].setCursorPos(1,1)
            monitors[side].setBackgroundColor(colors.black)
            monitors[side].setTextColor(colors.white)
            monitors[side].setTextScale(0.5)
            monitors[side].clear()
            print("monitor defaults set")
        end
    end
    return monitors
end


return util