local map = function(key)
	local opts = { noremap = true, silent = true }
	for i, v in pairs(key) do
		if type(i) == "string" then
			opts[i] = v
		end
	end

	local buffer = opts.buffer
	opts.buffer = nil

	if buffer then
		vim.apt.nvim_buf_set_keymap(0, key[1], key[2], key[3], opts)
	else
		vim.api.nvim_set_keymap(key[1], key[2], key[3], opts)
	end
end

-- map { noremap = true, 'n', ';', ':' }
vim.keymap.set("n", ";", ":")
-- vim.keymap.set({ "n", "v" }, "<C-E>", "<Nop>")
-- vim.keymap.del({ "n", "v" }, "<C-E>")

map({ noremap = true, "n", "<C-p>", ":bprev<CR>" })
map({ noremap = true, "n", "<C-n>", ":bnext<CR>" })

map({ noremap = true, "n", "ss", "<C-w>s" })
map({ noremap = true, "n", "sv", "<C-w>v" })
map({ noremap = true, "n", "sh", "<C-w>h" })
map({ noremap = true, "n", "sj", "<C-w>j" })
map({ noremap = true, "n", "sk", "<C-w>k" })
map({ noremap = true, "n", "sl", "<C-w>l" })
map({ noremap = true, "n", "sq", "<C-w>q" })
map({ noremap = true, "n", "sH", "<C-w>H" })
map({ noremap = true, "n", "sL", "<C-w>L" })
map({ noremap = true, "n", "sJ", "<C-w>J" })
map({ noremap = true, "n", "sK", "<C-w>K" })

map({ noremap = true, "i", "jj", "<ESC>" })
map({ noremap = true, "t", "JJ", "<C-\\><C-n>" })

vim.cmd([[nnoremap <C-e> <Nop>]])
vim.cmd([[nnoremap <C-d> <Nop>]])
vim.cmd([[nnoremap <C-y> <Nop>]])
vim.cmd([[nnoremap <C-u> <Nop>]])
