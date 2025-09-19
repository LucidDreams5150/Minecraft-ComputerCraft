-- page_updates.lua  v0.1.0
-- Shows repo manifest, compares local BaseControl files, lets you broadcast client update, and self-update BaseControl from Mainframe.

local M = {}
local PKG_PROTO = 'pkg_repo'

local function openRepoHost() return rednet.lookup(PKG_PROTO, 'mainframe') end

local function vhash_bytes(s) local sum=0; for i=1,#s do sum=(sum*31+s:byte(i))%2147483647 end; return ('%08x'):format(sum) end

local function file_sum(path) if not fs.exists(path) then return nil end local f=fs.open(path,'rb'); local d=f.readAll(); f.close(); return vhash_bytes(d) end

local function fetch_manifest()
  local host=openRepoHost(); if not host then return nil,'no repo host' end
  rednet.send(host, {cmd='manifest'}, PKG_PROTO)
  local _, msg = rednet.receive(PKG_PROTO, 2)
  if type(msg)=='table' and msg.ok and msg.manifest then return msg.manifest end
  return nil,'no reply'
end

local function download_to(path)
  local host=openRepoHost(); if not host then return false,'no host' end
  rednet.send(host, {cmd='get', path=path}, PKG_PROTO)
  local meta; local tmp=path..'.new'; local f=fs.open(tmp,'wb'); if not f then return false,'open fail' end
  while true do
    local _,msg = rednet.receive(PKG_PROTO,5)
    if not msg then f.close(); return false,'timeout' end
    if msg.type=='begin' then meta=msg elseif msg.type=='chunk' then f.write(msg.data) elseif msg.type=='end' then break end
  end
  f.close()
  if not meta then return false,'no meta' end
  local f2=fs.open(tmp,'rb'); local data=f2.readAll(); f2.close(); if vhash_bytes(data)~=meta.sum then return false,'checksum' end
  if fs.exists(path) then fs.delete(path) end; fs.move(tmp, path); return true
end

local function draw(state, ui, status, manifest)
  ui.drawHeader(state)
  term.setCursorPos(2,3); write('Updates — Mainframe manifest vs local')
  if status then term.setCursorPos(2,4); write('Status: '..status) end
  local y=6
  if not manifest then term.setCursorPos(2,y); write('(no manifest)') else
    term.setCursorPos(2,y);   write(('Repo labelClient: %s'):format(manifest.versions and manifest.versions.labelClient or '?')); y=y+1
    term.setCursorPos(2,y);   write(('Repo repoServer:  %s'):format(manifest.versions and manifest.versions.repoServer or '?')); y=y+1
    term.setCursorPos(2,y);   write(('Repo distAgent:   %s'):format(manifest.versions and manifest.versions.distAgent or '?')); y=y+2
    term.setCursorPos(2,y);   write('Local BaseControl files:'); y=y+1
    local list={'/basectl/main.lua','/basectl/ui.lua','/basectl/server.lua','/basectl/store.lua','/basectl/util.lua','/basectl/page_labels.lua','/basectl/page_stats.lua','/basectl/page_server.lua'}
    for _,p in ipairs(list) do term.setCursorPos(4,y); write(p..'  '..(file_sum(p) or '(missing)')); y=y+1 end
  end
  ui.drawFooter("[C]heck  [B]roadcast update  [U]pdate BaseControl  [Q]Back")
end

function M.run(state, ui, util, store, server, PROTO, NAME)
  util.clear(); local manifest=nil; draw(state, ui, 'press C to fetch manifest', manifest)
  while true do
    local ev,a,b,c=os.pullEvent()
    server.handleEvent(state, ev, a, b, c, store, util, PROTO)
    if ev=='key' then
      if a==keys.q then return end
      if a==keys.c then manifest=fetch_manifest(); util.clear(); draw(state, ui, manifest and 'manifest loaded' or 'failed to load', manifest) end
      if a==keys.b then rednet.broadcast({cmd='update'}, PKG_PROTO); util.clear(); draw(state, ui, 'update broadcast sent', manifest) end
      if a==keys.u then
        local ok=true
        local files={'/basectl/main.lua','/basectl/ui.lua','/basectl/server.lua','/basectl/store.lua','/basectl/util.lua','/basectl/page_labels.lua','/basectl/page_stats.lua','/basectl/page_server.lua'}
        for _,p in ipairs(files) do local ok1,err=download_to(p); if not ok1 then ok=false; term.setCursorPos(2,2); print('Failed '..p..' : '..tostring(err)) end end
        util.clear(); draw(state, ui, ok and 'BaseControl updated (restart recommended)' or 'Some files failed — see console', manifest)
      end
    elseif ev=='mouse_click' then if ui.maybeHandleHeaderClick(state, b, c, server, store, util, PROTO, NAME) then util.clear(); draw(state, ui, 'header toggled', manifest) end end
  end
end

return M