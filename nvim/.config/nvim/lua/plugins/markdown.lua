return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    cmd = { "RenderMarkdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>mp", "<Cmd>RenderMarkdown preview<CR>", desc = "Markdown preview" },
      { "<leader>mt", "<Cmd>RenderMarkdown toggle<CR>", desc = "Toggle markdown render" },
    },
    opts = {
      pipe_table = {
        enabled = false,
      },
    },
  },
}
