return {
  {
    'ThePrimeagen/harpoon',
    config = function()
      local harpoon = require 'harpoon'
      local list = require 'harpoon.mark'
      local ui = require 'harpoon.ui'

      vim.keymap.set('n', '<leader>a', function()
        list.add_file()
      end)
      vim.keymap.set('n', '<C-e>', function()
        ui.toggle_quick_menu()
      end)

      -- vim.keymap.set('n', '<C-h>', function()
      --   ui.nav_file(1)
      -- end)
      vim.keymap.set('n', '<C-t>', function()
        ui.nav_file(2)
      end)
      vim.keymap.set('n', '<C-n>', function()
        ui.nav_file(3)
      end)
      vim.keymap.set('n', '<C-s>', function()
        ui.nav_file(4)
      end)

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<C-S-P>', function()
        ui.nav_prev()
      end)
      vim.keymap.set('n', '<C-S-N>', function()
        ui.nav_next()
      end)
    end,
  },
}
