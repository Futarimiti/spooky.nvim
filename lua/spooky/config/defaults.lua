local M = {}

M.defaults = { directory = vim.fn.stdpath('config') .. '/skeletons'
             , case_sensitive = true
             , auto_use_only = true
             }

-- Panics when the typecheck fails.
M.typecheck = function (config)
  vim.validate { directory = { config.directory, 'string' }
               , case_sensitive = { config.case_sensitive, 'boolean' }
               , auto_use_only = { config.auto_use_only, 'boolean' }
               }
end

-- sanity check
assert(pcall(M.typecheck, M.defaults))

return M
