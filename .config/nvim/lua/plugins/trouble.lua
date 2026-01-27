-- vim.api.nvim_set_hl(0, "FloatBorder", { link = "NormalFloat" })
return {
	"folke/trouble.nvim",
	opts = {
		keys = {
			s = false,
		},
	},
	keys = {
		{
			"<leader>d",
			"<cmd>Trouble diagnostics toggle<cr>",
			desc = "Diostics (Trouble)",
		},
	},
}
