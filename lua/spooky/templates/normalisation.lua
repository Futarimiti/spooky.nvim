local M = {}

-- Accept template content in lines, return normalised lines.
--[[
# NORMALISE RULES

A template file is either:
* entirely a template (just put the template as-is)
* preamble + template, where template may contain contents to be substituted.

## Format

### Preamble

A preamble is optional and should be starting at the beginning of the template file,
finished by a line containing three or more dashes.
It's nothing but lua code, and is executed before the template is processed.
It should return a function that accepts a buffer id,
and in turn, returns a table of variables to be substituted in the template.

Example use - Java class name
```
return function (buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local basename = vim.fs.basename(name)
  return { class_name = basename:gsub('%.java$', ''):gsub('^%l', string.upper) }
end
---
public class ${class_name}
{
    
}
```

Some keys are special and will be used by spooky:
* `_cursor`: ({row, col}) the (1,0)-indexed cursor position after inserting the template,
             as passed to `nvim_win_set_cursor`.
             So using the last example, you can write:
  ```
  return function (buf)
    local name = vim.api.nvim_buf_get_name(buf)
    local basename = vim.fs.basename(name)
    return { class_name = basename:gsub('%.java$', ''):gsub('^%l', string.upper)
           , _cursor = { 3, 3 }
           }
  end
  ---
  public class ${class_name}
  {
      
  }
  ```

  Which will produce:
  ```
  public class ${class_name}
  {
     █
  }
  ```

---

The preamble could be empty.
In this case, the line of dashes at the beginning is optional,
and will be ignored if present.
The rest of the content will be considered as the template.
This is useful for certain filetypes, such as yaml.

### Template

The template section may embed variables to be substituted,
using syntax `${variable}`.
If you need to use `${...}` literally, simply use a variable for it:

```
return function (buf)
  return { _ = '${literal}' }
end
---
here's your "${_}"
```
]]

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

-- Split the content into preamble
-- and lines that are template.
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

local interpolate = function (bindings, template)
  return vim.tbl_map(function (line)
    return line:gsub('${([^}]+)}', function (var)
      local res = bindings[var] or error('[spooky] Variable ' .. var .. ' not found in preamble bindings')
      return tostring(res)
    end)
  end, template)
end

M.normalise = function (buf, lined_content)
  local preamble, template = parse(lined_content)
  local bindings = get_bindings(preamble, buf)
  local normalised = interpolate(bindings, template)
  local special = { _cursor = bindings._cursor or { 1, 0 } }
  return normalised, special
end

return M
