-- install_pocket.lua (robust streaming + verify)
local BASE = "https://raw.githubusercontent.com/LucidDreams5150/Minecraft-ComputerCraft/main/base_Control/basectl"
local FILES = {
  "main.lua","ui.lua","util.lua","store.lua","server.lua",
  "page_labels.lua","page_stats.lua","page_server.lua",
  "page_updates.lua","page_dist.lua","page_utils.lua",
}

local function stream_to(url, dst)
  local tries=0
  while tries<3 do
    tries=tries+1
    local req = http.request(url, nil, {["Cache-Control"]="no-cache"})
    while true do
      local ev, id, res = os.pullEvent()
      if ev=="http_success" and id==url then
        local dir=fs.getDir(dst); if dir~="" and not fs.exists(dir) then fs.makeDir(dir) end
        local f=fs.open(dst,"wb"); local bytes=0
        while true do
          local chunk = res.read(8192); if not chunk then break end
          f.write(chunk); bytes = bytes + #chunk
        end
        f.close(); res.close()
        -- quick syntax check to catch truncation
        local ok, err = loadfile(dst)
        if ok then return true, bytes else
          print("  ! syntax/load failed, retrying ("..tostring(err)..")")
          os.sleep(0.4)
        end
        break
      elseif ev=="http_failure" and id==url then
        print("  ! http failure, retrying")
        os.sleep(0.4); break
      end
    end
  end
  return false
end

print("Installing BaseControl to /basectl ...")
for _,name in ipairs(FILES) do
  local url = BASE.."/"..name
  local dst = "/basectl/"..name
  io.write(("  - %-20s "):format(name))
  local ok = stream_to(url, dst)
  if not ok then error("\nDownload failed: "..name.." (check file exists in repo)") end
  print("OK")
end

print("Create /startup to autostart BaseControl? (Y/n)")
local ans=(read() or ""):lower()
if ans=="" or ans=="y" or ans=="yes" then
  local f=fs.open("/startup","w")
  f.write('shell.run("/basectl/main.lua")\n'); f.close()
  print("Wrote /startup")
end

print("Launch BaseControl now? (Y/n)")
local runAns=(read() or ""):lower()
if runAns=="" or runAns=="y" or runAns=="yes" then
  shell.run("/basectl/main.lua")
else
  print("Done. Run /basectl/main.lua to start.")
end
