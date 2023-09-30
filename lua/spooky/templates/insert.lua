local M = {}

-- Undoable.
-- Alternatively, use :0r
M.insert_to = function (buf, template)
  local lines = vim.fn.readfile(template)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

return M
