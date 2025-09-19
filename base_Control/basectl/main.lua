-- main.lua  v0.6.1
-- BaseControl entrypoint. Menu: Stats / Labels / Server / Utils. Starts LabelsConfigServer.

local APP_VER = "v0.6.1"

local util   = dofile("/basectl/util.lua")
local store  = dofile("/basectl/store.lua")
local server = dofile("/basectl/server.lua")
local ui     = dofile("/basectl/ui.lua")
local pageL  = dofile("/basectl/page_labels.lua")
local pageS  = dofile("/basectl/page_stats.lua")
local pageSrv= dofile("/basectl/page_server.lua")
local pageU  = dofile("/basectl/page_utils.lua")

local PROTO = "labels_cfg"
local NAME  = "labels-hub"

local state = {
  page = "menu",
  appVersion = APP_VER,
  serverOn = false,
  serverVersion = nil,
  serverPrevVersion = nil,
  serverTimerId = nil,
  headerBtn = nil,
  cfg = nil,
  baseCfg = nil,
  monitors = {}, monSel = 1,
  generators = {}, genSel = 1,
}

local function drawMenu()
  util.clear(); ui.drawHeader(state)
  local y = util.centerY()-1
  term.setCursorPos(3,y);     write("1) Stats")
  term.setCursorPos(3,y + 1); write("2) Labels")
  term.setCursorPos(3,y + 2); write("3) Server")
  term.setCursorPos(3,y + 3); write("4) Utils")
  ui.drawFooter()
end

local function handleMenu()
  drawMenu()
  while true do
    local ev,a,b,c = os.pullEvent()
    server.handleEvent(state, ev, a, b, c, store, util, PROTO)
    if ev == "timer" and a == state.serverTimerId then ui.drawHeader(state) end
    if ev == "mouse_click" then
      if ui.maybeHandleHeaderClick(state, b, c, server, store, util, PROTO, NAME) then drawMenu() end
    elseif ev == "key" then
      if a == keys.one then state.page = "stats"; return
      elseif a == keys.two then state.page = "labels"; return
      elseif a == keys.three then state.page = "server"; return
      elseif a == keys.four then state.page = "utils"; return
      elseif a == keys.q then state.page = "quit"; return end
    end
  end
end

local function main()
  store.ensureFiles()
  util.clear()
  local ok, err = pcall(util.openWirelessOrError)
  if not ok then util.clear(); print("ERROR: "..tostring(err)); sleep(3); return end
  server.start(state, store, util, PROTO, NAME)
  state.baseCfg = store.loadBaseCfg()

  while true do
    if state.page == "menu" then handleMenu()
    elseif state.page == "stats" then pageS.run(state, ui, util, store, server, PROTO, NAME); state.page = "menu"
    elseif state.page == "labels" then pageL.run(state, ui, util, store, server, PROTO, NAME); state.page = "menu"
    elseif state.page == "server" then pageSrv.run(state, ui, util, store, server, PROTO, NAME); state.page = "menu"
    elseif state.page == "utils" then pageU.run(state, ui, util, store, server, PROTO, NAME); state.page = "menu"
    elseif state.page == "quit" then break else state.page = "menu" end
  end

  util.clear(); print("Base Control exited.")
end

main()
