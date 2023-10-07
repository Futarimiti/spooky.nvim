local M = {}

local const = require 'spooky.consts'

-- Keep track buffers we've already written to
local did_write = {}

-- Given buffer of insertion,
-- list of filepaths to choose from,
-- user settings,
-- what to do after getting the choice,
-- and how to preview the choice (if supported),
-- prompt the user to choose one
-- only if the buffer hasn't been written to already (unless forced)
-- and there are one or more items to choose from.
-- Return the choice, or nil if no choice was made.
M.choose = function (forced, log, buf, filepaths, user, do_with_choice, preview)
  local ui = user.ui.select
  assert(vim.tbl_contains(const.ui_list, ui))
  if did_write[buf] and not forced then
    log('[spooky] template already written to this buffer (add ! to override)', vim.log.levels.WARN)
    return
  end

  if vim.tbl_isempty(filepaths) then
    log('[spooky] no templates available', vim.log.levels.WARN)
    return
  end

  if #filepaths == 1 and user.auto_use_only then
    do_with_choice(filepaths[1])
    return
  end

  if ui == 'builtin' then
    local builtin_choose_one = require('spooky.templates.choose.builtin').choose_one
    builtin_choose_one(filepaths, user, function (x)
      do_with_choice(x)
      did_write[buf] = true
    end)
  else
    local telescope_choose_one = require('spooky.templates.choose.telescope').choose_one
    telescope_choose_one(buf, filepaths, user, function (x)
      do_with_choice(x)
      did_write[buf] = true
    end, preview)
  end
end

return M

