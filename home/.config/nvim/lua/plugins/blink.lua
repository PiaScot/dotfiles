return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets",
		{ "folke/lazydev.nvim", opts = {} },
	},

	version = "1.*",

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {

		keymap = {
			preset = "default",
		},

		appearance = {
			nerd_font_variant = "mono",
		},

		signature = {
			enabled = true,
			window = {},
		},

		completion = {
			accept = {
				auto_brackets = { enabled = true },
			},
			menu = {
				-- border = "rounded",
				draw = {
					columns = {
						{ "kind_icon" },
						{ "label", "label_description", gap = 1 },
						{ "source_name" },
					},
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
				window = {},
			},
		},

		sources = {

			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},

		fuzzy = {
			implementation = "prefer_rust_with_warning",
		},

		cmdline = {
			completion = {
				menu = {
					auto_show = function(ctx)
						return vim.fn.getcmdtype() == ":"
						-- enable for inputs as well, with:
						-- or vim.fn.getcmdtype() == '@'
					end,
				},
			},
		},
	},

	opts_extend = { "sources.default" },
}
