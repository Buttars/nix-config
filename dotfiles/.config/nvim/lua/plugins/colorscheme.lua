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

      ----------------------------------------------------------------
      -- Accent colors from the neon cyberpunk palette (your image)
      ----------------------------------------------------------------

      -- neon cyan (primary)
      c.blue = "#19F9FF" -- primary bright cyan
      c.blue0 = "#00F0FF" -- core cyan
      c.blue1 = "#19F9FF" -- consistent primary
      c.blue2 = "#8DFBFF" -- glow cyan
      c.blue5 = "#A3FFFF" -- super bright outer glow
      c.blue6 = "#C7FFFF"
      c.blue7 = "#0CE7F2"

      c.cyan = "#19F9FF"
      c.teal = "#00F0FF"

      -- neon pink (secondary)
      c.magenta = "#FF2EA6"
      c.magenta2 = "#FF6EC7"

      -- c.purple = "#FF2EA6"
      -- c.purple = "#FF5768"
      -- c.purple = "#FF474C"

      -- other accents
      c.red = "#FF3B7F"
      c.red1 = "#FF6B9F"
      c.red2 = "#FF474C"
      c.orange = "#FF9933"
      c.yellow = "#FCEE0C"
      c.green = "#19FF92"
      c.green1 = "#5FFFD2"

      -- borders
      c.border = "#19F9FF"
      c.border_highlight = "#FF2EA6"

      c.error = c.red
      c.warning = c.yellow
      c.info = c.blue1
      c.hint = c.cyan
    end,

    on_highlights = function(hl, c)
      ----------------------------------------------------------------
      -- Core UI with your bg/fg intact
      ----------------------------------------------------------------
      hl.Normal = { fg = c.fg, bg = c.bg }
      hl.NormalNC = { fg = c.fg, bg = c.bg }
      hl.EndOfBuffer = { fg = c.bg }

      hl.LineNr = { fg = c.fg_gutter }
      hl.CursorLine = { bg = "#15161A" }
      hl.CursorLineNr = { fg = c.yellow, bold = true }

      ----------------------------------------------------------------
      -- Syntax using neon accents
      ----------------------------------------------------------------
      hl.Keyword = { fg = c.red2, italic = true }
      hl["@keyword"] = hl.Keyword
      hl["@keyword.return"] = hl.Keyword
      hl["@keyword.function"] = { fg = c.blue1, italic = true }

      hl.Function = { fg = c.blue1 }
      hl["@function"] = hl.Function
      hl["@property"] = { fg = c.blue }
      hl.String = { fg = c.green }
      hl.Number = { fg = c.yellow }
      hl.Operator = { fg = c.blue1 }
      hl.Identifier = { fg = c.blue }
    end,
  },
}
