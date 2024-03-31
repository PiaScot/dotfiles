local silent = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap

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
