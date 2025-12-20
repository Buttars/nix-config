return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "night",
    transparent = false,
    dim_inactive = false,

    on_colors = function(c)
      -- keep your original
      c.bg = "#0F0F11"
      c.bg_dark = "#0C141D"
      c.bg_dark1 = "#0C141D"
      c.bg_sidebar = c.bg_dark
      c.bg_statusline = c.bg_dark
      c.bg_popup = c.bg_dark
      c.bg_float = c.bg_dark
      c.bg_visual = "#2E2E2E"

      c.fg = "#D9D7D6"
      c.fg_dark = "#A0A0A0"
      c.fg_gutter = "#2E2E2E"
    end,

    on_highlights = function(hl, c)
      ----------------------------------------------------------------
      -- Core UI with your bg/fg intact
      ----------------------------------------------------------------
      hl.Normal = { fg = c.fg, bg = c.bg }
      hl.NormalNC = { fg = c.fg, bg = c.bg }
      hl.EndOfBuffer = { fg = c.bg }

      hl.LineNr = { fg = c.fg_gutter }
    end,
  },
}
