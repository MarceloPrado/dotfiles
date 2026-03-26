return {
  {
    "ibhagwan/fzf-lua",
    opts = {
      winopts = {
        on_create = function()
          local job = vim.b.terminal_job_id
          if not job then
            return
          end

          local function send_ctrl_w()
            vim.api.nvim_chan_send(job, "\023")
          end

          for _, lhs in ipairs({ "<M-BS>", "<M-Del>", "<Esc><BS>", "<Esc><Del>" }) do
            vim.keymap.set("t", lhs, send_ctrl_w, { buffer = true, nowait = true, desc = "Delete previous word" })
          end
        end,
      },
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
