return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		-- opts = {
		-- 	direction = "float",
		-- },
		config = function()
			require("toggleterm").setup({
				direction = "float",
			})

			vim.api.nvim_set_keymap("n", "<leader>t", ":ToggleTerm<CR>", { noremap = true, silent = true })
		end,
	},
}
