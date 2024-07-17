-- obsidian.nvim
-- https://https://github.com/epwalsh/obsidian.nvim

return {
  'epwalsh/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  event = 'VimEnter',
  lazy = true,
  ft = 'markdown',
  -- Optional dependency
  dependencies = { 'nvim-lua/plenary.nvim' },

  mappings = {
    -- overrides the 'gf' mapping to work on markdown/wiki links within your vault
    ['gf'] = {
      action = function()
        return require('obsidian').util.gf_passthrough()
      end,
      opts = { noremap = false, expr = true, buffer = true },
    },
    -- toggle check-boxes
    -- ["<leader>ch"] = {
    --   action = function()
    --     return require("obsidian").util.toggle_checkbox()
    --   end,
    --   opts = { buffer = true },
    -- },
  },

  opts = {
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
    workspaces = {
      {
        name = 'default',
        path = '~/Notes',
      },
    },
  },
}
