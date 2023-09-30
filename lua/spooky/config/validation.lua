local M = {}

-- Returns validated, full user config
-- or throws an error if the user config is invalid
M.validate = function (raw)
  local user = raw or {}
  vim.validate { user_config = { user, 'table' } }

  local def = require 'spooky.config.defaults'
  local defaults = def.defaults
  local updated = vim.tbl_deep_extend('keep', user, defaults)
  def.typecheck(updated)

  return updated
end

return M
