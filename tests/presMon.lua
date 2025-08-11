




local function setup()
    print("Starting setup...")
    sidelist = {}
    sidelist.top = rs.getInput("top")
    sidelist.front = rs.getInput("front")
    sidelist.left = rs.getInput("left")
    sidelist.right = rs.getInput("right")
    sidelist.back = rs.getInput("back")
    sidelist.bottom = rs.getInput("bottom")
    
    sideRSLevel = {}
    sideRSLevel.top = rs.getAnalogInput("top")
    sideRSLevel.front = rs.getAnalogInput("front")
    sideRSLevel.left = rs.getAnalogInput("left")
    sideRSLevel.right = rs.getAnalogInput("right")
    sideRSLevel.back = rs.getAnalogInput("back")
    sideRSLevel.bottom = rs.getAnalogInput("buttom")


    for side, state in pairs(sidelist) do
        print(side.." | current state | "..tostring(sidelist[side]).." | at level | "..sideRSLevel[side])
    end
    print("Setup complete!")
    return sidelist, sideRSLevel
end

local function toggleOutput(sidetotoggle)
    if sidelist[sidetotoggle] then
        sidelist[sidetotoggle] = not sidelist[sidetotoggle]
        sideRSLevel[sidetotoggle] = rs.setAnalogOutput(0)
    else
        sidelist[sidetotoggle] = true
        sideRSLevel[sidetotoggle] = monitorRedstone()
    sidelist[sidetotoggle] = not sidelist[sidetotoggle]
    
    return sidelist
end

local function monitorRedstone()


end




