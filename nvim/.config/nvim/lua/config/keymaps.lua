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

local PICKER_RESUME_TTL = 5 * 60

local last_files_at = 0
map("n", "<leader>ff", function()
  local fresh = (os.time() - last_files_at) > PICKER_RESUME_TTL
  last_files_at = os.time()
  require("fzf-lua").files({ resume = not fresh })
end, { desc = "Find files" })

local last_grep_at = 0
map("n", "<leader>fg", function()
  local fresh = (os.time() - last_grep_at) > PICKER_RESUME_TTL
  last_grep_at = os.time()
  require("fzf-lua").live_grep({ resume = not fresh })
end, { desc = "Live grep" })

map("x", "<leader>fg", function()
  last_grep_at = os.time()
  require("fzf-lua").grep_visual()
end, { desc = "Live grep selection" })

map("n", "<leader>?", command_palette, { desc = "Command palette" })

map("i", "jj", "<Esc>", { desc = "Exit insert mode" })

map("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment" })
map("x", "<leader>/", "gc", { remap = true, desc = "Toggle comment" })

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
