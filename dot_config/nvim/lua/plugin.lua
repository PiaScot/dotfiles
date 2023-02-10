local fn = vim.fn

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end
vim.cmd([[
augroup packer_user_config
autocmd!
autocmd BufWritePost plugins.lua source <afile> | PackerSync
augroup end
]])

local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- Install your plugins here
return packer.startup(function(use)
	-- basic tools and packer manager
	use("wbthomason/packer.nvim")
	use("lewis6991/impatient.nvim")

	use("nvim-lua/popup.nvim")
	use("nvim-lua/plenary.nvim")

	-- Async building & commands
	-- when using some test uncomment below line
	-- use({
	-- 	"tpope/vim-dispatch",
	-- 	config = function()
	-- 		vim.b.dispatch = "cargo run %"
	-- 		vim.keymap.set("n", "<Leader>a", ":Dispatch<CR>")
	-- 	end,
	-- })

	use({
		"nathom/filetype.nvim",
		config = function()
			vim.g.did_load_filetypes = 1
		end,
	})

	use("kyazdani42/nvim-web-devicons")
	use("rebelot/kanagawa.nvim")
	use("cocopon/iceberg.vim")
	use({
		"projekt0n/github-nvim-theme",
		tag = "v0.0.7",
	})
	use({ "folke/tokyonight.nvim", config = [[require('config.tokyonight')]] })

	use({
		"navarasu/onedark.nvim",
		config = require("onedark").setup({
			style = "darker",
		}),
	})

	use({
		"akinsho/bufferline.nvim",
		requires = "kyandani42/nvim-web-devicons",
		config = function()
			require("bufferline").setup({})
		end,
	})
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyandani42/nvim-web-devicons", opt = true },
		config = [[require('config.lualine')]],
	})
	use({
		"lukas-reineke/indent-blankline.nvim",
		config = [[require('indent_blankline').setup({})]],
	})

	use({
		"numToStr/Comment.nvim",
		config = [[require('Comment').setup({})]],
	})

	use("fladson/vim-kitty")

	use({
		"sidebar-nvim/sidebar.nvim",
		config = [[require('config.sidebar')]],
	})

	use("machakann/vim-sandwich")

	use({
		"folke/trouble.nvim",
		config = [[require('config.trouble')]],
	})

	use({
		"neovim/nvim-lspconfig",
		requires = {
			"simrat39/rust-tools.nvim",
			"folke/neodev.nvim",
			"williamboman/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
			"jose-elias-alvarez/null-ls.nvim",
			"williamboman/mason-lspconfig.nvim",
			"lewis6991/hover.nvim",
		},
		config = [[require('config.lsp')]],
	})
	use("aduros/ai.vim")

	use({
		"hrsh7th/nvim-cmp",
		requires = {
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp",
			"onsails/lspkind.nvim",

			"dcampos/nvim-snippy",
			"dcampos/cmp-snippy",
			"honza/vim-snippets",
		},
		config = [[require('config.cmp')]],
	})

	use("tversteeg/registers.nvim")

	use({
		"mfussenegger/nvim-dap",
		"rcarriga/nvim-dap-ui",
		"theHamsta/nvim-dap-virtual-text",
		"mxsdev/nvim-dap-vscode-js",
		"jbyuki/one-small-step-for-vimkind",
	})

	use({
		"nvim-neotest/neotest",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-neotest/neotest-plenary",
			"nvim-treesitter/nvim-treesitter",
			"rouge8/neotest-rust",
			"antoinemadec/FixCursorHold.nvim",
		},
		config = [[require('config.neotest')]],
	})

	use({
		"nvim-treesitter/nvim-treesitter",
	})

	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
			"kkharji/sqlite.lua",
			"jvgrootveld/telescope-zoxide",
			"nvim-telescope/telescope-ui-select.nvim",
		},
		config = [[require('config.telescope')]],
	})

	use({
		"nvim-telescope/telescope-frecency.nvim",
		config = function()
			require("telescope").load_extension("frecency")
		end,
		requires = { "kkharji/sqlite.lua" },
	})

	use({
		"m-demare/hlargs.nvim",
		requires = { "nvim-treesitter/nvim-treesitter" },
		config = [[require('hlargs').setup{}]],
	})

	use({
		"ellisonleao/glow.nvim",
		config = [[require('glow').setup()]],
	})

	use({
		"phaazon/hop.nvim",
		config = [[require('config.hop')]],
		-- branch = "v2",
	})

	use({
		"max397574/better-escape.nvim",
		config = function()
			require("better_escape").setup({
				mapping = { "jj" },
			})
		end,
	})

	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
