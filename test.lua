local basalt = require("util.basalt")
local mon = peripheral.wrap("right")
--local logs = dofile("basaltLog.txt")

local myFrame = basalt.addMonitor()
myFrame:setMonitor(mon)
--local testButton = myFrame:addButton()


local success, err = pcall(function()
  testButton = myFrame:addButton()
  testButton:setBackground("'{self.clicked ? colors.blue : colors.green}'")
end)


if not success then
    basalt.debug("Error: "..err)
end



basalt.autoUpdate()
