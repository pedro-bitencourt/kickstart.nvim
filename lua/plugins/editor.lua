return {
  -- Automatically detect indentation style
  { 'NMAC427/guess-indent.nvim', opts = {} },

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
      vim.fn.serverstart '/tmp/nvim-vimtex.pipe'

      -- Optional: Disable conceal if you prefer seeing the raw LaTeX commands
      -- vim.g.tex_conceal = ''
    end,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    config = function()
      local filetypes = { 'bash', 'c', 'diff', 'html', 'latex', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
      require('nvim-treesitter').install(filetypes)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = filetypes,
        callback = function() vim.treesitter.start() end,
      })
    end,
  },
}
