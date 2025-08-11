local basalt = require("util.basalt")
local util = require("util.mclib")
local mon = util.findMonitors(true)



--Frame definitions and monitor assignments
--Parent Menu
local frame_main_Menu = basalt.addMonitor()
----Sub Menus--
local frame_sub_Crops = basalt.addMonitor()
local frame_sub_Essence = basalt.addMonitor()
local frame_sub_Mobs = basalt.addMonitor()
------Child Menus 1
local frame_child_essence_resource = basalt.addMonitor()
local frame_child_essence_mob = basalt.addMonitor()
--------Child Menus 2

--[[
local function backButton()
    local currentFrame = basalt.getActiveFrame():getName()
    local parent = currentFrame:getParent()
    if currentFrame == parent then
        print("Can't go back now!")
    else
        basalt.setActiveFrame(parent)
    end
end
]]
local function gotoMainMenu()
    basalt.debug(basalt.getActiveFrame():getName())
    
    basalt.setActiveFrame(frame_main_Menu)
end

--MenuBar definitions
local menuBar_Main = frame_main_Menu:setMonitor(mon.right):addMenubar()
menuBar_Main:setPosition(1,1):setSpace(1):setSize(mon.right.maxX,1):setVisible(false)
menuBar_Main:addItem("Back"):onClick(backButton)
menuBar_Main:addItem("Main Menu"):onClick(gotoMainMenu)
menuBar_Main:addItem("Crops")
menuBar_Main:addItem("Essence")
menuBar_Main:addItem("Mobs")
--
local menuBar_Crops = frame_sub_Crops:addMenubar()
menuBar_Crops:setPosition(1,1):setSpace(1):setSize(mon.right.maxX,1):setVisible(false)
menuBar_Crops:addItem("Back"):onClick(backButton)
menuBar_Crops:addItem("Main Menu"):onClick(gotoMainMenu)
menuBar_Crops:addItem("Essence")
menuBar_Crops:addItem("Another Item")
--

--main
local function setup()
    basalt.setActiveFrame(frame_main_Menu)
    frame_main_Menu:setVisible(true)
    menuBar_Main:setVisible(true)
end

setup()

basalt.autoUpdate()