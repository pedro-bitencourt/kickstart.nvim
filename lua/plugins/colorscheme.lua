-- Theme engine: multiple themes, live preview via Telescope, persists selection
local theme_cache = vim.fn.stdpath 'data' .. '/theme.txt'

local function load_saved_theme()
  local f = io.open(theme_cache, 'r')
  if f then
    local theme = f:read '*l'
    f:close()
    return theme
  end
  return nil
end

local function save_theme(name)
  local f = io.open(theme_cache, 'w')
  if f then
    f:write(name)
    f:close()
  end
end

-- Apply saved theme on startup (after plugins load)
vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyDone',
  once = true,
  callback = function()
    local saved = load_saved_theme()
    pcall(vim.cmd.colorscheme, saved or 'tokyonight-night')
  end,
})

-- Theme picker keymap
vim.keymap.set('n', '<leader>st', function()
  require('telescope.builtin').colorscheme {
    enable_preview = true,
    prompt_title = 'Switch Theme',
    attach_mappings = function(_, map)
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      local function select_theme(prompt_bufnr)
        local selection = action_state.get_selected_entry(prompt_bufnr)
        actions.close(prompt_bufnr)
        if selection then
          save_theme(selection.value)
          vim.notify('Theme saved: ' .. selection.value)
        end
      end

      map('i', '<CR>', select_theme)
      map('n', '<CR>', select_theme)
      return true
    end,
  }
end, { desc = '[S]witch [T]heme' })

return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = { styles = { comments = { italic = false } } },
  },
  { 'catppuccin/nvim', name = 'catppuccin', lazy = false, priority = 1000 },
  { 'rose-pine/neovim', name = 'rose-pine', lazy = false, priority = 1000 },
  { 'rebelot/kanagawa.nvim', lazy = false, priority = 1000 },
  { 'EdenEast/nightfox.nvim', lazy = false, priority = 1000 },
  { 'sainnhe/gruvbox-material', lazy = false, priority = 1000 },
  { 'sainnhe/everforest', lazy = false, priority = 1000 },
  { 'navarasu/onedark.nvim', lazy = false, priority = 1000 },
  { 'Mofiqul/dracula.nvim', lazy = false, priority = 1000 },
}
