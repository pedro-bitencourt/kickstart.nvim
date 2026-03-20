-- Build function that compiles a tree-sitter parser from source and installs it.
-- Works with nvim 0.11+ where the legacy TSInstall command is unavailable.
-- Handles mixed C/C++ sources by compiling each file with the correct compiler.
local function build_parser(parser_name, source_files)
  return function(plugin)
    local src_dir = plugin.dir .. '/src'
    local parser_dir = vim.fn.stdpath('data') .. '/site/parser'
    vim.fn.mkdir(parser_dir, 'p')

    local output = parser_dir .. '/' .. parser_name .. '.so'
    local cc = vim.fn.has('mac') == 1 and 'cc' or 'gcc'
    local cxx = vim.fn.has('mac') == 1 and 'c++' or 'g++'
    local has_cxx = false
    local obj_files = {}

    -- Compile each source file with the appropriate compiler
    for _, f in ipairs(source_files) do
      local src = src_dir .. '/' .. f
      local obj = src_dir .. '/' .. f:gsub('%.[^.]+$', '.o')
      table.insert(obj_files, obj)

      local is_cxx = f:match('%.cc$') or f:match('%.cpp$') or f:match('%.cxx$')
      if is_cxx then has_cxx = true end

      local compiler = is_cxx and cxx or cc
      vim.fn.system({ compiler, '-c', '-fPIC', '-O2', '-I', src_dir, src, '-o', obj })
      if vim.v.shell_error ~= 0 then
        vim.notify('Failed to compile ' .. f .. ' for ' .. parser_name, vim.log.levels.ERROR)
        return
      end
    end

    -- Link all object files into a shared library
    local linker = has_cxx and cxx or cc
    local link_cmd = { linker, '-shared', '-o', output }
    vim.list_extend(link_cmd, obj_files)
    vim.fn.system(link_cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify('Failed to link ' .. parser_name .. ' parser', vim.log.levels.ERROR)
    end

    -- Clean up object files
    for _, obj in ipairs(obj_files) do
      os.remove(obj)
    end
  end
end

return {
  'nvim-neorg/neorg',
  lazy = false,
  version = '*',
  dependencies = {
    {
      'nvim-neorg/tree-sitter-norg',
      build = build_parser('norg', { 'parser.c', 'scanner.cc' }),
    },
    {
      'nvim-neorg/tree-sitter-norg-meta',
      build = build_parser('norg_meta', { 'parser.c' }),
    },
    {
      '3rd/image.nvim',
      opts = {},
    },
  },
  config = function()
    -- Treesitter-based folding and Tab toggle for norg files
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'norg',
      callback = function()
        vim.wo.foldmethod = 'expr'
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.wo.foldlevel = 99 -- start with everything open
        vim.keymap.set('n', '<Tab>', 'za', { buffer = true, desc = 'Toggle fold' })
      end,
    })

    -- Ensure the highlight has an fg attribute so core.latex.renderer doesn't crash
    local normal_fg = vim.api.nvim_get_hl(0, { name = 'Normal', link = false }).fg or 0xc0c0c0
    vim.api.nvim_set_hl(0, '@neorg.rendered.latex', { fg = normal_fg })

    require('neorg').setup({
      load = {
        ['core.defaults'] = {},
        ['core.concealer'] = {},
        ['core.integrations.treesitter'] = {
          config = {
            configure_parsers = false,
            install_parsers = false,
          },
        },
        ['core.dirman'] = {
          config = {
            workspaces = {
              notes = '~/notes',
            },
            default_workspace = 'notes',
            index = 'index.norg',
          },
        },
        ['core.integrations.image'] = {},
        ['core.latex.renderer'] = {
          config = {
            conceal = true,
            render_on_enter = true,
          },
        },
      },
    })
  end,
}
