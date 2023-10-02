local M = {}

-- Given the preamble, retrieve the bindings
-- by evaluating the lua code.
local get_bindings = function (preamble_text, buf)
  local preamble = assert(loadstring(preamble_text))()
  if type(preamble) == 'nil' then return {} end
  assert(type(preamble) == 'function', '[spooky] Preamble should return a function')
  local res = preamble(buf)
  assert(type(res) == 'table', '[spooky] Preamble function should return a table')
  return res
end

-- Split the content into preamble (unlined)
-- and the template (lined).
local parse = function (lined_content)
  local preamble, template = '', {}
  local in_preamble = true
  for _, line in ipairs(lined_content) do
    if in_preamble then
      if line:match('^%s*%-%-%-%-*%s*$') then
        in_preamble = false
      else
        preamble = preamble .. line .. '\n'
      end
    else
      table.insert(template, line)
    end
  end
  if in_preamble then
    return '', lined_content
  end

  return preamble, template
end

-- Substitute the variables in the template
-- with the values from the bindings.
-- If a variable is not found, raise an error.
local interpolate = function (bindings, template)
  return vim.tbl_map(function (line)
    return line:gsub('${([^}]+)}', function (var)
      local res = bindings[var] or error('[spooky] Variable ' .. var .. ' not found in preamble bindings')
      return tostring(res)
    end)
  end, template)
end

-- Accept the whole content in lines,
-- return [1] normalised lines and [2] special data.
M.normalise = function (buf, lined_content)
  local preamble, template = parse(lined_content)
  local bindings = get_bindings(preamble, buf)
  local normalised = interpolate(bindings, template)
  local special = { _cursor = bindings._cursor or { 1, 0 } }
  return normalised, special
end

return M
