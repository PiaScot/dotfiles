return {
	"nvim-flutter/flutter-tools.nvim",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"stevearc/dressing.nvim", -- optional for better UI
	},
	config = function()
		require("flutter-tools").setup({
			lsp = {
				color_capabilities = true,
				settings = {
					showTodos = true,
					completeFunctionCalls = true,
					analysisExcludedFolders = {
						vim.fn.expand("~/.pub-cache"),
						vim.fn.expand("$HOME/.pub-cache"),
						vim.fn.expand("$HOME/flutter"),
					},
					updatePackageContents = true,
				},
			},
			debugger = {
				enabled = false,
			},
			widget_guides = {
				enabled = false,
			},
		})
	end,
}
