return {
	"hrsh7th/nvim-cmp",
	enabled = false,
	dependencies = {
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-nvim-lsp",

		"hrsh7th/cmp-nvim-lsp-signature-help",

		"onsails/lspkind.nvim",
		"dcampos/nvim-snippy",
		"dcampos/cmp-snippy",
		"honza/vim-snippets",
	},

	config = function()
		local cmp = require("cmp")
		local snippy = require("snippy")
		local lspkind = require("lspkind")

		local has_words_before = function()
			local line, col = unpack(vim.api.nvim_win_get_cursor(0))
			return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
		end

		snippy.setup({
			enable_auto = true,
			mappings = {
				is = {
					["<Enter>"] = "expand_or_advance",
					["<S-TAB>"] = "previous",
				},
				nx = {
					["<leader>x"] = "cut_text",
				},
			},
		})

		cmp.setup({
			formatting = {
				fields = { "abbr", "icon", "kind", "menu" },
				format = lspkind.cmp_format({
					maxwidth = {
						-- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
						-- can also be a function to dynamically calculate max width such as
						-- menu = function() return math.floor(0.45 * vim.o.columns) end,
						menu = 50, -- leading text (labelDetails)
						abbr = 50, -- actual suggestion item
					},
					ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
					show_labelDetails = true, -- show labelDetails in menu. Disabled by default

					-- The function below will be called before any actual modifications from lspkind
					-- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
					-- before = function (entry, vim_item)
					--   return vim_item
					-- end
				}),
			},
			snippet = {
				expand = function(args)
					require("snippy").expand_snippet(args.body)
				end,
			},
			window = {
				-- completion = cmp.config.window.bordered(),
				-- documentation = cmp.config.window.bordered(),
				completion = cmp.config.window.bordered({
					border = "rounded",
					-- winhighlight = "Normal:CmpMenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
				}),
				documentation = cmp.config.window.bordered({
					border = "rounded",
					-- winhighlight = "Normal:CmpMenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
				}),
			},
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
				-- ["<CR>"] = cmp.mapping.confirm({ select = false }),

				["<CR>"] = cmp.mapping({
					i = function(fallback)
						if cmp.visible() and cmp.get_active_entry() then
							cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
						else
							fallback()
						end
					end,
					-- s = cmp.mapping.confirm({ select = true }),
					-- c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
				}),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "nvim_lsp_signature_help" },
				{ name = "path" },
				{ name = "lazydev" },
				{ name = "snippy" }, -- For snippy users.
				-- { name = "buffer" },
			}, {
				{ name = "buffer" },
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
	end,
}
