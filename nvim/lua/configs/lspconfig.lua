require("nvchad.configs.lspconfig").defaults()

-- Enabled language servers. The names below match lspconfig's built-in
-- config names (lua/lspconfig/configs/<name>.lua), not Mason package names.
local servers = {
  "html",
  "cssls",
  "pyright",
  "ts_ls",
  "lua_ls",
  "gopls",
  "jsonls",
  "yamlls",
}
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
