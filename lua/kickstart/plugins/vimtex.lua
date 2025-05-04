return {
  {

    'lervag/vimtex',
    lazy = false, -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- VimTeX configuration goes here, e.g.
      vim.g.vimtex_view_general_viewer = 'okular'
      vim.gvimtex_view_general_options = '--unique file:@pdf\\#src:@line@tex'
      vim.g.maplocalleader = ','
      vim.keymap.set('n', '<F5>', ':w<CR>:VimtexCompile<CR>', {
        buffer = true, -- Make it buffer-local (like <localleader>)
      })
    end,
  },
}
