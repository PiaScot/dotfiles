return {
	"nvim-telescope/telescope-media-files.nvim",
	config = function()
		require("telescope").load_extension("media_files")
	end,
	dependencies = {
		"kkharji/sqlite.lua",
		"nvim-telescope/telescope.nvim",
		"nvim-lua/popup.nvim",
		"nvim-lua/plenary.nvim",
	},
}
