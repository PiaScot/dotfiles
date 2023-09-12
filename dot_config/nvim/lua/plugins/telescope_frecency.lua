return {
	"nvim-telescope/telescope-frecency.nvim",
	config = function()
		require("telescope").load_extension("frecency")
		vim.keymap.set("n", "<leader>f", "<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>")
	end,
	dependencies = {
		"kkharji/sqlite.lua",
		"nvim-telescope/telescope.nvim",
	},
}
