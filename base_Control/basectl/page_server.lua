-- page_server.lua  v0.1.0
-- Shows live output of LabelsConfigServer: status, versions, and served config.

local M = {}

local function ctrlLine(state)
  local on = state.serverOn and "ON" or "OFF"
  local cur = state.serverVersion or "-"
  local prev = state.serverPrevVersion or "-"
  return string.format("Server:%s  Cur:%s  Prev:%s", on, cur, prev)
end

local function lookupSelf(proto, name)
  return rednet.lookup(proto, name)
end

local function fetch(proto, hostID, known_version)
  if hostID then
    if known_version then
      rednet.send(hostID, { cmd = "get_if_new", known_version = known_version }, proto)
    else
      rednet.send(hostID, { cmd = "get" }, proto)
    end
  else
    rednet.broadcast({ cmd = "get" }, proto)
  end
  local timeout = os.startTimer(1.5)
  while true do
    local ev,a,b,c = os.pullEvent()
    if ev == "rednet_message" then
      local sender,msg,pr = a,b,c
      if pr == proto and type(msg) == "table" and (msg.ok or msg.cfg) then
        return sender, msg.cfg, msg.version
      end
    elseif ev == "timer" and a == timeout then
      return nil,nil,nil
    end
  end
end

local function draw(state, ui, text)
  ui.drawHeader(state)
  term.setCursorPos(2,3); write(ctrlLine(state))
  term.setCursorPos(2,5); write("Served config (preview):")
  local w,h = term.getSize()
  local y = 6
  for line in text:gmatch("([^]+)?") do
    if y >= h then break end
    term.setCursorPos(2,y); write(line)
    y = y + 1
  end
  ui.drawFooter("[R]Refresh  [Q]Back")
end

function M.run(state, ui, util, store, server, PROTO, NAME)
  util.clear()
  local host = state.serverOn and lookupSelf(PROTO, NAME) or nil
  local _, cfg, ver = fetch(PROTO, host, nil)
  if cfg then state.serverVersion = ver or state.serverVersion end
  local preview = cfg and textutils.serialize(cfg) or "(server off or no reply)"
  util.clear(); draw(state, ui, preview)
  while true do
    local ev,a,b,c = os.pullEvent()
    server.handleEvent(state, ev, a, b, c, store, util, PROTO)
    if ev == "timer" and a == state.serverTimerId then ui.drawHeader(state) end
    if ev == "mouse_click" then
      if ui.maybeHandleHeaderClick(state, b, c, server, store, util, PROTO, NAME) then
        host = state.serverOn and lookupSelf(PROTO, NAME) or nil
        _, cfg, ver = fetch(PROTO, host, nil)
        if cfg then state.serverVersion = ver or state.serverVersion end
        preview = cfg and textutils.serialize(cfg) or "(server off or no reply)"
        util.clear(); draw(state, ui, preview)
      end
    elseif ev == "key" then
      if a == keys.q then return end
      if a == keys.r then
        host = state.serverOn and lookupSelf(PROTO, NAME) or nil
        _, cfg, ver = fetch(PROTO, host, nil)
        if cfg then state.serverVersion = ver or state.serverVersion end
        preview = cfg and textutils.serialize(cfg) or "(server off or no reply)"
        util.clear(); draw(state, ui, preview)
      end
    end
  end
end

return M
