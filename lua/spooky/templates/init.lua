local M = {}

-- Should we perform insertion for this window?
-- Returns result and reason if false.
local should_insert = function (win)
  local buf = vim.api.nvim_win_get_buf(win)

  local normal_buf = vim.api.nvim_buf_get_option(buf, 'buftype') == ''
  if not normal_buf then return false, 'buftype is not empty' end

  local fullname = vim.api.nvim_buf_get_name(buf)
  if fullname == '' then return false, 'not a valid file (no name)' end

  -- prevent those with invalid filenames
  -- e.g. checkhealth
  local basename = vim.fs.basename(fullname)
  if basename == '' then return false, 'not a valid file (no basename)' end

  local fsize = vim.fn.getfsize(fullname)
  local emptyfile = fsize < 4
  if not emptyfile then return false, 'file not empty' end

  return true, nil
end

-- First check if we should insert, then:
-- When no templates: insert nothing.
-- When one template: depends on user opts
-- When multiple templates: select one, then insert it.
-- Find suitable templates for a buffer.
-- If any found, do insertion, which may be interactive;
-- If nothing found, or failed in determining ft, filename, etc., insert nothing.
---@param by_user boolean is this called by the user or by autocmd? if yes, be verbose.
---@param forced boolean force insertion, regardless of whether this buffer has been inserted
M.maybe_insert = function (win, user, by_user, forced)
  local log = function (...)
    if not by_user then return end
    vim.notify(...)
  end

  local should, reason = should_insert(win)
  if not should then
    log('[spooky] cannot insert template for current window, reason: ' .. reason, vim.log.levels.WARN)
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  local basename = vim.fs.basename(vim.api.nvim_buf_get_name(buf))

  local templates = require('spooky.templates.get').get_templates(user.directory, ft, basename)

  require('spooky.templates.choose').choose(forced, log, buf, templates, user, function (template_path)
    local lined_template = vim.fn.readfile(template_path)
    local lined_normalised, special_bindings = require('spooky.templates.normalisation').normalise(buf, lined_template)
    require('spooky.templates.insert').insert_to(buf, lined_normalised)
    require('spooky.templates.cursor').place_cursor(win, special_bindings._cursor)
  end)
end

return M

