-- Telescope theme picker with live preview
vim.keymap.set('n', '<leader>st', function()
  require('telescope.builtin').colorscheme {
    enable_preview = true,
    prompt_title = 'Switch Theme',
  }
end, { desc = '[S]witch [T]heme' })

return {}
