local M = {}

M.create_mappings = function (user, insert, mappings)
  local no_template = user.ui.no_template
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  return function (prompt_buf, _)
    actions.select_default:replace(function ()
      actions.close(prompt_buf)
      local selection = action_state.get_selected_entry()
      if #selection == 1 then
        local choice = selection[1]
        if choice == no_template then return end
        insert(mappings[choice])
      elseif #selection ~= 0 then
        error [[[spooky] Tbh I'm not sure how to do with multiple selections.
        Please, just pick 1 for now.]]
      end
    end)
    return true
  end
end

return M
