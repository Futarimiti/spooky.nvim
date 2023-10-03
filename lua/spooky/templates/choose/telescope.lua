-- Using Telescope as selector with preview.

local M = {}

-- Telescope picker to select a single item from a list
-- and return the selected item, or nil if none selected.
-- User should have Telescope dependency installed.
M.choose_one = function (buf, fullpaths, user, do_with_choice)
  assert(require 'telescope', 'Telescope is not installed')

  local opts = user.ui.telescope_opts
  local prompt = user.ui.prompt
  local previewer_prompt = user.ui.previewer_prompt
  local no_template = user.ui.no_template
  local show_full = user.ui.select_full_path
  local show_no_template = user.ui.show_no_template

  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local previewers = require 'telescope.previewers'
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local util = require 'telescope.previewers.utils'

  -- Alright, so this could seem confusing, but there's good reason.
  -- `representation` is the list of filepaths, full or not full,
  -- that will be displayed in the picker as the options to choose from.
  -- `mappings` is a table whose keys are the options to choose from,
  -- and values are the full filepaths,
  -- except for the `no_template` option, which has no value.
  local representation, mappings = (function ()
    local ret, map = {}, {}
    for _, fullpath in ipairs(fullpaths) do
      local path = show_full and fullpath or vim.fn.fnamemodify(fullpath, ':t:r')
      table.insert(ret, path)
      map[path] = fullpath
    end
    if show_no_template then table.insert(ret, no_template) end
    return ret, map
  end)()

  local previewer = previewers.new_buffer_previewer
  { title = previewer_prompt
  , define_preview = function (self, entry, _)
      local entry_name = entry[1]
      if entry_name == no_template then
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { '' })
      else
        local fullpath = mappings[entry_name]
        local content = vim.fn.readfile(fullpath)
        local result = (function ()
          if user.ui.preview_normalised then
            local normalised, _ = require('spooky.templates.normalisation').normalise(buf, content)
            return normalised
          else
            return content
          end
        end)()
        if user.ui.preview_normalised then
          local ft, _ = vim.filetype.match { buf = self.state.bufnr, filename = vim.api.nvim_buf_get_name(buf) }
          if ft ~= nil then
            util.highlighter(self.state.bufnr, ft)
          end
        else
          util.regex_highlighter(self.state.bufnr, 'spooky')
        end
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, result)
      end
    end
  }

  pickers.new(opts, { prompt_title = prompt
                    , finder = finders.new_table { results = representation }
                    , sorter = conf.generic_sorter(opts)
                    , previewer = previewer
                    , attach_mappings = function (prompt_buf, _)
                        actions.select_default:replace(function ()
                          actions.close(prompt_buf)
                          local selection = action_state.get_selected_entry()
                          if #selection == 1 then
                            local choice = selection[1]
                            if choice == no_template then return end
                            do_with_choice(mappings[choice])
                          elseif #selection ~= 0 then
                            error [[[spooky] Tbh I'm not sure how to do with multiple selections.
                            Please, just pick 1 for now.]]
                          end
                        end)
                        return true
                      end
                    }):find()
end

return M

