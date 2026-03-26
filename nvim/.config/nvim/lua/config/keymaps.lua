local map = vim.keymap.set
local float = require("config.float")
local permalink = require("config.permalink")

local function command_palette()
  Snacks.picker.commands()
end

for _, mode in ipairs({ "i", "c" }) do
  for _, lhs in ipairs({ "<M-BS>", "<M-Del>", "<Esc><BS>", "<Esc><Del>" }) do
    map(mode, lhs, "<C-w>", { desc = "Delete previous word" })
  end
end

map("n", "<leader>ff", function()
  require("fzf-lua").files()
end, { desc = "Find files" })

map("n", "<leader>fg", function()
  require("fzf-lua").live_grep()
end, { desc = "Live grep" })

map("n", "<leader>?", command_palette, { desc = "Command palette" })

map("i", "jj", "<Esc>", { desc = "Exit insert mode" })

map("n", "<leader>gy", function()
  permalink.copy(false)
end, { desc = "Yank git permalink" })

map("x", "<leader>gy", function()
  permalink.copy(true)
end, { desc = "Yank git permalink" })

map("n", "<Esc>", function()
  if float.close() then
    return
  end

  vim.cmd("nohlsearch")
end, { desc = "Close float or clear search highlight" })
