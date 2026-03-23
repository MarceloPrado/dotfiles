local function open_neogit(args)
  return function()
    require("neogit").open(args)
  end
end

return {
  {
    "sindrets/diffview.nvim",
    opts = {
      keymaps = {
        view = {
          { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diffview" } },
        },
        file_panel = {
          { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diffview" } },
        },
        file_history_panel = {
          { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diffview" } },
        },
      },
    },
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    keys = {
      { "<leader>gg", open_neogit({ kind = "tab" }), desc = "Open Neogit" },
      { "<leader>gc", open_neogit({ "commit", kind = "split" }), desc = "Neogit commit" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "ibhagwan/fzf-lua",
    },
    opts = {
      kind = "split",
      commit_editor = {
        kind = "split",
        staged_diff_split_kind = "split",
      },
      popup = {
        kind = "split",
      },
      integrations = {
        diffview = true,
        fzf_lua = true,
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signs_staged_enable = true,
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 300,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "]h", gs.next_hunk, "Next hunk")
        map("n", "[h", gs.prev_hunk, "Previous hunk")
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hi", gs.preview_hunk_inline, "Preview hunk inline")
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, "Blame line")
        map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle line blame")
        map("x", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage hunk")
        map("x", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset hunk")
      end,
    },
  },
}
