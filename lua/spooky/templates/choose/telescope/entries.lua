local M = {}

M.gen_entry = function (fullpaths, user)
  local show_full = user.ui.select_full_path
  local show_no_template = user.ui.show_no_template
  local no_template = user.ui.no_template

  local ret, map = {}, {}
  for _, fullpath in ipairs(fullpaths) do
    local path = show_full and fullpath or vim.fn.fnamemodify(fullpath, ':t:r')
    table.insert(ret, path)
    map[path] = fullpath
  end
  if show_no_template then table.insert(ret, no_template) end
  return ret, map
end

return M
