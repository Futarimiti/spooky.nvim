local M = {}

M.defaults = { directory = vim.fn.stdpath('config') .. 'skeletons'
             }

-- Panics when the typecheck fails.
M.typecheck = function (config)
  vim.validate { directory = { config.directory, 'string' } }
end

-- sanity check
assert(pcall(M.typecheck, M.defaults))

return M
