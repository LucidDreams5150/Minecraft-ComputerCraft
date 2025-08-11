--Farm Control UI

--TODO: 
--Add menu option to input a new farm and configure its settings
--Add quit and reboot buttons to the bottom of screen can use on key while in terminal?

--START MAIN PROGRAM
local basalt = require("util.basalt")
local util = require("util.mclib")
local config = require("lib.farmControlConfig")
local myTheme = require("lib.myTheme")
local mon = util.configureDisplays() -- Utility to find all connected displays -- Returns a table
basalt.setTheme(myTheme)
--local curTemplate = basalt:getTemplate()

--Base Frame that everything is built on top of -- LEVEL 0
---
local mainFrame = basalt.addMonitor()
mainFrame:setMonitor(mon.right)
mainFrame:setPosition(1,1)
---
--local mainFrame = basalt.createFrame()
--mainFrame:setPosition(1,1)
---

local titleFrame = mainFrame:addFrame()
titleFrame:addLabel():setText("*Farm Control Unit*"):setSize(mon.right.maxX, 3):setPosition(1,1):setFontSize(2):setBackground(colors.black)
---
local bgPane = mainFrame:addPane()
bgPane:setPosition(1,4)
bgPane:setSize(mon.right.maxX, 1)
bgPane:setBackground(colors.black, "*", colors.purple)
---Start sub frames LEVEL 1
---**---
----
local subFrame = {  --create table that contains subFrames(sub menus in this case) these are what is shown when a menubar option is selected
    mainFrame:addFrame(1):setPosition(1,11):setSize(mon.right.maxX,10), --first frame shown
    mainFrame:addFrame(2):setPosition(1,11):setSize(mon.right.maxX,10):hide(), --need one for each item in menubar
    mainFrame:addFrame():setPosition(1,11):setSize(mon.right.maxX,10):hide(),
    mainFrame:addFrame():setPosition(1,11):setSize(mon.right.maxX,10):hide(),
    mainFrame:addFrame():setPosition(1,11):setSize(mon.right.maxX,10):hide(),

}
local function openSubFrame(id)
    if (subFrame[id] ~= nil) then
        for eachIndex, frame in pairs(subFrame) do --for each index(key)(subframe) in the table subFrame, hide the frame
            frame:hide()
        end
        subFrame[id]:show()  --show the target frame
    end
end

local function selectionBorder(btn)
    if btn:isFocused() then
        btn:setBorder(colors.red)
        basalt.debug("button clicked"..btn:getName())
    else
        btn:setBorder(false)
    end
end
local function borderFlash(btn)
    btn:setBorder(colors.red)
    os.sleep(0.2)
    btn:setBorder(false)
end
local function backgroundFlash(btn)
    local curBG = 1
    curBG = btn:getBackground()
    btn:setBackground(colors.pink)
    os.sleep(0.2)
    btn:setBackground(curBG)
end
local function igotclicked()
    basalt.debug("i got clicked")
end

local topButtonsFrame = mainFrame:addFrame()
topButtonsFrame:setPosition(1,5):setSize(mon.right.maxX, 5)
----
local homeButton = topButtonsFrame:addButton()
homeButton:setText("Home")
    :setPosition(1,1)
    :setSize(mon.right.halfX - 1, 5)
    :onClick(basalt.schedule(function(self) backgroundFlash(self) openSubFrame(1) end))


--subFrame[1]:addLabel():setText("Control ALL the farms!"):setForeground(colors.purple):setFontSize(2):setPosition(1,1)
subFrame[1]:addPane():setSize(mon.right.maxX, 10):setPosition(1,1):setBackground(colors.gray, "%", colors.black)
subFrame[2]:addButton():setText("Template Test"):setPosition(5,5):onClick(igotclicked)

ddSizeX = util.findLongestString(config.menuItems)
subFrame[3]:addDropdown():setPosition(5,5):setSize(ddSizeX, 1):onChange(function(self, item) openSubFrame(self:getItemIndex())end):setOptions(config.menuItems)

--for k, v in pairs(config.menuItems) do
--    dd1:addItem(v)
--end

---
local statusButton = topButtonsFrame:addButton()
    :setText("Status Page")
    :setPosition(mon.right.halfX + 1, 1):setSize(mon.right.halfX + 1, 5)
    :onClick(basalt.schedule(function(self) backgroundFlash(self) openSubFrame(3) end))
--**Main Menubar**--
---
local menubar = mainFrame:addMenubar() --Create mainMenuBar on the base frame
    :setSize(mon.right.maxX, 1)
    :setPosition(1,5)
    :setSpace(1)
    :onChange(function(self,val) openSubFrame(self:getItemIndex())end) --use function to open correct sub frame based on table index
    --get all menu items from the config file and add them to the menu bar
    for k, v in pairs(config.menuItems) do
        menubar:addItem(v)
    end


local menubar2 = mainFrame:addMenubar()
    :setSize(mon.right.maxX + 1, 1)
    :setPosition(0,6)
    :setSpace(2)
    :onChange(function(self,val) openSubFrame(self:getItemIndex())end)
    --:addItem("Status Page")


--******************START******************--

--mainFrame:hide()
bgPane:hide()
menubar:hide()
menubar2:hide()
--titleFrame:hide()


basalt.autoUpdate()