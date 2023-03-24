vim.opt.completeopt = { "menu", "menuone", "noselect" }

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local snippy = require("snippy")
local lspkind = require("lspkind")
local cmp = require("cmp")

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
-- local select_opts = { behavior = cmp.SelectBehavior.Select }
local mappings = require("snippy.mapping")

vim.keymap.set("i", "<Tab>", mappings.expand_or_advance("<Tab>"))
vim.keymap.set("s", "<Tab>", mappings.next("<Tab>"))
vim.keymap.set({ "i", "s" }, "<S-Tab>", mappings.previous("<S-Tab>"))
vim.keymap.set("x", "<Tab>", mappings.cut_text, { remap = true })
vim.keymap.set("n", "g<Tab>", mappings.cut_text, { remap = true })

cmp.setup({
	snippet = {
		expand = function(args)
			snippy.expand_snippet(args.body)
		end,
	},
	mapping = {

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
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		-- { name = "vsnip" },
		{ name = "buffer" },
		{ name = "path" },
		{ name = "snippy" },
		-- { name = "rg" },
	}),
	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol",
			maxwidth = 50,
			-- before = nil,
		}),
	},
})

cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(), -- important!
	sources = {
		{ name = "nvim_lua" },
		{ name = "cmdline" },
	},
})
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(), -- important!
	sources = {
		{ name = "buffer" },
	},
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
