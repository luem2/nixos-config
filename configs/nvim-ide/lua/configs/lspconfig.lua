require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        checkThirdParty = false,
      },
    },
  },
})

local servers = {
  "lua_ls",
  "nil_ls",
  "pyright",
  "ts_ls",
  "html",
  "cssls",
  "jsonls",
}

vim.lsp.enable(servers)
