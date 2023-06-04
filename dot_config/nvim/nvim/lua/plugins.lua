return {
	{
		"rebelot/kanagawa.nvim",
		"nvim-tree/nvim-web-devicons",
		"nvim-treesitter/nvim-treesitter",
		"nvim-lua/popup.nvim",
		"nvim-lua/plenary.nvim",
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
		"edkolev/tmuxline.vim",
	},
	{
		"tpope/vim-surround",
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
				show_current_context = true,
			})
		end,
	},
}
