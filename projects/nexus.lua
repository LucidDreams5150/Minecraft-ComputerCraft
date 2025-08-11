-- teleport player to nexus when they type nexus in chat

local chatBox = peripheral.find("chatBox")

--local event, username, message, uuid, isHidden = os.pullEvent("chat")


--print("The 'chat' event was fired with username "..username.."and message "..message) 



--tp to nexus function
local function tpNexus(player)

    commands.tp(player, "730", "158", "-554")
    sleep(5)
    chatBox.sendMessage("Welcome "..player.." to the Nexus")
    
end

--main chat listener
local function chatListener()

    local event, username, message, uuid, isHidden = os.pullEvent("chat")
    
    if message == "nexus" then
    
        chatBox.sendMessage("Teleporting "..username.." to the Nexus!")
        tpNexus(username)
       -- commands.tp(username, "730.500000", "158.000000", "-554.500000")

    else
        print("no matching strings")
        sleep(5)
    
    end
end

print("Chat Listener Initalized")

while true do

    chatListener()

end  

    


    
