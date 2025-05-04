return {
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*', -- Recommended for latest features
    dependencies = {
      'rafamadriz/friendly-snippets', -- Optional: pre-made snippets
    },
    config = function()
      -- Basic setup
      local ls = require 'luasnip'
      local types = require 'luasnip.util.types'

      ls.config.set_config {
        history = true,
        updateevents = 'TextChanged,TextChangedI', -- Important for autosnippets
        enable_autosnippets = true, -- Enable autosnippets
        ext_opts = {
          [types.insertNode] = {
            unvisited = {
              virt_text = { { '●', 'Comment' } }, -- Visual hint for placeholders
            },
          },
        },
      }

      -- Load custom snippets from your directory
      require('luasnip.loaders.from_lua').lazy_load {
        paths = '~/.config/nvim/lua/luasnip',
      }

      -- Keybindings
      vim.keymap.set({ 'i', 's' }, '<Tab>', function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, true, true), 'n', false)
        end
      end)
    end,
  },
}
