-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
--

-- vim.cmd [[
--   command! -nargs=* Quit execute 'bdelete' <q-args>
--   cabbrev <expr> q getcmdtype() == ':' && getcmdline() == 'q' ? 'Quit' : 'q'
-- ]]
--
vim.wo.wrap = false
vim.wo.linebreak = false
vim.opt.relativenumber = true
vim.g.diagnostics_visible = true

