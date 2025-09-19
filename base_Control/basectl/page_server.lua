-- page_server.lua  (Server status + served-config preview)
-- Drop-in page that doesn't assume specific server/store APIs.
-- It tries common function names with pcall so it won't crash
-- if a helper isn't present.

local M = {}

-- Helpers that try multiple function names on the provided 'server'/'store'
local function try(func, ...)
  if type(func) ~= "function" then return false end
  local ok, a, b, c = pcall(func, ...)
  return ok and true or false, ok and a or nil, ok and b or nil, ok and c or nil
end

local function getServerOn(state, server)
  -- Try typical API names
  local ok, v = try(server and server.isOn, state)        ; if ok and type(v)=="boolean" then return v end
  ok, v = try(server and server.isEnabled, state)         ; if ok and type(v)=="boolean" then return v end
  ok, v = try(server and server.isRunning)                ; if ok and type(v)=="boolean" then return v end
  if type(state)=="table" and type(state.server_on)=="boolean" then return state.server_on end
  return false
end

local function setServerOn(state, server, on, store, util, PROTO, NAME)
  -- Prefer explicit setters/toggle/start/stop, fall back to state flag
  local ok = false
  ok = try(server and server.setEnabled, state, on, store, util, PROTO, NAME) and true or false
  if not ok and on then ok = try(server and server.start, state, store, util, PROTO, NAME) and true or false end
  if not ok and not on then ok = try(server and server.stop, state, store, util, PROTO, NAME) and true or false end
  if not ok and server and server.toggle then
    local now = getServerOn(state, server)
    if now ~= on then ok = try(server.toggle, state, store, util, PROTO, NAME) and true or false end
  end
  if (not ok) and type(state)=="table" then state.server_on = on; ok = true end
  return ok
end

local function bumpNow(server)
  -- If your server exposes a “broadcast on save / bumpNow” hook, use it
  return try(server and server.bumpNow)
end

local function servedVersion(server, store)
  -- Try a few possible sources for a version string
  local ok, v = try(server and server.getVersion); if ok and v then return tostring(v) end
  ok, v = try(store and store.get_labels_version); if ok and v then return tostring(v) end
  ok, v = try(store and store.getServedVersion);  if ok and v then return tostring(v) end
  return "—"
end

local function prevVersion(store)
  local ok, v = try(store and store.get_prev_labels_version); if ok and v then return tostring(v) end
  return "—"
end

local function loadServedConfig(server, store)
  -- Prefer server snapshot; fall back to store file on disk
  local ok, cfg = try(server and server.getServedConfig); if ok and cfg then return cfg end
  ok, cfg = try(store and store.load_labels_config); if ok and cfg then return cfg end
  return nil
end

local function serializePreview(tbl)
  if type(textutils.serializeJSON) == "function" then
    return textutils.serializeJSON(tbl, true)
  end
  return textutils.serialize(tbl)
end

local function draw(state, ui, status, on, verCur, verPrev, preview)
  local w, h = term.getSize()
  ui.drawHeader(state)

  -- Header rows
  term.setCursorPos(2, 3); write("Labels Config Server")
  term.setCursorPos(2, 4); write("Status: ")
  term.setTextColor(on and colors.lime or colors.red)
  write(on and "ON" or "OFF")
  term.setTextColor(colors.white)
  write("   (press ")
  term.setTextColor(colors.yellow); write("T"); term.setTextColor(colors.white)
  write(" to toggle)")

  term.setCursorPos(2, 5); write(("Version  Cur: %s   Prev: %s"):format(verCur or "—", verPrev or "—"))

  if status then
    term.setCursorPos(2, 7); term.se
