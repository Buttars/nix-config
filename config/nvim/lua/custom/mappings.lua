---@type MappingsTable
local M = {}

M.general = {
  n = {
    -- Spectre
    ["<leader>gs"] = {
      function()
        require("spectre").open()
      end,
      "Global search",
    },
    ["<leader>ss"] = {
      function()
        require("spectre").open()
      end,
      "Global search",
    },

    ["<leader>sw"] = {
      function()
        require("spectre").open_visual { select_word = true }
      end,
      "Global search current word",
    },

    ["<leader>sp"] = {
      function()
        require("spectre").open_file_search { select_word = true }
      end,
      "Search current file",
    },

    ["<C-h>"] = { "<cmd> TmuxNavigateLeft<CR>", "window left" },
    ["<C-l>"] = { "<cmd> TmuxNavigateRight<CR>", "window right" },
    ["<C-j>"] = { "<cmd> TmuxNavigateDown<CR>", "window down" },
    ["<C-k>"] = { "<cmd> TmuxNavigateUp<CR>", "window up" },

    ["<leader>="] = { ":resize +5 <CR>", "increase window size" },
    ["<leader>-"] = { ":resize -5 <CR>", "decrease window size" },
    ["="] = { ":resize +5 <CR>", opts = { noremap = true } },
    ["-"] = { ":resize -5 <CR>", opts = { noremap = true } },
    ["+"] = { ":vertical resize +5 <CR>", opts = { noremap = true } },
    ["_"] = { ":vertical resize -5 <CR>", opts = { noremap = true } },

    ["<leader>."] = { "<cmd> CodeActionMenu<CR>", "open code action menu" },
    ["<leader>cs"] = {
      function()
        require("null-ls").toggle "cspell"
      end,
      "toggle spell check",
    },
  },

  v = {
    ["K"] = { ":m '<-2<CR>gv=gv" },
    ["<SHIFT><CR>"] = { "<C-e>" },
  },

  c = {
    ["Q"] = { "qa", opts = { noremap = true } },
    ["W"] = { "w !sudo -S tee %<CR>", opts = { noremap = true } },
  },
}

return M
