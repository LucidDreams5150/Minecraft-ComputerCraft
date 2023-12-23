local basalt = require("util.basalt")

local rightMon = peripheral.wrap("right")
local leftMon = peripheral.wrap("left")

local function centerButton(display,bSize)
    local monX, monY = display.getSize()
    local center = math.floor(monX / 2)
    local startPos = center - (math.floor(bSize/2))
    print("startPos: ",startPos)
    return startPos
end
local function nextBtn(display)
    local monX, monY = display.getSize()
    local len = math.floor(monX - 11)
    return len
end
--MainMenu Button Instance
local mainMenuFrame = basalt.addMonitor():setMonitor(rightMon):setVisible(false)       --frame creation for main menu
mainMenuFrame:addButton()
    :setText("Back")
    :setPosition(1,1)
mainMenuFrame:addButton()
    :setText("Main Menu")
    :setPosition({"Main Menu.w * 0.5s"},1)
mainMenuFrame:addButton():setText("Next"):setPosition(nextBtn(rightMon),1)
mainMenuFrame:addButton():setText("Essence")
mainMenuFrame:addButton():setText("Crops")
mainMenuFrame:addButton():setText("Mobs")

--mainMenuFrame:animateOffset(3,4,2,0,"linear",function() basalt.debug("animation complete") end)
--local mainMenuList = mainMenuFrame:addList()    --Create list of options/buttons to display on the main menu
--mainMenuList:addItem("Essence")                 --list item
--mainMenuList:addItem("Crops")                   --list item
--mainMenuList:addItem("Mobs")                    --list item

local mainMenuBarFrame = basalt.addMonitor()
mainMenuBarFrame:setMonitor(rightMon)--:setVisible(false)
local mainMenuBar = mainMenuBarFrame:addMenubar()
    :setSpace(1)
    :setPosition(1,1)
    :setsize()
    :addItem("Back")
    :addItem("Main Menu")
    :addItem("Crops")
    :addItem("Essence")
    :addItem("Mobs")
    :addItem("Hide")
--
mainMenuBar:onClick(basalt.debug("something got clicked"))

--EssenceMenu Button Instance
local parentEssenceFrame = basalt.addMonitor():setVisible(false)
parentEssenceFrame:addButton():setText("Resource Essence")
parentEssenceFrame:addButton():setText("Mob Essence")
parentEssenceFrame:addButton():setText("Elemental Essence")
--
local childEssenceFrame = basalt.addMonitor()
childEssenceFrame:addButton():setText("Test")

--new frame for each menu?
--button grid?


--[[Main]]

mainMenuBar:show()

--basalt.setActiveFrame(mainMenuFrame)




--[[mainMenuFrame:show()    --Display main menu options

essenceMenuButton:onClick(function(self,event,button,x,y)
    if(event == "mouse_click") and (button == 1) then
        basalt.debug("clicked")
        mainMenuFrame:hide()
        basalt.debug("gothere")
        mobEssenceMenuButton:show()
    end
end)
]]




basalt.autoUpdate()