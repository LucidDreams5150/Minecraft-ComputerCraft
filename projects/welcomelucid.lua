local chatBox = peripheral.find("chatBox")
local pd = peripheral.find("playerDetector")

local event, username, dimension = os.pullEvent("playerJoin")

chatBox.sendMessage("Welcome to SuperCraft " ..username.. " ! Happy Crafting!")


