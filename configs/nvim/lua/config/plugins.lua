local function setup(module, opts)
  local ok, plugin = pcall(require, module)
  if ok and plugin.setup then
    plugin.setup(opts or {})
  end
end

setup("tokyonight", {
  style = "night",
  transparent = true,
  styles = {
    sidebars = "transparent",
    floats = "transparent",
  },
})
vim.cmd.colorscheme("tokyonight")

for _, group in ipairs({
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "SignColumn",
  "LineNr",
  "CursorLineNr",
  "EndOfBuffer",
}) do
  vim.api.nvim_set_hl(0, group, { bg = "none" })
end

setup("mini.ai")
setup("mini.icons")
setup("mini.pairs")

setup("which-key", {
  preset = "modern",
})

setup("oil", {
  columns = { "icon" },
  view_options = {
    show_hidden = true,
  },
})

setup("gitsigns")

setup("lualine", {
  options = {
    theme = "auto",
    globalstatus = true,
  },
})

setup("telescope", {
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = require("telescope.actions").close,
      },
    },
  },
})
pcall(function()
  require("telescope").load_extension("fzf")
end)

setup("nvim-treesitter.configs", {
  highlight = { enable = true },
  indent = { enable = true },
})

local servers = {
  "lua_ls",
  "nil_ls",
  "pyright",
  "ts_ls",
}

vim.lsp.enable(servers)
