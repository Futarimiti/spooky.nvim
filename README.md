# spooky.nvim

Another not-so-minimal plugin for skeleton templates,
based on and extending the idea of
[esqueleto.nvim](https://github.com/cvigilv/esqueleto.nvim)
by Carlos Vigil-Vásquez. Thanks Carl.

## Why another?

Combined with advantages from multiple skeleton plugins, 
`spooky` aims to focus on both easy creating and managing skeleton templates.

Supports:
- [x] Specific or general templates
- [x] Multiple templates (choose at creation)
- [x] Embedding logic inside templates
- [x] Cursor placement
- [x] Syntax highlighting for templates (yet basic)
- [x] Telescope preview for interpolated, syntax highlighted templates
- [x] User command to manually invoke Spooky
- [x] Auto-generated doc if you are on [lazy.nvim](https://github.com/folke/lazy.nvim)

![usage](https://github.com/Futarimiti/spooky.nvim/assets/96031125/887ed485-6210-49ae-a053-33532e0a0a36)

## Installation

```lua
-- lazy.nvim
return
{ 'Futarimiti/spooky.nvim'
-- if you'd like to use Telescope picker for templates
, dependencies = { 'nvim-telescope/telescope.nvim' }
, opts = {...}
}
```

## Configuration

Default configuration:

```lua
require('spooky').setup { directory = vim.fn.stdpath('config') .. '/skeletons'
                        , case_sensitive = false
                        , auto_use_only = true
                        , ui = { select = 'builtin'
                               , select_full_path = false
                               , show_no_template = true
                               , prompt = 'Select template'
                               , previewer_prompt = 'Preview'
                               , preview_normalised = true
                               , no_template = '<No template>'
                               , telescope_opts = {}
                               }
                        }
```

To use Telescope for template selection,
make Telescope a dependency and set `ui.select` to `'telescope'`.

Full description of the options:

| option                  | type    | desc                                                                                               |
|-------------------------|---------|----------------------------------------------------------------------------------------------------|
| `directory`             | string  | Path to skeletons directory                                                                        |
| `case_sensitive`        | boolean | Whether to match skeletons case sensitively (WIP)                                                  |
| `auto_use_only`         | boolean | Whether to only use auto-inserted skeletons when only 1 available                                  |
| `ui.select`             | string  | UI to use for selecting templates, one of `'builtin'` and `'telescope'`                            |
| `ui.select_full_path`   | boolean | Whether to show full templates paths or basenames in selection UI                                  |
| `ui.show_no_template`   | boolean | Whether to show "no template" as a possible choice                                                 |
| `ui.prompt`             | string  | Prompt for selecting templates                                                                     |
| `ui.previewer_prompt`   | string  | Prompt for previewing templates (Telescope only)                                                   |
| `ui.preview_normalised` | boolean | Whether to show normalised template in preview (Telescope only)                                    |
| `ui.no_template`        | string  | String for `show_no_template`                                                                      |
| `ui.telescope_opts`     | table   | Options to be passed to the picker, e.g. `require('telescope.themes').get_ivy {}` (Telescope only) |

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
no documentation, no very-fancy ui, restricted customisation, etc.
Here are some of the things I would like to add later on[^1]
(with no order of priority):

- [ ] Greater customisation
- [ ] Improve existing user options
    - [ ] Reorganise
    - [ ] Redesign cursor placement?
- [ ] Polish on interpolation mechanism
- [ ] Project-specific templates?
- [ ] Preset templates?
- [ ] Make command more useful
- [ ] Vimdoc?

[^1]: Those with question marks might not be implemented

If you feel like you can help with any of these,
or have better ideas, contributions are welcome;
just open a PR and we'll get to work.
