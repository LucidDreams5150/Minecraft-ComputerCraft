--LocalFarmControl
--Load touchpointAPI to ccreate buttons
--os.loadAPI("repo/util/touchpoint")
--os.loadAPI("repo/util/utility")
os.loadAPI("tmprepo/util/touchpoint")
--Create first button instance 't' on the right monitor *think of these as PAGES*
--[[farms
--    Menu - Essence - Inferium, Sulfur, fluorite, uranium, nether star, 
--        - Menu Metals - Steel, 
--    Menu - PAMS - Onion, tomato, etc...
--    Menu - Animals - Cow, Pig, Sheep(mutton), Sheep(wool), Chicken
--    Menu - Mobs - Wither, Cave Creeper, Creeper, Skeleton, Slime, Wither Skeleton, Witch, 
--    Menu - Remote Farms - Oil Rig, 
--]]

local mainMenu = touchpoint.new("left") --Button instance for mainMenu
local essenceMenu = touchpoint.new("left") --Button instance for Mystical Agriculture Essence Menu
local cropMenu = touchpoint.new("left")
local mobMenu = touchpoint.new("left")
local animalMenu = touchpoint.new("left")

--formatting

local mon = peripheral.wrap("left")
--todo add logic to make sure button text fits within button region maybe auto assign x, y  values based on text

--Buttons
local gr = colors.gray
local lg = colors.lightGray
local lime = colors.lime

local function drawMenuBar()
    local dis = peripheral.wrap("right")
    term.redirect(dis)
    paintutils.drawFilledBox(12,1,47,3,colors.red)
    term.redirect(term.current())
    dis.setTextColor(colors.white)
    dis.setCursorPos(20,2)
    dis.write("Central Farm Control")
end

buttonGrid = touchpoint.new("right")

buttonGrid:add("Previous",nil,1,1,11,3)
buttonGrid:add("Next",nil,48,1,57,3)

buttonGrid:add("C1,R1",nil,2,5,12,8)    --column 1
buttonGrid:add("C1,R2",nil,2,10,12,13)  --column 1
buttonGrid:add("C1,R3",nil,2,15,12,18)  --column 1
--
buttonGrid:add("C2,R1",nil,15,5,25,8)   --column 2
buttonGrid:add("C2,R2",nil,15,10,25,13) --column 2
buttonGrid:add("C2,R3",nil,15,15,25,18) --column 2

buttonGrid:add("C3,R1",nil,33,5,43,8)   --column 3
buttonGrid:add("C3,R2",nil,33,10,43,13) --column 3
buttonGrid:add("C3,R3",nil,33,15,43,18) --column 3

buttonGrid:add("C4,R1",nil,46,5,56,8)   --column 4
buttonGrid:add("C4,R2",nil,46,10,56,13) --column 4
buttonGrid:add("C4,R3",nil,46,15,56,18) --column 4


mainMenu:add("Previous",nil,1,1,11,3)
mainMenu:add("Next",nil,48,1,57,3)

mainMenu:add("Essence",nil,2,5,20,8)
mainMenu:add("PAMS",nil,2,10,20,13)
mainMenu:add("Hostile Mobs",nil,2,15,20,18)
mainMenu:add("Passive Animals",nil,2,20,20,23)
mainMenu:add("Other",nil,2,25,20,28)

--****button width 10, height 3, padding 1, 3, 8, 3, 1****--

--Finds the coordinates of each label (startX, startY, endX, endY) when provided the number of rows and cols 
function labelGrid(mon, numRows, numCols)
    local display = peripheral.wrap(mon) --wrap target display
    local maxX, maxY = display.getSize() --get size of display
    local incY = maxX/numCols --endY of C1R1 increment
    local incX = maxY/numRows --endX of C1R1 increment
    print("monitor divided incX:",incX, " incY",incY)
    display.setCursorPos(1,1)
    display.setBackgroundColor(colors.black)
    display.clear()
    term.redirect(display)
    paintutils.drawFilledBox(1,1,57,3, colors.lightGray)
end



--mainMenu:add("Next",nil, 40, 2, 45, 4, gr, lg)
--mainMenu:add("Prev",nil, 2, 2, 12, 4, gr, lg)
--mainMenu:add("Essence",nil, 2, 6, 12, 8, gr, lg)
--mainMenu:add("Mobs",nil, 2, 10, 12, 12, gr, lg)
--Mystical Agriculture essence farms
essenceMenu:add("Next", nil, 40, 1, 45, 3, gr, lg)
essenceMenu:add("Prev", nil, 1, 1, 6, 3, gr, lg)



--Regular Crop Farms
--cropMenu:add("Wheat", nil, )
--Mob farms

--Passive Mob Farms


--Main Code
mainMenu:draw()
--buttonGrid:draw()
drawMenuBar()


--add loop to find what button was clicked. 
while true do
    local event, p1 = buttonGrid:handleEvents(os.pullEvent())
    if event == "button_click" then
        if p1 == "Previous" then
            buttonGrid:flash(p1)
            sleep(0.15)
        elseif p1 == "Next" then
            buttonGrid:flash(p1)
            sleep(0.15)
        elseif p1 == "Essence" then
            buttonGrid:flash(p1)
            sleep(0.15)
            essenceMenu:draw()
        
        end
    end
end



