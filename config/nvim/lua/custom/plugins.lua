local overrides = require "custom.configs.overrides"

---@type NvPluginSpec[]
local plugins = {
  -- Override plugin definition options
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  {
    "weilbith/nvim-code-action-menu",
    lazy = false,
  },
  {
    "kosayoda/nvim-lightbulb",
    lazy = false,
    config = function()
      require("nvim-lightbulb").setup {
        autocmd = { enabled = true },
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- format & linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  {
    "nvim-lua/plenary.nvim",
  },
  {
    "nvim-pack/nvim-spectre",
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {}
    end,
  },
  {
    "lervag/vimtex",
    lazy = false,
  },
  {
    "hrsh7th/nvim-cmp",
    options = overrides.cmp,
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        config = function(_, opts)
          require("plugins.configs.others").luasnip(opts)
          require("luasnip.loaders.from_vscode").lazy_load()
          require("luasnip.loaders.from_vscode").load_standalone {
            path = "~/.config/nvim/lua/custom/snippets/buttars.code-snippets",
          }
        end,
      },
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
  },
  {
    "mg979/vim-visual-multi",
    lazy = false,
  },
  {
    "jiangmiao/auto-pairs",
    lazy = false,
  },
  {
    "axieax/urlview.nvim",
    lazy = false
  },
}

return plugins
