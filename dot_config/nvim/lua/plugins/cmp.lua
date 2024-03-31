return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-nvim-lsp",
		"onsails/lspkind.nvim",
		"hrsh7th/cmp-nvim-lsp-signature-help",
		"dcampos/nvim-snippy",
		"dcampos/cmp-snippy",
		"honza/vim-snippets",
	},
	config = function()
		local has_words_before = function()
			local line, col = unpack(vim.api.nvim_win_get_cursor(0))
			return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
		end

		local cmp = require("cmp")
		local snippy = require("snippy")
		local lspkind = require("lspkind")

		snippy.setup({
			enable_auto = true,
			mappings = {
				is = {
					["<TAB>"] = "expand_or_advance",
					["<S-TAB>"] = "previous",
				},
				nx = {
					["<leader>x"] = "cut_text",
				},
			},
		})

		cmp.setup({
			snippet = {
				expand = function(args)
					require("snippy").expand_snippet(args.body)
				end,
			},
			-- window = {
			-- 	-- completion = cmp.config.window.bordered(),
			-- 	-- documentation = cmp.config.window.bordered(),
			-- },
			mapping = cmp.mapping.preset.insert({
				["<C-n>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif snippy.can_expand_or_advance() then
						snippy.expand_or_advance()
					elseif has_words_before() then
						cmp.complete()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<C-p>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif snippy.can_jump(-1) then
						snippy.previous()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
				["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
				["<C-e>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
				["<CR>"] = cmp.mapping.confirm({ select = false }),
			}),
			formatting = {
				format = function(entry, vim_item)
					if vim.tbl_contains({ "path" }, entry.source.name) then
						local icon, hl_group = require("nvim-web-devicons").get_icon(entry:get_completion_item().label)
						if icon then
							vim_item.kind = icon
							vim_item.kind_hl_group = hl_group
							return vim_item
						end
					end
					return lspkind.cmp_format({ with_text = false })(entry, vim_item)
				end,
			},
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "nvim_lsp_signature_help" },
				{ name = "path" },
				-- { name = 'luasnip' }, -- For luasnip users.
				-- { name = 'ultisnips' }, -- For ultisnips users.
				{ name = "snippy" }, -- For snippy users.
				{ name = "buffer" },
				-- }, {
				-- 	{ name = "buffer" },
				-- }),
			}),
		})

		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "nvim_lua" },
				{ name = "cmdline" },
			},
		})

		cmp.setup.cmdline("/", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})
		-- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		-- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	end,
}
