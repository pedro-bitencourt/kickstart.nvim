return {
  {
    name = 'theme-hotreload',
    dir = vim.fn.stdpath 'config',
    lazy = false,
    priority = 1000,
    config = function()
      local omarchy_theme_file = vim.fn.expand '~/.config/omarchy/current/theme/neovim.lua'
      local transparency_file = vim.fn.stdpath 'config' .. '/plugin/after/transparency.lua'

      local function apply_omarchy_theme()
        if vim.fn.filereadable(omarchy_theme_file) ~= 1 then
          return
        end
        local ok, theme_spec = pcall(dofile, omarchy_theme_file)
        if not ok or type(theme_spec) ~= 'table' then
          return
        end

        local colorscheme = nil
        for _, spec in ipairs(theme_spec) do
          if type(spec) == 'table' and spec.opts and spec.opts.colorscheme then
            colorscheme = spec.opts.colorscheme
            break
          end
        end

        if not colorscheme then
          return
        end

        -- Remember current colorscheme so we can restore on failure
        local prev = vim.g.colors_name

        local applied, err = pcall(vim.cmd.colorscheme, colorscheme)
        if not applied then
          vim.notify('Theme hotreload: "' .. colorscheme .. '" not available', vim.log.levels.WARN)
          -- Restore previous theme to avoid black & white fallback
          if prev then
            pcall(vim.cmd.colorscheme, prev)
          end
          return
        end

        if vim.fn.filereadable(transparency_file) == 1 then
          vim.defer_fn(function()
            pcall(vim.cmd.source, transparency_file)
          end, 10)
        end
      end

      -- Watch ~/.config/omarchy/current/ for theme directory swaps.
      -- omarchy-theme-set does: rm -rf current/theme, then mv next-theme -> theme
      -- On Linux, uv_fs_event ignores recursive=true, so we watch the parent dir
      -- which sees the subdirectory delete + rename events.
      -- Debounce to let the swap complete before reading the new theme file.
      local theme_dir = vim.fn.expand '~/.config/omarchy/current'
      local debounce_timer = vim.uv.new_timer()
      local w = vim.uv.new_fs_event()
      if w and debounce_timer then
        w:start(theme_dir, {}, function(err)
          if err then
            return
          end
          -- Debounce: reset timer on each event, apply 200ms after last event
          debounce_timer:stop()
          debounce_timer:start(200, 0, function()
            vim.schedule(apply_omarchy_theme)
          end)
        end)
      end

      -- Also support manual trigger via LazyReload
      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyReload',
        callback = function()
          vim.schedule(apply_omarchy_theme)
        end,
      })
    end,
  },
}
