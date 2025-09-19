-- /basectl/update.lua : rewrite all BaseControl files from PKG.lua
local function write_file(path, content)
  local dir = fs.getDir(path)
  if dir ~= "" and not fs.exists(dir) then fs.makeDir(dir) end
  local f = fs.open(path, "w"); f.write(content); f.close()
end
local ok, PKG = pcall(dofile, "/basectl/PKG.lua")
if not ok or type(PKG) ~= "table" or type(PKG.files) ~= "table" then
  print("PKG.lua missing or invalid. Re-run basectl_install.")
  return
end
for path, content in pairs(PKG.files) do write_file(path, content) end
print("Update complete. Restart /basectl/main.")
