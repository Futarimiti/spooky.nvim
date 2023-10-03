local M = {}

local const = require 'spooky.consts'

M.defaults = { directory = vim.fn.stdpath('config') .. '/skeletons'
             , case_sensitive = false
             , auto_use_only = true
             , ui = { select = 'builtin'
                    , select_full_path = false
                    , show_no_template = true
                    , prompt = 'Select template'
                    , previewer_prompt = 'Preview'
                    , preview_normalised = true
                    , no_template = '<No template>'
                    , telescope_opts = {}
                    }
             }

-- Panics when the typecheck fails.
M.typecheck = function (config)
  vim.validate { directory = { config.directory, 'string' }
               , case_sensitive = { config.case_sensitive, 'boolean' }
               , auto_use_only = { config.auto_use_only, 'boolean' }
               , ui = { config.ui, 'table' }
               , ['ui.select'] = { config.ui.select, function (ui) return vim.tbl_contains(const.ui_list, ui) end }
               , ['ui.select_full_path'] = { config.ui.select_full_path, 'boolean' }
               , ['ui.show_no_template'] = { config.ui.show_no_template, 'boolean' }
               , ['ui.prompt'] = { config.ui.prompt, 'string' }
               , ['ui.previewer_prompt'] = { config.ui.previewer_prompt, 'string' }
               , ['ui.preview_normalised'] = { config.ui.preview_normalised, 'boolean' }
               , ['ui.no_template'] = { config.ui.no_template, 'string' }
               , ['ui.telescope_opts'] = { config.ui.telescope_opts, 'table' }
               }
end

-- sanity check
assert(pcall(M.typecheck, M.defaults))

return M
