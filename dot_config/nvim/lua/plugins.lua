return {
	{
		"rebelot/kanagawa.nvim",
		"nvim-lua/popup.nvim",
		"nvim-lua/plenary.nvim",
		-- for KLD syntax highlight
		"imsnif/kdl.vim",
	},
	{
		"nvim-tree/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").setup({ default = true })
		end,
	},

	{
		"ojroques/nvim-bufdel",
		config = true,
	},
	{
		"simrat39/symbols-outline.nvim",
		config = true,
	},
	{
		"tpope/vim-surround",
	},
	{
		"stevearc/dressing.nvim",
		opts = {},
	},
	{
		"ellisonleao/glow.nvim",
		config = true,
		cmd = "Glow",
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("indent_blankline").setup({
				show_current_context = false,
			})
		end,
	},
}
