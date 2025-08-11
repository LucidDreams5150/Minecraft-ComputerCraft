local basalt = require("util.basalt")

local main = basalt.createFrame()
local button = main:addButton()
  :setPosition(3,3)
  :setSize(12,3)
  :setText("Click")

function buttonOnClick()
  basalt.debug("Button got clicked!")
end
button:onClick(buttonOnClick)


basalt.autoUpdate()