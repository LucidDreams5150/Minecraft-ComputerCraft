-- page_labels.lua  v0.5.5
-- Labels management UI page (scrolling list, per-monitor editors, defaults editor)

local M = {}

local function clamp(n, lo, hi) if n < lo then return lo elseif n > hi then return hi else return n end end
local function fpad(s, width) s = tostring(s or ""); if #s > width then return s:sub(1, math.max(0,width-1)) .. "…" end; return s .. string.rep(" ", width - #s) end
local function normAlign(a) a = tostring(a or "center"):lower(); if a=="left" or a=="right" or a=="center" then return a end; return "center" end
local COLOR_NAMES = {"white","orange","magenta","lightBlue","yellow","lime","pink","gray","lightGray","cyan","purple","blue","brown","green","red","black"}
local function isValidColorName(name) name=tostring(name or ""); for _,n in ipairs(COLOR_NAMES) do if n==name then return true end end; return false end
local function shortNumberFromName(name) local num = tostring(name or ""):match("(%d+)$"); return num or tostring(name or "?") end
local function normalizeInputName(input) local digits = tostring(input or ""):match("^%s*(%d+)%s*$"); if digits then return "monitor_"..digits end; return input end

function M.reload(state, store)
  state.cfg = store.loadLabelsCfg()
  state.monitors = {}
  for _,e in ipairs(state.cfg.monitors or {}) do table.insert(state.monitors, e) end
  state.monSel = clamp(state.monSel or 1, 1, math.max(1, #state.monitors))
  state.scroll = state.scroll or 0
end

local function drawList(state, ui)
  local w,h = term.getSize()
  ui.drawHeader(state)
  for y=3,6 do term.setCursorPos(1,y); term.setBackgroundColor(colors.black); term.clearLine() end

  local d = state.cfg.defaults or {}
  term.setCursorPos(2,3); write(("Defaults: bg=%s  fg=%s  align=%s"):format(tostring(d.bg or "-"), tostring(d.fg or "-"), tostring(d.align or "center")):sub(1, w-1))
  term.setCursorPos(2,4); write(("Template: %s  autodiscover=%s"):format(tostring(d.default_label_template or "Monitor $n"), tostring(d.autodiscover ~= false)):sub(1, w-1))

  local yStart = 7
  local maxRows = math.max(0, h - yStart - 1)

  local colNo, colLabel = 4, 26
  local colBG, colFG = 6, 6
  local colTS, colPX, colPY = 5, 4, 4

  term.setCursorPos(1,6); term.clearLine(); term.setCursorPos(2,6)
  write(fpad("#", colNo) .. " " .. fpad("Label", colLabel) .. " " .. fpad("BG", colBG) .. " " .. fpad("FG", colFG) .. " " .. fpad("TS", colTS) .. " " .. fpad("PX", colPX) .. " " .. fpad("PY", colPY))

  local total = #state.monitors
  local counterY = (maxRows > 0) and (yStart + maxRows - 1) or (h-2)
  if total == 0 then
    term.setCursorPos(4,yStart); term.clearLine(); write("(none)")
  else
    if state.monSel < state.scroll + 1 then state.scroll = state.monSel - 1 end
    if state.monSel > state.scroll + maxRows then state.scroll = state.monSel - maxRows end
    state.scroll = clamp(state.scroll, 0, math.max(0, total - maxRows))

    for row = 1, maxRows do
      local idx = state.scroll + row
      local y = yStart + row - 1
      term.setCursorPos(2,y); term.clearLine()
      if idx <= total then
        local e = state.monitors[idx]
        local no    = fpad(shortNumberFromName(e.name), colNo)
        local label = fpad(e.label or "", colLabel)
        local bg = fpad(e.bg or "-", colBG)
        local fg = fpad(e.fg or "-", colFG)
        local ts = fpad(e.text_scale and tostring(e.text_scale) or "-", colTS)
        local px = fpad(e.pad_x~=nil and tostring(e.pad_x) or "-", colPX)
        local py = fpad(e.pad_y~=nil and tostring(e.pad_y) or "-", colPY)

        if idx == state.monSel then term.setTextColor(colors.yellow) else term.setTextColor(colors.white) end
        write(no .. " " .. label .. " " .. bg .. " " .. fg .. " " .. ts .. " " .. px .. " " .. py)
        term.setTextColor(colors.white)
      end
    end

    if total > maxRows then
      local barH = math.max(1, math.floor(maxRows * maxRows / total))
      local rel = (state.scroll / math.max(1, total - maxRows))
      local top = yStart + math.floor(rel * (maxRows - barH))
      for i=0,barH-1 do term.setCursorPos(w, top + i); write("|") end
      term.setCursorPos(w-6, counterY); write( ("%d/%d"):format(state.monSel, total) )
    else
      term.setCursorPos(w-6, counterY); write( ("%d/%d"):format(state.monSel, total) )
    end
  end

  local footer = "[A]Add  [E]Edit  [B]BG  [F]FG  [T]Scale  [H]PadX  [V]PadY  [D]Defaults  [S]Save  [R]Reload  [Q]Back"
  if #footer > w then footer = footer:sub(1, w) end
  ui.drawFooter(footer)
end

local function promptScale(util, current)
  local hint = "(0.5..5 or 'auto' to clear)"
  local raw = util.inputPrompt("Text scale "..hint..":", current and tostring(current) or "auto")
  if not raw or raw == "" or raw:lower() == "auto" then return nil end
  local n = tonumber(raw)
  if not n then return current end
  if n < 0.5 then n = 0.5 elseif n > 5 then n = 5 end
  return n
end

local function promptPad(util, label, current)
  local hint = "(integer; negative = left/up, positive = right/down)"
  local raw = util.inputPrompt(label.." "..hint..":", current and tostring(current) or "0")
  if not raw or raw == "" then return current end
  local n = tonumber(raw)
  if not n then return current end
  if n < -50 then n = -50 elseif n > 50 then n = 50 end
  return math.floor(n)
end

local function promptColor(util, label, current)
  local raw = util.inputPrompt(label.." color:", current)
  if not raw or raw == "" then return current end
  if isValidColorName(raw) then return raw end
  return current
end

local function promptAlign(util, current)
  local raw = util.inputPrompt("Align (left/center/right):", current or "center")
  return normAlign(raw)
end

local function editDefaults(state, util, store, server, PROTO)
  local d = state.cfg.defaults or {}
  while true do
    term.setBackgroundColor(colors.black); term.setTextColor(colors.white)
    term.clear(); term.setCursorPos(1,1)
    print("=== Defaults Editor ===")
    print("1) bg              = "..tostring(d.bg))
    print("2) fg              = "..tostring(d.fg))
    print("3) text_scale      = "..tostring(d.text_scale or "auto"))
    print("4) align           = "..tostring(d.align or "center"))
    print("5) pad_x           = "..tostring(d.pad_x or 0))
    print("6) pad_y           = "..tostring(d.pad_y or 0))
    print("7) clear_on_draw   = "..tostring(d.clear_on_draw ~= false))
    print("8) autodiscover    = "..tostring(d.autodiscover ~= false))
    print("9) template        = "..tostring(d.default_label_template or "Monitor $n"))
    print("")
    print("[1-9]=edit  [S]=Save  [Q]=Back")

    local ev,k = os.pullEvent("key")
    if k == keys.q then break
    elseif k == keys.s then
      state.cfg.defaults = d
      store.saveLabelsCfg(state.cfg)
      if server.bumpNow then server.bumpNow(state, store, util, PROTO) end
      break
    elseif k == keys.one then d.bg = promptColor(util, "bg", d.bg)
    elseif k == keys.two then d.fg = promptColor(util, "fg", d.fg)
    elseif k == keys.three then d.text_scale = promptScale(util, d.text_scale)
    elseif k == keys.four then d.align = promptAlign(util, d.align)
    elseif k == keys.five then d.pad_x = promptPad(util, "Pad X", d.pad_x)
    elseif k == keys.six then d.pad_y = promptPad(util, "Pad Y", d.pad_y)
    elseif k == keys.seven then d.clear_on_draw = not (d.clear_on_draw == false)
    elseif k == keys.eight then d.autodiscover = not (d.autodiscover == false)
    elseif k == keys.nine then d.default_label_template = util.inputPrompt("Template:", d.default_label_template or "Monitor $n")
    end
  end
end

function M.run(state, ui, util, store, server, PROTO, NAME)
  M.reload(state, store)
  util.clear(); drawList(state, ui)
  while true do
    local ev,a,b,c = os.pullEvent()
    server.handleEvent(state, ev, a, b, c, store, util, PROTO)

    if ev == "timer" and a == state.serverTimerId then drawList(state, ui) end

    if ev == "mouse_click" then
      if ui.maybeHandleHeaderClick(state, b, c, server, store, util, PROTO, NAME) then drawList(state, ui) end
    elseif ev == "mouse_scroll" then
      local dir = a
      local w,h = term.getSize(); local yStart = 7; local maxRows = math.max(0, h - yStart - 1)
      local total = #state.monitors
      state.scroll = clamp(state.scroll + dir, 0, math.max(0, total - maxRows))
      state.monSel = clamp(state.monSel + dir, 1, math.max(1, total))
      drawList(state, ui)

    elseif ev == "key" then
      local total = #state.monitors
      if a == keys.q then return end
      if a == keys.up then state.monSel = clamp(state.monSel-1, 1, math.max(1,total)); drawList(state, ui) end
      if a == keys.down then state.monSel = clamp(state.monSel+1, 1, math.max(1,total)); drawList(state, ui) end
      if keys.pageUp and a == keys.pageUp then
        local w,h = term.getSize(); local yStart = 7; local maxRows = math.max(0, h - yStart - 1)
        state.monSel = clamp(state.monSel - maxRows, 1, math.max(1,total))
        state.scroll = clamp(state.scroll - maxRows, 0, math.max(0, total - maxRows))
        drawList(state, ui)
      end
      if keys.pageDown and a == keys.pageDown then
        local w,h = term.getSize(); local yStart = 7; local maxRows = math.max(0, h - yStart - 1)
        state.monSel = clamp(state.monSel + maxRows, 1, math.max(1,total))
        state.scroll = clamp(state.scroll + maxRows, 0, math.max(0, total - maxRows))
        drawList(state, ui)
      end
      if keys.home and a == keys.home then state.monSel = 1; state.scroll = 0; drawList(state, ui) end
      if keys["end"] and a == keys["end"] then state.monSel = total; state.scroll = math.max(0, total-1); drawList(state, ui) end

      if a == keys.a then
        local raw = util.inputPrompt("Monitor name (number or full peripheral name):")
        if raw and raw ~= "" then
          local name = normalizeInputName(raw)
          local lab = util.inputPrompt("Label (empty = use template)", "")
          table.insert(state.monitors, { name = name, label = (lab ~= "" and lab or nil) })
          total = #state.monitors; state.monSel = total
          drawList(state, ui)
        end

      elseif a == keys.e then
        local e = state.monitors[state.monSel]
        if e then e.label = util.inputPrompt("Label:", e.label or ""); drawList(state, ui) end

      elseif a == keys.b then
        local e = state.monitors[state.monSel]
        if e then e.bg = promptColor(util, "bg", e.bg); drawList(state, ui) end

      elseif a == keys.f then
        local e = state.monitors[state.monSel]
        if e then e.fg = promptColor(util, "fg", e.fg); drawList(state, ui) end

      elseif a == keys.t then
        local e = state.monitors[state.monSel]
        if e then e.text_scale = promptScale(util, e.text_scale); drawList(state, ui) end

      elseif a == keys.h then
        local e = state.monitors[state.monSel]
        if e then e.pad_x = promptPad(util, "Pad X", e.pad_x); drawList(state, ui) end

      elseif a == keys.v then
        local e = state.monitors[state.monSel]
        if e then e.pad_y = promptPad(util, "Pad Y", e.pad_y); drawList(state, ui) end

      elseif a == keys.d then
        editDefaults(state, util, store, server, PROTO)
        M.reload(state, store)
        drawList(state, ui)

      elseif a == keys.x then
        if total > 0 then table.remove(state.monitors, state.monSel); total = #state.monitors; state.monSel = clamp(state.monSel,1,math.max(1,total)) end
        drawList(state, ui)

      elseif a == keys.s then
        state.cfg.monitors = state.monitors
        store.saveLabelsCfg(state.cfg)
        if server.bumpNow then server.bumpNow(state, store, util, PROTO) end
        drawList(state, ui)

      elseif a == keys.r then
        M.reload(state, store); drawList(state, ui)
      end
    end
  end
end

return M
