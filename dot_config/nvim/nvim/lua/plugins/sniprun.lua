return {
	"michaelb/sniprun",
	build = "bash ./install.sh",
	config = function()
		require("sniprun").setup({})
		-- vim.api.nvim_set_keymap("v", "<leader>tf", "<Plug>SnipRun", { silent = true })
		-- vim.api.nvim_set_keymap("n", "<leader>f", "<Plug>SnipRunOperator", { silent = true })
		vim.api.nvim_set_keymap(
			"n",
			"<leader>tr",
			":let b:caret=winsaveview() <CR> | :%SnipRun <CR>| :call winrestview(b:caret) <CR>",
			{ silent = true }
		)
	end,
}
