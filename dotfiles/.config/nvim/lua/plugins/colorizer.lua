return {
  "NvChad/nvim-colorizer.lua",
  event = "VeryLazy",
  opts = {
    user_default_options = {
      RGB = true, -- #RGB
      RRGGBB = true, -- #RRGGBB
      names = false, -- "blue", "red", etc
      RRGGBBAA = true,
      rgb_fn = true, -- rgb(…)
      hsl_fn = true, -- hsl(…)
      mode = "background", -- or foreground
      tailwind = false,
      sass = { enabled = true },
      virtualtext = "■",
    },
  },
}
