local M = {}

local readable = function (file)
  return vim.fn.filereadable(file) == 1
end

local exists_dir = function (dir)
  return vim.fn.isdirectory(dir) == 1
end

-- either: <specific_dir>/<basename>.skl (prioritised)
-- or:     <specific_dir>/<basename>/name.skl
local get_specific_templates = function (skeleton_dir, basename)
  local specific_dir = skeleton_dir .. '/specific'
  if not exists_dir(specific_dir) then return {} end

  local supposed_specific = specific_dir .. '/' .. basename .. '.skl'
  if readable(supposed_specific) then
    return { supposed_specific }
  end

  local supposed_specific_dir = specific_dir .. '/' .. basename
  local ret = {}
  for f in vim.fs.dir(supposed_specific_dir) do
    local fullname = supposed_specific_dir .. '/' .. f
    table.insert(ret, fullname)
  end

  return ret
end

-- either: <general_dir>/<ft>.skl (prioritised)
-- or:     <general_dir>/<ft>/name.skl
local get_general_templates = function (skeleton_dir, ft)
  local general_dir = skeleton_dir .. '/general'
  if not exists_dir(general_dir) then return {} end
  local supposed_general = general_dir .. '/' .. ft .. '.skl'
  if readable(supposed_general) then
    return { supposed_general }
  end

  local supposed_general_dir = general_dir .. '/' .. ft
  local ret = {}
  for f in vim.fs.dir(supposed_general_dir) do
    local fullname = supposed_general_dir .. '/' .. f
    table.insert(ret, fullname)
  end
  return ret
end

-- Given the filetype and filename,
-- find all templates that match them.
local get_templates = function (skeleton_dir, ft, basename)
  if not exists_dir(skeleton_dir) then
    vim.notify('[spooky] Directory *' .. skeleton_dir .. '* does not exist', vim.log.levels.ERROR)
    return {}
  end

  local specifics = get_specific_templates(skeleton_dir, basename)
  if specifics ~= {} then
    return specifics
  end

  return get_general_templates(skeleton_dir, ft)
end

-- Alternatively, use :0r
local write_to = function (buf, template)
  local lines = vim.fn.readfile(template)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

-- When no templates: insert nothing.
-- When one template: insert it.
-- When multiple templates: select one, then insert it.
local maybe_select_template = function (buf, templates, user)
  if vim.tbl_isempty(templates) then return end
  if #templates == 1 and user.auto_use_only then
    write_to(buf, templates[1])
  end

  local select_options = { '<No template>', unpack(templates) }

  vim.ui.select(select_options, { prompt = '[spooky] Select template:' }, function (choice)
    if choice == 0 then return end
    write_to(buf, templates[choice])
  end)
end

-- Find suitable templates for a buffer.
-- If any found, do insertion, which may be interactive;
-- If nothing found, or failed in determining ft, filename, etc., insert nothing.
M.maybe_insert = function (buf, user)
  local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  if ft == '' then return end
  local fullname = vim.api.nvim_buf_get_name(buf)
  if fullname == '' then return end

  local skeleton_dir = user.directory
  local basename = vim.fs.basename(fullname)

  local templates = get_templates(skeleton_dir, ft, basename)

  maybe_select_template(buf, templates, user)
end

return M
