vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- [[ Setting options ]]
require 'options'
require 'circuitmacro'

require('circuitmacro').setup {
  keep_pdf = true, -- Keep PDF output
  auto_open = false, -- Don't auto-open the image
}

-- [[ Basic Keymaps ]]
require 'keymaps'

-- [[ Install `lazy.nvim` plugin manager ]]
require 'lazy-bootstrap'

-- [[ Configure and install plugins ]]
require 'lazy-plugins'
