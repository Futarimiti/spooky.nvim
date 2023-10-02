local M = {}

-- Keep track buffers we've already written to
local did_write = {}

M.maybe_choose_template = function (buf, templates, user)
  if vim.tbl_contains(did_write, buf) or vim.tbl_isempty(templates) then return end

  if #templates == 1 and user.auto_use_only then
    table.insert(did_write, buf)
    return templates[1]
  end

  local no_template = '<No template>'
  local select_choices = vim.deepcopy(templates)
  if user.show_no_template then table.insert(select_choices, 1, no_template) end

  local user_choice

  vim.ui.select(select_choices, { prompt = '[spooky] Select template:' }, function (choice)
    if not (choice == nil or choice == no_template) then user_choice = choice end
    table.insert(did_write, buf)
  end)

  return user_choice
end


return M
