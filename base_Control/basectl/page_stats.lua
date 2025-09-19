-- page_stats.lua  v0.2.0
-- Example control surface for generators over the 'base_ctrl' protocol

local M = {}
local CTRL_PROTOCOL = "base_ctrl"

local function ctrlLookup(host)
  return rednet.lookup(CTRL_PROTOCOL, host)
end

local function ctrlToggle(host)
  local id = ctrlLookup(host)
  if not id then return false, "not found" end
  rednet.send(id, { cmd = "toggle" }, CTRL_PROTOCOL)
  local _, reply = rednet.receive(CTRL_PROTOCOL, 2)
  if reply and reply.ok then return true, reply.status end
  return true, nil
end

local function ctrlStatus(host)
  local id = ctrlLookup(host)
  if not id then return nil, "not found" end
  rednet.send(id, { cmd = "status" }, CTRL_PROTOCOL)
  local _, reply = rednet.receive(CTRL_PROTOCOL, 1.5)
  if reply and reply.ok then return reply.status end
  return nil
end

local function draw(state, ui)
  ui.drawHeader(state)
  term.setCursorPos(2,3); write("Generators:")
  local list = state.baseCfg.generators or {}
  if #list == 0 then
    term.setCursorPos(4,5); write("(no generators configured; edit /base_control_config.lua)")
  else
    for i, g in ipairs(list) do
      local y = 4 + i
      term.setCursorPos(2,y)
      if i == state.genSel then term.setTextColor(colors.yellow) else term.setTextColor(colors.white) end
      local status = ctrlStatus(g.host) or "?"
      write( string.format("%s  [%s]  (%s)", g.name, status, g.host or "-") )
      term.setTextColor(colors.white)
    end
  end
  ui.drawFooter("Up/Down select  [Space/Enter]=Toggle  [R]Refresh  [Q]Back")
end

function M.run(state, ui, util, store, server, PROTO, NAME)
  util.clear(); draw(state, ui)
  local list = state.baseCfg.generators or {}
  while true do
    local ev,a,b,c = os.pullEvent()
    server.handleEvent(state, ev, a, b, c, store, util, PROTO)
    if ev == "timer" and a == state.serverTimerId then ui.drawHeader(state) end
    if ev == "mouse_click" then
      if ui.maybeHandleHeaderClick(state, b, c, server, store, util, PROTO, NAME) then util.clear(); draw(state, ui) end
    elseif ev == "key" then
      if a == keys.q then return end
      if a == keys.up then state.genSel = util.clamp((state.genSel or 1)-1, 1, math.max(1,#list)); util.clear(); draw(state, ui) end
      if a == keys.down then state.genSel = util.clamp((state.genSel or 1)+1, 1, math.max(1,#list)); util.clear(); draw(state, ui) end
      if a == keys.space or a == keys.enter then
        local g = list[state.genSel]
        if g then ctrlToggle(g.host); util.clear(); draw(state, ui) end
      end
      if a == keys.r then util.clear(); draw(state, ui) end
    end
  end
end

return M
