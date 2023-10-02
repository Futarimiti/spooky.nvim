local M = {}

local const = require 'spooky.consts'

M.defaults = { directory = vim.fn.stdpath('config') .. '/skeletons'
             , case_sensitive = false
             , auto_use_only = true
             , show_no_template = true
             , ui = { select = 'builtin'
                    , prompt = 'Select template'
                    , no_template = '<No template>'
                    , telescope_opts = {}
                    }
             }

-- Panics when the typecheck fails.
M.typecheck = function (config)
  vim.validate { directory = { config.directory, 'string' }
               , case_sensitive = { config.case_sensitive, 'boolean' }
               , auto_use_only = { config.auto_use_only, 'boolean' }
               , show_no_template = { config.show_no_template, 'boolean' }
               , ui = { config.ui, 'table' }
               , ['ui.prompt'] = { config.ui.prompt, 'string' }
               , ['ui.select'] = { config.ui.select, function (ui) return vim.tbl_contains(const.ui_list, ui) end }
               , ['ui.no_template'] = { config.ui.no_template, 'string' }
               , ['ui.telescope_opts'] = { config.ui.telescope_opts, 'table' }
               }
end

-- sanity check
assert(pcall(M.typecheck, M.defaults))

return M
