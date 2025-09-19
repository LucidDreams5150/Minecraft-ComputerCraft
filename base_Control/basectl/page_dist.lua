-- page_dist.lua  v0.1.0
local M = {}
local PROTO='labels_dist'

local function openRepoHost() return rednet.lookup('pkg_repo', 'mainframe') end
local function vhash_bytes(s) local sum=0; for i=1,#s do sum=(sum*31+s:byte(i))%2147483647 end; return ('%08x'):format(sum) end

local function fetch_client_bytes()
  local host=openRepoHost(); if not host then return nil,'no repo host' end
  rednet.send(host, {cmd='get', path='/clients/labelClient.lua'}, 'pkg_repo')
  local meta; local buf=''
  while true do
    local _, msg = rednet.receive('pkg_repo', 5)
    if not msg then return nil,'timeout' end
    if msg.type=='begin' then meta=msg elseif msg.type=='chunk' then buf=buf..(msg.data or '') elseif msg.type=='end' then break end
  end
  if not meta then return nil,'no meta' end
  if vhash_bytes(buf)~=meta.sum then return nil,'checksum' end
  return buf
end

local list={}
local function scan()
  list={}
  rednet.broadcast({cmd='ping'}, PROTO)
  local t=os.startTimer(1.5)
  while true do
    local ev,a,b,c=os.pullEvent()
    if ev=='rednet_message' and c==PROTO and type(b)=='table' and b.ok then table.insert(list,{id=a,label=b.label or ('id'..a)}) end
    if ev=='timer' and a==t then break end
  end
end

local function push(id, path, data, write_startup)
  rednet.send(id,{cmd='send_begin', path=path, sum=vhash_bytes(data)},PROTO); local _, ack = rednet.receive(PROTO,2)
  if not (ack and ack.ok) then return false,'no begin ack' end
  local i=1; local chunk=4096
  while i<=#data do
    rednet.send(id,{cmd='chunk', data=data:sub(i, math.min(#data,i+chunk-1))},PROTO)
    local _,ack2=rednet.receive(PROTO,2); if not(ack2 and ack2.ok) then return false,'chunk nack' end
    i=i+chunk
  end
  rednet.send(id,{cmd='send_end', set_startup=write_startup},PROTO)
  local _,ack3=rednet.receive(PROTO,3); return (ack3 and ack3.ok) and true or false, (ack3 and ack3.err)
end

local function draw(state, ui, status)
  ui.drawHeader(state)
  term.setCursorPos(2,3); write('Distributor — Agents: '..tostring(#list))
  if status then term.setCursorPos(2,4); write('Status: '..status) end
  local y=6
  for i,item in ipairs(list) do term.setCursorPos(2,y+i-1); write(('%2d) %s (%d)'):format(i, item.label or '?', item.id)) end
  ui.drawFooter('[S]can  [I]nstall client  [I]+[T] with startup  [Q]Back')
end

function M.run(state, ui, util, store, server, PROTO, NAME)
  util.clear(); scan(); draw(state, ui, 'scanned')
  while true do
    local ev,a,b,c=os.pullEvent()
    server.handleEvent(state, ev, a, b, c, store, util, PROTO)
    if ev=='key' then
      if a==keys.q then return end
      if a==keys.s then scan(); util.clear(); draw(state, ui, 'scanned') end
      if a==keys.i or a==keys.t then
        local data,err=fetch_client_bytes(); if not data then util.clear(); draw(state, ui, 'fetch err: '..tostring(err)); goto continue end
        local wrote_all=true
        for _,item in ipairs(list) do local ok,why=push(item.id, '/labelClient.lua', data, a==keys.t); if not ok then wrote_all=false; print('fail '..item.id..' '..tostring(why)) end end
        util.clear(); draw(state, ui, wrote_all and 'deployed to all' or 'some failures — see console')
      end
    elseif ev=='mouse_click' then if ui.maybeHandleHeaderClick(state, b, c, server, store, util, PROTO, NAME) then util.clear(); draw(state, ui, 'header toggled') end end
    ::continue::
  end
end

return M