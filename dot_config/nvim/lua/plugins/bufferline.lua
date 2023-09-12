return {
	{
		"akinsho/bufferline.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"echasnovski/mini.bufremove",
		},
		config = function()
			require("bufferline").setup({
				options = {
					close_command = function(n)
						require("mini.bufremove").delete(n, false)
					end,
					right_mouse_command = function(n)
						require("mini.bufremove").delete(n, false)
					end,
					show_buffer_close_icons = false,
					separator_style = { "|", "|" },
					always_show_bufferline = true,
					numbers = function(opts)
						return string.format("%s", opts.ordinal)
					end,

					custom_filter = function(buf_number)
						if vim.bo[buf_number].filetype ~= "qf" then
							return true
						end
					end,
					offsets = {
						{
							filetype = "NvimTree",
							text = "File Explorer",
							text_align = "center",
							separetor = true,
						},
					},
				},
			})
		end,
	},
}
