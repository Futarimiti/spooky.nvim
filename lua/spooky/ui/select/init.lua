local M = {}

local const = require 'spooky.consts'

-- Keep track buffers we've already written to
local did_write = {}

-- Given the ui of select menu,
-- buffer of insertion,
-- list of items to choose from
-- and user settings,
-- prompt the user to choose one
-- only if the buffer hasn't been written to already
-- and there are one or more items to choose from.
-- Return the choice, or nil if no choice was made.
M.select_using = function (ui, buf, items, user)
  assert(vim.tbl_contains(const.ui_list, ui))
  if did_write[buf] or vim.tbl_isempty(items) then
    return
  end

  local chosen = (function ()
    if ui == 'builtin' then
      return require('spooky.ui.select.builtin').choose_one(items, user)
    else
      return require('spooky.ui.select.telescope').choose_one(items, user)
    end
  end)()

  did_write[buf] = true

  return chosen
end

return M
