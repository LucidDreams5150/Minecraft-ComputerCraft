-- store.lua  v0.3.0
-- File access helpers for BaseControl
local M = {}

M.LABELS_CFG_PATH = "/labels_config.lua"
M.BASE_CFG_PATH   = "/base_control_config.lua"

function M.ensureFiles()
  if not fs.exists(M.LABELS_CFG_PATH) then
    local f = fs.open(M.LABELS_CFG_PATH, "w")
    f.write("return " .. textutils.serialize({
      defaults = {
        bg = "gray",
        fg = "purple",
        text_scale = nil,
        align = "center",
        pad_x = 0,
        pad_y = 0,
        clear_on_draw = true,
        autodiscover = true,
        default_label_template = "Monitor $n",
      },
      monitors = {},
    }) .. "")
    f.close()
  end
  if not fs.exists(M.BASE_CFG_PATH) then
    local f = fs.open(M.BASE_CFG_PATH, "w")
    f.write("return " .. textutils.serialize({
      generators = {
        -- Example: { name = 'Reactor A', host = 'gen-reactor-a' },
      },
    }) .. "")
    f.close()
  end
end

function M.loadLabelsCfg()
  local ok, t = pcall(dofile, M.LABELS_CFG_PATH)
  if ok and type(t) == "table" then return t end
  return { defaults = {}, monitors = {} }
end

function M.saveLabelsCfg(t)
  local f = fs.open(M.LABELS_CFG_PATH, "w")
  f.write("return " .. textutils.serialize(t) .. "")
  f.close()
end

function M.loadBaseCfg()
  local ok, t = pcall(dofile, M.BASE_CFG_PATH)
  if ok and type(t) == "table" then return t end
  return { generators = {} }
end

return M
