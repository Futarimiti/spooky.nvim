local M = {}

M.place_cursor = function (win, pos)
  vim.api.nvim_win_set_cursor(win, pos)
end

return M
