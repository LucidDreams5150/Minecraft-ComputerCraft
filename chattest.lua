local chatBox = peripheral.find("chatBox")

chatBox.sendMessage("Hello world!")
os.sleep(1)
chatBox.sendMessage("I am dave", "Dave") 
os.sleep(1)

--chatBox.sendMessage("Welcome!"[, "Box", "<>", "&b", 30)


local message = {
    {text = "Click "},
    {
        text = "here",
        underlined = true,
        color = "aqua",
        clickEvent = {
            action = "open_url",
            value = "https://advancedperipherals.madefor.cc/"
        }
    },
    {text = " for the AP "},
    {text = "documentation", color = "red"},
    {text = "!"}
}

local json = textutils.serialiseJSON(message)

chatBox.sendFormattedMessage(json)
