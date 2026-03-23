return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300,
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "git hunk" },
        { "<leader>m", group = "markdown" },
        { "<leader>t", group = "toggle" },
      },
    },
  },
}
