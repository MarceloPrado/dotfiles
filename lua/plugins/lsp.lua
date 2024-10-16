return {
  "neovim/nvim-lspconfig",
  config = function()
    require("lspconfig").relay_lsp.setup({})
    require("lspconfig").vtsls.setup({
      autoUseWorkspaceTsdk = true,
      settings = {
        typescript = {
          tsserver = {
            maxTsServerMemory = 16384,
          },
        },
      },
    })
    require("lspconfig").biome.setup({
      cmd = { "biome", "lsp-proxy" },
      filetypes = {
        "css",
        "graphql",
        "javascript",
        "javascriptreact",
        "json",
        "jsonc",
        "typescript",
        "typescript.tsx",
        "typescriptreact",
      },
      root_dir = require("lspconfig.util").root_pattern("biome.json", "biome.jsonc"),
      single_file_support = false,
    })
  end,
}
