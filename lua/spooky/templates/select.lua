local M = {}

-- Undoable.
-- Alternatively, use :0r
local write_to = function (buf, template)
  local lines = vim.fn.readfile(template)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

-- Keep track buffers we've already written to
local did_write = {}

M.maybe_select_template = function (buf, templates, user)
  if vim.tbl_contains(did_write, buf) or vim.tbl_isempty(templates) then return end

  if #templates == 1 and user.auto_use_only then
    write_to(buf, templates[1])
    table.insert(did_write, buf)
    return
  end

  local no_template = '<No template>'
  if user.show_no_template then table.insert(templates, 1, no_template) end

  vim.ui.select(templates, { prompt = '[spooky] Select template:' }, function (choice)
    if not (choice == nil or choice == no_template) then write_to(buf, choice) end
    table.insert(did_write, buf)
  end)
end


return M
