return {
  'https://codeberg.org/esensar/nvim-dev-container',
  dependencies = 'nvim-treesitter/nvim-treesitter',
  event = 'VimEnter',
  config = function()
    require('devcontainer').setup {}
  end,
}
