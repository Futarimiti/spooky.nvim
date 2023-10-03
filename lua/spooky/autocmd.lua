local M = {}

M.setup_autocmds = function (user)
  local group = vim.api.nvim_create_augroup('spooky', {})
  vim.api.nvim_create_autocmd( { 'VimEnter' }
                             , { group = group
                               , pattern = '*'
                               , callback = function (_)
                                   local win = vim.api.nvim_get_current_win()
                                   require('spooky.templates').maybe_insert(win, user, false)
                                 end
                               }
                             )
end

return M
