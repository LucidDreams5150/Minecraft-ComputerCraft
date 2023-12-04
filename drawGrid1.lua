--Draws a grid on the attached monitor

local mon = peripheral.wrap("top")


--Format monitor

function clear()
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1,1)
    mon.setTextScale(.5)
end


--Draw text on monitor

function drawText(x, y, text, textColor, bgColor)
    mon.setBackgroundColor(bgColor)
    mon.setTextColor(textColor)
    mon.setCursorPos(x,y)
    mon.write(text)
end


--Draw horizontal line on monitor using dashes

function drawLine(x, y, length, color)
    mon.setBackgroundColor(color)
    mon.setCursorPos(x,y)
    mon.write(string.rep("*", length))
end

--Draw vertical line on monitor using piping symbol

function drawVertical(x, y, length, color)
    mon.setBackgroundColor(color)
    mon.setCursorPos(x,y)
    mon.write(string.rep("*", length))
end

function prepMon()
    if mon == null then
        print("Error: no monitor detected")
    else
        monX, monY = mon.getSize()
        print("Found Monitor of size - X:"..monX.." and Y:"..monY)
        sleep(0.5)
        return monX, monY
    end
end

--Draw a grid on monitor marking each "pixel" or "cursor position"

function drawGrid(color1, color2)
    
    xTot, yTot = mon.getSize()
   -- print("Found monitor with dimensions - X:"..xTot.." and Y:"..yTot)
    
    local xPos = 1
    local yPos = 1
    
    while xPos <= xTot do
        while yPos <= yTot do
            if (math.mod(xPos, 2) == 0) then --if x coord is even print -
                drawLine(xPos, yPos, 1, color1)
                yPos = yPos + 1
                --sleep(.01)
            else                             -- if x coord is odd print |
                drawVertical(xPos, yPos, 1, color2)
                yPos = yPos + 1
                --sleep(.01)
           end
       end
        xPos = xPos + 1
        yPos = 1
    end
end

function start()
    clear()
    print("DrawGrid")
    drawGrid(colors.blue, colors.orange)
    
--    local i = 1
--    while i < 15 do
--        drawGrid(colors.blue, colors.orange)
--        sleep(0.3)
--        drawGrid(colors.lime, colors.purple)
--        sleep(0.3)
--        drawGrid(colors.red, colors.white)
--        sleep(0.3)
--        i = i + 1
--    end
--    clear() 
        
end

start()
        
    
    
    
    



