-- labelClient.lua  v1.3.0 (auto-update + wrap)
-- Pulls labels_config from BaseControl server and now auto-updates itself
-- from a LAN Mainframe that hosts the 'pkg_repo' protocol.

local CLIENT_VER = "v1.3.0"
local CFG_PROTO  = "labels_cfg"
local CFG_NAME   = "labels-hub"
local PKG_PROTO  = "pkg_repo"

-- === simple 31-hash (matches manifest builder) ===
local function vhash_bytes(s)
  local sum = 0
  for i = 1, #s do sum = (sum * 31 + s:byte(i)) % 2147483647 end
  return ("%08x"):format(sum)
end

-- === color + text helpers (same as v1.2.0) ===
local function colorOf(name, fallback)
  local m = colors
  local t = {white=m.white,orange=m.orange,magenta=m.magenta,lightBlue=m.lightBlue,
    yellow=m.yellow,lime=m.lime,pink=m.pink,gray=m.gray,lightGray=m.lightGray,cyan=m.cyan,
    purple=m.purple,blue=m.blue,brown=m.brown,green=m.green,red=m.red,black=m.black}
  return t[tostring(name or "")] or fallback or colors.black
end
local function firstDigits(s) return tostring(s or ""):match("(%d+)") end
local function clientName() return os.getComputerLabel() or ("id"..tostring(os.getComputerID())) end

local function openWirelessOrError()
  local opened = false
  for _, side in ipairs({"back","top","bottom","left","right","front"}) do
    if peripheral.getType(side) == "modem" then if not rednet.isOpen(side) then rednet.open(side) end opened = true end
  end
  for _, side in ipairs(peripheral.getNames()) do
    if peripheral.getType(side) == "modem" then if not rednet.isOpen(side) then rednet.open(side) end opened = true end
  end
  if opened then return true end
  error("No modem found (wireless or Ender). Attach one and retry.")
end

local function lookup(proto, name) return rednet.lookup(proto, name) end

-- === wrap helpers ===
local function wrapText(text, width)
  width = math.max(1, tonumber(width) or 1)
  local lines, line = {}, ""
  for word in tostring(text):gmatch("%S+") do
    if #line == 0 then
      if #word <= width then line = word else
        local i=1; while i<=#word do table.insert(lines, word:sub(i,i+width-1)); i=i+width end; line=""
      end
    else
      if #line + 1 + #word <= width then line = line .. " " .. word else
        table.insert(lines, line)
        if #word <= width then line = word else
          local i=1; while i<=#word do table.insert(lines, word:sub(i,i+width-1)); i=i+width end; line=""
        end
      end
    end
  end
  if #line>0 then table.insert(lines, line) end
  if #lines==0 then lines={""} end
  return lines
end
local function horizXFor(line, w, align, pad_x)
  pad_x = tonumber(pad_x or 0) or 0
  if align=="left" then return math.max(1,1+pad_x)
  elseif align=="right" then return math.max(1, w-#line-pad_x+1)
  else return math.floor((w-#line)/2)+1 end
end

-- === drawing ===
local function applyTextScale(mon, scale)
  if scale==nil then mon.setTextScale(1); return end
  scale = tonumber(scale) or 1; if scale<0.5 then scale=0.5 elseif scale>5 then scale=5 end; mon.setTextScale(scale)
end
local function drawLabelOnMonitor(monName, entry, defaults)
  local mon = peripheral.wrap(monName); if not mon then return end
  local bg = colorOf(entry.bg or defaults.bg, colors.black)
  local fg = colorOf(entry.fg or defaults.fg, colors.white)
  mon.setBackgroundColor(bg); mon.setTextColor(fg)
  applyTextScale(mon, entry.text_scale or defaults.text_scale)
  local w,h = mon.getSize()
  local label = entry.label
  if not label or label=="" then
    local t = (defaults.default_label_template or "Monitor $n")
    t = t:gsub("%$name", monName):gsub("%$client", clientName()):gsub("%$n", firstDigits(monName) or "")
    label = t
  end
  if defaults.clear_on_draw ~= false then mon.clear() end
  local align=(entry.align or defaults.align or "center")
  local pad_x=tonumber(entry.pad_x or defaults.pad_x or 0) or 0
  local pad_y=tonumber(entry.pad_y or defaults.pad_y or 0) or 0
  local doWrap=(entry.wrap ~= false) and (entry.wrap or defaults.wrap)
  local maxLines=entry.max_lines or defaults.max_lines or h
  local centerVert=(entry.center_vert ~= false) and (entry.center_vert or defaults.center_vert or true)
  if doWrap then
    local widthAvail=(align=="center" and w) or math.max(1, w - pad_x)
    local lines=wrapText(label, widthAvail)
    if #lines>maxLines then
      lines={table.unpack(lines,1,maxLines)}
      local last=lines[#lines]
      if #last>1 and widthAvail>=2 then lines[#lines]=last:sub(1, math.max(1,widthAvail-1)).."…" end
    end
    local startY = centerVert and math.max(1, math.floor((h-#lines)/2)+1+pad_y) or math.max(1,1+pad_y)
    local y=startY
    for _,line in ipairs(lines) do if y>h then break end; local x=horizXFor(line,w,align,pad_x); mon.setCursorPos(x,y); mon.write(line); y=y+1 end
  else
    local x=horizXFor(label,w,align,pad_x); local y=math.max(1, math.floor(h/2)+pad_y); mon.setCursorPos(x,y); mon.write(label)
  end
end

local function listLocalMonitors()
  local names={}; for _,n in ipairs(peripheral.getNames()) do if peripheral.getType(n)=="monitor" then table.insert(names,n) end end; table.sort(names); return names end
local function indexMonitors(list) local idx={}; for _,e in ipairs(list or {}) do if e and e.name then idx[e.name]=e end end; return idx end
local function drawAll(cfg)
  local defaults=cfg.defaults or {}; local listed=cfg.monitors or {}; local indexed=indexMonitors(listed)
  for _,e in ipairs(listed) do if type(e)=="table" and e.name then drawLabelOnMonitor(e.name,e,defaults) end end
  if defaults.autodiscover ~= false then for _,name in ipairs(listLocalMonitors()) do if not indexed[name] then drawLabelOnMonitor(name,{name=name},defaults) end end end
end

-- === labels_cfg fetch ===
local function requestConfig(hostID, known_version)
  if hostID then
    if known_version then rednet.send(hostID, {cmd="get_if_new", known_version=known_version}, CFG_PROTO)
    else rednet.send(hostID, {cmd="get"}, CFG_PROTO) end
  else rednet.broadcast({cmd="get"}, CFG_PROTO) end
  local timeout=os.startTimer(2)
  while true do
    local ev,a,b,c=os.pullEvent()
    if ev=="rednet_message" then local sender,msg,pr=a,b,c; if pr==CFG_PROTO and type(msg)=="table" then
      if msg.up_to_date then return {up_to_date=true, version=msg.version} elseif msg.cfg then return {cfg=msg.cfg, version=msg.version} end end
    elseif ev=="timer" and a==timeout then return nil end
  end
end

local function lookupCfgHost() return rednet.lookup(CFG_PROTO, CFG_NAME) end
local function lookupRepoHost() return rednet.lookup(PKG_PROTO, "mainframe") end

-- === pkg_repo client (auto-update) ===
local function pkg_manifest()
  local host=lookupRepoHost(); if not host then return nil, "no repo host" end
  rednet.send(host, {cmd="manifest"}, PKG_PROTO)
  local _, msg = rednet.receive(PKG_PROTO, 2)
  if type(msg)=="table" and msg.ok and msg.manifest then return msg.manifest end
  return nil, "no reply"
end

local function pkg_download(path)
  local host=lookupRepoHost(); if not host then return nil, "no repo host" end
  rednet.send(host, {cmd="get", path=path}, PKG_PROTO)
  local ftmp = fs.open(path..".new", "wb"); if not ftmp then return nil, "open fail" end
  local meta
  while true do
    local _, msg = rednet.receive(PKG_PROTO, 5)
    if not msg then ftmp.close(); return nil, "timeout" end
    if msg.type=="begin" then meta=msg
    elseif msg.type=="chunk" then ftmp.write(msg.data)
    elseif msg.type=="end" then break end
  end
  ftmp.close()
  if not meta then return nil, "no meta" end
  local f = fs.open(path..".new", "rb"); local data = f.readAll(); f.close()
  local sum = vhash_bytes(data)
  if sum ~= (meta.sum or "") then return nil, "checksum" end
  if fs.exists(path) then fs.delete(path) end; fs.move(path..".new", path)
  return true
end

local function maybeUpdateSelf()
  local m, err = pkg_manifest(); if not m then return false, err end
  local rec = m.files and m.files["/clients/labelClient.lua"]; if not rec then return false, "manifest missing client" end
  -- compare current file sum (if exists)
  local path = "/labelClient.lua"
  local curSum
  if fs.exists(path) then local f=fs.open(path, "rb"); local data=f.readAll(); f.close(); curSum=vhash_bytes(data) end
  if curSum == rec.sum then return false, "up-to-date" end
  local ok, why = pkg_download("/labelClient.lua")
  if ok then return true else return false, why end
end

-- === main ===
local function main()
  term.setBackgroundColor(colors.black); term.setTextColor(colors.white); term.clear(); term.setCursorPos(1,1)
  print("labelClient "..CLIENT_VER.." starting…")
  local ok, err = pcall(openWirelessOrError); if not ok then print("ERROR: "..tostring(err)); return end

  -- Try self-update first (if Mainframe present)
  local updated, why = maybeUpdateSelf()
  if updated then print("Client updated, restarting…"); os.sleep(1); shell.run("reboot"); return
  elseif why then print("Update check: "..why) end

  local hostID; for i=1,5 do hostID=lookup(CFG_PROTO, CFG_NAME); if hostID then break end; print("No labels server; retry "..i.."/5…"); sleep(1) end
  if not hostID then print("No labels host found. Start BaseControl.") end

  local known_version=nil; local cfg
  local function fetchAndDraw()
    local reply=requestConfig(hostID, known_version)
    if reply and reply.up_to_date then return elseif reply and reply.cfg then cfg=reply.cfg; known_version=reply.version; drawAll(cfg); print("Cfg v="..tostring(known_version)) else hostID=lookup(CFG_PROTO, CFG_NAME) or hostID end
  end

  do local reply=requestConfig(hostID, nil); if reply and reply.cfg then cfg=reply.cfg; known_version=reply.version; drawAll(cfg); print("Initial cfg v="..tostring(known_version)) else print("Waiting for server…") end end

  while true do
    local ev,a,b,c=os.pullEvent()
    if ev=="rednet_message" then
      local sender,msg,pr=a,b,c
      if pr==CFG_PROTO and type(msg)=="table" and msg.cmd=="changed" then fetchAndDraw() end
      if pr==PKG_PROTO and type(msg)=="table" and msg.cmd=="update" then local ok2,why2=maybeUpdateSelf(); if ok2 then print("Auto-updated, rebooting…"); sleep(1); shell.run("reboot") end end
    elseif ev=="peripheral" or ev=="peripheral_detach" or ev=="monitor_resize" then if cfg then drawAll(cfg) end end
  end
end

main()