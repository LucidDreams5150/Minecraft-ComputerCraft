-- util.lua  v0.4.1
local M = {}

function M.clamp(n, lo, hi)
  if n < lo then return lo elseif n > hi then return hi else return n end
end

function M.clear()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear(); term.setCursorPos(1,1)
end

function M.centerY()
  local _, h = term.getSize()
  return math.floor(h/2)
end

function M.inputPrompt(prompt, default)
  term.setTextColor(colors.yellow)
  write(prompt)
  term.setTextColor(colors.white)
  if default ~= nil and default ~= "" then write(" ["..tostring(default).."] ") end
  term.setCursorBlink(true)
  local s = read()
  term.setCursorBlink(false)
  if (s == nil or s == "") and default ~= nil then return default end
  return s
end

M.COLOR_NAMES = {
  "white","orange","magenta","lightBlue","yellow","lime","pink","gray",
  "lightGray","cyan","purple","blue","brown","green","red","black",
}

function M.isValidColorName(name)
  for _,n in ipairs(M.COLOR_NAMES) do if n == name then return true end end
  return false
end

function M.openWirelessOrError()
  local opened = false
  if peripheral.getType("back") == "modem" then
    if not rednet.isOpen("back") then rednet.open("back") end
    opened = true
  end
  for _, side in ipairs(peripheral.getNames()) do
    if peripheral.getType(side) == "modem" then
      local m = peripheral.wrap(side)
      if m and (m.isWireless == nil or m.isWireless()) then
        if not rednet.isOpen(side) then rednet.open(side) end
        opened = true
      end
    end
  end
  if opened then return true end
  local t = os.startTimer(1)
  while true do
    local ev, a = os.pullEvent()
    if ev == "peripheral" and peripheral.getType(a) == "modem" then
      local m = peripheral.wrap(a)
      if m and (m.isWireless == nil or m.isWireless()) then
        if not rednet.isOpen(a) then rednet.open(a) end
        return true
      end
    elseif ev == "timer" and a == t then break end
  end
  error("No wireless or Ender modem found.")
end

function M.versionOf(tbl)
  local s = textutils.serialize(tbl)
  local sum = 0; for i = 1, #s do sum = (sum * 31 + s:byte(i)) % 2147483647 end
  return ("%08x"):format(sum)
end

return M
