-- The builtin selector (vim.ui.select).

local M = {}

M.choose_one = function (fullpaths, user, do_with_choice)
  local no_template = user.ui.no_template
  local show_full = user.ui.select_full_path
  local show_no_template = user.show_no_template
  local representation = (function ()
    local ret = {}
    for _, fullpath in ipairs(fullpaths) do
      local path = show_full and fullpath or vim.fn.fnamemodify(fullpath, ':t:r')
      table.insert(ret, path)
    end
    if show_no_template then table.insert(ret, no_template) end
    return ret
  end)()

  vim.ui.select(representation, { prompt = user.ui.prompt }, function (choice, idx)
    if choice == nil or choice == no_template then return end
    local fullpath = fullpaths[idx]
    do_with_choice(fullpath)
  end)
end


return M


