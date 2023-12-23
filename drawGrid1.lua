--Draws a grid on the attached monitor
os.loadAPI("repo/util/touchpoint")
local pxl = touchpoint.new("right")
local mon = peripheral.wrap("right")

--pxl:add("X", nil, 1, 1, 1, 1, colors.black, colors.red)
--Format monitor
--pxl:add("X", nil, 1, 1, 1, 1, colors.lightGray, colors.red)

--pad of 1 pixel vertically and horizontally each button is 5 wide (X) by 3 tall (Y)

local function clearMon()
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1,1)
    mon.setTextScale(0.5)
end


--Draw text on monitor

local function drawText(x, y, text, textColor, bgColor)
    mon.setBackgroundColor(bgColor)
    mon.setTextColor(textColor)
    mon.setCursorPos(x,y)
    mon.write(text)
end


--Draw horizontal line on monitor using dashes

local function drawLine(x, y, width)
    mon.setBackgroundColor(color)
    mon.setCursorPos(x,y)
    mon.write(string.rep("*", width))
   
end

--Draw vertical line on monitor using piping symbol

local function drawVertical(x, y, height)
    mon.setBackgroundColor(color)
    mon.setCursorPos(x,y)
    mon.write(string.rep("*", height))
end

local function prepMon()
    if mon == null then
        print("Error: no monitor detected")
    else
        local monX, monY = mon.getSize()
        print("Found Monitor of size - X:"..monX.." and Y:"..monY)
        sleep(3)
        return monX, monY
    end
end

--Draw a grid on monitor marking each "pixel" or "cursor position"

local function drawGrid(color1, color2)
    
    local xTot, yTot = mon.getSize()
   -- print("Found monitor with dimensions - X:"..xTot.." and Y:"..yTot)

    local xPos = 1
    local yPos = 1
    local labelWidth = 5
    local labelHeight = 3
    local labelPadding = 1
    while xPos <= xTot do
        while yPos <= yTot do
            if (math.mod(xPos, 2) == 0) then --if x coord is even print -
                drawLine(xPos, yPos, 5)
                drawVertical(xPos, yPos, 3)
                --drawPixel(xPos, yPos, 1)
                yPos = yPos + 1
                --sleep(.01)
            else                             -- if x coord is odd print |
                --drawVertical(xPos, yPos, 1, color2)
                --drawPixel(xPos, yPos, 1)
                yPos = yPos + 1
                --sleep(.01)
           end
       end
        xPos = xPos + 1
        yPos = 1
    end
end

local function start()
    clearMon()
    prepMon()
    print("DrawGrid")
    drawGrid(colors.blue, colors.orange)
    






    --[[widdewey mode
    local i = 1
    while i < 15 do
        drawGrid(colors.blue, colors.orange)
        sleep(0.3)
        drawGrid(colors.lime, colors.purple)
        sleep(0.3)
        drawGrid(colors.red, colors.white)
        sleep(0.3)
        i = i + 1
    end
    clearMon() --]]

end

start()
