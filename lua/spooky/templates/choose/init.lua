local M = {}

local const = require 'spooky.consts'

-- Keep track buffers we've already written to
local did_write = {}

-- Given buffer of insertion,
-- list of filepaths to choose from,
-- user settings,
-- and what to do after getting the choice,
-- prompt the user to choose one
-- only if the buffer hasn't been written to already
-- and there are one or more items to choose from.
-- Return the choice, or nil if no choice was made.
M.choose = function (buf, filepaths, user, do_with_choice)
  local ui = user.ui.select
  assert(vim.tbl_contains(const.ui_list, ui))
  if did_write[buf] or vim.tbl_isempty(filepaths) then
    return
  end

  if #filepaths == 1 and user.auto_use_only then
    return filepaths[1]
  end

  if ui == 'builtin' then
    require('spooky.templates.choose.builtin').choose_one(filepaths, user, function (x)
      do_with_choice(x)
      did_write[buf] = true
    end)
  else
    require('spooky.templates.choose.telescope').choose_one(filepaths, user, function (x)
      do_with_choice(x)
      did_write[buf] = true
    end)
  end
end

return M

