local M = {}

-- Should we perform insertion for this window?
-- Returns result and reason if false.
M.should_insert = function (win, forced)
  local buf = vim.api.nvim_win_get_buf(win)

  local normal_buf = vim.api.nvim_buf_get_option(buf, 'buftype') == ''
  if not normal_buf and not forced then return false, 'buftype is not empty (add ! to override)' end

  local fullname = vim.api.nvim_buf_get_name(buf)
  if fullname == '' then return false, 'not a valid file (no name)' end

  -- prevent those with invalid filenames
  -- e.g. checkhealth
  local basename = vim.fs.basename(fullname)
  if basename == '' then return false, 'not a valid file (no basename)' end

  local fsize = vim.fn.getfsize(fullname)
  local emptyfile = fsize < 4
  if not emptyfile and not forced then return false, 'file not empty (add ! to override)' end

  return true, nil
end

return M
