-- repo_server.lua  v0.1.0
-- Hosts 'pkg_repo' over rednet, mirrors GitHub manifest & files via HTTP.
-- First run will prompt for GitHub owner/repo/branch; saves to /repo/config.lua

local PKG_PROTO = 'pkg_repo'
local HOST_NAME = 'mainframe'

local function vhash_bytes(s) local sum=0; for i=1,#s do sum=(sum*31+s:byte(i))%2147483647 end; return ('%08x'):format(sum) end

local function open_modems()
  local any=false
  for _,s in ipairs(peripheral.getNames()) do if peripheral.getType(s)=='modem' then if not rednet.isOpen(s) then rednet.open(s) end; any=true end end
  if not any then error('No modem present') end
end

local function load_or_init_cfg()
  if fs.exists('/repo/config.lua') then return dofile('/repo/config.lua') end
  term.setTextColor(colors.yellow); write('GitHub owner (user or org): '); term.setTextColor(colors.white); local owner=read()
  term.setTextColor(colors.yellow); write('Repo name: '); term.setTextColor(colors.white); local repo=read()
  term.setTextColor(colors.yellow); write('Branch (main): '); term.setTextColor(colors.white); local branch=read(); if branch=='' then branch='main' end
  local cfg={owner=owner, repo=repo, branch=branch}
  local f=fs.open('/repo/config.lua','w'); f.write('return '..textutils.serialize(cfg)..'\n'); f.close(); return cfg
end

local function http_get(url)
  local ok, resp = pcall(http.get, url, {['Cache-Control']='no-cache'})
  if not ok or not resp then return nil end
  local s = resp.readAll(); resp.close(); return s
end

local function write_file(path, data)
  local dir=fs.getDir(path); if dir~='' and not fs.exists(dir) then fs.makeDir(dir) end
  local f=fs.open(path, 'wb'); f.write(data); f.close()
end

local function read_file(path) if not fs.exists(path) then return nil end local f=fs.open(path,'rb'); local d=f.readAll(); f.close(); return d end

local function fetch_manifest(cfg)
  local url=('https://raw.githubusercontent.com/%s/%s/%s/manifest.json'):format(cfg.owner, cfg.repo, cfg.branch)
  return http_get(url)
end

local function ensure_cache(cfg, m)
  for path, rec in pairs(m.files or {}) do
    local cache_path = '/repo/cache'..path
    if not fs.exists(cache_path) or vhash_bytes(read_file(cache_path) or '') ~= rec.sum then
      local data = http_get(rec.url)
      if data and vhash_bytes(data)==rec.sum then write_file(cache_path, data) end
    end
  end
end

local function serve()
  open_modems(); rednet.host(PKG_PROTO, HOST_NAME)
  local cfg = load_or_init_cfg()
  local last_sum=nil
  print('repo_server on '..PKG_PROTO..' as '..HOST_NAME)
  while true do
    -- Poll manifest every 15s
    local man_s = fetch_manifest(cfg)
    if man_s then
      local sum=vhash_bytes(man_s)
      if sum~=last_sum then
        last_sum=sum
        write_file('/repo/manifest.json', man_s)
        local ok, m = pcall(textutils.unserializeJSON, man_s)
        if ok and type(m)=='table' then
          ensure_cache(cfg, m)
          rednet.broadcast({cmd='update', versions=m.versions}, PKG_PROTO)
          print('Manifest updated; broadcasted update')
        end
      end
    end

    local t=os.startTimer(0.5)
    while true do
      local ev,a,b,c = os.pullEvent()
      if ev=='rednet_message' then
        local sender, msg, proto = a,b,c
        if proto==PKG_PROTO and type(msg)=='table' then
          if msg.cmd=='manifest' then
            local man = read_file('/repo/manifest.json')
            if man then rednet.send(sender, {ok=true, manifest=textutils.unserializeJSON(man)}, PKG_PROTO) else rednet.send(sender, {ok=false, err='no manifest'}, PKG_PROTO) end
          elseif msg.cmd=='get' and type(msg.path)=='string' then
            local cache_path = '/repo/cache'..msg.path
            local data = read_file(cache_path)
            if not data then rednet.send(sender, {ok=false, err='not cached'}, PKG_PROTO) else
              rednet.send(sender, {type='begin', size=#data, sum=vhash_bytes(data)}, PKG_PROTO)
              local i=1; local chunk=4096
              while i<=#data do
                rednet.send(sender, {type='chunk', data=data:sub(i, math.min(#data, i+chunk-1))}, PKG_PROTO)
                i=i+chunk
              end
              rednet.send(sender, {type='end'}, PKG_PROTO)
            end
          end
        end
      elseif ev=='timer' and a==t then break end
    end
  end
end

serve()