local M = {}

local create_callback = function (user)
  return function (args)
    local fsize = vim.fn.getfsize(args.file)
    local emptyfile = fsize < 4
    if not emptyfile then return end

    require('spooky.templates').maybe_insert(args.buf, user)
  end
end

M.setup_autocmds = function (user)
  local group = vim.api.nvim_create_augroup('spooky', {})
  vim.api.nvim_create_autocmd( { 'BufWinEnter', 'BufReadPost', 'FileType' }
                             , { group = group
                               , pattern = '*'
                               , callback = create_callback(user)
                               }
                             )
end

return M
