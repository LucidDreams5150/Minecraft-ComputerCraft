-- install_agent.lua (Distributor Agent)
local RAW = "https://raw.githubusercontent.com/LucidDreams5150/Minecraft-ComputerCraft/main/base_Control/dist/dist_agent.lua"
local function fetch(url)
  local ok, h = pcall(http.get, url, {["Cache-Control"]="no-cache"})
  if not ok or not h then return nil, "http error" end
  local s=h.readAll(); h.close(); return s
end
local function write(path, data)
  local dir=fs.getDir(path); if dir~="" and not fs.exists(dir) then fs.makeDir(dir) end
  local f=fs.open(path,"wb"); f.write(data); f.close()
end

print("Installing dist_agent.lua to /dist_agent.lua ...")
local data, err = fetch(RAW)
if not data then error("download failed (is the file in the repo?): "..tostring(err)) end
write("/dist_agent.lua", data)
print("  ✓ /dist_agent.lua")

print("Create /startup to keep agent running on boot? (Y/n)")
local ans=(read() or ""):lower()
if ans=="" or ans=="y" or ans=="yes" then
  write("/startup", 'shell.run("/dist_agent.lua")\n')
  print("Wrote /startup")
end

print("Run dist_agent now? (Y/n)")
local runAns=(read() or ""):lower()
if runAns=="" or runAns=="y" or runAns=="yes" then
  shell.run("/dist_agent.lua")
else
  print("Done. Run /dist_agent.lua to start.")
end
