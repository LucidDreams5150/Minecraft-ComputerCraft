local chatBox = peripheral.find("chatBox")

local event, username, dimension = os.pullEvent("playerJoin")


chatBox.sendMessage("Welcome to SuperCraft " ..username.. "!", "SCMC", "<>", '&b')
chatBox.sendMessage("You are currently in: " ..dimension.. ". Have fun!")
