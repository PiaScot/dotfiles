local mason = require("mason")
local lspconfig = require("lspconfig")
local util = lspconfig.util
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local rt = require("rust-tools")
local nls = require("null-ls")

require("neodev").setup({
	library = { plugins = { "nvim-dap-ui" }, types = true },
})
-- local cmp_capabilities = cmp_nvim_lsp.default_capabilities()

local capabilities
do
	local default_capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = {
		offsetEncoding = "utf-8",
		textDocument = {
			completion = {
				completionItem = {
					snippetSupport = true,
				},
			},
			codeAction = {
				resolveSupport = {
					properties = vim.list_extend(default_capabilities.textDocument.codeAction.resolveSupport.properties, {
						"documentation",
						"detail",
						"additionalTextEdits",
					}),
				},
			},
		},
	}
end

util.default_config = vim.tbl_deep_extend("force", util.default_config, {
	capabilities = vim.tbl_deep_extend(
		"force",
		vim.lsp.protocol.make_client_capabilities(),
		cmp_nvim_lsp.default_capabilities(capabilities)
	),
})

mason.setup({
	ui = {

		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

require("mason-nvim-dap").setup({})

vim.diagnostic.config({
	virtual_text = false,
	signs = true,
	underline = false,
	update_in_insert = false,
	severity_sort = false,
})

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function()
		local bufmap = function(mode, lhs, rhs)
			local opts = { buffer = true }
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		-- bufmap("n", "K", '<cmd>lua require("hover").hover, { desc = "hover.nvim" }<cr>')
		bufmap("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")
		bufmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
		bufmap("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
		bufmap("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>")
		bufmap("n", "<C-k>", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
		bufmap("n", "<C-j>", "<cmd>lua vim.diagnostic.goto_next()<cr>")
	end,
})

require("mason-lspconfig").setup_handlers({
	function(name)
		lspconfig[name].setup({})
	end,
	["lua_ls"] = function()
		lspconfig.lua_ls.setup({
			settings = {
				Lua = {
					completion = {
						callSnippet = "Replace",
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false,
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})
	end,
	["gopls"] = function()
		lspconfig.gopls.setup({
			settings = {
				hoverKind = "NoDocumentation",
				deepCompletion = true,
				fuzzyMatching = true,
				completeUnimported = true,
				usePlaceholders = true,
			},
		})
	end,
	["pyright"] = function()
		lspconfig.pyright.setup({
			settings = {
				python = {
					venvPath = ".",
					pythonPath = "./venv/bin/python",
					analysis = {
						extraPaths = { "." },
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
					},
				},
			},
		})
	end,
	["rust_analyzer"] = function()
		rt.setup({
			assist = {
				importEnforceGranularity = true,
				importPrefix = "crate",
			},
			cargo = {
				allFeatures = true,
			},
			checkOnSave = {
				enable = true,
				command = "clippy",
			},
			-- rust-tools options
			tools = {
				autoSetHints = true,
				inlay_hints = {
					show_parameter_hints = true,
					parameter_hints_prefix = "",
					other_hints_prefix = "",
				},
			},
			dap = {
				adapter = {
					type = "server",
					command = "codelldb",
					name = "rt_lldb",
				},
			},
		})
	end,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
})

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

nls.setup({
	-- capabilities = capabilities,
	on_attach = function(client, bufnr)
		-- client.offset_encodings = "utf-32"
		client.offset_encoding = "utf-8"
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ bufnr = bufnr })
				end,
			})
		end
	end,
	sources = {
		nls.builtins.formatting.black,
		nls.builtins.diagnostics.flake8.with({
			extra_args = { "--config", "~/.config/flake8" },
			method = nls.methods.DIAGNOSTICS_ON_SAVE,
		}),
		nls.builtins.diagnostics.shellcheck,
		nls.builtins.formatting.shfmt,
		-- nls.builtins.formatting.clang_format,
		nls.builtins.formatting.clang_format.with({
			extra_args = { '--style=file:"/home/plum/.clang-format' },
		}),
		-- nls.builtins.code_actions.gitsigns,
		-- nls.builtins.formatting.gofmt,
		-- nls.builtins.formatting.gofumpt,
		-- nls.builtins.formatting.goimports,
		-- nls.builtins.formatting.golines,
		nls.builtins.formatting.stylua,
	},
})

local sign = function(opts)
	vim.fn.sign_define(opts.name, {
		texthl = opts.name,
		text = opts.text,
		numhl = "",
	})
end

sign({ name = "DiagnosticSignError", text = "✘ " })
sign({ name = "DiagnosticSignWarn", text = "▲ " })
sign({ name = "DiagnosticSignHint", text = "⚑ " })
sign({ name = "DiagnosticSignInfo", text = " " })
