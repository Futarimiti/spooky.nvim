-- The builtin selector (vim.ui.select).

local M = {}

M.choose_one = function (fullpaths, user, do_with_choice)
  local no_template = user.ui.no_template
  local show_full = user.ui.select_full_path
  local show_no_template = user.ui.show_no_template
  local representation, mappings = (function ()
    local ret, map = {}, {}
    for _, fullpath in ipairs(fullpaths) do
      local path = show_full and fullpath or vim.fn.fnamemodify(fullpath, ':t:r')
      table.insert(ret, path)
      map[path] = fullpath
    end
    if show_no_template then table.insert(ret, no_template) end
    return ret, map
  end)()

  vim.ui.select(representation, { prompt = user.ui.prompt }, function (choice, _)
    if choice == nil or choice == no_template then return end
    local fullpath = assert(mappings[choice])
    do_with_choice(fullpath)
  end)
end


return M


