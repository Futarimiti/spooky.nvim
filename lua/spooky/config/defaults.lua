local M = {}

M.defaults = { directory = vim.fn.stdpath('config') .. 'skeletons'
             , case_sensitive = true
             }

-- Panics when the typecheck fails.
M.typecheck = function (config)
  vim.validate { directory = { config.directory, 'string' }
               , case_sensitive = { config.case_sensitive, 'boolean' }
               }
end

-- sanity check
assert(pcall(M.typecheck, M.defaults))

return M
