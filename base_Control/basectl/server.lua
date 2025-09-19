-- server.lua  v0.4.1
-- Labels Config Server: hosts DNS, serves config, broadcasts change events with versions.

local M = {}

function M.start(state, store, util, proto, name)
  if rednet.unhost then pcall(rednet.unhost, proto, name) end
  rednet.host(proto, name)
  state.serverOn = true
  local cfg = store.loadLabelsCfg()
  state.serverPrevVersion = state.serverPrevVersion or nil
  state.serverVersion = util.versionOf(cfg)
  state.serverTimerId = os.startTimer(1)
end

function M.stop(state, proto, name)
  if rednet.unhost then pcall(rednet.unhost, proto, name) end
  state.serverOn = false
  state.serverTimerId = nil
end

function M.bumpNow(state, store, util, proto)
  local cfg = store.loadLabelsCfg()
  local ver = util.versionOf(cfg)
  if ver ~= state.serverVersion then
    state.serverPrevVersion = state.serverVersion
    state.serverVersion = ver
    rednet.broadcast({ cmd = "changed", version = ver }, proto)
  end
end

function M.handleEvent(state, ev, a, b, c, store, util, proto)
  if not state.serverOn then return end
  if ev == "rednet_message" then
    local sender, msg, protoIn = a, b, c
    if protoIn == proto and type(msg) == "table" then
      local cfg = store.loadLabelsCfg()
      if msg.cmd == "get" then
        rednet.send(sender, { ok = true, cfg = cfg, version = util.versionOf(cfg) }, proto)
      elseif msg.cmd == "get_if_new" then
        local ver = util.versionOf(cfg)
        if msg.known_version == ver then
          rednet.send(sender, { ok = true, up_to_date = true, version = ver }, proto)
        else
          rednet.send(sender, { ok = true, cfg = cfg, version = ver }, proto)
        end
      end
    end
  elseif ev == "timer" and a == state.serverTimerId then
    local cfg = store.loadLabelsCfg()
    local ver = util.versionOf(cfg)
    if ver ~= state.serverVersion then
      state.serverPrevVersion = state.serverVersion
      state.serverVersion = ver
      rednet.broadcast({ cmd = "changed", version = ver }, proto)
    end
    state.serverTimerId = os.startTimer(1)
  end
end

return M
