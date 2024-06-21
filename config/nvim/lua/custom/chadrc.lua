---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

M.ui = {
  theme = "rxyhn",
  changed_themes = {
    a = {
      base_30 = {
        white = "#D9D7D6",
        darker_black = "#000a0e",
        black = "#061115", --  nvim bg
        black2 = "#0d181c",
        one_bg = "#131e22",
        one_bg2 = "#1c272b",
        one_bg3 = "#242f33",
        grey = "#313c40",
        grey_fg = "#3b464a",
        grey_fg2 = "#455054",
        light_grey = "#4f5a5e",
        red = "#DF5B61",
        baby_pink = "#EE6A70",
        pink = "#F16269",
        line = "#222d31", -- for lines like vertsplit
        green = "#78B892",
        vibrant_green = "#8CD7AA",
        nord_blue = "#5A84BC",
        blue = "#6791C9",
        yellow = "#ecd28b",
        sun = "#f6dc95",
        purple = "#C488EC",
        dark_purple = "#BC83E3",
        teal = "#7ACFE4",
        orange = "#E89982",
        cyan = "#67AFC1",
        statusline_bg = "#0A1519",
        lightbg = "#1a2529",
        pmenu_bg = "#78B892",
        folder_bg = "#6791C9",
      },
    },
    rxyhn = {
      base_30 = {
        darker_black = "#020409",
        black = "#0E1116",
        statusline_bg = "#0E1116",
      },
      base_16 = {
        base00 = "#0E1116",
        base01 = "#0C171B",
        base02 = "#101B1F",
        base03 = "#192428",
        base04 = "#212C30",
        base05 = "#D9D7D6",
        base06 = "#E3E1E0",
        base07 = "#EDEBEA",
        base08 = "#FF3377",
        base09 = "#FFFF00",
        base0A = "#EFEFEF",
        base0B = "#7bff67",
        base0C = "#61D0FF",
        base0D = "#61D0FF",
        base0E = "#8EFBEE",
        base0F = "#F16269",
      },
    },
  },

  hl_override = highlights.override,
  hl_add = highlights.add,
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

return M
