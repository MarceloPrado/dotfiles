-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "jj", "<ESC>", { silent = true })

vim.keymap.set("n", "<C-S-R>", require("telescope.builtin").lsp_references, {
  noremap = true,
  silent = true,
})

local cmp = require("cmp")

cmp.setup({
  mapping = {
    ["<C-.>"] = cmp.mapping.complete(), -- Map Control + Dot to trigger completion
    -- Other mappings can go here
  },
})
