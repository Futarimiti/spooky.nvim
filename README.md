# spooky.nvim

Another not-so-minimal plugin for skeleton templates,
heavily based on [`esqueleto`](https://github.com/cvigilv/esqueleto.nvim)
by Carlos Vigil-Vásquez. Thanks Carl.

## Why another?

Combined with advantages from multiple skeleton plugins, 
`spooky` aims to focus on both easy creating and managing skeleton templates.

Supports:
- [x] Specific or general templates
- [x] Multiple templates (choose at creation)
- [x] Variable interpolation
- [x] Cursor placement

## Installation

```lua
-- lazy.nvim
return { { 'Futarimiti/spooky.nvim' }
       , { 'Futarimiti/spooky.vim' }  -- syntax highlighting
       }
```

## Configuration

Default configuration:

```lua
require('spooky').setup { directory = vim.fn.stdpath('config') .. '/skeletons'
                        , case_sensitive = false
                        , auto_use_only = true
                        , show_no_template = true
                        }
```

## Usage

You will put your skeletons in a directory of your choice,
by default `vim.fn.stdpath('config') .. '/skeletons'`.
The structure of the directory should be as follows:

```
skeletons
├── general
│   ├── java.skl
│   └── python.skl
└── specific
    ├── main.py.skl
    └── test.py.skl -> main.py.skl
```

Where `general` and `specific` are the two types of skeletons.
Upon creation, `spooky` will look at the file name and 
try to match and use a specific skeleton.
If it can't find one, a general skeleton will be used instead
by filetype. Symlink skeletons are supported.

Multiple skeletons can be defined for a single pattern,
where you will be prompted to choose one.
For example license:

```
skeletons
└── specific
    └── LICENSE
        ├── Apache.skl
        ├── GNU-v3.skl
        ├── MIT.skl
        └── Unlicense.skl
```

Check [here](https://github.com/Futarimiti/graveyard?search=1) for my personal skeleton files hierarchy.

### Skeleton syntax

Skeleton templates are just regular files with the `.skl` extension.
Each template is divided into two sections: the preamble and the body.
Preambles are optional, so the following is a valid skeleton for Python:

```
def main():
    

if __name__ == '__main__':
    main()
```

The preamble comes to play when you want to use variable interpolation,
which is useful for things like namespaces, author names, etc.
It should be starting at the beginning of the template file,
finished by a line containing three or more dashes.

Say you want to add a module declaration
and a main function for a Haskell file,
here's what you could do:

```
return function (buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local basename = vim.fs.basename(name)
  return { module_name = basename:gsub('%.hs$', ''):gsub('^%l', string.upper)
         , _cursor = { 4, 6 }
         }
end
---
module ${module_name} where

main :: IO ()
main = 
```

If you haven't noticed, the preamble is just a lua function,
to be evaluated right before the insertion of template.
It accepts the buffer id for which the template is being inserted,
which should be suffice for most information about the file,
and in turn returns a table of variables to be substituted in the template.
Variables are interpolated by wrapping them in `${}`.

Some keys returned by the preamble function
are special and will be used by spooky:

* `_cursor`: ({row, col}) the (1,0)-indexed cursor position after inserting the template,
             as passed to `nvim_win_set_cursor`. So within the last example, the cursor
             will be placed right next to the equal sign to start typing the main function.

## Roadmap

`spooky` is currently, and might forever be in its infancy,
so please do expect breaking changes.
Things are still quite limited for now:
no documentation, no fancy ui, restricted customisation, etc.
Here are some of the things I would like to add later on
(with no order of priority):

- [ ] Doc
- [ ] Preview templates (e.g. with Telescope)
- [ ] Add `.skl` filetype plugin
- [ ] Greater customisation
- [ ] Improve existing user options
    - [ ] Reorganise
    - [ ] Redesign cursor placement?
- [ ] Polish on interpolation mechanism
- [ ] Project-specific templates?
- [ ] Preset templates?
- [ ] User command?

If you feel like you can help with any of these,
or have better ideas, contributions are welcome;
just open a PR and we'll get to work.
