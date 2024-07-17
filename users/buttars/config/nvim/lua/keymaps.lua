-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Obsidian Keybinds
-- General Navigation
-- vim.keymap.set('n', '<leader>op', ':ObsidianPanelToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>od', ':ObsidianToday<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ow', ':ObsidianWeek<CR>', { noremap = true, silent = true })

-- Creating and Managing Notes
vim.keymap.set('n', '<leader>on', ':ObsidianNew<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>os', ':ObsidianSearch<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ol', ':ObsidianLink<CR>', { noremap = true, silent = true })

-- Backlink Navigation
vim.keymap.set('n', '<leader>ob', ':ObsidianBacklinks<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>of', ':ObsidianFollowLink<CR>', { noremap = true, silent = true })

-- Tags and Metadata
vim.keymap.set('n', '<leader>ot', ':ObsidianTag<CR>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<leader>ov', ':ObsidianViewTags<CR>', { noremap = true, silent = true })

-- Templates and Snippets
vim.keymap.set('n', '<leader>oi', ':ObsidianTemplate<CR>', { noremap = true, silent = true })

-- Task Management
-- vim.keymap.set('n', '<leader>ox', ':ObsidianToggleTask<CR>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<leader>oa', ':ObsidianTasks<CR>', { noremap = true, silent = true })

-- Advanced Features
-- vim.keymap.set('n', '<leader>os', ':ObsidianSync<CR>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<leader>oe', ':ObsidianExportPDF<CR>', { noremap = true, silent = true })

-- Telescope Integration
-- vim.keymap.set('n', '<leader>of', ':Telescope find_files cwd=~/path/to/obsidian/vault<CR>', { noremap = true, silent = true })

-- ZenMode
vim.keymap.set('n', '<leader>z', ':ZenMode<CR>', { noremap = true, silent = true })

-- vim: ts=2 sts=2 sw=2 et
