local function explorer_confirm(picker, item, action)
  if not item then
    return
  end

  if picker.input.filter.meta.searching and not item.dir then
    return Snacks.picker.actions.jump(picker, item, action)
  end

  return require("snacks.explorer.actions").actions.confirm(picker, item, action)
end

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    dependencies = {
      { "nvim-tree/nvim-web-devicons", lazy = true },
    },
    ---@type snacks.Config
    opts = {
      explorer = {
        enabled = true,
        replace_netrw = false,
      },
      picker = {
        enabled = true,
        win = {
          input = {
            keys = {
              ["<M-BS>"] = { "<c-s-w>", mode = { "i" }, expr = true, desc = "Delete word" },
              ["<M-Del>"] = { "<c-s-w>", mode = { "i" }, expr = true, desc = "Delete word" },
              ["<Esc><BS>"] = { "<c-s-w>", mode = { "i" }, expr = true, desc = "Delete word" },
              ["<Esc><Del>"] = { "<c-s-w>", mode = { "i" }, expr = true, desc = "Delete word" },
            },
          },
        },
        sources = {
          explorer = {
            actions = {
              confirm = explorer_confirm,
            },
            win = {
              list = {
                keys = {
                  ["/"] = "focus_input",
                },
              },
            },
          },
        },
      },
    },
    keys = {
      { "<leader>e", function() Snacks.explorer() end, desc = "File explorer" },
    },
  },
}
