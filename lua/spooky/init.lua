local M = {}

M.setup = function (raw)
  local config = require 'spooky.config'
  local autocmd = require 'spooky.autocmd'
  local command = require 'spooky.command'

  local user = config.validate(raw)

  autocmd.setup_autocmds(user)
  command.setup_commands(user)
end

return M
