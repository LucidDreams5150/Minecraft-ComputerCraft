-- install_mainframe.lua
local RAW = "https://raw.githubusercontent.com/LucidDreams5150/Minecraft-ComputerCraft/main/base_Control"
local function fetch(url)
  local ok, h = pcall(http.get, url, {["Cache-Control"]="no-cache"})
  if not ok or not h then return nil, "http error" end
  local s = h.readAll(); h.close(); return s
end
local function write(path, data)
  local dir = fs.getDir(path); if dir~="" and not fs.exists(dir) then fs.makeDir(dir) end
  local f = fs.open(path, "wb"); f.write(data); f.close()
end

print("Installing Mainframe repo_server...")
local data, err = fetch(RAW.."/mainframe/repo_server.lua")
if not data then error("Failed to download repo_server.lua: "..tostring(err)) end
write("/mainframe/repo_server.lua", data)
print("Wrote /mainframe/repo_server.lua")

print("Create /startup for autostart? (Y/n)")
local ans = (read() or ""):lower()
if ans == "" or ans == "y" or ans == "yes" then
  write("/startup", 'shell.run("/mainframe/repo_server.lua")\n')
  print("Wrote /startup")
end

print("Run repo_server now? (Y/n)")
local runAns = (read() or ""):lower()
if runAns == "" or runAns == "y" or runAns == "yes" then
  shell.run("/mainframe/repo_server.lua")
else
  print("Done. Run /mainframe/repo_server.lua when ready.")
end
