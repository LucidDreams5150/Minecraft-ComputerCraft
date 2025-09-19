-- install_client.lua  (Label Client)
local RAW = "https://raw.githubusercontent.com/LucidDreams5150/Minecraft-ComputerCraft/main/base_Control/clients/labelClient.lua"
local function fetch(url)
  local ok, h = pcall(http.get, url, {["Cache-Control"]="no-cache"})
  if not ok or not h then return nil, "http error" end
  local s=h.readAll(); h.close(); return s
end
local function write(path, data)
  local dir=fs.getDir(path); if dir~="" and not fs.exists(dir) then fs.makeDir(dir) end
  local f=fs.open(path,"wb"); f.write(data); f.close()
end

print("Installing labelClient.lua to /labelClient.lua ...")
local data, err = fetch(RAW)
if not data then error("download failed: "..tostring(err)) end
write("/labelClient.lua", data)
print("  ✓ /labelClient.lua")

print("Create /startup to auto-run labelClient on boot? (Y/n)")
local ans=(read() or ""):lower()
if ans=="" or ans=="y" or ans=="yes" then
  write("/startup", 'shell.run("/labelClient.lua")\n')
  print("Wrote /startup")
end

print("Run labelClient now? (Y/n)")
local runAns=(read() or ""):lower()
if runAns=="" or runAns=="y" or runAns=="yes" then
  shell.run("/labelClient.lua")
else
  print("Done. Run /labelClient.lua to start.")
end
