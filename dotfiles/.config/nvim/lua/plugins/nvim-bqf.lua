return {
  "kevinhwang91/nvim-bqf",
  version = "*", -- recommended, use latest release instead of latest commit
  event = "VimEnter",
  init = function()
    -- nvim-treesitter's main branch removed APIs (configs, parsers.ft_to_lang)
    -- that nvim-bqf's preview still calls. Replace bqf's treesitter module with
    -- a no-op stub so previews fall back to regular syntax highlighting.
    package.preload["bqf.preview.treesitter"] = function()
      return {
        attach = function()
          return false
        end,
        tryAttach = function()
          return false
        end,
        shrinkCache = function() end,
        disableActive = function() end,
      }
    end
  end,
}
