--Controls liquid compressors
os.loadAPI("repo/util/touchpoint")
local tpMain = touchpoint.new("back")
local mainMon = peripheral.wrap("back")
local redLevel --Redstone level read from pressure gauge
local genStatus = false --if generators are on or off
local emergencyCutoff = false --Emercengy shutoff lever

local function mainMenu()
    mainMon.clear()
    mainMon.setTextScale(0.5)
    mainMon.setCursorPos(1,1)
    mainMon.setBackgroundColor(colors.gray)
    tpMain:add("Manual Cutoff", nil, 1, 1, 15, 15)
    tpMain:draw()
end

local function setup()
    print("Starting setup")
    statelist = {}
    statelist.top = rs.getInput("top")
    statelist.front = rs.getInput("front")
    statelist.left = rs.getInput("left")
    statelist.right = rs.getInput("right")
    statelist.back = rs.getInput("back")
    statelist.bottom = rs.getInput("bottom")
    
    for sde, ste in pairs(statelist) do
        print(sde.."--"..tostring(statelist[sde]))
        
    end
    
    
end
    

local function emergencyCutoff()
    if rs.getInput("top")  == true then
        print("Emergency cutoff triggered")
        rs.setAnalogOutput("left", 0)   
    else
        print("Operations resumed")
    end
end


local function monitorRedstone()
    redLevel = statelist["back"]
    if redLevel >= 7 then
        genStatus = false
        print("Generators Disabled at rs level "..redLevel)
    else
        genStatus = true
        print("Generators enabled at rs level "..redLevel)
    end
    rs.setOutput("left", genStatus)
end

term.clear()
term.setCursorPos(1,1)
print("Monitoring")
setup()
while true do
    if rs.getInput("top") then print("manual cutoff enabled generators will not run") break end
    os.pullEvent("redstone") --yeild computer until  a redstone change is detected
    for side, state in pairs(statelist) do
        print(side.." is now "..tostring(rs.getInput(side)))
        --statelist[side] = rs.getInput(side)
        if side == "back" then
            monitorRedstone()
            break
        elseif side == "top" then
            emergencyCutoff()
            --print("Emergency cutoff tiggered")
            break
        else
            print(side.." recieved redstone signal but nothing to do")
        end
    end
     
end





