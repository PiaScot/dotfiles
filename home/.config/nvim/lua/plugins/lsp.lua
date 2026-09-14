return {
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			{ "neovim/nvim-lspconfig" },
			{
				"williamboman/mason.nvim",
				opts = {
					ui = {
						border = "single",
						icons = {
							package_installed = "✓",
							package_pending = "➜",
							package_uninstalled = "✗",
						},
					},
				},
			},
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				opts = {
					ensure_installed = {
						-- LSP
						"pyright",
						"lua_ls",
						"ruff",
						-- "tailwindcss",
						"gopls",
						"rust_analyzer",
						"jdtls",
						-- "deno_ls",
						"svelte",
						"ts_ls",
						"clangd",

						-- formatter
						"google-java-format",
						"stylua",
						"gofumpt",
						"goimports",
						"prettierd",
						"biome",
						"jq",

						-- linter
						-- "clippy"
						"jsonlint",
						"golangci-lint",
						"eslint_d",
					},
					auto_update = false,
					run_on_start = true,
					start_delay = 3000,
					integrations = {
						["mason-lspconfig"] = true,
					},
				},
			},
			opts = {
				ui = {
					border = "single",
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			},
		},
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	-- { "stevearc/dressing.nvim", config = true },
}
