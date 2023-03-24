local fn = vim.fn

local notify = vim.notify
vim.notify = function(msg, ...)
	if msg:match("warning: multiple different client offset_encodings") then
		return
	end

	notify(msg, ...)
end

local ensure_packer = function()
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

local status_ok, packer = pcall(require, "packer")
if not status_ok then
	vim.notify("Error loading packer! plugins.lua 31")
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
	max_jobs = 10,
})
return require("packer").startup({
	function(use)
		use("wbthomason/packer.nvim")
		use("lewis6991/impatient.nvim")

		use("nvim-lua/popup.nvim")
		use("nvim-lua/plenary.nvim")

		use({
			"nathom/filetype.nvim",
			config = function()
				vim.g.did_load_filetypes = 1
			end,
		})

		use("nvim-tree/nvim-web-devicons")
		use("rebelot/kanagawa.nvim")
		use({ "folke/tokyonight.nvim", config = [[require('config.tokyonight')]] })
		use("dstein64/vim-startuptime")

		use({
			"akinsho/bufferline.nvim",
			requires = "nvim-tree/nvim-web-devicons",
			config = [[require('config.bufferline')]],
		})
		use({
			"nvim-lualine/lualine.nvim",
			requires = { "nvim-tree/nvim-web-devicons", opt = true },
			config = [[require('config.lualine')]],
		})
		use({
			"lukas-reineke/indent-blankline.nvim",
			config = [[require('indent_blankline').setup({})]],
		})

		use({
			"ojroques/nvim-bufdel",
			config = [[require('bufdel').setup({})]],
		})
		use({
			"folke/noice.nvim",
			config = [[require('config.noice')]],
			requires = {
				-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
				"MunifTanjim/nui.nvim",
				-- OPTIONAL:
				--   `nvim-notify` is only needed, if you want to use the notification view.
				--   If not available, we use `mini` as the fallback
				"rcarriga/nvim-notify",
			},
		})
		use({
			"cshuaimin/ssr.nvim",
			module = "ssr",
			config = [[require('config.ssr')]],
		})
		use({
			"simrat39/symbols-outline.nvim",
			config = function()
				require("symbols-outline").setup()
			end,
		})

		use({
			"numToStr/Comment.nvim",
			-- config = [[require('Comment').setup({})]],
			config = [[require('config.comment')]],
		})

		use("fladson/vim-kitty")
		use("jez/vim-better-sml")
		use("khaveesh/vim-fish-syntax")
		use("machakann/vim-sandwich")
		use({
			"windwp/nvim-autopairs",
			config = [[require('config.autopairs')]],
		})

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
				"hrsh7th/cmp-nvim-lsp-signature-help",
				"windwp/nvim-autopairs",
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
			"phaazon/hop.nvim",
			branch = "v2",
			config = [[require('config.hop')]],
		})

		use({
			"max397574/better-escape.nvim",
			config = function()
				require("better_escape").setup({
					mapping = { "jj" },
				})
			end,
		})

		if packer_bootstrap then
			require("packer").sync()
		end
	end,
})
