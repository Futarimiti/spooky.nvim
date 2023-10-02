-- Using Telescope as selector with preview.

local M = {}

-- Telescope picker to select a single item from a list
-- and return the selected item, or nil if none selected.
-- User should have Telescope dependency installed.
M.choose_one = function (items, user, do_with_choice)
  assert(require 'telescope', 'Telescope is not installed')

  local opts = user.ui.telescope_opts
  local prompt = user.ui.prompt
  local previewer_prompt = user.ui.previewer_prompt
  local no_template = user.ui.no_template

  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local previewers = require('telescope.previewers')
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  local previewer = previewers.new_buffer_previewer
  { title = previewer_prompt
  , define_preview = function (self, entry, _)
      if entry == no_template then
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { '' })
      else
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { 'example', 'preview', 'screen' })
      end
    end
  }

  local telescope_choices = (function ()
    if not user.show_no_template then
      return items
    end

    local ret = {}
    table.insert(ret, no_template)
    for _, item in ipairs(items) do
      table.insert(ret, item)
    end
    return ret
  end)()

  pickers.new(opts, { prompt_title = prompt
                    , finder = finders.new_table { results = telescope_choices }
                    , sorter = conf.generic_sorter(opts)
                    , previewer = previewer
                    , attach_mappings = function (prompt_buf, _)
                        actions.select_default:replace(function ()
                          actions.close(prompt_buf)
                          local selection = action_state.get_selected_entry()
                          if #selection == 1 then
                            local choice = selection[1]
                            if choice == no_template then return end
                            do_with_choice(choice)
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

