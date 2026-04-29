return {
	"stevearc/conform.nvim",
	dependencies = {
		"jay-babu/mason-null-ls.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim",
		},
	},
	config = function()
		local conform = require("conform")

		local function get_formatter()
			if vim.fs.find({ "deno.json", "deno.jsonc" }, { upward = true, stop = vim.loop.os_homedir() })[1] then
				return { "deno_fmt" }
			end
			if
				vim.fs.find({
					".prettierrc",
					".prettierrc.json",
					".prettierrc.yml",
					".prettierrc.yaml",
					".prettierrc.json5",
					".prettierrc.js",
					".prettierrc.cjs",
					"prettier.config.js",
					"prettier.config.cjs",
					".prettierrc.toml",
				}, { upward = true, stop = vim.loop.os_homedir() })[1]
			then
				return { "prettierd" }
			end
			if vim.fs.find({ "biome.json" }, { upward = true, stop = vim.loop.os_homedir() })[1] then
				return { "biome" }
			end
			-- Default to biome for single files
			return { "biome" }
		end

		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },
				go = { "gofumpt", "goimports" },
				json = { "jq" },
				java = { "google-java-format" },
				html = { "prettierd" },
				python = { "ruff_format", "ruff_fix" },
				dart = { "lsp" },
				svelte = get_formatter,
				javascript = get_formatter,
				typescript = get_formatter,
				["_"] = { "trim_whitespace" },
			},
			-- default_format_opts = {
			-- 	lsp_format = "fallback",
			-- },
			-- format_on_save = { timeout_ms = 500, lsp_fallback = true },
			format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
		})
	end,
}
