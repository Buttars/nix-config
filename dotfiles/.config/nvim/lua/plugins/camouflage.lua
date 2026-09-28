return {
  {
    "zeybek/camouflage.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
    keys = {
      { "<leader>mt", "<cmd>CamouflageToggle<cr>", desc = "Toggle Camouflage" },
      { "<leader>mr", "<cmd>CamouflageReveal<cr>", desc = "Reveal Line" },
      { "<leader>my", "<cmd>CamouflageYank<cr>", desc = "Yank Value" },
      { "<leader>mf", "<cmd>CamouflageFollowCursor<cr>", desc = "Follow Cursor" },
    },
  },
}
