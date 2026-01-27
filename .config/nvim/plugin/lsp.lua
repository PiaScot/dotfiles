local installedPacks = require("mason-registry").get_installed_packages()

local lspNames = vim.iter(installedPacks):fold({}, function(acc, pack)
	table.insert(acc, pack.spec.neovim and pack.spec.neovim.lspconfig)
	return acc
end)

vim.lsp.enable(lspNames)

vim.diagnostic.config({
	virtual_text = false,
	update_in_insert = false,
	underline = true,
	severity_sort = true,
	float = {
		focusable = true,
		style = "minimal",
		border = "rounded",
		source = true,
		header = "",
		prefix = "",
		-- winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
	},
	signs = {
		text = {
			-- [vim.diagnostic.severity.ERROR] = "✘",
			-- [vim.diagnostic.severity.WARN] = "",
			-- [vim.diagnostic.severity.HINT] = "",
			-- [vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.ERROR] = " ",
		},
	},
})

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if not client then
			return
		end
		---[[ Disable default formatting
		if client.name == "tsserver" then
			client.server_capabilities.documentFormattingProvider = false
		end

		if client.name == "lua_ls" then
			client.server_capabilities.documentFormattingProvider = false
		end
		---]]

		---[[ Lsp Keymaps
		local nmap = function(keys, func, desc)
			if desc then
				desc = "LSP: " .. desc
			end
			vim.keymap.set("n", keys, func, { buffer = args.buf, noremap = true, silent = true, desc = desc })
		end

		nmap("K", function()
			vim.lsp.buf.hover({ border = "rounded" })
		end, "Open hover")
		nmap("gr", vim.lsp.buf.rename, "Rename")
		nmap("gi", vim.lsp.buf.implementation, "Implementation")
		nmap("gt", vim.lsp.buf.type_definition, "Type definition")
		nmap("gD", vim.lsp.buf.references, "References")
		nmap("gd", vim.lsp.buf.definition, "Goto definition")
		nmap("gca", vim.lsp.buf.code_action, "Code action")
		-- nmap("gds", "<cmd>vs | lua vim.lsp.buf.definition()<cr>", "Goto definition (v-split)")
		-- nmap("gdv", "<cmd>sp | lua vim.lsp.buf.definition()<cr>", "Goto definition (h-split)")

		-- Diagnostic
		nmap("<C-k>", function()
			vim.diagnostic.jump({ count = 1, float = true })
		end, "Goto next diagnostic")
		nmap("<C-j>", function()
			vim.diagnostic.jump({ count = -1, float = true })
		end, "Goto prev diagnostic")
		vim.keymap.set("i", "<Alt-t>", vim.lsp.buf.signature_help, { buffer = args.buf })

		-- inlay hints
		nmap("<leader>lh", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end, "Toggle inlay hints")

		vim.api.nvim_buf_create_user_command(args.buf, "Fmt", function(_)
			vim.lsp.buf.format()
		end, { desc = "Format current buffer with LSP" })
		---]]
	end,
})
