return {
    {
        "phaazon/hop.nvim",
        branch = "v2",
        config = function()
            require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })

            local keymap = vim.api.nvim_set_keymap
            keymap("", "f", "<cmd>HopChar1<CR>", {})
        end,
    },
}
