local M = {}

-- Telescope picker to select a single item from a list
-- and return the selected item, or nil if none selected.
-- User should have Telescope dependency installed.
M.choose_one = function (items, user)
  assert(require 'telescope', 'Telescope is not installed')

  local opts = user.ui.telescope_opts
  local prompt = user.ui.prompt

  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  local choice

  pickers.new(opts, { prompt_title = prompt
                    , finder = finders.new_table { results = items }
                    , sorter = conf.generic_sorter(opts)
                    , attach_mappings = function (prompt_buf, _)
                        actions.select_default:replace(function ()
                          while true do
                            local selection = action_state.get_selected_entry()
                            if #selection == 0 then  -- no choice
                              break
                            elseif #selection == 1 then
                              choice = selection[1]
                              actions.close(prompt_buf)
                              break
                            else
                              vim.notify([[[spooky] Tbh I'm not sure how to do with multiple selections.
                              Please, just pick 1 for now.]], vim.log.levels.ERROR)
                            end
                          end
                        end)
                        return true
                      end
                    }):find()

  return choice
end

return M
