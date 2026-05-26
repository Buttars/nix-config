return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "WGU",
        path = "~/Documents/Notes/WGU",
      },
      {
        name = "osint",
        path = "~/Documents/Notes/osint",
      },
    },
    daily_notes = {
      folder = "Daily",
      date_format = "%Y-%m-%d",
      alias_format = "%B %-d, %Y",
      default_tags = { "daily-notes" },
    },
    templates = {
      folder = "_templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },
    preferred_link_style = "wiki",
    follow_url_func = function(url)
      vim.fn.jobstart({ "open", url })
    end,
    picker = {
      name = "snacks.pick",
    },
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
    attachments = {
      img_folder = "_assets",
    },
    ui = {
      enable = true,
      checkboxes = {
        [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
        ["x"] = { char = "", hl_group = "ObsidianDone" },
        [">"] = { char = "", hl_group = "ObsidianRightArrow" },
        ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
        ["!"] = { char = "", hl_group = "ObsidianImportant" },
      },
      bullets = { char = "•", hl_group = "ObsidianBullet" },
      external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
    },
  },
}
