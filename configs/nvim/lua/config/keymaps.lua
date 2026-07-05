local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "<leader>a", "gg<S-v>G", opts)
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "<leader>+", "<C-a>", opts)
keymap.set("n", "<leader>-", "<C-x>", opts)
keymap.set("n", "-", "<cmd>Oil --float<CR>", { desc = "Open parent directory" })
keymap.set("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
keymap.set("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

keymap.set("n", ";f", function()
  require("telescope.builtin").find_files({ hidden = true })
end, { desc = "Find files" })

keymap.set("n", ";r", function()
  require("telescope.builtin").live_grep()
end, { desc = "Live grep" })

keymap.set("n", ";b", function()
  require("telescope.builtin").buffers()
end, { desc = "Buffers" })

keymap.set("n", ";t", function()
  require("telescope.builtin").help_tags()
end, { desc = "Help tags" })

keymap.set("n", ";;", function()
  require("telescope.builtin").resume()
end, { desc = "Resume picker" })
