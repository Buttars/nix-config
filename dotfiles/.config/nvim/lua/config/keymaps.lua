-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function lineCountByPercentage(percentageAsInt)
  local currentWindowHeight = vim.fn.winheight(0)
  local percentage = percentageAsInt / 100
  return math.floor(currentWindowHeight * percentage)
end

vim.keymap.set("n", "<C-u>", function()
  vim.cmd("norm! " .. tostring(lineCountByPercentage(25)) .. "kzz")
end)
vim.keymap.set("n", "<C-d>", function()
  vim.cmd("norm! " .. tostring(lineCountByPercentage(25)) .. "jzz")
end)
