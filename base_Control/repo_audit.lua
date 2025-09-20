-- /repo_audit.lua — fetch manifest.json and verify required files exist
local OWNER, REPO, BRANCH = "LucidDreams5150","Minecraft-ComputerCraft","main"
local RAW = ("https://raw.githubusercontent.com/%s/%s/%s"):format(OWNER, REPO, BRANCH)

local function fetch(url)
  local ok,h = pcall(http.get, url, {["Cache-Control"]="no-cache"})
  if not ok or not h then return nil,"http" end
  local s=h.readAll() h.close() return s
end

local function ok(x) return x and "\169a" or "\215c" end -- check/x glyphs on many fonts

print("Fetching manifest.json ...")
local data, err = fetch(("%s/manifest.json"):format(RAW))
if not data then error("manifest.json not reachable: "..tostring(err)) end
local manifest = textutils.unserializeJSON and textutils.unserializeJSON(data) or textutils.unserialize(data)
if type(manifest)~="table" or type(manifest.files)~="table" then error("Bad manifest format") end

-- REQUIRED repo files (paths as keys)
local need = {
  ["/base_Control/clients/labelClient.lua"]=true,
  ["/base_Control/mainframe/repo_server.lua"]=true,
  ["/base_Control/dist/dist_agent.lua"]=true,

  -- installers (singular folder name per your setup)
  ["/base_Control/installer/install_mainframe.lua"]=true,
  ["/base_Control/installer/install_pocket.lua"]=true,
  ["/base_Control/installer/install_client.lua"]=true,
  ["/base_Control/installer/install_agent.lua"]=true,

  -- Pocket BaseControl pages (add/remove if you’re not using some pages)
  ["/base_Control/basectl/main.lua"]=true,
  ["/base_Control/basectl/ui.lua"]=true,
  ["/base_Control/basectl/util.lua"]=true,
  ["/base_Control/basectl/store.lua"]=true,
  ["/base_Control/basectl/server.lua"]=true,
  ["/base_Control/basectl/page_labels.lua"]=true,
  ["/base_Control/basectl/page_server.lua"]=true,
  ["/base_Control/basectl/page_updates.lua"]=true,
  ["/base_Control/basectl/page_dist.lua"]=true,
  ["/base_Control/basectl/page_stats.lua"]=true,
  ["/base_Control/basectl/page_utils.lua"]=true, -- new page you added
}

local have = {}
for path,_ in pairs(manifest.files) do have[path]=true end

local missing = {}
for path,_ in pairs(need) do
  if not have[path] then missing[#missing+1]=path end
end

print("Repo audit:")
print("  Files in manifest: "..tostring((function() local c=0 for _ in pairs(have) do c=c+1 end return c end)()))
print("  Required present:  "..ok(#missing==0))
if #missing>0 then
  print("  Missing entries (fix paths or workflow globs):")
  for _,p in ipairs(missing) do print("   - "..p) end
end

-- show versions parsed by the workflow (handy sanity check)
if manifest.versions then
  print("Versions from manifest:")
  for k,v in pairs(manifest.versions) do print(("  %s: %s"):format(k, v)) end
end
print("Done.")
