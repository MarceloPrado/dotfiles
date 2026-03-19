return {
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = { "ts_ls" },
      automatic_enable = { "ts_ls" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local float = require("config.float")
      local group = vim.api.nvim_create_augroup("dotfiles-lsp", { clear = true })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(args)
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, {
              buffer = args.buf,
              desc = desc,
            })
          end

          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gr", function()
            require("fzf-lua").lsp_references()
          end, "Go to references")
          map("gh", float.toggle_lsp_hover, "Hover")
        end,
      })

      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded" },
      })

      vim.lsp.config("ts_ls", {})
    end,
  },
}
