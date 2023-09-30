local M = {}

-- When no templates: insert nothing.
-- When one template: insert it.
-- When multiple templates: select one, then insert it.
-- Find suitable templates for a buffer.
-- If any found, do insertion, which may be interactive;
-- If nothing found, or failed in determining ft, filename, etc., insert nothing.
M.maybe_insert = function (buf, user)
  local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  if ft == '' then return end
  local fullname = vim.api.nvim_buf_get_name(buf)
  if fullname == '' then return end

  local skeleton_dir = user.directory
  local basename = vim.fs.basename(fullname)

  local templates = require('spooky.templates.get').get_templates(skeleton_dir, ft, basename)

  require('spooky.templates.select').maybe_select_template(buf, templates, user)
end

return M

