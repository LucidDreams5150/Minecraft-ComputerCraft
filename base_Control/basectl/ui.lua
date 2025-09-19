-- ui.lua  v0.5.0
-- Draws header/footer, clickable server toggle, version line, and app version next to title.

local M = {}

function M.drawHeader(state)
  local w,_ = term.getSize()
  term.setCursorPos(1,1)
  term.setBackgroundColor(colors.blue)
  term.setTextColor(colors.white)
  term.clearLine()
  local title = " Base Control " .. (state.appVersion and ("("..state.appVersion..") ") or "")
  write(title)
  local badge = state.serverOn and "[Server:ON]" or "[Server:OFF]"
  local x = w - #badge + 1
  term.setCursorPos(x,1); write(badge)
  state.headerBtn = { x1 = x, x2 = x + #badge - 1, y = 1 }

  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.lightGray)
  term.setCursorPos(1,2); term.clearLine()
  local cur = state.serverVersion or "-"
  local prev = state.serverPrevVersion or "-"
  local verline = ("Cur:%s  Prev:%s"):format(cur, prev)
  local vx = math.max(1, w - #verline + 1)
  term.setCursorPos(vx, 2); write(verline)
  term.setTextColor(colors.white)
end

function M.drawFooter(help)
  local w,h = term.getSize()
  term.setCursorPos(1,h)
  term.setBackgroundColor(colors.gray)
  term.setTextColor(colors.black)
  term.clearLine()
  term.setCursorPos(1,h)
  if help and #help > w then help = help:sub(1, w) end
  write(help or "[1]Stats  [2]Labels  [3]Server  [4]Utils  [Q]Quit")
  term.setBackgroundColor(colors.black); term.setTextColor(colors.white)
end

function M.maybeHandleHeaderClick(state, x, y, server, store, util, PROTO, NAME)
  local b = state.headerBtn
  if b and y == b.y and x >= b.x1 and x <= b.x2 then
    if state.serverOn then server.stop(state, PROTO, NAME) else server.start(state, store, util, PROTO, NAME) end
    M.drawHeader(state)
    return true
  end
  return false
end

return M
