local silent = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap

map("n", ";", ":", { noremap = true })
map("n", ":", ";", { noremap = true })

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
map("n", "n", "nzz", silent)
map("n", "N", "Nzz", silent)

map("i", "jj", "<ESC>", silent)
map("t", "JJ", "<C-\\><C-n>", silent)

map("n", "<C-p>", "<Cmd>BufferPrevious<CR>", silent)
map("n", "<C-n>", "<Cmd>BufferNext<CR>", silent)
-- Goto buffer in position...
map("n", "<A-1>", "<Cmd>BufferGoto 1<CR>", silent)
map("n", "<A-2>", "<Cmd>BufferGoto 2<CR>", silent)
map("n", "<A-3>", "<Cmd>BufferGoto 3<CR>", silent)
map("n", "<A-4>", "<Cmd>BufferGoto 4<CR>", silent)
map("n", "<A-5>", "<Cmd>BufferGoto 5<CR>", silent)
map("n", "<A-6>", "<Cmd>BufferGoto 6<CR>", silent)
map("n", "<A-7>", "<Cmd>BufferGoto 7<CR>", silent)
map("n", "<A-8>", "<Cmd>BufferGoto 8<CR>", silent)
map("n", "<A-9>", "<Cmd>BufferGoto 9<CR>", silent)
map("n", "<A-0>", "<Cmd>BufferLast<CR>", silent)

-- Excludes buffers from the tabline
map("n", "<C-q>", "<Cmd>BufferClose<CR>", silent)
map("n", "<A-q>", "<Cmd>BufferCloseAllButVisible<CR>", silent)
-- require pandoc format table in .md file
map("v", "\\e", "!pandoc -t markdown-simple_tables<CR>", silent)
