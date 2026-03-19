local map = vim.keymap.set

map("n", "<leader>ff", function()
  require("fzf-lua").files()
end, { desc = "Find files" })

map("n", "<leader>fg", function()
  require("fzf-lua").live_grep()
end, { desc = "Live grep" })

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
