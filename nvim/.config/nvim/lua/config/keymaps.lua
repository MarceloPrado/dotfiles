local map = vim.keymap.set
local float = require("config.float")

map("n", "<leader>ff", function()
  require("fzf-lua").files()
end, { desc = "Find files" })

map("n", "<leader>fg", function()
  require("fzf-lua").live_grep()
end, { desc = "Live grep" })

map("n", "<Esc>", function()
  if float.close() then
    return
  end

  vim.cmd("nohlsearch")
end, { desc = "Close float or clear search highlight" })
