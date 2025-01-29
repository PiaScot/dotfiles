return {
    "andersevenrud/nvim_context_vt",
    dependencides = {
	"nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("nvim_context_vt").setup({})
    end,
}
