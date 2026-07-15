local M = {}

M.base46 = {
  theme = "onedark",
  transparency = true,

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}

M.ui = {
  tabufline = {
    lazyload = true,
  },
}

return M
