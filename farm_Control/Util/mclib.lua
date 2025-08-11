--MC Utility Library

---@class
---@return table

local util = {}

--setup is true by default so always start with a clean monitor state. Flase used if monitor settings must be retained (unlikely)
--Utility to find all connected monitors, wrap them and optionally set default configs
---@param setup boolean (optional)
function util.configureDisplays(setup)
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
            monitors[side].halfX = math.floor(monitors[side].maxX / 2)
            monitors[side].halfY = math.floor(monitors[side].maxY / 2)
            print("Monitor on Side: "..side.." wrapped")
            if setDefaults then
                monitors[side].clear()
                monitors[side].setCursorPos(1,1)
                monitors[side].setBackgroundColor(colors.black)
                monitors[side].setTextColor(colors.white)
                monitors[side].setTextScale(0.5)
                monitors[side].clear()
                --[[sleep(0.5)
                monitors[side].setBackgroundColor(colors.purple)
                monitors[side].clear()
                sleep(0.5)
                monitors[side].setBackgroundColor(colors.black)
                monitors[side].clear()
                sleep(0.5)]]
                print("monitor defaults set")
            end
        
        end
    end
    return monitors
end

function util.findLongestString(strings)
    local longest = ""
    local currentLongest = 0
    for k, v in pairs(strings) do
        if(v~=nil)then
            if currentLongest < #v then
                currentLongest = #v
                longest = v
            end
        end
    end
    return currentLongest
end

return util