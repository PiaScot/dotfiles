-- local map = vim.keymap.set
--
-- -- local opts = { silent = true }
--
-- map("n", ";", ":")
-- map("n", "<C-p>", ":bprev<CR>")
-- map("n", "<C-n>", ":bnext<CR>")
--
-- map("n", "ss", "<C-w>s")
-- map("n", "sv", "<C-w>v")
-- map("n", "sh", "<C-w>h")
-- map("n", "sj", "<C-w>j")
-- map("n", "sk", "<C-w>k")
-- map("n", "sl", "<C-w>l")
-- map("n", "sq", "<C-w>q")
-- map("n", "sH", "<C-w>H")
-- map("n", "sL", "<C-w>L")
-- map("n", "sJ", "<C-w>J")
-- map("n", "sK", "<C-w>K")
--
-- map("i", "jj", "<ESC>")
-- map("t", "JJ", "<C-\\><C-n>")
--
local silent = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap

-- vim.keymap.set("n", ";", ":")
map("n", ";", ":", { noremap = true })
map("n", ":", ";", { noremap = true })

map("n", "<C-p>", ":bprev<CR>", silent)
map("n", "<C-n>", ":bnext<CR>", silent)

map("n", "ss", "<C-w>s", silent)
map("n", "sv", "<C-w>v", silent)
map("n", "sh", "<C-w>h", silent)
map("n", "sj", "<C-w>j", silent)
map("n", "sk", "<C-w>k", silent)
map("n", "sl", "<C-w>l", silent)
map("n", "sq", "<C-w>q", silent)
map("n", "sH", "<C-w>H", silent)
map("n", "sL", "<C-w>L", silent)
map("n", "sJ", "<C-w>J", silent)
map("n", "sK", "<C-w>K", silent)

map("i", "jj", "<ESC>", silent)
map("t", "JJ", "<C-\\><C-n>", silent)
