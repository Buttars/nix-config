-- obsidian.nvim
-- https://https://github.com/epwalsh/obsidian.nvim

return {
  'epwalsh/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = 'markdown',
  -- Optional dependency
  dependencies = { 'nvim-lua/plenary.nvim' },

  opts = {
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
  },
}
