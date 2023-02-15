-- require("lualine").setup({
-- 	option = {
-- 		-- theme = "tokyonight",
-- 		theme = "solarized_dark",
-- 	},
-- })

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		-- disabled_filetypes = {
		-- 	statusline = { "packer", "NVimTree" },
		-- 	winbar = { "packer", "NvimTree" },
		-- },
		disabled_filetypes = { "packer", "NvimTree", "SidebarNvim" },
		ignore_focus = {},
		always_divide_middle = true,
		globalstatus = false,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diagnostics" },
		lualine_c = {
			{
				"filename",
				file_status = true,
				path = 0,
				shorting_target = 40,
			},
		},

		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		-- lualine_z = { "location" },
		lualine_z = {
			function()
				return " " .. os.date("%R")
			end,
		},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		-- lualine_c = { "filename" },

		lualine_c = {
			{
				"filename",
				file_status = true,
				path = 2,
				shorting_target = 20,
			},
		},
		lualine_x = { "location" },
		lualine_y = {},
		-- lualine_z = {},
		lualine_z = {
			function()
				return " " .. os.date("%R")
			end,
		},
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {},
})
