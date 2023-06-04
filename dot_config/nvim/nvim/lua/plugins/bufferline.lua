return {
    {
        "akinsho/bufferline.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("bufferline").setup({
                options = {
                    indicator = {
                        icon = "",
                        style = "icon",
                    },
                    max_name_length = 12,
                    separator_style = "slant",
                },
            })

        end,
    },
}
