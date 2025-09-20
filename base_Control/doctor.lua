-- /basectl/doctor.lua — verify BaseControl files and runtime bits
local PATH="/basectl"
local REQ={
  "main.lua","ui.lua","util.lua","store.lua","server.lua",
  "page_labels.lua","page_server.lua","page_updates.lua","page_dist.lua","page_stats.lua","page_utils.lua"
}
local function exists(p) return fs.exists(p) and not fs.isDir(p) end
local function probe(p)
  local ok,ret = pcall(dofile,p)
  return ok, ret
end
local function anyModem()
  for _,n in ipairs(peripheral.getNames()) do
    if peripheral.getType(n)=="modem" then if not rednet.isOpen(n) then rednet.open(n) end; return true,n end
  end
  return false,nil
end

print("BaseControl file check:")
local bad={}
for _,f in ipairs(REQ) do
  local p=("%s/%s"):format(PATH,f)
  local e=exists(p)
  io.write(("  %-28s %s"):format(f, e and "found" or "MISSING"))
  if e then
    local ok = select(1, probe(p))
    print(ok and "  (loads)" or "  (LOAD ERROR)")
    if not ok then bad[#bad+1]=f end
  else print() end
end
if #bad>0 then
  print("Files that fail to load (syntax/runtime error at top-level):")
  for _,f in ipairs(bad) do print("  - "..f) end
end

print("\nNetwork check:")
local mdm,side = anyModem()
print("  Modem: "..(mdm and ("open on "..side) or "NOT FOUND"))

if mdm then
  local cfgHost = rednet.lookup("labels_cfg","labels-hub")
  print("  labels_cfg host: "..tostring(cfgHost))
  local repoHost = rednet.lookup("pkg_repo","mainframe")
  print("  pkg_repo host:   "..tostring(repoHost))
  if repoHost then
    rednet.send(repoHost,{cmd="manifest"},"pkg_repo")
    local _,msg = rednet.receive("pkg_repo",3)
    print("  manifest reply:  "..(type(msg)=="table" and msg.ok and "OK" or "NO REPLY"))
  end
end

print("\nMain loader sanity (main.lua should use dofile):")
local s = ""
if exists(PATH.."/main.lua") then
  local h = fs.open(PATH.."/main.lua","r"); s = h.readAll(); h.close()
end
local usesRequire = s:match("require%(")
print("  require(...) used: "..tostring(usesRequire and true or false).." (should be false)")
print("Done.")
