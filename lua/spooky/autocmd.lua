local M = {}

local create_callback = function (user)
  return function (args)
    local normal_buf = vim.api.nvim_buf_get_option(args.buf, 'buftype') == ''
    if not normal_buf then return end

    local fsize = vim.fn.getfsize(args.file)
    local emptyfile = fsize < 4
    if not emptyfile then return end

    require('spooky.templates').maybe_insert(user)
  end
end

M.setup_autocmds = function (user)
  local group = vim.api.nvim_create_augroup('spooky', {})
  vim.api.nvim_create_autocmd( { 'VimEnter' }
                             , { group = group
                               , pattern = '*'
                               , callback = create_callback(user)
                               }
                             )
end

return M
