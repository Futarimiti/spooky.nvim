local M = {}

-- When no templates: insert nothing.
-- When one template: insert it.
-- When multiple templates: select one, then insert it.
-- Find suitable templates for a buffer.
-- If any found, do insertion, which may be interactive;
-- If nothing found, or failed in determining ft, filename, etc., insert nothing.
M.maybe_insert = function (user)
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  if ft == '' then return end
  local fullname = vim.api.nvim_buf_get_name(buf)
  if fullname == '' then return end

  local skeleton_dir = user.directory
  local basename = vim.fs.basename(fullname)
  if basename == '' then return end

  local templates = require('spooky.templates.get').get_templates(skeleton_dir, ft, basename)

  local template_path = require('spooky.ui.select').select_using(user.ui.select, buf, templates, user)
  if template_path ~= nil then
    local lined_template = vim.fn.readfile(template_path)
    local lined_normalised, special_bindings = require('spooky.templates.normalisation').normalise(buf, lined_template)
    require('spooky.templates.insert').insert_to(buf, lined_normalised)
    require('spooky.templates.cursor').place_cursor(win, special_bindings._cursor)
  end
end

return M

