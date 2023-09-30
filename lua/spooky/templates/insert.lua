local M = {}

-- Undoable.
-- Alternatively, use :0r
M.insert_to = function (buf, lines)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

return M
