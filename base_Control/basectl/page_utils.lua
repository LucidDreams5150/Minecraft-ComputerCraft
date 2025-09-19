-- page_utils.lua  v0.1.0
-- Pocket utilities: modem tools, network ping, broadcast, label set, and info panel.

local M = {}

local function openAllModems()
  local opened = 0
  for _, side in ipairs(peripheral.getNames()) do
    if peripheral.getType(side) == "modem" then
      if not rednet.isOpen(side) then rednet.open(side); opened = opened + 1 end
    end
  end
  return opened
end

local function closeAllModems()
  local closed = 0
  for _, side in ipairs(rs.getSides()) do
    if rednet.isOpen(side) then rednet.close(side); closed = closed + 1 end
  end
  return closed
end

local function lookupHost(proto, name)
  return rednet.lookup(proto, name)
end

local function pingServer(proto, name)
  local id = lookupHost(proto, name)
  if not id then return false, "not in DNS" end
  rednet.send(id, { cmd = "get" }, proto)
  local _, msg = rednet.receive(proto, 1.5)
  if type(msg) == "table" and (msg.ok or msg.cfg) then
    return true, (msg.version or "?")
  end
  return false, "no reply"
end

local function openSidesList()
  local list = {}
  for _, side in ipairs(rs.getSides()) do if rednet.isOpen(side) then table.insert(list, side) end end
  return table.concat(list, ", ")
end

local function draw(state, ui, status)
  ui.drawHeader(state)
  local w,h = term.getSize()
  term.setCursorPos(2,3); write(string.format("ID:%d  Label:%s  Ver:%s", os.getComputerID(), os.getComputerLabel() or "(nil)", state.appVersion or "-"))
  term.setCursorPos(2,4); write(string.format("Proto:%s  Host:%s", state.PROTO, state.NAME))
  term.setCursorPos(2,5); write("Rednet open: "..(openSidesList() ~= "" and openSidesList() or "(none)"))
  term.setCursorPos(2,7); write("Actions: [O]pen modems  [C]lose modems  [P]ing server  [B]roadcast changed  [L]ist peripherals  [K] set label  [R]efresh  [Q]Back")

  if status and status ~= "" then
    term.setCursorPos(2,h-2); term.clearLine(); write("Status: "..status)
  end
  ui.drawFooter("[1]Stats  [2]Labels  [3]Server  [4]Utils  [Q]Quit")
end

function M.run(state, ui, util, store, server, PROTO, NAME)
  state.PROTO, state.NAME = PROTO, NAME
  util.clear(); draw(state, ui, "")
  while true do
    local ev,a,b,c = os.pullEvent()
    server.handleEvent(state, ev, a, b, c, store, util, PROTO)
    if ev == "timer" and a == state.serverTimerId then draw(state, ui, "") end

    if ev == "key" then
      if a == keys.q then return end
      if a == keys.o then local n = openAllModems(); draw(state, ui, ("opened %d modem side(s)"):format(n)) end
      if a == keys.c then local n = closeAllModems(); draw(state, ui, ("closed %d modem side(s)"):format(n)) end
      if a == keys.p then local ok, info = pingServer(PROTO, NAME); draw(state, ui, ok and ("server OK v="..info) or ("ping failed: "..info)) end
      if a == keys.b then rednet.broadcast({ cmd = "changed" }, PROTO); draw(state, ui, "broadcasted changed") end
      if a == keys.l then
        util.clear(); ui.drawHeader(state)
        print("Peripherals:")
        for _,n in ipairs(peripheral.getNames()) do print(" - "..n.." ("..(peripheral.getType(n) or "?")..")") end
        ui.drawFooter("[Any key] Back")
        os.pullEvent("key"); util.clear(); draw(state, ui, "")
      end
      if a == keys.k then
        local new = util.inputPrompt("New computer label:", os.getComputerLabel() or "")
        if new and new ~= "" then os.setComputerLabel(new); draw(state, ui, "label set") else draw(state, ui, "label unchanged") end
      end
      if a == keys.r then draw(state, ui, "refreshed") end
    elseif ev == "mouse_click" then
      if ui.maybeHandleHeaderClick(state, b, c, server, store, util, PROTO, NAME) then draw(state, ui, "") end
    end
  end
end

return M
