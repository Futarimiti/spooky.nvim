local M = {}

-- Should we perform insertion for this window?
local should_insert = function (win)
  local buf = vim.api.nvim_win_get_buf(win)

  local normal_buf = vim.api.nvim_buf_get_option(buf, 'buftype') == ''
  if not normal_buf then return false end

  -- not really necessary
  -- local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  -- if ft == '' then return false end

  local fullname = vim.api.nvim_buf_get_name(buf)
  if fullname == '' then return false end

  -- prevent those with invalid filenames
  -- e.g. checkhealth
  local basename = vim.fs.basename(fullname)
  if basename == '' then return false end

  local fsize = vim.fn.getfsize(fullname)
  local emptyfile = fsize < 4
  if not emptyfile then return false end

  return true
end

-- First check if we should insert, then:
-- When no templates: insert nothing.
-- When one template: depends on user opts
-- When multiple templates: select one, then insert it.
-- Find suitable templates for a buffer.
-- If any found, do insertion, which may be interactive;
-- If nothing found, or failed in determining ft, filename, etc., insert nothing.
M.maybe_insert = function (win, user)
  if not should_insert(win) then return end

  local buf = vim.api.nvim_win_get_buf(win)
  local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  local fullname = vim.api.nvim_buf_get_name(buf)
  local basename = vim.fs.basename(fullname)

  local templates = require('spooky.templates.get').get_templates(user.directory, ft, basename)

  require('spooky.templates.choose').choose(buf, templates, user, function (template_path)
    local lined_template = vim.fn.readfile(template_path)
    local lined_normalised, special_bindings = require('spooky.templates.normalisation').normalise(buf, lined_template)
    require('spooky.templates.insert').insert_to(buf, lined_normalised)
    require('spooky.templates.cursor').place_cursor(win, special_bindings._cursor)
  end)
end

return M

