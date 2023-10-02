local M = {}

M.choose_one = function (items, user, do_with_choice)
  local no_template = user.ui.no_template
  local select_choices = vim.deepcopy(items)
  if user.show_no_template then table.insert(select_choices, 1, no_template) end

  vim.ui.select(select_choices, { prompt = user.ui.prompt }, function (choice)
    if not (choice == nil or choice == no_template) then do_with_choice(choice) end
  end)
end


return M


