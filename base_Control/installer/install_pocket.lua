-- install_pocket.lua  (BaseControl tablet)
local RAW = "https://raw.githubusercontent.com/LucidDreams5150/Minecraft-ComputerCraft/main/base_Control/basectl"
local files = {
  "main.lua","ui.lua","util.lua","store.lua","server.lua",
  "page_labels.lua","page_stats.lua","page_server.lua",
  "page_updates.lua","page_dist.lua",
}
local function fetch(url)
  local ok, h = pcall(http.get, url, {["Cache-Control"]="no-cache"})
  if not ok or not h then return nil, "http error" end
  local s=h.readAll(); h.close(); return s
end
local function write(path, data)
  local dir=fs.getDir(path); if dir~="" and not fs.exists(dir) then fs.makeDir(dir) end
  local f=fs.open(path,"wb"); f.write(data); f.close()
end

print("Installing BaseControl to /basectl ...")
for _,name in ipairs(files) do
  local url = RAW.."/"..name
  local data, err = fetch(url)
  if not data then error("Failed: "..name.." ("..tostring(err)..")") end
  write("/basectl/"..name, data)
  print("  ✓ "..name)
end

print("Create /startup to autostart BaseControl? (Y/n)")
local ans=(read() or ""):lower()
if ans=="" or ans=="y" or ans=="yes" then
  write("/startup", 'shell.run("/basectl/main.lua")\n')
  print("Wrote /startup")
end

print("Launch BaseControl now? (Y/n)")
local runAns=(read() or ""):lower()
if runAns=="" or runAns=="y" or runAns=="yes" then
  shell.run("/basectl/main.lua")
else
  print("Done. Run /basectl/main.lua to start.")
end
