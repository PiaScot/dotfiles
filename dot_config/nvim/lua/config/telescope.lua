local telescope = require("telescope")
telescope.setup({})

-- Extensions
-- telescope.load_extension("frecency")
telescope.load_extension("ui-select")
telescope.load_extension("zoxide")

local function map(modes, lhs, rhs, opts)
	opts = opts or {}
	opts.noremap = opts.noremap == nil and true or opts.noremap
	if type(modes) == "string" then
		modes = { modes }
	end
	for _, mode in ipairs(modes) do
		vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
	end
end

local silent = { silent = true }
-- Navigate buffers and repos
map("n", "<Leader>f", [[<cmd>Telescope frecency<cr>]], silent)
-- map("n", "<Leader>g", [[<cmd>Telescope git_files<cr>]], silent)
map("n", "<Leader>s", [[<cmd>Telescope find_files<cr>]], silent)
map("n", "<Leader>h", [[<cmd>Telescope help_tags<cr>]], silent)
map("n", "<Leader>r", [[<cmd>Telescope live_grep<cr>]], silent)
map("n", "<Leader>z", [[<cmd>Telescope zoxide list<cr>]], silent)
