local M = {}

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

  local get_templates = require('spooky.templates.get').get_templates
  local choose = require('spooky.templates.choose').choose
  local insert_to = require('spooky.templates.insert').insert_to
  local place_cursor = require('spooky.cursor').place_cursor
  local normalise = require('spooky.templates.normalisation').normalise
  local should_insert = require('spooky.templates.check').should_insert

  local should, reason = should_insert(win, forced)
  if not should then
    log('[spooky] cannot insert template for current window, reason: ' .. reason, vim.log.levels.WARN)
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  local basename = vim.fs.basename(vim.api.nvim_buf_get_name(buf))

  local templates = get_templates(user.directory, ft, basename)

  -- Cache of:
  -- [1] original template in lines
  -- [2] normalised template in lines
  -- [3] special bindings.
  -- normalised templates will be used in both preview and insertion
  -- so there's need to cache them
  local cache = {}
  local update = function (template_fullpath, c)
    if cache[template_fullpath] ~= nil then return end
    local lined_template = vim.fn.readfile(template_fullpath)
    local lined_normalised, special_binds = normalise(buf, lined_template)
    c[template_fullpath] = { lined_template, lined_normalised, special_binds }
  end

  -- Given a template path,
  -- a boolean normalise
  -- returns a normalised template IN LINES.
  local preview = function (template_fullpath, should_normalise)
    update(template_fullpath, cache)
    local original, normal, _ = unpack(cache[template_fullpath])
    return should_normalise and normal or original
  end

  local insert = function (template_fullpath)
    update(template_fullpath, cache)
    local _, lined_normalised, special_bindings = unpack(cache[template_fullpath])
    insert_to(buf, lined_normalised)
    place_cursor(win, special_bindings._cursor)
  end

  choose(forced, log, buf, templates, user, insert, preview)
end

return M

