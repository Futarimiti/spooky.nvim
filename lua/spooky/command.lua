local M = {}

M.setup_commands = function (user)
  vim.api.nvim_create_user_command('Spook', function (args)
    local win = vim.api.nvim_get_current_win()
    require('spooky.templates').maybe_insert(win, user, true, args.bang)
  end, { nargs = 0, bang = true })
end

return M
