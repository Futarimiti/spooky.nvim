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


