return {
	{ "rebelot/kanagawa.nvim" },
	{ "mfussenegger/nvim-jdtls" },
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		keys = {
			{ "<leader>e", "<cmd>ToggleTerm<cr>", desc = "Open terminal" },
		},
		opts = {
			direction = "float",
		},
	},
	{
		"Bekaboo/dropbar.nvim",
		-- optional, but required for fuzzy finder support
		dependencies = {
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
		config = function()
			local dropbar_api = require("dropbar.api")
			vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
			vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
			vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
		end,
	},

	{
		"numToStr/Comment.nvim",
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		config = function()
			require("ts_context_commentstring").setup({
				enable_autocmd = false,
			})
			require("Comment").setup({
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})
		end,
	},
	{
		-- phaazon/hop.nvim (the "v2" branch this used to pin) is gone
		-- from GitHub -- it moved to sourcehut and the repo here was
		-- deleted, which is why cloning it always failed with
		-- "could not read Username for 'https://github.com'"
		-- (GitHub returns 401, not 404, for a git-protocol request
		-- against a repo that doesn't exist). smoka7/hop.nvim is the
		-- actively maintained fork; its default branch is master, so
		-- no `branch` override is needed.
		"smoka7/hop.nvim",
		keys = {
			{ "f", "<cmd>HopChar1<cr>", desc = "Hop mode with f-press with normal mode" },
		},
		opts = { keys = "etovxqpdygfblzhckisuran" },
	},
}
