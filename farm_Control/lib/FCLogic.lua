--Farm Control Logic Module
local basalt = require("util.basalt")
local util = require("util.mclib")
local config = require("lib.farmControlConfig")


local function getBundledStates()
    local bundleState = {}

    for i = 0, 15 do
        bundleState[i] = rs.getBundledOutput("")
    end


    return bundleState
end



local function toggleFarm(string)

end