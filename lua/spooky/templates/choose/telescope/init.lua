-- Using Telescope as selector with preview.

local M = {}

-- Telescope picker to select a single item from a list
-- and return the selected item, or nil if none selected.
-- User should have Telescope dependency installed.
M.choose_one = function (buf, fullpaths, user, insert, preview)
  assert(require 'telescope', 'Telescope is not installed')

  local opts = user.ui.telescope_opts
  local prompt = user.ui.prompt

  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values

  -- `mappings`: from picker opts to full filepaths, except `no_template`
  local picker_opts, mappings = require('spooky.templates.choose.telescope.entries').gen_entry(fullpaths, user)
  local previewer = require('spooky.templates.choose.telescope.preview').create_previewer(buf, user, mappings, preview)
  local attach_mappings = require('spooky.templates.choose.telescope.mappings').create_mappings(user, insert, mappings)

  pickers.new(opts, { prompt_title = prompt
                    , finder = finders.new_table { results = picker_opts }
                    , sorter = conf.generic_sorter(opts)
                    , previewer = previewer
                    , attach_mappings = attach_mappings
                    }):find()
end

return M

