local M = {}

local put_lines = function (buf, lines)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

local create_preview = function (buf, user, mappings, preview)
  local highlight = require('spooky.templates.choose.telescope.preview.highlight').highlight
  local no_template = user.ui.no_template
  local define_preview = function (self, entry, _)
    local entry_name = entry[1]
    local selected_no_template = entry_name == no_template
    local preview_buf = self.state.bufnr

    if selected_no_template then
      put_lines(preview_buf, { '' })
      return
    end

    local fullpath = mappings[entry_name]
    local should_normalise = user.ui.preview_normalised
    local should_highlight = user.ui.highlight_preview
    local result = preview(fullpath, should_normalise)

    put_lines(preview_buf, result)
    if should_highlight then highlight(buf, preview_buf, should_normalise) end
  end
  return define_preview
end

M.create_previewer = function (buf, user, mappings, preview)
  local previewer_prompt = user.ui.previewer_prompt
  local previewers = require 'telescope.previewers'
  return previewers.new_buffer_previewer
  { title = previewer_prompt
  , define_preview = create_preview(buf, user, mappings, preview)
  }
end

return M
