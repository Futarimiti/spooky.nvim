local M = {}

local const = require 'spooky.consts'

M.defaults = { directory = vim.fn.stdpath('config') .. '/skeletons'
             , case_sensitive = false
             , auto_use_only = true
             , show_no_template = true
             , ui = { select = 'builtin' }
             }

-- Panics when the typecheck fails.
M.typecheck = function (config)
  vim.validate { directory = { config.directory, 'string' }
               , case_sensitive = { config.case_sensitive, 'boolean' }
               , auto_use_only = { config.auto_use_only, 'boolean' }
               , show_no_template = { config.show_no_template, 'boolean' }
               , ui = { config.ui, 'table' }
               , ['ui.select'] = { config.ui.select, function (ui) return vim.tbl_contains(const.ui_list, ui) end }
               }
end

-- sanity check
assert(pcall(M.typecheck, M.defaults))

return M
