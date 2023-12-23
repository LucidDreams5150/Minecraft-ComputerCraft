local basalt = require("util.basalt")
local util = require("util.mclib")
local mon = util.findMonitors(true)



--Frame definitions and monitor assignments
--Root Menu
local frame_main_Menu = basalt.addMonitor()
frame_main_Menu:setMonitor(mon.right)
----Parent Menus
local frame_main_Crops = basalt.addMonitor()
frame_main_Crops:setMonitor(mon.right)

local frame_main_Essence = basalt.addMonitor()
frame_main_Essence:setMonitor(mon.right)

local frame_main_Mobs = basalt.addMonitor()
frame_main_Mobs:setMonitor(mon.right)
------Child Menus 1

--------Child Menus 2


local function backButton()
    local currentFrame = basalt.getActiveFrame()
    local parent = currentFrame.getParent()
    if currentFrame == parent then
        print("Can't go back now!")
    else
        basalt.setActiveFrame(parent)
    end
end

--MenuBar definitions
local menuBar_Main = frame_main_Menu:addMenubar()
menuBar_Main:setPosition(1,1)
    :setSpace(1)
    :setSize(mon.right.maxX,1)
menuBar_Main:addItem("Back"):onClick(backButton)
menuBar_Main:addItem("Main Menu"):onClick(basalt.setActiveFrame(frame_main_Menu))
menuBar_Main:addItem("Crops"):onClick(basalt.setActiveFrame(frame_main_Crops))
menuBar_Main:addItem("Essence")
menuBar_Main:addItem("Mobs")
--[[
local menuBar_Crops = frame_main_Crops:addMenubar()
menuBar_Crops:setPosition(1,1):setSpace(1):setSize(mon.right.maxX,1)
menuBar_Crops:addItem("Back"):onClick(backButton)
menuBar_Crops:addItem("Main Menu"):onClick(basalt.setActiveFrame(frame_main_Menu))
menuBar_Crops:addItem("Essence")
menuBar_Crops:addItem("Another Item")
]]

--main


basalt.autoUpdate()