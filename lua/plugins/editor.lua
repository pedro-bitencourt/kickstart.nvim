return {
  -- Automatically detect indentation style
  { 'NMAC427/guess-indent.nvim', opts = {} },

  { -- Visual undo history browser
    'mbbill/undotree',
    keys = {
      { '<leader>u', vim.cmd.UndotreeToggle, desc = '[U]ndo tree' },
    },
  },

  { -- VimTeX for LaTeX editing
    'lervag/vimtex',
    lazy = false, -- VimTeX relies on its own lazy loading on ft=tex
    init = function()
      -- VimTeX configuration goes here
      vim.g.vimtex_quickfix_mode = 1
      vim.g.vimtex_view_method = 'zathura'
      vim.g.vimtex_compiler_method = 'latexmk'

      -- Enable reverse search (Ctrl+click in Zathura jumps to source in Neovim).
      -- VimTeX needs a stable servername so Zathura can connect back via synctex.
      pcall(vim.fn.serverstart, '/tmp/nvim-vimtex.pipe')
    end,
    keys = {
      { ']]', '<plug>(vimtex-]])', desc = 'Next section', ft = 'tex' },
      { '[[', '<plug>(vimtex-[[)', desc = 'Previous section', ft = 'tex' },
      { '][', '<plug>(vimtex-][)', desc = 'Next section end', ft = 'tex' },
      { '[]', '<plug>(vimtex-[])', desc = 'Previous section end', ft = 'tex' },
    },
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    config = function()
      local filetypes = { 'bash', 'c', 'diff', 'html', 'latex', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'norg', 'python', 'query', 'r', 'vim', 'vimdoc' }
      require('nvim-treesitter').install(filetypes)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = filetypes,
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}
