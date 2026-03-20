return {
  {
    "ibhagwan/fzf-lua",
    opts = {
      keymap = {
        builtin = {
          [1] = true,
          ["<C-j>"] = "preview-down",
          ["<C-k>"] = "preview-up",
        },
      },
    },
  },
}
