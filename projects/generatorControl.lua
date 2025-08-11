--Controls Liquid Compressors
--Created by Lucid

os.loadAPI("repo/util/touchpoint")
os.loadAPI("repo/util/utility")
local menu = touchpoint.new("back") --Button instance for monitor buttons
local mainMon = peripheral.wrap("back")
local redLevel --Global Redstone level detected from pressure gauge
local genStatus = false --If generators are on or off
local cutoff = false --Manual cutoff 

--Formatting
local function mainMenu()
    --some code
end

local function setup()
    --some code
    print("*Starting Setup...*")
    statelist = {} --Stores redstone output state for each face of computer
    statelist.top = rs.getInput("top")
    statelist.front = rs.getInput("front")
    statelist.left = rs.getInput("left")
    statelist.right = rs.getInput("right")
    statelist.back = rs.getInput("back")
    statelist.bottom = rs.getInput("bottom")

    levelList = {} --Stores Redstone Level of each face
    levelList.top = rs.getAnalogInput("top")
    levelList.front = rs.getAnalogInput("front")
    levelList.left = rs.getAnalogInput("left")
    levelList.right = rs.getAnalogInput("right")
    levelList.back = rs.getAnalogInput("back")
    levelList.bottom = rs.getAnalogInput("bottom")

    for stside, ststate in pairs(statelist) do
        print(stside.."--"..tostring(statelist[stside]).." has level "..tostring(levelList[stside]))
    end

    if statelist.top then manualCutoff()
    elseif statelist.right then compareRedstone()
    else print("*Checks Completed*")
    end
    print("*Setup Complete*")
    return statelist, levelList
end

local function manualCutoff()
    --some code
    if rs.getInput("top") then
        print("Manual Cutoff Triggered")
        rs.setAnalogOutput("bottom", 0)
    else
        print("Operations Resumed")
    end
end

local function compareRedstone()
    if levelList.right >= 7 then
        genStatus = false
        print("Generators Disabled because redstone reached level"..tostring(rs.getAnalogInput("right")))
    elseif levelList.right <= 5 then
        genStatus = true
        print("Generators Enabled because redstone reached level"..tostring(rs.getAnalogInput("right")))
    else
        print("Generator status unknown"..tostring(genStatus).." rs level "..tostring(rs.getAnalogInput("right")))
    end
    rs.setOutput("bottom", genStatus)
    
end

term.clear()
term.setBackgroundColor(colors.lightGray)
term.setCursorPos(1,1)
setup()

while true do
    print("Top of main loop")
    local event = os.pullEvent("redstone")
    if event == "redstone" then
        for side, state in pairs(levelList) do
            if rs.getInput("top") then
                print("Manual Cutoff Enabled, Generators cannot run")
                break
            end
            if rs.getAnalogInput(side) ~= state then
                if rs.getInput(side) ~= levelList[side] then
                    print(side.." has changed from "..tostring(statelist[side]).." to "..tostring(rs.getInput(side)))
                else
                    print(side.." has changed from "..levelList[side].." to receiving "..rs.getAnalogInput(side).." red level")
                end
                statelist[side] = rs.getInput(side)
                levelList[side] = rs.getAnalogInput(side)

                if side == "top" then
                    manualCutoff()
                    break
                elseif side == "right" then
                    compareRedstone()
                    break
                else
                    break
                end
            end
        end
    end
end
