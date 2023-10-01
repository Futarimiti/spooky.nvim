local M = {}

local readable = function (file)
  return vim.fn.filereadable(file) == 1
end

local exists_dir = function (dir)
  return vim.fn.isdirectory(dir) == 1
end

-- either: <specific_dir>/<basename>.skl (prioritised)
-- or:     <specific_dir>/<basename>/name.skl
-- where <basename> must not be empty
local get_specific_templates = function (skeleton_dir, basename)
  if basename == '' then return {} end
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
  if ft == '' then return {} end
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
M.get_templates = function (skeleton_dir, ft, basename)
  if not exists_dir(skeleton_dir) then
    vim.notify('[spooky] Directory *' .. skeleton_dir .. '* does not exist', vim.log.levels.ERROR)
    return {}
  end

  local specifics = get_specific_templates(skeleton_dir, basename)
  if not vim.tbl_isempty(specifics) then
    return specifics
  end

  return get_general_templates(skeleton_dir, ft)
end

return M
