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
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			action_keys = {
				switch_severity = {},
			},
		},
	},
	{
		"phaazon/hop.nvim",
		branch = "v2",
		config = function()
			require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })

			local keymap = vim.api.nvim_set_keymap
			keymap("", "f", "<cmd>HopChar1<CR>", {})
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.1",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>s", builtin.find_files, {})
			vim.keymap.set("n", "<leader>h", builtin.help_tags, {})
			vim.keymap.set("n", "<leader>r", builtin.live_grep, {})

			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-u>"] = false,
						},
					},
				},
			})
		end,
	},
	{
		"nvim-telescope/telescope-frecency.nvim",
		config = function()
			require("telescope").load_extension("frecency")
			vim.keymap.set("n", "<leader>f", "<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>")
		end,
		dependencies = {
			"kkharji/sqlite.lua",
			"nvim-telescope/telescope.nvim",
		},
	},
	{
		"nvim-telescope/telescope-media-files.nvim",
		config = function()
			require("telescope").load_extension("media_files")
		end,
		dependencies = {
			"kkharji/sqlite.lua",
			"nvim-telescope/telescope.nvim",
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
		},
	},
	{
		{
			"akinsho/toggleterm.nvim",
			version = "*",
			-- opts = {
			--      direction = "float",
			-- },
			config = function()
				require("toggleterm").setup({
					direction = "float",
				})

				vim.api.nvim_set_keymap("n", "<leader>t", ":ToggleTerm<CR>", { noremap = true, silent = true })
			end,
		},
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
		"numToStr/Comment.nvim",
		config = true,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		config = function()
			require("ibl").setup({
				scope = { enabled = false },
			})
		end,
	},
}
