local M = {}

M.choose_one = function (items, user)
  if #items == 1 and user.auto_use_only then
    return items[1]
  end

  local no_template = '<No template>'
  local select_choices = vim.deepcopy(items)
  if user.show_no_template then table.insert(select_choices, 1, no_template) end

  local user_choice = (function ()
    local temp

    vim.ui.select(select_choices, { prompt = '[spooky] Select template:' }, function (choice)
      if not (choice == nil or choice == no_template) then temp = choice end
    end)

    return temp
  end)

  return user_choice
end


return M

