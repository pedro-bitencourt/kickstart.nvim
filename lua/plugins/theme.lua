-- Reads omarchy's current theme neovim.lua as DATA (not a symlink).
-- Returns the theme plugin spec to lazy.nvim so it loads eagerly.
-- Filters out LazyVim/LazyVim to avoid import order warnings.

local omarchy_theme_file = vim.fn.expand '~/.config/omarchy/current/theme/neovim.lua'
local specs = {}

if vim.fn.filereadable(omarchy_theme_file) == 1 then
  local ok, theme_spec = pcall(dofile, omarchy_theme_file)
  if ok and type(theme_spec) == 'table' then
    local colorscheme = nil

    for _, spec in ipairs(theme_spec) do
      if type(spec) == 'table' then
        if spec.opts and spec.opts.colorscheme then
          colorscheme = spec.opts.colorscheme
        elseif spec[1] and spec[1] ~= 'LazyVim/LazyVim' then
          spec.lazy = false
          table.insert(specs, spec)
        end
      end
    end

    if colorscheme then
      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyDone',
        once = true,
        callback = function()
          vim.cmd.colorscheme(colorscheme)
        end,
      })
    end
  end
end

return specs
