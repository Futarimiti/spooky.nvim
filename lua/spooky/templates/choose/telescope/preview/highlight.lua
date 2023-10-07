local M = {}

M.highlight = function (buf, previewer_buf, normalised)
  local util = require 'telescope.previewers.utils'
  if not normalised then
    util.regex_highlighter(previewer_buf, 'spooky')
    return
  end

  -- vim.filetype.match cannot detect on previewer_bufs
  local ft, _ = vim.filetype.match { buf = buf }
  if ft ~= nil then
    util.highlighter(previewer_buf, ft)
  end
end

return M
