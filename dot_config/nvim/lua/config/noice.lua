local ignore_msg = function(kind, msg)
	return {
		opts = { skip = true },
		filter = {
			event = "msg_show",
			kind = kind,
			find = msg,
		},
	}
end

require("noice").setup({
	lsp = {
		-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
	},
	-- you can enable a preset for easier configuration
	presets = {
		bottom_search = true, -- use a classic bottom cmdline for search
		command_palette = true, -- position the cmdline and popupmenu together
		long_message_to_split = true, -- long messages will be sent to a split
		inc_rename = false, -- enables an input dialog for inc-rename.nvim
		lsp_doc_border = false, -- add a border to hover docs and signature help
	},
	routes = {
		ignore_msg("search_count", nil), -- https://github.com/folke/noice.nvim/wiki/Configuration-Recipes#hide-search-virtual-text
		ignore_msg("", "written"), -- https://github.com/folke/noice.nvim/wiki/Configuration-Recipes#hide-written-messages-1
		ignore_msg("emsg", "E433: No tags file"),
		ignore_msg("emsg", "E486: Pattern not found"),
		ignore_msg("emsg", "E555: at bottom of tag stack"),
	},
})
