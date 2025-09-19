-- dist_agent.lua  v0.1.0
-- Minimal receiver for Distributor tool (protocol 'labels_dist')
local PROTO = 'labels_dist'

local function open()
  local any=false
  for _,s in ipairs(peripheral.getNames()) do
    if peripheral.getType(s)=='modem' then if not rednet.isOpen(s) then rednet.open(s) end; any=true end
  end
  if not any then error('No modem present') end
end

local function write_file(path, data)
  local dir=fs.getDir(path); if dir~='' and not fs.exists(dir) then fs.makeDir(dir) end
  local f=fs.open(path, 'wb'); f.write(data); f.close()
end

local state={sending=nil, buf=nil}

local function loop()
  print('dist_agent listening on '..PROTO..' (Ctrl+T to stop)')
  while true do
    local _, sender, msg, proto = os.pullEvent('rednet_message')
    if proto~=PROTO or type(msg)~='table' then goto continue end
    if msg.cmd=='ping' then
      rednet.send(sender, {ok=true, id=os.getComputerID(), label=os.getComputerLabel()}, PROTO)
    elseif msg.cmd=='send_begin' then
      state.buf=''; state.sending={path=msg.path, sum=msg.sum}; rednet.send(sender, {ok=true, ack='begin'}, PROTO)
    elseif msg.cmd=='chunk' and state.sending then
      state.buf = state.buf .. (msg.data or '')
      rednet.send(sender, {ok=true, ack='chunk', n=#state.buf}, PROTO)
    elseif msg.cmd=='send_end' and state.sending then
      -- verify simple 31-sum
      local sum=0; for i=1,#state.buf do sum=(sum*31+state.buf:byte(i))%2147483647 end; sum=('%08x'):format(sum)
      if sum~=state.sending.sum then rednet.send(sender, {ok=false, err='checksum'}, PROTO) else
        write_file(state.sending.path, state.buf)
        if msg.set_startup then write_file('/startup', 'shell.run("'..state.sending.path..'")\n') end
        rednet.send(sender, {ok=true, wrote=state.sending.path}, PROTO)
      end
      state.buf=nil; state.sending=nil
    end
    ::continue::
  end
end

open(); loop()